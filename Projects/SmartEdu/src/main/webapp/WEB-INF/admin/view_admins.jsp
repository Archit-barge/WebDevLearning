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

<%
Integer currentUserId = null;
if (user != null) {
	currentUserId = user.getUserId();
}
%>

<script>
  const ctx = '<%=request.getContextPath()%>';
</script>

<div class="view_admins-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Admins Management</h1>
			<p>Manage and view all admin accounts.</p>
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

	<div class="stats-grid" id="adminStats">
		<%
		int totalAdmins = 0;
		try (Connection conn = SQLConnection.getConnection()) {
			ResultSet rs = conn.prepareStatement("SELECT COUNT(*) AS total FROM admins").executeQuery();
			if (rs.next())
				totalAdmins = rs.getInt("total");
			rs.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		%>
		<div class="stat-card">
			<div class="stat-number"><%=totalAdmins%></div>
			<div class="stat-label">Total Admins</div>
		</div>
	</div>

	<div class="filters-container">
		<form method="get" onsubmit="return false;">
			<div class="filters-grid">
				<div class="filter-group">
					<label for="adminSearch">Search Admins</label> <input type="text"
						id="adminSearch" name="adminSearch"
						placeholder="Search by name, username, or email..." onkeyup="loadAdminsTable()">
				</div>

				<div class="remove-filter-wrapper ux-mb-4">
					<button type="button" id="clearAdminsFilterBtn" class="btn btn-secondary remove-filter-btn ux-hidden" onclick="document.getElementById('adminSearch').value=''; loadAdminsTable(); this.style.display='none';" title="Clear Filters">
						X Filter
					</button>
				</div>
			</div>
		</form>
	</div>

	<div class="table-container">
		<div class="table-header">
			<h3>Admins List</h3>
			<%
			int adminCount = 0;
			try (Connection conn = SQLConnection.getConnection()) {
				PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) AS total FROM admins");
				ResultSet countRs = countStmt.executeQuery();
				if (countRs.next())
					adminCount = countRs.getInt("total");
				countRs.close();
				countStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			%>
			<span><%=adminCount%> admins found</span>
		</div>

		<div class="table-wrapper admin-list-scroll split-table">
			<table class="admin-list-table table-head-table">
				<colgroup>
					<col class="col-admin-user">
					<col class="col-admin-name">
					<col class="col-admin-email">
					<col class="col-admin-phone">
					<col class="col-actions-lg">
				</colgroup>
				<thead>
					<tr>
						<th>Username</th>
						<th>Full Name</th>
						<th>Email</th>
						<th>Phone</th>
						<th>Actions</th>
					</tr>
				</thead>
			</table>
			<div class="table-body-scroll">
				<table class="admin-list-table table-body-table">
					<colgroup>
						<col class="col-admin-user">
						<col class="col-admin-name">
						<col class="col-admin-email">
						<col class="col-admin-phone">
						<col class="col-actions-lg">
					</colgroup>
					<tbody id="adminsTableBody">
					<%
					try (Connection conn = SQLConnection.getConnection()) {

						String sql = "SELECT a.admin_id, u.user_id, u.username, a.first_name, a.last_name, "
						+ "u.email, a.phone, a.address, u.password " + "FROM admins a JOIN users u ON a.user_id = u.user_id "
						+ "ORDER BY LOWER(a.first_name), LOWER(a.last_name), LOWER(u.username) ASC";

						PreparedStatement stmt = conn.prepareStatement(sql);
						ResultSet rs = stmt.executeQuery();

						while (rs.next()) {
							int adminId = rs.getInt("admin_id");
							int userId = rs.getInt("user_id");
							String username = rs.getString("username");
							String firstName = rs.getString("first_name");
							String lastName = rs.getString("last_name");
							String fullName = firstName + " " + lastName;
							String email = rs.getString("email");
							String phone = rs.getString("phone") != null ? rs.getString("phone") : "-";
							String address = rs.getString("address") != null ? rs.getString("address") : "-";
							String password = rs.getString("password") != null ? rs.getString("password") : "";

							boolean isCurrent = (currentUserId != null && currentUserId == userId);
					%>

					<tr>
						<td><%=username%></td>
						<td>
							<div class="admin-info">
								<div class="admin-avatar"><%=firstName.substring(0, 1).toUpperCase()%></div>
								<div class="admin-details">
									<h6>
										<%=fullName%>
										<%
										if (isCurrent) {
										%>
										<span class="self-badge-inline">You</span>
										<%
										}
										%>
									</h6>
									<p class="self-text">
										<%
										if (isCurrent) {
										%>Currently logged in<%
										}
										%>
									</p>
								</div>
							</div>
						</td>

						<td><%=email%></td>
						<td><%=phone%></td>

						<td>
							<div class="admin-actions-row">
							<button type="button" class="action-btn edit"
								onclick="openEditAdminModal(
                    <%=adminId%>,
                    '<%=escapeJsAttr(fullName)%>',
                    '<%=escapeJsAttr(username)%>',
                    '<%=escapeJsAttr(email)%>',
                    '<%=escapeJsAttr(phone)%>',
                    '<%=escapeJsAttr(password)%>',
                    '<%=escapeJsAttr(address)%>')">
								<i class="fas fa-edit"></i> Edit
							</button>

							<button type="button" class="action-btn view"
								onclick="openViewAdminModal(
                    '<%=escapeJsAttr(fullName)%>',
                    '<%=escapeJsAttr(username)%>',
                    '<%=escapeJsAttr(email)%>',
                    '<%=escapeJsAttr(phone)%>',
                    '<%=escapeJsAttr(password)%>',
                    '<%=escapeJsAttr(address)%>')">
								<i class="fas fa-eye"></i> View
							</button>
							<%
							if (!isCurrent) {
							%>
							<button type="button" class="action-btn delete"
								onclick="openDeleteAdminModal(<%=adminId%>, '<%=escapeJsAttr(fullName)%>')">
								<i class="fas fa-trash"></i> Delete
							</button>
							<%
							}
							%>
							</div>
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
</div>

<div id="editAdminModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Edit Admin</h2>
			<button class="modal-close" onclick="closeEditAdminModal()">×</button>
		</div>

		<form name="editAdminForm">
			<input type="hidden" id="editAdminId">

			<h3 class="ux-modal-section-title">Account
				Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label>Username <span class="required">*</span></label> <input
						type="text" id="editAdminUsername" required>
				</div>

				<div class="form-group">
					<label>Password <span class="required">*</span></label> <input
						type="text" id="editAdminPassword" required>
				</div>

				<div class="form-group">
					<label>Email Address <span class="required">*</span></label> <input
						type="email" id="editAdminEmail" required>
				</div>
			</div>

			<h3 class="ux-modal-section-title-spaced">Personal
				Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label>First Name <span class="required">*</span></label> <input
						type="text" id="editAdminFirstName" required>
				</div>

				<div class="form-group">
					<label>Last Name <span class="required">*</span></label> <input
						type="text" id="editAdminLastName" required>
				</div>

				<div class="form-group">
					<label>Phone Number</label> <input type="tel" id="editAdminPhone">
				</div>

				<div class="form-group">
					<label>Address</label> <textarea id="editAdminAddress"></textarea>
				</div>
			</div>

			<div id="editAdminResult" class="ux-result-space"></div>

			<div class="form-actions">
				<button type="button" class="btn btn-secondary"
					onclick="closeEditAdminModal()">Cancel</button>
				<button type="button" class="btn btn-primary"
					onclick="updateAdmin()">Save Changes</button>
			</div>
		</form>
	</div>
</div>

<div id="viewAdminDetailsModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Admin Details</h2>
			<button class="modal-close" onclick="closeViewAdminModal()">×</button>
		</div>

		<div class="details-content">
			<div class="detail-section">
				<h3 class="ux-modal-section-title">Account
					Information</h3>
				<div class="detail-grid">
					<div class="detail-item">
						<label>Username</label>
						<p id="detailAdminUsername"></p>
					</div>
					<div class="detail-item">
						<label>Password</label>
						<p id="detailAdminPassword"></p>
					</div>
					<div class="detail-item">
						<label>Email</label>
						<p id="detailAdminEmail"></p>
					</div>
				</div>
			</div>

			<div class="detail-section">
				<h3 class="ux-modal-section-title">Personal
					Information</h3>
				<div class="detail-grid">
					<div class="detail-item">
						<label>Full Name</label>
						<p id="detailAdminFullName"></p>
					</div>
					<div class="detail-item">
						<label>Phone Number</label>
						<p id="detailAdminPhone"></p>
					</div>
					<div class="detail-item">
						<label>Address</label>
						<p id="detailAdminAddress"></p>
					</div>
				</div>
			</div>
		</div>

		<div class="form-actions">
			<button type="button" class="btn btn-secondary"
				onclick="closeViewAdminModal()">Close</button>
		</div>
	</div>
</div>

<div id="deleteAdminModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Delete Admin</h2>
			<button class="modal-close" onclick="closeDeleteAdminModal()">×</button>
		</div>
		<div class="details-content">
			<p>
				Are you sure you want to delete admin <strong id="deleteAdminName"></strong>?
			</p>
		</div>
		<div class="form-actions">
			<button type="button" class="btn btn-secondary"
				onclick="closeDeleteAdminModal()">Cancel</button>
			<button type="button" class="btn btn-primary"
				onclick="confirmDeleteAdmin()">Delete</button>
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

