<%@page import="com.seh.util.SQLConnection"%>
<%@page import="com.seh.model.User"%>
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

<div class="manage_whatsapp_links-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Class Groups</h1>
			<p>
				Welcome back,
				<%=user.getFullName()%>! Manage WhatsApp group links for class
				announcements.
			</p>
		</div>
		<div class="user-info">
			<div class="user-avatar">
				<%=avatarLetter%>
			</div>
			<div class="user-details">
				<p class="user-role-name"><%=user.getFullName()%></p>
				<p class="user-role-desc"><%=user.getRole()%></p>
			</div>
			<button class="logout-btn" onclick="logout()">
				<i class="fas fa-sign-out-alt"></i> Logout
			</button>
		</div>
	</div>

	<div class="stats-grid" id="whatsappStats">
		<%
		int totalClasses = 0;
		int configuredLinks = 0;
		try {
			Connection conn1 = SQLConnection.getConnection();
			ResultSet rs1 = conn1.prepareStatement("SELECT COUNT(*) AS total FROM classes").executeQuery();
			if (rs1.next())
				totalClasses = rs1.getInt("total");
			rs1.close();
			ResultSet rs2 = conn1.prepareStatement("SELECT COUNT(*) AS total FROM class_whatsapp_group").executeQuery();
			if (rs2.next())
				configuredLinks = rs2.getInt("total");
			rs2.close();
			conn1.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		%>
		<div class="stat-card">
			<div class="stat-number">
				<%=totalClasses%>
			</div>
			<div class="stat-label">Total Classes</div>
		</div>
		<div class="stat-card">
			<div class="stat-number">
				<%=configuredLinks%>
			</div>
			<div class="stat-label">Configured Links</div>
		</div>
	</div>

	<div class="form-container">
		<h2>Add WhatsApp Link</h2>
		<form name="whatsappForm">
			<div class="form-grid">
				<div class="form-group">
					<label>Select Class <span class="required">*</span></label> <select
						name="classId" required>
						<option value="">Choose a class</option>
						<%
						try {
							Connection conn2 = SQLConnection.getConnection();
							String addSql = "SELECT c.class_id, c.class_name, c.section FROM classes c LEFT JOIN class_whatsapp_group w ON c.class_id = w.class_id WHERE w.class_id IS NULL ORDER BY c.class_name, c.section";
							PreparedStatement addStmt = conn2.prepareStatement(addSql);
							ResultSet addRs = addStmt.executeQuery();
							while (addRs.next()) {
								int cid = addRs.getInt("class_id");
								String cname = addRs.getString("class_name");
								String csec = addRs.getString("section");
								String cdisplay = cname + (csec != null ? " - " + csec : "");
						%>
						<option value="<%=cid%>">
							<%=cdisplay%>
						</option>
						<%
						}
						addRs.close();
						addStmt.close();
						conn2.close();
						} catch (SQLException e) {
						e.printStackTrace();
						}
						%>
					</select>
				</div>
				<div class="form-group">
					<label>WhatsApp Group Link <span class="required">*</span></label>
					<input type="url" name="whatsappLink" required
						placeholder="https://chat.whatsapp.com/...">
				</div>
			</div>
			<div id="linkResult" class="u-mt-1"></div>
			<button type="button" class="btn btn-primary"
				onclick="addWhatsAppLink()">
				<i class="fas fa-plus"></i> Add Link
			</button>
		</form>
	</div>

	<div class="filters-container">
		<div class="filters-grid">
			<div class="filter-group">
				<label for="classFilter">Filter by Class</label> <select id="classFilter"
					onchange="loadLinksTable()">
					<option value="all">All Classes</option>
					<%
					try {
						Connection conn3 = SQLConnection.getConnection();
						// Select distinct class names only
						String filterSql = "SELECT DISTINCT c.class_name FROM classes c JOIN class_whatsapp_group w ON c.class_id = w.class_id ORDER BY c.class_name";
						PreparedStatement filterStmt = conn3.prepareStatement(filterSql);
						ResultSet filterRs = filterStmt.executeQuery();
						while (filterRs.next()) {
							String fname = filterRs.getString("class_name");
					%>
					<option value="<%=fname%>">
						<%=fname%>
					</option>
					<%
					}
					filterRs.close();
					filterStmt.close();
					conn3.close();
					} catch (SQLException e) {
					e.printStackTrace();
					}
					%>
				</select>
			</div>
		</div>
	</div>

	<div class="table-container">
		<div class="table-header">
			<h3>Existing Links</h3>
		</div>

		<div class="table-wrapper split-table">
			<table class="table-head-table">
				<colgroup>
					<col class="col-wa-class">
					<col class="col-wa-section">
					<col class="col-wa-link">
					<col class="col-actions-md">
				</colgroup>
				<thead>
					<tr>
						<th>Class Name</th>
						<th>Section</th>
						<th>WhatsApp Link</th>
						<th>Actions</th>
					</tr>
				</thead>
			</table>
			<div class="table-body-scroll">
				<table class="table-body-table">
					<colgroup>
						<col class="col-wa-class">
						<col class="col-wa-section">
						<col class="col-wa-link">
						<col class="col-actions-md">
					</colgroup>
					<tbody id="linksTableBody">
					<%
					try {
						Connection conn4 = SQLConnection.getConnection();
						String tableSql = "SELECT c.class_id, c.class_name, c.section, w.whatsapp_link FROM class_whatsapp_group w JOIN classes c ON w.class_id = c.class_id ORDER BY c.class_name, c.section";
						PreparedStatement tableStmt = conn4.prepareStatement(tableSql);
						ResultSet tableRs = tableStmt.executeQuery();
						boolean hasRows = false;
						while (tableRs.next()) {
							hasRows = true;
							int tid = tableRs.getInt("class_id");
							String tname = tableRs.getString("class_name");
							String tsec = tableRs.getString("section");
							String tlink = tableRs.getString("whatsapp_link");
							String tsecDisplay = tsec != null ? tsec : "-";
							String classDisplayName = tname + ((tsec != null && !tsec.trim().isEmpty()) ? (" - " + tsec) : "");
							String ttruncLink = tlink.length() > 50 ? tlink.substring(0, 50) + "..." : tlink;
					%>
					<tr>
						<td><%=tname%></td>
						<td><%=tsecDisplay%></td>
						<td><a href="<%=tlink%>" target="_blank"
							class="ux-text-sky"> <%=ttruncLink%>
						</a></td>
						<td>
							<button type="button" class="action-btn edit"
								onclick="openEditLinkModal(<%=tid%>, '<%=escapeJsAttr(tname)%>', '<%=escapeJsAttr(tsec != null ? tsec : "")%>', '<%=escapeJsAttr(tlink)%>')">
								<i class="fas fa-edit"></i> Edit
							</button>
							<button type="button" class="action-btn delete"
								onclick="deleteWhatsAppLink(<%=tid%>, '<%=escapeJsAttr(classDisplayName)%>')">
								<i class="fas fa-trash"></i> Delete
							</button>
						</td>
					</tr>
					<%
					}
					if (!hasRows) {
					%>
					<tr>
						<td colspan="4" class="u-text-center">No WhatsApp links
							found.</td>
					</tr>
					<%
					}
					tableRs.close();
					tableStmt.close();
					conn4.close();
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

<!-- Edit Modal -->
<div id="editLinkModal" class="modal-overlay ux-hidden">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Edit WhatsApp Link</h2>
			<button class="modal-close" onclick="closeEditLinkModal()">&times;</button>
		</div>
		<form name="editLinkForm">
			<input type="hidden" name="classId" id="editClassId">
			<div class="form-group">
				<label>Class</label> <input type="text" id="editClassName" disabled
					class="ux-bg-slate-100">
			</div>
			<div class="form-group">
				<label>WhatsApp Group Link <span class="required">*</span></label> <input
					type="url" name="whatsappLink" id="editWhatsAppLink" required>
			</div>
			<div id="editResult" class="ux-result-space"></div>
			<div class="form-actions">
				<button type="button" class="btn btn-secondary"
					onclick="closeEditLinkModal()">Cancel</button>
				<button type="button" class="btn btn-primary"
					onclick="updateWhatsAppLink()">Save Changes</button>
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

