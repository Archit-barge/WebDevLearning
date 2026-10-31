<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.seh.util.SQLConnection"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.seh.model.User"%>
<%
User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="add_parent-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Add New Parent</h1>
			<p>Register a new parent account and link students</p>
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

	<%
	String error = (String) session.getAttribute("error");
	String success = (String) session.getAttribute("success");
	if (error != null && !error.isEmpty()) {
		session.removeAttribute("error");
	%>
	<div class="alert alert-error">
		<i class="fas fa-exclamation-triangle"></i>
		<%=error%>
	</div>
	<%
	}
	%>

	<%
	if (success != null && !success.isEmpty()) {
		session.removeAttribute("success");
	%>
	<div class="alert alert-success">
		<i class="fas fa-check-circle"></i>
		<%=success%>
	</div>
	<%
	}
	%>

	<div class="form-container">
		<div class="form-header">
			<h2>Parent Information</h2>
			<p>
				Please fill in all required fields marked with <span
					class="required">*</span>
			</p>
		</div>

		<form action="../addParent" method="post"
			onsubmit="return validateParentForm()">
			<h3 class="section-title-first">Account
				Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label for="parentUsername">Username <span class="required">*</span></label>
					<input type="text" id="parentUsername" name="username" required>
				</div>

				<div class="form-group">
					<label for="parentPassword">Password <span class="required">*</span></label>
					<input type="text" id="parentPassword" name="password" required>
				</div>

				<div class="form-group">
					<label for="parentEmail">Email Address <span
						class="required">*</span></label> <input type="email" id="parentEmail"
						name="email" required>
				</div>
			</div>

			<h3>Personal
				Details</h3>
			<div class="form-grid">
				<div class="form-group">
					<label for="parentFirstName">First Name <span
						class="required">*</span></label> <input type="text" id="parentFirstName"
						name="firstName" required>
				</div>

				<div class="form-group">
					<label for="parentLastName">Last Name <span
						class="required">*</span></label> <input type="text" id="parentLastName"
						name="lastName" required>
				</div>

				<div class="form-group">
					<label for="parentPhone">Phone Number</label> <input type="tel"
						id="parentPhone" name="phone" placeholder="9876543210" pattern="\d{10}" maxlength="10" inputmode="numeric">
				</div>

				<div class="form-group">
					<label for="parentRelationship">Relationship <span
						class="required">*</span></label> <select id="parentRelationship"
						name="relationship" required>
						<option value="">Select Relationship</option>
						<option value="father">Father</option>
						<option value="mother">Mother</option>
						<option value="guardian">Guardian</option>
					</select>
				</div>

				<div class="form-group full-span">
					<label for="parentAddress">Address</label>
					<textarea id="parentAddress" name="address"
						placeholder="Enter full address"></textarea>
				</div>
			</div>

			<h3>Link Student</h3>

				<div class="filters-container">
					<div class="filters-grid">
						<div class="filter-group">
							<label for="addParentStudentSearch">Search Students</label>
							<input type="text" id="addParentStudentSearch"
								class="filter-control"
								placeholder="Search by name, roll number..."
								onkeyup="searchStudentsForParent('add')">
						</div>

						<div class="filter-group">
							<label for="addParentClassFilter">Filter by Class</label>
							<select id="addParentClassFilter" onchange="searchStudentsForParent('add')"
								class="filter-control">
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
								<option value="<%=classId%>">
									<%=displayName%>
								</option>
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

						<button type="button" class="btn btn-primary student-search-btn"
							onclick="searchStudentsForParent('add')">
							<i class="fas fa-search"></i> Search
						</button>
					</div>
				</div>


			<div class="table-wrapper student-search-table split-table">
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
				<div class="table-body-scroll student-search-table-body">
					<table class="table-body-table">
						<colgroup>
							<col class="col-link-roll">
							<col class="col-link-name">
							<col class="col-link-class">
							<col class="col-actions-sm">
						</colgroup>
						<tbody id="addStudentSearchResults">
						<%
						// Auto-load students using JSP
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, c.class_name, c.section " +
									"FROM students s LEFT JOIN classes c ON s.class_id = c.class_id ORDER BY s.roll_number ASC";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							boolean hasData = false;
							while (rs.next()) {
								hasData = true;
								int sid = rs.getInt("student_id");
								String roll = rs.getString("roll_number");
								String name = rs.getString("first_name") + " " + rs.getString("last_name");
								String cName = rs.getString("class_name");
								String sec = rs.getString("section");
								String classDisplay = cName != null ? cName + (sec != null ? " - " + sec : "") : "Unassigned";
						%>
						<tr>
							<td><%=roll%></td>
							<td><%=name%></td>
							<td><%=classDisplay%></td>
							<td>
								<button type="button" class="action-btn view" onclick="selectStudentForParent(<%=sid%>, '<%=escapeJsAttr(name)%>', '<%=escapeJsAttr(roll)%>', 'add')">
									<i class="fas fa-plus"></i> Select
								</button>
							</td>
						</tr>
						<%
							}
							if (!hasData) {
						%>
						<tr><td colspan="4" class="table-cell-center">No students found</td></tr>
						<%
							}
							rs.close();
							stmt.close();
						} catch(Exception e) {
							e.printStackTrace();
						%>
							<tr><td colspan="4" class="table-cell-error">Error loading students: <%=e.getMessage()%></td></tr>
						<%
						}
						%>
						</tbody>
					</table>
				</div>
			</div>

			<div id="selectedStudentsContainer" class="selected-students-container">
				<label class="selected-students-label">Selected
					Students</label>
				<div id="selectedStudentsList" class="selected-students-list"></div>
			</div>

			<div class="form-actions">
				<button type="button" class="btn btn-secondary"
					onclick="loadPage('dashboard.jsp')">
					<i class="fas fa-arrow-left"></i> Back to Dashboard
				</button>
				<button type="submit" class="btn btn-primary">
					<i class="fas fa-user-plus"></i> Add Parent
				</button>
			</div>
		</form>
	</div>
</div>

<script>
	function validateParentForm() {
		var container = document.getElementById('selectedStudentsList');
		var chips = container.querySelectorAll('input[name="studentIds"]');
		if (chips.length === 0) {
			alert('Please select at least one student to link.');
			return false;
		}
		return true;
	}
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
