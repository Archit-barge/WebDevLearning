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

<div class="manage_subjects-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Manage Subjects</h1>
			<p>
				Welcome back,
				<%=user.getFullName()%>! Create and manage school subjects.
			</p>
		</div>

		<div class="user-info">
			<div class="user-avatar"><%=avatarLetter%></div>
			<div class="user-details">
				<p class="user-role-name"><%=user.getFullName()%></p>
				<p class="user-role-desc"><%=user.getRole()%></p>
			</div>
			<button class="logout-btn" onclick="logout()">
				<i class="fas fa-sign-out-alt"></i> Logout
			</button>
		</div>
	</div>

	<div class="stats-grid" id="subjectsStats">
		<%
		int totalSubjects = 0;
		try (Connection conn = SQLConnection.getConnection()) {
			ResultSet rs = conn.prepareStatement("SELECT COUNT(*) AS total FROM subjects").executeQuery();
			if (rs.next())
				totalSubjects = rs.getInt("total");
			rs.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		%>
		<div class="stat-card">
			<div class="stat-number" id="totalSubjectsCount"><%=totalSubjects%></div>
			<div class="stat-label">Total Subjects</div>
		</div>
	</div>

	<div class="form-container">
		<h2>Add New Subject</h2>
		<form name="subjectForm">
			<div class="form-grid">
				<div class="form-group">
					<label>Subject Name <span class="required">*</span></label> <input
						type="text" name="subjectName" required
						placeholder="e.g., Mathematics">
				</div>

				<div class="form-group">
					<label>Subject Code <span class="required">*</span></label> <input
						type="text" name="subjectCode" required
						placeholder="e.g., MATH101">
				</div>

				<div class="form-group ux-grid-span-full">
					<label>Description</label>
					<textarea name="description"
						class="ux-textarea-h100" placeholder="Enter subject description"></textarea>
				</div>
			</div>

			<button type="button" class="btn btn-primary" onclick="addSubject()">
				<i class="fas fa-plus"></i> Add Subject
			</button>
		</form>

		<div id="result" class="u-mt-1"></div>
	</div>

	<div class="table-container">
		<div class="table-header">
			<h3>Existing Subjects</h3>
		</div>

		<div class="table-wrapper split-table">
			<table class="table-head-table">
				<colgroup>
					<col class="col-subject-name">
					<col class="col-subject-code">
					<col class="col-subject-desc">
					<col class="col-actions-md">
				</colgroup>
				<thead>
					<tr>
						<th>Subject Name</th>
						<th>Subject Code</th>
						<th>Description</th>
						<th>Actions</th>
					</tr>
				</thead>
			</table>
			<div class="table-body-scroll">
				<table class="table-body-table">
					<colgroup>
						<col class="col-subject-name">
						<col class="col-subject-code">
						<col class="col-subject-desc">
						<col class="col-actions-md">
					</colgroup>
					<tbody id="subjectsTableBody">
					<%
					try (Connection conn = SQLConnection.getConnection()) {
						String sql = "SELECT subject_id, subject_name, subject_code, description "
						+ "FROM subjects ORDER BY subject_name ASC";
						PreparedStatement stmt = conn.prepareStatement(sql);
						ResultSet rs = stmt.executeQuery();

						if (!rs.isBeforeFirst()) {
					%>
					<tr>
						<td colspan="4" class="u-text-center">No subjects
							found. Add one using the form above.</td>
					</tr>
					<%
					} else {
					while (rs.next()) {
						int subjectId = rs.getInt("subject_id");
						String subjectName = rs.getString("subject_name");
						String subjectCode = rs.getString("subject_code");
						String description = rs.getString("description");
					%>
					<tr>
						<td><%=subjectName%></td>
						<td><%=subjectCode%></td>
						<td><%=description != null ? description : "-"%></td>
						<td>
							<%
							%>
							<button type="button" class="action-btn edit"
								onclick="openEditSubjectModal(<%=subjectId%>, '<%=escapeJsAttr(subjectName)%>', '<%=escapeJsAttr(subjectCode)%>', '<%=escapeJsAttr(description)%>')">
								<i class="fas fa-edit"></i> Edit
							</button>
							<button type="button" class="action-btn delete"
								onclick="deleteSubject(<%=subjectId%>, '<%=escapeJsAttr(subjectName)%>')">
								<i class="fas fa-trash"></i> Delete
							</button>
						</td>
					</tr>
					<%
					}
					}
					rs.close();
					stmt.close();
					} catch (SQLException e) {
					e.printStackTrace();
					%>
					<tr>
						<td colspan="4" class="u-text-center">Error loading
							subjects.</td>
					</tr>
					<%
					}
					%>
					</tbody>
				</table>
			</div>
		</div>
	</div>

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

	<div id="editSubjectModal" class="modal-overlay ux-hidden">
		<div class="modal-container">
			<div class="modal-header">
				<h2>Edit Subject</h2>
				<button class="modal-close" onclick="closeEditSubjectModal()">×</button>
			</div>

			<form id="editSubjectForm">
				<input type="hidden" id="editSubjectId">

				<div class="form-group">
					<label>Subject Name <span class="required">*</span></label> <input
						type="text" id="editSubjectName" required>
				</div>

				<div class="form-group">
					<label>Subject Code <span class="required">*</span></label> <input
						type="text" id="editSubjectCode" required>
				</div>

				<div class="form-group">
					<label>Description</label>
					<textarea id="editSubjectDescription" rows="4"></textarea>
				</div>

				<div id="editSubjectResult" class="ux-result-space"></div>

				<div class="form-actions">
					<button type="button" class="btn btn-secondary"
						onclick="closeEditSubjectModal()">Cancel</button>
					<button type="button" class="btn btn-primary"
						onclick="updateSubject()">Save Changes</button>
				</div>
			</form>
		</div>
	</div>
</div>
<script>
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = '../LogoutServlet';
    }
}
</script>

