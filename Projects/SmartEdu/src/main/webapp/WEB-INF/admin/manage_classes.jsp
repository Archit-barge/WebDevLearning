<%@page import="com.seh.util.SQLConnection"%>
<%@page import="com.seh.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%


User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="manage_classes-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Manage Classes</h1>
			<p>
				Welcome back,
				<%=user.getFullName()%>! Create and manage school classes.
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

	<div class="stats-grid" id="classesStats">
		<%
		int totalClasses = 0;
		int totalTeachers = 0;
		try (Connection conn = SQLConnection.getConnection()) {

			ResultSet rs1 = conn.prepareStatement("SELECT COUNT(*) AS total_classes FROM classes").executeQuery();
			if (rs1.next())
				totalClasses = rs1.getInt("total_classes");
			rs1.close();

			ResultSet rs2 = conn.prepareStatement("SELECT COUNT(*) AS total_teachers FROM teachers").executeQuery();
			if (rs2.next())
				totalTeachers = rs2.getInt("total_teachers");
			rs2.close();

		} catch (SQLException e) {
			e.printStackTrace();
		}
		%>
		<div class="stat-card">
			<div class="stat-number"><%=totalClasses%></div>
			<div class="stat-label">Total Classes</div>
		</div>
		<div class="stat-card">
			<div class="stat-number"><%=totalTeachers%></div>
			<div class="stat-label">Total Teachers</div>
		</div>
	</div>

	<div class="form-container">
		<h2>Add New Class</h2>
		<form name="classForm">
			<div class="form-grid">
				<div class="form-group">
					<label>Class Name <span class="required">*</span></label> <input
						type="text" name="className" required
						placeholder="e.g., Grade 1, Class A">
				</div>
				<div class="form-group">
					<label>Section</label> <input type="text" name="section"
						placeholder="e.g., A, B, C">
				</div>
				<div class="form-group">
					<label>Capacity</label> <input type="number" name="capacity"
						placeholder="Maximum Students" min="1" max="100">
				</div>
				<div class="form-group">
					<label>Class Teacher</label> <select name="classTeacherId">
						<option value="">Select Teacher</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT teacher_id, first_name, last_name FROM teachers ORDER BY first_name, last_name";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							while (rs.next()) {
						%>
						<option value="<%=rs.getInt("teacher_id")%>"><%=rs.getString("first_name") + " " + rs.getString("last_name")%></option>
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
			</div>
                <div id="classResult" class="u-mt-1"></div>
			
			<button type="button" class="btn btn-primary" onclick="addClass()">
				<i class="fas fa-plus"></i> Add Class
			</button>
		</form>

		

	</div>

	<div class="table-container">
		<div class="table-header">
			<h3>Existing Classes</h3>
		</div>

		<div class="table-wrapper split-table">
			<table class="table-head-table">
				<colgroup>
					<col class="col-class-name">
					<col class="col-class-section">
					<col class="col-class-capacity">
					<col class="col-class-teacher">
					<col class="col-actions-md">
				</colgroup>
				<thead>
					<tr>
						<th>Class Name</th>
						<th>Section</th>
						<th>Capacity</th>
						<th>Class Teacher</th>
						<th>Actions</th>
					</tr>
				</thead>
			</table>
			<div class="table-body-scroll">
				<table id="classesTableBody" class="table-body-table">
					<colgroup>
						<col class="col-class-name">
						<col class="col-class-section">
						<col class="col-class-capacity">
						<col class="col-class-teacher">
						<col class="col-actions-md">
					</colgroup>
					<tbody>
					<%
					try (Connection conn = SQLConnection.getConnection()) {
						String sql = "SELECT c.class_id, c.class_name, c.section, c.academic_year, c.max_students, t.teacher_id, t.first_name, t.last_name FROM classes c LEFT JOIN teachers t ON c.teacher_id = t.teacher_id ORDER BY c.class_name, c.section;";
						PreparedStatement stmt = conn.prepareStatement(sql);
						ResultSet rs = stmt.executeQuery();

						if (!rs.next()) {
					%>
					<tr>
                                <td colspan="5" class="u-text-center">No classes found.</td>
					</tr>
					<%
					} else {
					do {
						String teacherName = rs.getString("first_name") != null
						? rs.getString("first_name") + " " + rs.getString("last_name")
						: "Not Assigned";
						String className = rs.getString("class_name");
						String sectionName = rs.getString("section");
						String classDisplayName = className
								+ ((sectionName != null && !sectionName.trim().isEmpty()) ? (" - " + sectionName) : "");
					%>
					<tr>
						<td><%=rs.getString("class_name")%></td>
						<td><%=rs.getString("section") != null ? rs.getString("section") : "-"%></td>
						<td><%=rs.getInt("max_students")%></td>
						<td><%=teacherName%></td>
						<td>
							<button type="button" class="action-btn edit"
								onclick="openEditClassModal(<%=rs.getInt("class_id")%>, '<%=escapeJsAttr(rs.getString("class_name"))%>', '<%=escapeJsAttr(rs.getString("section"))%>', <%=rs.getInt("max_students")%>, <%=rs.getInt("teacher_id") != 0 ? rs.getInt("teacher_id") : "''"%>)">
								<i class="fas fa-edit"></i> Edit
							</button>
							<button type="button" class="action-btn delete"
								onclick="deleteClass(<%=rs.getInt("class_id")%>, '<%=escapeJsAttr(classDisplayName)%>')">
								<i class="fas fa-trash"></i> Delete
							</button>
						</td>
					</tr>
					<%
					} while (rs.next());
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
</div>

<div id="editModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Edit Class</h2>
			<button class="modal-close" onclick="closeEditModal()">×</button>
		</div>

		<form name="editClassForm">
			<input type="hidden" name="classId" id="editClassId">

			<div class="form-group">
				<label>Class Name <span class="required">*</span></label> <input
					type="text" name="className" id="editClassName" required>
			</div>

			<div class="form-group">
				<label>Section</label> <input type="text" name="section"
					id="editSection">
			</div>

			<div class="form-group">
				<label>Capacity</label> <input type="number" name="capacity"
					id="editCapacity" min="1" max="100">
			</div>

			<div class="form-group">
				<label>Class Teacher</label> <select name="classTeacherId"
					id="editClassTeacherId">
					<option value="">Select Teacher</option>
					<%
					try (Connection conn = SQLConnection.getConnection()) {
						String sql = "SELECT teacher_id, first_name, last_name FROM teachers ORDER BY first_name, last_name";
						PreparedStatement stmt = conn.prepareStatement(sql);
						ResultSet rs2 = stmt.executeQuery();
						while (rs2.next()) {
					%>
					<option value="<%=rs2.getInt("teacher_id")%>"><%=rs2.getString("first_name") + " " + rs2.getString("last_name")%></option>
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

            <div id="editResult" class="ux-result-space"></div>

			<div class="form-actions">
				<button type="button" class="btn btn-secondary"
					onclick="closeEditModal()">Cancel</button>
				<button type="button" class="btn btn-primary"
					onclick="updateClass()">Save Changes</button>
			</div>
		</form>
	</div>
</div>


<script>
function logout() {
if (confirm('Are you sure you want to logout?')) {
window.location.href = '../LogoutServlet';
}
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

