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

<div class="view_teachers-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Teachers Management</h1>
			<p>
				Welcome back,
				<%=user.getFullName()%>
				! Manage and view all teacher records.
			</p>
		</div>

		<div class="user-info">
			<div class="user-avatar"><%=avatarLetter%></div>
			<div class="user-details">
				<p class="user-role-name"><%=user.getFullName() %></p>
				<p class="user-role-desc"><%=user.getRole()%></p>
			</div>
			<button class="logout-btn" onclick="logout()">
				<i class="fas fa-sign-out-alt"></i> Logout
			</button>
		</div>
	</div>

	<div class="stats-grid" id="teacherStats">
		<%
		int totalTeachers = 0;
		int activeTeachers = 0;
		int totalSubjects = 0;

		try (Connection conn = SQLConnection.getConnection()) {
			ResultSet rs1 = conn.prepareStatement("SELECT COUNT(*) AS total FROM teachers").executeQuery();
			if (rs1.next())
				totalTeachers = rs1.getInt("total");
			rs1.close();

			ResultSet rs2 = conn.prepareStatement(
			"SELECT COUNT(*) AS active FROM teachers t JOIN users u ON t.user_id = u.user_id WHERE u.status='active'")
			.executeQuery();
			if (rs2.next())
				activeTeachers = rs2.getInt("active");
			rs2.close();

			ResultSet rs3 = conn.prepareStatement("SELECT COUNT(*) AS total_subjects FROM subjects").executeQuery();
			if (rs3.next())
				totalSubjects = rs3.getInt("total_subjects");
			rs3.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		%>

		<div class="stat-card">
			<div class="stat-number"><%=totalTeachers%></div>
			<div class="stat-label">Total Teachers</div>
		</div>
		<div class="stat-card">
			<div class="stat-number"><%=totalSubjects%></div>
			<div class="stat-label">Total Subjects</div>
		</div>
	</div>

	<div class="filters-container">
		<form method="get" onsubmit="return false;">
			<div class="filters-grid">
				<div class="filter-group">
					<label for="teacherSearch">Search Teachers</label> <input
						type="text" id="teacherSearch" name="search"
						placeholder="Search by name, ID, username, or email..." onkeyup="loadTeachersTable()">
				</div>

				<div class="filter-group">
					<label for="teacherClassFilter">Filter by Class</label> <select
						id="teacherClassFilter" name="class" onchange="loadTeachersTable()">
						<option value="">All Classes</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section ASC";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							while (rs.next()) {
								int classId = rs.getInt("class_id");
								String className = rs.getString("class_name");
								String section = rs.getString("section");
								String displayName = className + (section != null ? " - " + section : "");
						%>
						<option value="<%=classId%>"><%=displayName%></option>
						<%
						}
						rs.close();
						stmt.close();
						} catch (SQLException e) {
						e.printStackTrace();
						}
						%>
					</select>
				</div>

				<div class="filter-group">
					<label for="teacherSubjectFilter">Filter by Subject</label> <select
						id="teacherSubjectFilter" name="subject" onchange="loadTeachersTable()">
						<option value="">All Subjects</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT subject_id, subject_name FROM subjects ORDER BY subject_name ASC";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							while (rs.next()) {
								int subjectId = rs.getInt("subject_id");
								String subjectName = rs.getString("subject_name");
						%>
						<option value="<%=subjectId%>"><%=subjectName%></option>
						<%
						}
						rs.close();
						stmt.close();
						} catch (SQLException e) {
						e.printStackTrace();
						}
						%>
					</select>
				</div>

				<div class="remove-filter-wrapper ux-mb-4">
					<button type="button" id="clearTeachersFilterBtn" class="btn btn-secondary remove-filter-btn ux-hidden" onclick="document.getElementById('teacherSearch').value=''; document.getElementById('teacherClassFilter').value=''; document.getElementById('teacherSubjectFilter').value=''; loadTeachersTable(); this.style.display='none';" title="Clear Filters">
						X Filter
					</button>
				</div>
			</div>
		</form>
	</div>

	<div class="table-container">
		<div class="table-header">
			<h3>Teachers List</h3>
			<%
			int teacherCount = 0;
			try (Connection conn = SQLConnection.getConnection()) {
				PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) AS total FROM teachers");
				ResultSet countRs = countStmt.executeQuery();
				if (countRs.next())
					teacherCount = countRs.getInt("total");
				countRs.close();
				countStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			%>
			<span><%=teacherCount%> teachers found</span>
		</div>

		<div class="table-wrapper teacher-list-scroll split-table">
			<table class="table-head-table">
				<colgroup>
					<col class="col-teacher-id">
					<col class="col-teacher-name">
					<col class="col-teacher-user">
					<col class="col-teacher-class">
					<col class="col-teacher-subject">
					<col class="col-teacher-phone">
					<col class="col-actions-lg">
				</colgroup>
				<thead>
					<tr>
						<th>Employee ID</th>
						<th>Teacher Name</th>
						<th>Username</th>
						<th>Class</th>
						<th>Subject</th>
						<th>Phone</th>
						<th>Actions</th>
					</tr>
				</thead>
			</table>
			<div class="table-body-scroll">
				<table class="table-body-table">
					<colgroup>
						<col class="col-teacher-id">
						<col class="col-teacher-name">
						<col class="col-teacher-user">
						<col class="col-teacher-class">
						<col class="col-teacher-subject">
						<col class="col-teacher-phone">
						<col class="col-actions-lg">
					</colgroup>
					<tbody id="teachersTableBody">
					<%
					try (Connection conn = SQLConnection.getConnection()) {
						String search = request.getParameter("search");
						String classFilter = request.getParameter("class");
						String subjectFilter = request.getParameter("subject");

						String sql = "SELECT t.teacher_id, t.employee_id, t.first_name, t.last_name, t.phone, t.address, "
						+ "u.username, u.email, u.password, "
						+ "s.subject_id, s.subject_name, " + "c.class_id, c.class_name, c.section " + "FROM teachers t "
						+ "JOIN users u ON t.user_id = u.user_id " + "LEFT JOIN subjects s ON t.subject_id = s.subject_id "
						+ "LEFT JOIN classes c ON c.teacher_id = t.teacher_id " + "WHERE u.role = 'teacher' ";

						if (search != null && !search.trim().isEmpty()) {
							String esc = search.replace("'", "''");
							sql += "AND (t.first_name LIKE '%" + esc + "%' " + "OR t.last_name LIKE '%" + esc + "%' "
							+ "OR t.employee_id LIKE '%" + esc + "%' " + "OR u.username LIKE '%" + esc + "%' "
							+ "OR u.email LIKE '%" + esc + "%') ";
						}

						if (classFilter != null && !classFilter.trim().isEmpty()) {
							String esc = classFilter.replace("'", "''");
							sql += "AND c.class_id = " + esc + " ";
						}

						if (subjectFilter != null && !subjectFilter.trim().isEmpty()) {
							String esc = subjectFilter.replace("'", "''");
							sql += "AND s.subject_id = " + esc + " ";
						}

						sql += "ORDER BY t.employee_id ASC";

						PreparedStatement stmt = conn.prepareStatement(sql);
						ResultSet rs = stmt.executeQuery();

						boolean hasData = false;

						while (rs.next()) {
							hasData = true;

							int teacherId = rs.getInt("teacher_id");
							String employeeId = rs.getString("employee_id");
							String firstName = rs.getString("first_name");
							String lastName = rs.getString("last_name");
							String fullName = firstName + " " + lastName;
							String username = rs.getString("username");
							String emailVal = rs.getString("email") != null ? rs.getString("email") : "";
							String password = rs.getString("password") != null ? rs.getString("password") : "";
							String phoneVal = rs.getString("phone") != null ? rs.getString("phone") : "-";
							String addressVal = rs.getString("address") != null ? rs.getString("address") : "";


							int classId = rs.getInt("class_id");
							String className = rs.getString("class_name");
							String section = rs.getString("section");
							String classDisplay = (className != null ? className : "-") + (section != null ? "-" + section : "");

							int subjectId = rs.getInt("subject_id");
							String subjectName = rs.getString("subject_name") != null ? rs.getString("subject_name") : "-";
					%>

					<tr>
						<td><%=employeeId%></td>
						<td>
							<div class="student-info">
								<div class="student-avatar"><%=fullName.substring(0, 1).toUpperCase()%></div>
								<div class="student-details">
									<h6><%=fullName%></h6>
								</div>
							</div>
						</td>
						<td><%=username%></td>
						<td><%=classDisplay%></td>
						<td><%=subjectName%></td>
						<td><%=phoneVal%></td>
						<td>
							<button type="button" class="action-btn edit"
								onclick="openEditTeacherModal(
                                        <%=teacherId%>,
                                        '<%=escapeJsAttr(fullName)%>',
                                        '<%=escapeJsAttr(username)%>',
                                        '<%=escapeJsAttr(emailVal)%>',
                                        '<%=escapeJsAttr(employeeId)%>',
                                        '<%=escapeJsAttr(phoneVal)%>',
                                        <%=classId%>,
                                        <%=subjectId%>,
                                        '<%=escapeJsAttr(addressVal)%>',
                                        '<%=escapeJsAttr(password)%>'
                                    )">
								<i class="fas fa-edit"></i> Edit
							</button>

							<button type="button" class="action-btn view"
								onclick="openViewTeacherModal(
                                        '<%=escapeJsAttr(fullName)%>',
                                        '<%=escapeJsAttr(username)%>',
                                        '<%=escapeJsAttr(emailVal)%>',
                                        '<%=escapeJsAttr(employeeId)%>',
                                        '<%=escapeJsAttr(phoneVal)%>',
                                        '<%=escapeJsAttr(classDisplay)%>',
                                        '<%=escapeJsAttr(subjectName)%>',
                                        '<%=escapeJsAttr(addressVal)%>',
                                        '<%=escapeJsAttr(password)%>'
                                    )">
								<i class="fas fa-eye"></i> View
							</button>

							<button type="button" class="action-btn delete"
								onclick="deleteTeacher(<%=teacherId%>, '<%=escapeJsAttr(fullName)%>')">
								<i class="fas fa-trash"></i> Delete
							</button>
						</td>
					</tr>

					<%
					}

					if (!hasData) {
					%>
					<tr>
						<td colspan="7" class="u-text-center">No teachers
							found.</td>
					</tr>
					<%
					}

					rs.close();
					stmt.close();
					} catch (SQLException e) {
					e.printStackTrace();
					%>
					<tr>
						<td colspan="7" class="u-text-center">Error loading
							teachers.</td>
					</tr>
					<%
					}
					%>
					</tbody>
				</table>
			</div>
		</div>
	</div>
</div>

<div id="editTeacherModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Edit Teacher</h2>
			<button class="modal-close" onclick="closeEditTeacherModal()">×</button>
		</div>

		<form name="editTeacherForm">
			<input type="hidden" id="editTeacherId">

			<h3 class="ux-modal-section-title">Account
				Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label>Username <span class="required">*</span></label> <input
						type="text" id="editTeacherUsername" required>
				</div>

				<div class="form-group">
					<label>Password <span class="required">*</span></label> <input
						type="text" id="editTeacherPassword" required
						placeholder="Current password / change here">
				</div>

				<div class="form-group">
					<label>Email Address <span class="required">*</span></label> <input
						type="email" id="editTeacherEmail" required>
				</div>

				<div class="form-group">
					<label>Employee ID <span class="required">*</span></label> <input
						type="text" id="editEmployeeId" required>
				</div>
			</div>

			<h3 class="ux-modal-section-title-spaced">Personal
				Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label>First Name <span class="required">*</span></label> <input
						type="text" id="editTeacherFirstName" required>
				</div>

				<div class="form-group">
					<label>Last Name <span class="required">*</span></label> <input
						type="text" id="editTeacherLastName" required>
				</div>

				<div class="form-group">
					<label>Phone Number</label> <input type="tel" id="editTeacherPhone">
				</div>

				<div class="form-group">
					<label>Class</label> <select id="editTeacherClassId">
						<option value="">Select Class</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section ASC";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs2 = stmt.executeQuery();
							while (rs2.next()) {
								int classId = rs2.getInt("class_id");
								String className = rs2.getString("class_name");
								String section = rs2.getString("section");
								String displayName = className + (section != null ? " - " + section : "");
						%>
						<option value="<%=classId%>"><%=displayName%></option>
						<%
						}
						rs2.close();
						stmt.close();
						} catch (SQLException e) {
						e.printStackTrace();
						}
						%>
					</select>
				</div>
			</div>

			<h3 class="ux-modal-section-title-spaced">Professional
				Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label>Subject</label> <select id="editTeacherSubjectId">
						<option value="">Select Subject</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT subject_id, subject_name FROM subjects ORDER BY subject_name ASC";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs3 = stmt.executeQuery();
							while (rs3.next()) {
								int subjectId = rs3.getInt("subject_id");
								String subjectName = rs3.getString("subject_name");
						%>
						<option value="<%=subjectId%>"><%=subjectName%></option>
						<%
						}
						rs3.close();
						stmt.close();
						} catch (SQLException e) {
						e.printStackTrace();
						}
						%>
					</select>
				</div>

			</div>

			<h3 class="ux-modal-section-title-spaced">Additional
				Information</h3>
			<div class="form-grid">
				<div class="form-group ux-grid-span-full">
					<label>Address</label>
					<textarea id="editTeacherAddress" placeholder="Enter full address"></textarea>
				</div>
			</div>

			<div id="editTeacherResult" class="ux-result-space"></div>

			<div class="form-actions">
				<button type="button" class="btn btn-secondary"
					onclick="closeEditTeacherModal()">Cancel</button>
				<button type="button" class="btn btn-primary"
					onclick="updateTeacher()">Save Changes</button>
			</div>
		</form>
	</div>
</div>


<div id="viewTeacherModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Teacher Details</h2>
			<button class="modal-close" onclick="closeViewTeacherModal()">×</button>
		</div>

		<div class="details-content">
			<div class="detail-section">
				<h3 class="ux-modal-section-title">Account
					Information</h3>
				<div class="detail-grid">
					<div class="detail-item">
						<label>Username</label>
						<p id="detailTeacherUsername"></p>
					</div>
					<div class="detail-item">
						<label>Password</label>
						<p id="detailTeacherPassword"></p>
					</div>
					<div class="detail-item">
						<label>Email</label>
						<p id="detailTeacherEmail"></p>
					</div>
					<div class="detail-item">
						<label>Employee ID</label>
						<p id="detailEmployeeId"></p>
					</div>
				</div>
			</div>

			<div class="detail-section">
				<h3 class="ux-modal-section-title">Personal
					Information</h3>
				<div class="detail-grid">
					<div class="detail-item">
						<label>First Name</label>
						<p id="detailTeacherFirstName"></p>
					</div>
					<div class="detail-item">
						<label>Last Name</label>
						<p id="detailTeacherLastName"></p>
					</div>
					<div class="detail-item">
						<label>Phone Number</label>
						<p id="detailTeacherPhone"></p>
					</div>
					<div class="detail-item">
						<label>Address</label>
						<p id="detailTeacherAddress"></p>
					</div>
				</div>
			</div>

			<div class="detail-section">
				<h3 class="ux-modal-section-title">Professional
					Information</h3>
				<div class="detail-grid">
					<div class="detail-item">
						<label>Class</label>
						<p id="detailTeacherClass"></p>
					</div>
					<div class="detail-item">
						<label>Subject</label>
						<p id="detailTeacherSubject"></p>
					</div>

				</div>
			</div>
		</div>

		<div class="form-actions">
			<button type="button" class="btn btn-secondary"
				onclick="closeViewTeacherModal()">Close</button>
		</div>
	</div>
</div>

<%!private String escapeJs(String value) {
		if (value == null)
			return "";
		return value.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r",
				"\\r");
	}

	private String escapeJsAttr(String value) {
		String jsEscaped = escapeJs(value);
		return jsEscaped.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}%>

