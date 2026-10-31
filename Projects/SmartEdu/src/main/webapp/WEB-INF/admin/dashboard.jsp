<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.seh.model.User"%>
<%@ page import="com.seh.util.SQLConnection"%>
<%
User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="dashboard-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Admin Dashboard</h1>
			<p>Monitor and manage your school system</p>
		</div>
		<div class="user-info">
            <div class="user-avatar"><%=avatarLetter%></div>
            <div class="user-details">
                <p class="user-role-name"><%=user.getFullName() %></p>
                <p class="user-role-desc"><%=user.getRole()%></p>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i> 
                <span>Logout</span>
            </button>
        </div>
	</div>

	<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	int totalStudents = 0, totalTeachers = 0, totalParents = 0, totalClasses = 0;

	try {
		conn = SQLConnection.getConnection();

		pstmt = conn.prepareStatement("SELECT COUNT(*) FROM students");
		rs = pstmt.executeQuery();
		if (rs.next())
			totalStudents = rs.getInt(1);
		rs.close();
		pstmt.close();

		pstmt = conn.prepareStatement("SELECT COUNT(*) FROM teachers");
		rs = pstmt.executeQuery();
		if (rs.next())
			totalTeachers = rs.getInt(1);
		rs.close();
		pstmt.close();

		pstmt = conn.prepareStatement("SELECT COUNT(*) FROM parents");
		rs = pstmt.executeQuery();
		if (rs.next())
			totalParents = rs.getInt(1);
		rs.close();
		pstmt.close();

		pstmt = conn.prepareStatement("SELECT COUNT(*) FROM classes");
		rs = pstmt.executeQuery();
		if (rs.next())
			totalClasses = rs.getInt(1);

	} catch (SQLException e) {
		e.printStackTrace();
	} finally {
		SQLConnection.closeResources(conn, rs, pstmt);
	}
	%>

	<div class="stat-grid">
		<div class="stat-card">
			<div class="stat-header">
				<div class="stat-title">Students</div>
				<div class="stat-icon students">
					<i class="fas fa-users"></i>
				</div>
			</div>
			<div class="stat-number"><%=totalStudents%></div>
			<div class="stat-label">Active</div>
		</div>
		<div class="stat-card">
			<div class="stat-header">
				<div class="stat-title">Teachers</div>
				<div class="stat-icon teachers">
					<i class="fas fa-chalkboard-teacher"></i>
				</div>
			</div>
			<div class="stat-number"><%=totalTeachers%></div>
			<div class="stat-label">Active</div>
		</div>
		<div class="stat-card">
			<div class="stat-header">
				<div class="stat-title">Parents</div>
				<div class="stat-icon parents">
					<i class="fas fa-users"></i>
				</div>
			</div>
			<div class="stat-number"><%=totalParents%></div>
			<div class="stat-label">Registered</div>
		</div>
		<div class="stat-card">
			<div class="stat-header">
				<div class="stat-title">Classes</div>
				<div class="stat-icon classes">
					<i class="fas fa-school"></i>
				</div>
			</div>
			<div class="stat-number"><%=totalClasses%></div>
			<div class="stat-label">Active</div>
		</div>
	</div>

	<div class="action-container">
		<div class="action-header">
			<div class="action-title">Quick Actions</div>
		</div>
		<div class="action-grid">
			<a href="javascript:void(0)" onclick="loadPage('add_student.jsp')" class="action-card">
				<div class="action-icon students">
					<i class="fas fa-user-plus"></i>
				</div>
				<h3>Add Student</h3>
				<p>Register new students</p>
			</a>
			<a href="javascript:void(0)" onclick="loadPage('add_teacher.jsp')" class="action-card">
				<div class="action-icon teachers">
					<i class="fas fa-chalkboard-teacher"></i>
				</div>
				<h3>Add Teacher</h3>
				<p>Add new teachers</p>
			</a>
			<a href="javascript:void(0)" onclick="loadPage('admin_announcements.jsp')" class="action-card">
				<div class="action-icon announcements">
					<i class="fas fa-bullhorn"></i>
				</div>
				<h3>Announcements</h3>
				<p>Send notifications</p>
			</a>
			<a href="javascript:void(0)" onclick="loadPage('post_doc.jsp')" class="action-card">
				<div class="action-icon post-notes">
					<i class="fas fa-book"></i>
				</div>
				<h3>Post Notes</h3>
				<p>Upload syllabus</p>
			</a>
		</div>
	</div>

	<div class="content-grid">
		<div class="feed-stack">
			<div class="dashboard-card">
				<div class="activity-header">
					<h2 class="activity-title">Recent Announcements</h2>
					<a href="javascript:void(0)" class="view-all-btn" onclick="loadPage('admin_announcements.jsp')">View All</a>
				</div>
				<div class="activity-list">
					<%
					boolean hasAnnouncements = false;
					try (Connection aConn = SQLConnection.getConnection();
						 PreparedStatement aStmt = aConn.prepareStatement(
							 "SELECT a.title, a.class_id, a.created_at, c.class_name, c.section " +
							 "FROM announcements a " +
							 "LEFT JOIN classes c ON a.class_id = c.class_id " +
							 "ORDER BY a.created_at DESC LIMIT 5");
						 ResultSet aRs = aStmt.executeQuery()) {

						while (aRs.next()) {
							hasAnnouncements = true;
							String annTitle = aRs.getString("title");
							Integer annClassId = (Integer) aRs.getObject("class_id");
							String clsName = aRs.getString("class_name");
							String clsSection = aRs.getString("section");
							String scopeText = "School";
							if (annClassId != null) {
								if (clsName != null && !clsName.trim().isEmpty()) {
									scopeText = clsName + ((clsSection != null && !clsSection.trim().isEmpty()) ? (" - " + clsSection) : "");
								} else {
									scopeText = "Class";
								}
							}
							String scopeClass = (annClassId == null) ? "badge-scope-school" : "badge-scope-class";
							String annRole = (annClassId == null) ? "Admin" : "Teacher";
							String annRoleClass = (annClassId == null) ? "badge-role-admin" : "badge-role-teacher";
							java.sql.Timestamp annTs = aRs.getTimestamp("created_at");
							String annTime = (annTs != null) ? annTs.toString().substring(0, 16) : "-";
					%>
					<div class="activity-item">
						<div class="activity-icon icon-announcement">
							<i class="fas fa-bullhorn"></i>
						</div>
						<div class="activity-content">
							<h4><%=annTitle%></h4>
							<div class="item-meta">
								<span class="badge-pill <%=scopeClass%>"><%=scopeText%></span>
								<span class="badge-pill <%=annRoleClass%>">By <%=annRole%></span>
							</div>
						</div>
						<div class="activity-time"><%=annTime%></div>
					</div>
					<%
						}
					} catch (SQLException e) {
						e.printStackTrace();
					}
					if (!hasAnnouncements) {
					%>
					<div class="empty-feed">No announcements found.</div>
					<% } %>
				</div>
			</div>

			<div class="dashboard-card">
				<div class="activity-header">
					<h2 class="activity-title">Recent Uploaded Documents</h2>
					<a href="javascript:void(0)" class="view-all-btn" onclick="loadPage('document_library.jsp')">View All</a>
				</div>
				<div class="activity-list">
					<%
					boolean hasDocs = false;
					try (Connection dConn = SQLConnection.getConnection();
						 PreparedStatement dStmt = dConn.prepareStatement(
							"SELECT d.title, d.document_type, d.upload_date, u.username, c.class_name, c.section " +
							", u.role " +
							"FROM documents d LEFT JOIN users u ON d.uploaded_by = u.user_id " +
							"LEFT JOIN classes c ON d.class_id = c.class_id " +
							"ORDER BY d.upload_date DESC LIMIT 5");
						 ResultSet dRs = dStmt.executeQuery()) {

						while (dRs.next()) {
							hasDocs = true;
							String docTitle = dRs.getString("title");
							String docType = dRs.getString("document_type");
							String uploader = dRs.getString("username") != null ? dRs.getString("username") : "Unknown";
							String clsName = dRs.getString("class_name");
							String clsSection = dRs.getString("section");
							String docClass = (clsName != null && !clsName.trim().isEmpty())
									? (clsName + ((clsSection != null && !clsSection.trim().isEmpty()) ? (" - " + clsSection) : ""))
									: "General";
							String uploaderRole = dRs.getString("role") != null ? dRs.getString("role") : "unknown";
							String roleClass = "badge-role-student";
							if ("admin".equalsIgnoreCase(uploaderRole)) roleClass = "badge-role-admin";
							else if ("teacher".equalsIgnoreCase(uploaderRole)) roleClass = "badge-role-teacher";
							else if ("parent".equalsIgnoreCase(uploaderRole)) roleClass = "badge-role-parent";
							String roleText = uploaderRole.substring(0, 1).toUpperCase() + uploaderRole.substring(1).toLowerCase();
							java.sql.Timestamp docTs = dRs.getTimestamp("upload_date");
							String docTime = (docTs != null) ? docTs.toString().substring(0, 16) : "-";
					%>
					<div class="activity-item">
						<div class="activity-icon icon-document">
							<i class="fas fa-file-alt"></i>
						</div>
						<div class="activity-content">
							<h4><%=docTitle%></h4>
							<div class="item-meta">
								<span class="badge-pill badge-scope-school"><%=docType%></span>
								<span class="badge-pill badge-scope-class"><%=docClass%></span>
								<span class="badge-pill <%=roleClass%>">By <%=roleText%></span>
								<span class="badge-pill badge-user-name">@<%=uploader%></span>
							</div>
						</div>
						<div class="activity-time"><%=docTime%></div>
					</div>
					<%
						}
					} catch (SQLException e) {
						e.printStackTrace();
					}
					if (!hasDocs) {
					%>
					<div class="empty-feed">No documents uploaded yet.</div>
					<% } %>
				</div>
			</div>
		</div>

		<div class="dashboard-card">
			<div class="activity-header">
				<h2 class="activity-title">Recent Users</h2>
			</div>
			<div class="activity-list">
				<%
				boolean hasUsers = false;
				try (Connection uConn = SQLConnection.getConnection();
					 PreparedStatement uStmt = uConn.prepareStatement(
						"SELECT user_id, username, role, created_at " +
						"FROM users ORDER BY created_at DESC, user_id DESC LIMIT 6");
					 ResultSet uRs = uStmt.executeQuery()) {

					while (uRs.next()) {
						hasUsers = true;
						String uname = uRs.getString("username");
						String urole = uRs.getString("role");
						String roleClass = "badge-role-student";
						if ("admin".equalsIgnoreCase(urole)) roleClass = "badge-role-admin";
						else if ("teacher".equalsIgnoreCase(urole)) roleClass = "badge-role-teacher";
						else if ("parent".equalsIgnoreCase(urole)) roleClass = "badge-role-parent";
						String roleText = urole.substring(0, 1).toUpperCase() + urole.substring(1).toLowerCase();
						java.sql.Timestamp userTs = uRs.getTimestamp("created_at");
						String utime = (userTs != null) ? userTs.toString().substring(0, 16) : "-";
				%>
				<div class="activity-item">
					<div class="activity-icon icon-user">
						<i class="fas fa-user-plus"></i>
					</div>
					<div class="activity-content">
						<h4><%=uname%></h4>
						<div class="item-meta">
							<span class="badge-pill <%=roleClass%>"><%=roleText%></span>
						</div>
					</div>
					<div class="activity-time"><%=utime%></div>
				</div>
				<%
					}
				} catch (SQLException e) {
					e.printStackTrace();
				}
				if (!hasUsers) {
				%>
				<div class="empty-feed">No users found.</div>
				<% } %>
			</div>
		</div>
	</div>
</div>

<script>
function logout() {
	if(confirm('Are you sure you want to logout?')) {
		window.location.href = '<%=request.getContextPath()%>/LogoutServlet';
	}
}
</script>

