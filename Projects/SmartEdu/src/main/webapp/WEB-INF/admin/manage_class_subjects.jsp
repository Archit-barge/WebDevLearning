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

<div class="manage_class_subjects-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Manage Class Subjects</h1>
			<p>
				Welcome back,
				<%=user.getFullName()%>! Assign subjects to classes and assign
				teachers.
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

	<%
	int totalClassSubjects = 0;
	int totalClasses = 0;
	int totalSubjects = 0;
	try (Connection conn = SQLConnection.getConnection()) {
		ResultSet rs1 = conn.prepareStatement("SELECT COUNT(*) AS total FROM class_subjects").executeQuery();
		if (rs1.next())
			totalClassSubjects = rs1.getInt("total");
		rs1.close();

		ResultSet rs2 = conn.prepareStatement("SELECT COUNT(*) AS total FROM classes").executeQuery();
		if (rs2.next())
			totalClasses = rs2.getInt("total");
		rs2.close();

		ResultSet rs3 = conn.prepareStatement("SELECT COUNT(*) AS total FROM subjects").executeQuery();
		if (rs3.next())
			totalSubjects = rs3.getInt("total");
		rs3.close();

	} catch (SQLException e) {
		e.printStackTrace();
	}
	%>
	<div class="stat-grid">
		<div class="stat-card">
			<div class="stat-number" id="totalClassSubjectsCount"><%=totalClassSubjects%></div>
			<div class="stat-label">Total Assignments</div>
		</div>
		<div class="stat-card">
			<div class="stat-number"><%=totalClasses%></div>
			<div class="stat-label">Total Classes</div>
		</div>
		<div class="stat-card">
			<div class="stat-number"><%=totalSubjects%></div>
			<div class="stat-label">Total Subjects</div>
		</div>
	</div>

	<div class="form-container">
		<h2>Assign Subject to Class</h2>
		<form name="classSubjectForm">
			<div class="form-grid">
				<div class="form-group">
					<label>Class <span class="required">*</span></label> <select
						name="classId" required>
						<option value="">Select Class</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							while (rs.next()) {
								String section = rs.getString("section");
								String displayName = rs.getString("class_name");
								if (section != null && !section.isEmpty()) {
									displayName += " - " + section;
								}
						%>
						<option value="<%=rs.getInt("class_id")%>"><%=displayName%></option>
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

				<div class="form-group">
					<label>Subject <span class="required">*</span></label> <select
						name="subjectId" required>
						<option value="">Select Subject</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT subject_id, subject_name FROM subjects ORDER BY subject_name";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							while (rs.next()) {
						%>
						<option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
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

				<div class="form-group">
					<label>Teacher <span class="required">*</span></label> <select
						name="teacherId" required>
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

			<button type="button" class="btn btn-primary" onclick="addClassSubject()">
				<i class="fas fa-plus"></i> Assign Subject
			</button>
		</form>

                <div id="result" class="u-mt-1"></div>
	</div>

	<div class="table-container">
		<div class="table-header">
			<h3>Class Subject Assignments</h3>
		</div>

		<div class="table-wrapper split-table">
			<table class="table-head-table">
				<colgroup>
					<col class="col-cs-class">
					<col class="col-cs-subject">
					<col class="col-cs-teacher">
					<col class="col-actions-md">
				</colgroup>
				<thead>
					<tr>
						<th>Class</th>
						<th>Subject</th>
						<th>Teacher</th>
						<th>Actions</th>
					</tr>
				</thead>
			</table>
			<div class="table-body-scroll">
				<table class="table-body-table">
					<colgroup>
						<col class="col-cs-class">
						<col class="col-cs-subject">
						<col class="col-cs-teacher">
						<col class="col-actions-md">
					</colgroup>
					<tbody id="classSubjectsTableBody">
					<%
					try (Connection conn = SQLConnection.getConnection()) {
						String sql = "SELECT cs.id, c.class_id, c.class_name, c.section, s.subject_id, s.subject_name, "
						+ "t.teacher_id, t.first_name, t.last_name FROM class_subjects cs "
						+ "JOIN classes c ON cs.class_id = c.class_id "
						+ "JOIN subjects s ON cs.subject_id = s.subject_id "
						+ "JOIN teachers t ON cs.teacher_id = t.teacher_id "
						+ "ORDER BY c.class_name, s.subject_name ASC";
						PreparedStatement stmt = conn.prepareStatement(sql);
						ResultSet rs = stmt.executeQuery();

						if (!rs.isBeforeFirst()) {
					%>
					<tr>
                                <td colspan="4" class="u-text-center">No class subjects found. Add one using the form above.</td>
					</tr>
					<%
					} else {
					while (rs.next()) {
						int id = rs.getInt("id");
						String className = rs.getString("class_name");
						String section = rs.getString("section");
						String subjectName = rs.getString("subject_name");
						String teacherName = rs.getString("first_name") + " " + rs.getString("last_name");

						String classDisplay = section != null && !section.isEmpty() ? className + " - " + section : className;

					%>
					<tr>
						<td><%=classDisplay%></td>
						<td><%=subjectName%></td>
						<td><%=teacherName%></td>
						<td>
							<%
							int classId = rs.getInt("class_id");
							int subjectId = rs.getInt("subject_id");
							int teacherId = rs.getInt("teacher_id");
							%>
							<button type="button" class="action-btn edit"
								onclick="openEditClassSubjectModal(<%=id%>, <%=classId%>, <%=subjectId%>, <%=teacherId%>, '<%=escapeJsAttr(classDisplay)%>', '<%=escapeJsAttr(subjectName)%>', '<%=escapeJsAttr(teacherName)%>')">
								<i class="fas fa-edit"></i> Edit
							</button>
							<button type="button" class="action-btn delete"
								onclick="deleteClassSubject(<%=id%>, '<%=escapeJsAttr(classDisplay)%>', '<%=escapeJsAttr(subjectName)%>')">
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
                                <td colspan="4" class="u-text-center">Error loading class subjects.</td>
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
</div>

<div id="editClassSubjectModal" class="modal-overlay ux-hidden">
		<div class="modal-container">
			<div class="modal-header">
				<h2>Edit Class Subject</h2>
				<button class="modal-close" onclick="closeEditClassSubjectModal()">×</button>
			</div>

			<form id="editClassSubjectForm">
				<input type="hidden" id="editClassSubjectId">

				<div class="form-group">
					<label>Class <span class="required">*</span></label> 
					<select id="editClassId" required>
						<option value="">Select Class</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							while (rs.next()) {
								String section = rs.getString("section");
								String displayName = rs.getString("class_name");
								if (section != null && !section.isEmpty()) {
									displayName += " - " + section;
								}
						%>
						<option value="<%=rs.getInt("class_id")%>"><%=displayName%></option>
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

				<div class="form-group">
					<label>Subject <span class="required">*</span></label> 
					<select id="editSubjectId" required>
						<option value="">Select Subject</option>
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT subject_id, subject_name FROM subjects ORDER BY subject_name";
							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();
							while (rs.next()) {
						%>
						<option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
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

				<div class="form-group">
					<label>Teacher <span class="required">*</span></label> 
					<select id="editTeacherId" required>
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

            <div id="editClassSubjectResult" class="ux-result-space"></div>

				<div class="form-actions">
					<button type="button" class="btn btn-secondary"
						onclick="closeEditClassSubjectModal()">Cancel</button>
					<button type="button" class="btn btn-primary"
						onclick="updateClassSubject()">Save Changes</button>
				</div>
			</form>
		</div>
	</div>

