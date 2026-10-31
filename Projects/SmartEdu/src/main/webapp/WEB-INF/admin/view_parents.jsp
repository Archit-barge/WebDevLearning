<%@page import="com.seh.util.SQLConnection"%>
<%@ page import="com.seh.model.User"%>
<%@page import="java.sql.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%


User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
    avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="view_parents-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Parents Management</h1>
			<p>Manage and view all parent accounts.</p>
		</div>

		<div class="user-info">
			<div class="user-avatar">
				<%=avatarLetter%>
			</div>
			<div class="user-details">
				<p class="user-role-name"><%=user.getFullName() %></p>
				<p class="user-role-desc"><%=user.getRole()%></p>
			</div>
			<button class="logout-btn" onclick="logout()">
				<i class="fas fa-sign-out-alt"></i> Logout
			</button>
		</div>
	</div>

	<div class="stats-grid" id="parentStats">
		<% 
			int totalParents = 0;
			int linkedStudents = 0;
			try (Connection conn = SQLConnection.getConnection()) {
				ResultSet rs = conn.prepareStatement("SELECT COUNT(*) AS total FROM parents").executeQuery();
				if (rs.next())
					totalParents = rs.getInt("total");
				rs.close();
				
				ResultSet rs2 = conn.prepareStatement("SELECT COUNT(DISTINCT student_id) AS total FROM student_parents").executeQuery();
				if (rs2.next())
					linkedStudents = rs2.getInt("total");
				rs2.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		%>
		<div class="stat-card">
			<div class="stat-number">
				<%=totalParents%>
			</div>
			<div class="stat-label">Total Parents</div>
		</div>
		<div class="stat-card">
			<div class="stat-number">
				<%=linkedStudents%>
			</div>
			<div class="stat-label">Linked Students</div>
		</div>
	</div>

	<div class="filters-container">
		<form method="get" onsubmit="return false;">
			<div class="filters-grid">
				<div class="filter-group">
					<label for="parentSearch">Search Parents</label> <input type="text"
						id="parentSearch" name="parentSearch"
						placeholder="Search by name, email, or phone..." onkeyup="loadParentsTable()">
				</div>

				<div class="remove-filter-wrapper ux-mb-4">
					<button type="button" id="clearParentsFilterBtn" class="btn btn-secondary remove-filter-btn ux-hidden" onclick="document.getElementById('parentSearch').value=''; loadParentsTable(); this.style.display='none';" title="Clear Filters">
						X Filter
					</button>
				</div>
			</div>
		</form>
	</div>

	<div class="table-container">
		<div class="table-header">
			<h3>Parents List</h3>
			<% 
				int parentCount = 0;
				try (Connection conn = SQLConnection.getConnection()) {
					PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) AS total FROM parents");
					ResultSet countRs = countStmt.executeQuery();
					if (countRs.next())
						 parentCount = countRs.getInt("total");
					countRs.close();
					countStmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			%>
			<span> <%=parentCount%> parents found
			</span>
		</div>

		<div class="table-wrapper parent-list-scroll split-table">
			<table class="table-head-table">
				<colgroup>
					<col class="col-parent-name">
					<col class="col-parent-email">
					<col class="col-parent-phone">
					<col class="col-parent-relation">
					<col class="col-parent-linked">
					<col class="col-actions-parent">
				</colgroup>
				<thead>
					<tr>
						<th>Name</th>
						<th>Email</th>
						<th>Phone</th>
						<th>Relationship</th>
						<th>Linked Students</th>
						<th>Actions</th>
					</tr>
				</thead>
			</table>
			<div class="table-body-scroll">
				<table class="table-body-table">
					<colgroup>
						<col class="col-parent-name">
						<col class="col-parent-email">
						<col class="col-parent-phone">
						<col class="col-parent-relation">
						<col class="col-parent-linked">
						<col class="col-actions-parent">
					</colgroup>
					<tbody id="parentsTableBody">
					<% 
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT p.parent_id, u.user_id, u.username, p.first_name, p.last_name, "
									+ "u.email, p.phone, p.address, p.relationship_to_student, u.password "
									+ "FROM parents p JOIN users u ON p.user_id = u.user_id "
									+ "ORDER BY LOWER(p.first_name), LOWER(p.last_name), LOWER(u.username) ASC";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							while (rs.next()) {
								int parentId = rs.getInt("parent_id");
								String username = rs.getString("username");
								String firstName = rs.getString("first_name");
								String lastName = rs.getString("last_name");
								String fullName = firstName + " " + lastName;
								String email = rs.getString("email") != null ? rs.getString("email") : "-";
								String phone = rs.getString("phone") != null ? rs.getString("phone") : "-";
								String address = rs.getString("address") != null ? rs.getString("address") : "-";
								String relationship = rs.getString("relationship_to_student") != null ? rs.getString("relationship_to_student") : "-";
								String password = rs.getString("password") != null ? rs.getString("password") : "";
								
								PreparedStatement linkStmt = conn.prepareStatement("SELECT s.first_name, s.last_name, s.roll_number FROM student_parents sp JOIN students s ON sp.student_id = s.student_id WHERE sp.parent_id = ?");
								linkStmt.setInt(1, parentId);
								ResultSet linkRs = linkStmt.executeQuery();
								String linkedStudentsDisplay = "";
								int studentCount = 0;
								while (linkRs.next()) {
									studentCount++;
									if (studentCount == 1) {
										linkedStudentsDisplay = linkRs.getString("first_name") + " " + linkRs.getString("last_name") + " (" + linkRs.getString("roll_number") + ")";
									}
								}
								if (studentCount > 1) {
									linkedStudentsDisplay += " ...";
								}
								linkRs.close();
								linkStmt.close();
								
								String relDisplay = relationship.substring(0, 1).toUpperCase() + relationship.substring(1);
					%>
					<tr>
						<td>
							<div class="admin-info">
								<div class="admin-avatar">
									<%=firstName.substring(0, 1).toUpperCase()%>
								</div>
								<div class="admin-details">
									<h6>
										<%=fullName%>
									</h6>
								</div>
							</div>
						</td>
						<td><%=email%></td>
						<td><%=phone%></td>
					<td><%=relDisplay%></td>
						<td><%=linkedStudentsDisplay.isEmpty() ? "<span style=\"color:#94a3b8;\">None</span>" : linkedStudentsDisplay%></td>
						<td class="ux-nowrap-cell">
							<button type="button" class="action-btn edit"
								onclick="openEditParentModal(<%=parentId%>, '<%=escapeJsAttr(firstName)%>', '<%=escapeJsAttr(lastName)%>', '<%=escapeJsAttr(phone)%>', '<%=escapeJsAttr(email)%>', '<%=escapeJsAttr(address)%>', '<%=escapeJsAttr(relationship)%>', '<%=escapeJsAttr(username)%>', '<%=escapeJsAttr(password)%>')">
								<i class="fas fa-edit"></i> Edit
							</button>

							<button type="button" class="action-btn view"
								onclick="openViewParentModal(<%=parentId%>, '<%=escapeJsAttr(fullName)%>', '<%=escapeJsAttr(username)%>', '<%=escapeJsAttr(email)%>', '<%=escapeJsAttr(phone)%>', '<%=escapeJsAttr(address)%>', '', '<%=escapeJsAttr(relationship)%>', '<%=escapeJsAttr(password)%>')">
								<i class="fas fa-eye"></i> View
							</button>

							<button type="button" class="action-btn view"
								onclick="openLinkParentModal(<%=parentId%>, '<%=escapeJsAttr(fullName)%>')">
								<i class="fas fa-link"></i> Link
							</button>

							<button type="button" class="action-btn delete"
								onclick="openDeleteParentModal(<%=parentId%>, '<%=escapeJsAttr(fullName)%>')">
								<i class="fas fa-trash"></i> Delete
							</button>
						</td>
					</tr>
					<% 
						} 
						rs.close(); 
						stmt.close(); 
					} catch (SQLException e) {
						e.printStackTrace();
					} 
					%>
				</tbody>
			</table>
		</div>
	</div>
</div>

<!-- Edit Parent Modal -->
<div id="editParentModal" class="modal-overlay ux-hidden">
	<div class="modal-container ux-modal-wide">
		<div class="modal-header">
			<h2>Edit Parent</h2>
			<button class="modal-close" onclick="closeEditParentModal()">&times;</button>
		</div>

		<form id="editParentForm" onsubmit="event.preventDefault(); updateParent();">
			<input type="hidden" id="editParentId">
			
			<h3 class="ux-modal-section-title">Account Information</h3>
			<div class="form-grid ux-form-grid-spaced">
				<div class="form-group">
					<label>Username <span class="required">*</span></label>
					<input type="text" id="editParentUsername" required>
				</div>
				<div class="form-group">
					<label>Password <span class="required">*</span></label>
					<input type="text" id="editParentPassword" required>
				</div>
			</div>

			<h3 class="ux-modal-section-title">Personal Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label>First Name</label> <input type="text"
						id="editParentFirstName" required>
				</div>
				<div class="form-group">
					<label>Last Name</label> <input type="text"
						id="editParentLastName" required>
				</div>
				<!-- Phone, Email, Address, Relationship -->
				<div class="form-group">
					<label>Phone</label> <input type="text" id="editParentPhone"
						required>
				</div>
				<div class="form-group">
					<label>Email</label> <input type="email" id="editParentEmail"
						required>
				</div>
				<div class="form-group">
					<label>Address</label> <input type="text" id="editParentAddress">
				</div>
				<div class="form-group">
					<label>Relationship</label> <select id="editParentRelationship">
						<option value="father">Father</option>
						<option value="mother">Mother</option>
						<option value="guardian">Guardian</option>
					</select>
				</div>
			</div>

			<h3 class="ux-modal-section-title-tight">Linked Students</h3>
			<div id="editLinkedStudentsList" class="ux-linked-list">Loading...</div>

			<div id="editParentResult" class="u-mb-1"></div>

			<div class="form-actions">
				<button type="button" class="btn btn-secondary"
					onclick="closeEditParentModal()">Cancel</button>
				<button type="submit" class="btn btn-primary">Save Changes</button>
			</div>
		</form>
	</div>
</div>

<!-- View Parent Modal -->
<div id="viewParentModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Parent Details</h2>
			<button class="modal-close" onclick="closeViewParentModal()">&times;</button>
		</div>
		<div class="details-content">
			<div class="detail-section">
				<h3 class="ux-modal-section-title">Account Information</h3>
				<div class="detail-grid">
					<div class="detail-item">
						<label>Username</label>
						<p id="detailParentUsername"></p>
					</div>
					<div class="detail-item">
						<label>Password</label>
						<p id="detailParentPassword"></p>
					</div>
					<div class="detail-item">
						<label>Email</label>
						<p id="detailParentEmail"></p>
					</div>
					<div class="detail-item">
						<label>Phone</label>
						<p id="detailParentPhone"></p>
					</div>
				</div>
			</div>

			<div class="detail-section">
				<h3 class="ux-modal-section-title">Personal Information</h3>
				<div class="detail-grid">
					<div class="detail-item">
						<label>Full Name</label>
						<p id="detailParentFullNamePersonal"></p>
					</div>
					<div class="detail-item">
						<label>Relationship</label>
						<p id="detailParentRelationship"></p>
					</div>
				</div>
			</div>

			<div class="detail-section">
				<h3 class="ux-modal-section-title">Additional Information</h3>
				<div class="detail-grid">
					<div class="detail-item ux-grid-span-full">
						<label>Address</label>
						<p id="detailParentAddress"></p>
					</div>
				</div>
			</div>
			
			<div class="detail-section">
				<h3 class="ux-modal-section-title">Linked Students</h3>
				<div id="viewLinkedStudentsList" class="ux-linked-list-view">Loading...</div>
			</div>
		</div>
	</div>
</div>

<!-- Link Parent Modal -->
<div id="linkParentModal" class="modal-overlay ux-hidden">
	<div class="modal-container ux-modal-wide">
		<div class="modal-header">
			<h2>Link Student to Parent</h2>
			<button class="modal-close" onclick="closeLinkParentModal()">&times;</button>
		</div>

		<input type="hidden" id="linkParentId">
		<p class="ux-parent-note">
			Parent: <strong id="linkParentName"></strong>
		</p>

		<h3 class="ux-modal-section-title-tight">Currently
			Linked</h3>
		<div id="linkCurrentStudents" class="ux-form-grid-spaced">Loading...</div>

		<h3 class="ux-modal-section-title-tight">Search
			Students to Link</h3>
		<div class="filters-container ux-filters-panel">
			<div class="filters-grid ux-filters-row">
				<div class="filter-group ux-filter-group-flex">
					<label for="linkStudentSearch" class="ux-filter-label">Search Students</label>
					<input type="text" id="linkStudentSearch"
						class="ux-filter-input"
						placeholder="Search by name, roll number..."
						onkeyup="searchStudentsForLink()">
				</div>

				<div class="filter-group ux-filter-group-flex">
					<label for="linkClassFilter" class="ux-filter-label">Filter by Class</label>
					<select id="linkClassFilter" onchange="searchStudentsForLink()"
						class="ux-filter-select">
						<option value="">All Classes</option>
						<% 
							try (Connection conn2 = SQLConnection.getConnection()) {
								String clsSql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section ASC";
								PreparedStatement clsStmt = conn2.prepareStatement(clsSql);
								ResultSet clsRs = clsStmt.executeQuery();
								while (clsRs.next()) {
									int cId = clsRs.getInt("class_id");
									String cName = clsRs.getString("class_name");
									String cSec = clsRs.getString("section");
									String cDisplay = cName + (cSec != null ? " - " + cSec : "");
						%>
						<option value="<%=cId%>">
							<%=cDisplay%>
						</option>
						<% 
								}
								clsRs.close();
								clsStmt.close();
							} catch (SQLException e) {
								e.printStackTrace();
							}
						%>
					</select>
				</div>

				<button type="button" class="btn btn-primary ux-search-btn"
					onclick="searchStudentsForLink()">
					<i class="fas fa-search"></i> Search
				</button>
			</div>
		</div>

		<div class="table-wrapper split-table">
			<table class="table-head-table">
				<colgroup>
					<col class="col-link-roll">
					<col class="col-link-name">
					<col class="col-link-class">
					<col class="col-actions-sm">
				</colgroup>
				<thead>
					<tr>
						<th>Roll No</th>
						<th>Student Name</th>
						<th>Class</th>
						<th>Action</th>
					</tr>
				</thead>
			</table>
			<div class="table-body-scroll ux-table-scroll-300">
				<table class="table-body-table">
					<colgroup>
						<col class="col-link-roll">
						<col class="col-link-name">
						<col class="col-link-class">
						<col class="col-actions-sm">
					</colgroup>
					<tbody id="linkStudentSearchResults">
					<%
						try (Connection conn3 = SQLConnection.getConnection()) {
							String stuSql = "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, c.class_name, c.section "
									+ "FROM students s LEFT JOIN classes c ON s.class_id = c.class_id ORDER BY s.roll_number ASC";
							PreparedStatement stuStmt = conn3.prepareStatement(stuSql);
							ResultSet stuRs = stuStmt.executeQuery();
							boolean hasStudents = false;
							while (stuRs.next()) {
								hasStudents = true;
								int sid = stuRs.getInt("student_id");
								String roll = stuRs.getString("roll_number") != null ? stuRs.getString("roll_number") : "-";
								String fname = stuRs.getString("first_name") != null ? stuRs.getString("first_name") : "";
								String lname = stuRs.getString("last_name") != null ? stuRs.getString("last_name") : "";
								String name = (fname + " " + lname).trim();
								String cName = stuRs.getString("class_name");
								String sec = stuRs.getString("section");
								String classDisplay = cName != null ? cName + (sec != null ? " - " + sec : "") : "Unassigned";
					%>
					<tr>
						<td><%=roll%></td>
						<td><%=name%></td>
						<td><%=classDisplay%></td>
						<td>
							<button type="button" class="action-btn view"
								onclick="selectStudentForParent(<%=sid%>, '<%=escapeJsAttr(name)%>', '<%=escapeJsAttr(roll)%>', 'link')">
								<i class="fas fa-link"></i> Link
							</button>
						</td>
					</tr>
					<%
							}
							if (!hasStudents) {
					%>
					<tr>
						<td colspan="4" class="ux-text-empty-muted">No students found</td>
					</tr>
					<%
							}
							stuRs.close();
							stuStmt.close();
						} catch (Exception e) {
							e.printStackTrace();
					%>
					<tr>
						<td colspan="4" class="ux-text-empty-danger">Error loading students</td>
					</tr>
					<%
						}
					%>
					</tbody>
				</table>
			</div>
			</div>
		</div>

		<div id="linkParentResult" class="ux-result-space"></div>

	</div>
</div>

<!-- Delete Parent Modal -->
<div id="deleteParentModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Delete Parent</h2>
			<button class="modal-close" onclick="closeDeleteParentModal()">&times;</button>
		</div>
		<div class="details-content">
			<p>
				Are you sure you want to delete parent <strong id="deleteParentName"></strong>?
				This will also remove their user account and all student links.
			</p>
		</div>
		<div class="form-actions">
			<button type="button" class="btn btn-secondary"
				onclick="closeDeleteParentModal()">Cancel</button>
			<button type="button" class="btn btn-primary"
				onclick="confirmDeleteParent()">Delete</button>
		</div>
	</div>
</div>

	<script>
		// Logout function is already defined in Index.jsp/script.js
	</script>

<%!private String escapeJs(String value) {
		if (value == null)
			return "";
		return value.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n")
				.replace("\r", "\\r");
	}

	private String escapeJsAttr(String value) {
		String jsEscaped = escapeJs(value);
		return jsEscaped.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}%>

