<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="com.seh.util.SQLConnection, com.seh.model.User, java.sql.*"%>

<%
// AUTH CHECK
User user = (User) session.getAttribute("user");
if (user == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

String avatarLetter = "A";
if (user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Academic Planning | SEH</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
:root {
	--primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	--success: #10b981;
	--danger: #ef4444;
	--warning: #f59e0b;
	--bg: #f8fafc;
	--surface: #ffffff;
	--text-primary: #1e293b;
	--text-secondary: #64748b;
	--border-light: #e2e8f0;
	--shadow-sm: 0 1px 2px 0 rgb(0 0 0/ 0.05);
	--shadow: 0 4px 6px -1px rgb(0 0 0/ 0.1);
	--shadow-lg: 0 20px 25px -5px rgb(0 0 0/ 0.1);
}

* {
	box-sizing: border-box;
}

body {
	font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
	background: var(--bg);
	color: var(--text-primary);
	margin: 0;
	line-height: 1.6;
}

.container {
	max-width: 1200px;
	margin: 30px auto;
	padding: 0 20px;
}

.top-bar {
	display: flex;
	justify-content: space-between;
	align-items: center;
	width: 100%;
	margin-bottom: 2rem;
	padding: 1.5rem 2rem;
	background: #fff;
	border-radius: 12px;
	box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.welcome-section h1 {
	font-size: 2rem;
	font-weight: 700;
	color: #1e293b;
	margin-bottom: 0.5rem;
	line-height: 1.2;
}

.welcome-section p {
	color: #64748b;
	font-size: 1rem;
}

.user-info {
	display: flex;
	align-items: center;
	gap: 1rem;
}

.user-avatar {
	width: 50px;
	height: 50px;
	border-radius: 50%;
	background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
	display: flex;
	align-items: center;
	justify-content: center;
	color: #fff;
	font-weight: 600;
	font-size: 1.2rem;
}

.logout-btn {
	background: #ef4444;
	color: #fff;
	border: none;
	padding: 0.75rem 1.5rem;
	border-radius: 8px;
	cursor: pointer;
	transition: all 0.3s;
	font-weight: 500;
}

.logout-btn:hover {
	background: #dc2626;
	transform: translateY(-1px);
}

.card {
	background: var(--surface);
	border-radius: 1rem;
	border: 1px solid var(--border-light);
	box-shadow: var(--shadow);
	margin-bottom: 2rem;
	overflow: hidden;
}

.card-header {
	padding: 1.5rem 2rem;
	border-bottom: 1px solid var(--border-light);
	background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
	font-weight: 700;
	font-size: 1.125rem;
	display: flex;
	align-items: center;
	gap: 0.75rem;
	color: var(--text-primary);
}

.card-body {
	padding: 2rem;
}

.form-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
	gap: 1.5rem;
}

.full {
	grid-column: 1/-1;
}

label {
	display: block;
	margin-bottom: 0.5rem;
	font-weight: 600;
	font-size: 0.875rem;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 0.025em;
}

label.required::after {
	content: '*';
	color: var(--danger);
	margin-left: 0.25rem;
}

.modal-footer button[onclick="saveEdit()"] {
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	color: white;
	border: none;
	padding: 0.75rem 1.5rem;
	border-radius: 0.6rem;
	font-weight: 600;
	cursor: pointer;
	transition: all 0.2s ease;
}

.modal-footer button[onclick="saveEdit()"]:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

.modal-footer button[onclick="saveEdit()"]:active {
	transform: scale(0.97);
}

.input, select, textarea {
	width: 100%;
	padding: 0.875rem 1rem;
	border: 2px solid var(--border-light);
	border-radius: 0.75rem;
	font-size: 1rem;
	background: white;
	transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.input:focus, select:focus, textarea:focus {
	outline: none;
	border-color: #6366f1;
	box-shadow: 0 0 0 3px rgb(99 102 241/ 0.1);
	transform: translateY(-1px);
}

textarea {
	resize: vertical;
	min-height: 120px;
}

.btn {
	padding: 0.875rem 2rem;
	border: none;
	border-radius: 0.75rem;
	cursor: pointer;
	font-weight: 600;
	font-size: 0.95rem;
	transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
	display: inline-flex;
	align-items: center;
	gap: 0.5rem;
	text-decoration: none;
}

.btn:hover {
	transform: translateY(-2px);
	box-shadow: var(--shadow-lg);
}

.btn-primary {
	background: var(--primary);
	color: white;
}

.btn-secondary {
	background: #f1f5f9;
	color: var(--text-primary);
}

table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 1rem;
	background: white;
	border-radius: 0.75rem;
	overflow: hidden;
	box-shadow: var(--shadow);
}

th {
	text-align: left;
	padding: 1rem 1.25rem;
	background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
	font-size: 0.8rem;
	font-weight: 700;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 0.05em;
	border-bottom: 2px solid var(--border-light);
}

td {
	padding: 1.25rem;
	border-bottom: 1px solid var(--border-light);
}

tr:hover {
	background: #f8fafc;
}

.tag {
	background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
	color: #4338ca;
	padding: 0.375rem 0.875rem;
	border-radius: 9999px;
	font-size: 0.75rem;
	font-weight: 600;
}

.desc-col {
	color: var(--text-secondary);
	max-width: 250px;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.action-group {
	display: flex;
	gap: 0.5rem;
	justify-content: center;
}

.action-btn {
	width: 2.5rem;
	height: 2.5rem;
	border-radius: 0.5rem;
	border: none;
	cursor: pointer;
	font-size: 0.875rem;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.2s;
	color: white;
}

.action-btn:hover {
	transform: translateY(-2px) scale(1.05);
	box-shadow: var(--shadow-lg);
}

.btn-view {
	background: #3b82f6;
}

.btn-edit {
	background: #eab308;
}

.btn-delete {
	background: #ef4444;
}

.modal-backdrop {
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.5);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 1000;
	opacity: 0;
	visibility: hidden;
	transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-backdrop.active {
	opacity: 1;
	visibility: visible;
}

.modal-container {
	background: var(--surface);
	border-radius: 1.25rem;
	max-width: 700px;
	width: 90vw;
	max-height: 90vh;
	box-shadow: var(--shadow-lg);
	transform: scale(0.8) translateY(-20px);
	transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	overflow-y: auto; /* allow scrolling */
}

.modal-backdrop.active .modal-container {
	transform: scale(1) translateY(0);
}

.modal-header {
	padding: 1.5rem 1.5rem 1rem;
	border-bottom: 1px solid var(--border-light);
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.modal-title {
	margin: 0;
	font-size: 1.25rem;
	font-weight: 700;
}

.modal-close {
	background: none;
	border: none;
	font-size: 1.5rem;
	cursor: pointer;
	color: var(--text-secondary);
	padding: 0.25rem;
	border-radius: 0.375rem;
	transition: all 0.2s;
}

.modal-close:hover {
	background: #f1f5f9;
	color: var(--text-primary);
}

.modal-body {
	padding: 1.5rem;
}

.modal-footer {
	padding: 1rem 1.5rem 1.5rem;
	border-top: 1px solid var(--border-light);
	display: flex;
	gap: 0.75rem;
	justify-content: flex-end;
}

.toast-container {
	position: fixed;
	top: 1.5rem;
	right: 1.5rem;
	z-index: 2000;
}

.toast {
	padding: 1rem 1.25rem;
	border-radius: 0.75rem;
	color: white;
	font-weight: 500;
	box-shadow: var(--shadow-lg);
	transform: translateX(100%);
	opacity: 0;
	transition: all 0.3s ease;
	margin-bottom: 1rem;
	min-width: 300px;
}

.toast.show {
	transform: translateX(0);
	opacity: 1;
}

.toast.success {
	background: linear-gradient(135deg, var(--success) 0%, #059669 100%);
}

.toast.error {
	background: linear-gradient(135deg, var(--danger) 0%, #dc2626 100%);
}

@media ( max-width : 768px) {
	body {
		font-size: 14px;
	}
	.container {
		padding: 0 12px;
		margin: 20px auto;
	}
	.card-header {
		flex-direction: column;
		align-items: flex-start;
		gap: 6px;
		font-size: 1rem;
		padding: 1rem 1.2rem;
	}
	.card-body {
		padding: 1rem;
	}
	.form-grid {
		grid-template-columns: 1fr;
		gap: 1rem;
	}
	label {
		font-size: 0.8rem;
	}
	.input, select, textarea {
		font-size: 16px;
		padding: 0.75rem;
	}
	textarea {
		min-height: 100px;
	}
	.btn {
		width: 100%;
		justify-content: center;
		padding: 0.75rem 1rem;
	}
	table {
		display: block;
		overflow-x: auto;
		white-space: nowrap;
		font-size: 0.85rem;
	}
	th, td {
		padding: 0.7rem;
	}
	.desc-col {
		max-width: 160px;
	}
	.tag {
		font-size: 0.7rem;
		padding: 0.25rem 0.6rem;
	}
	.action-group {
		flex-wrap: wrap;
		gap: 5px;
	}
	.action-btn {
		width: 2rem;
		height: 2rem;
		font-size: 0.8rem;
	}
	.modal-container {
		width: 95vw;
		max-height: 85vh;
		border-radius: 0.8rem;
	}
	.modal-header {
		padding: 1rem;
	}
	.modal-body {
		padding: 1rem;
	}
	.modal-footer {
		padding: 0.8rem 1rem 1rem;
		flex-direction: column;
	}
	.modal-footer button {
		width: 100%;
	}
	.toast {
		min-width: 220px;
		font-size: 0.85rem;
	}
}

@media ( max-width : 768px) {
	body {
		padding: 12px;
	}
	.top-bar {
		flex-direction: column;
		text-align: center;
		padding: 16px;
		gap: 14px;
		border-radius: var(--radius-lg);
		margin-bottom: 16px;
	}
	.welcome-section {
		min-width: 100%;
	}
	.welcome-section h1 {
		font-size: 1.35rem;
	}
	.user-info {
		width: 100%;
		justify-content: center;
		flex-wrap: wrap;
	}
	.user-details {
		text-align: center;
	}
	.logout-btn {
		width: 100%;
		justify-content: center;
	}
	.header {
		flex-direction: column;
		text-align: center;
		padding: 18px;
		border-radius: var(--radius-md);
		margin-bottom: 18px;
	}
	.header-icon {
		margin-right: 0;
		margin-bottom: 12px;
		width: 50px;
		height: 50px;
		font-size: 1.25rem;
	}
}
@media (max-width: 768px) {

.container{
    width:100%;
    max-width:100%;
    padding:0 10px;
    margin:15px auto;
}

.card{
    width:100%;
    margin:0;
}

.card-body{
    width:100%;
}

form{
    width:100%;
}

.input,
select,
textarea{
    width:100%;
}

.btn{
    width:100%;
}

}
</style>
</head>
<body>
	<!-- TOAST CONTAINER -->
	<div class="toast-container" id="toastContainer"></div>

	<div class="top-bar">
		<div class="welcome-section">
			<h1>📚 Academic Planning</h1>
			<p>
				Welcome back, <strong><%=user.getUsername()%></strong>! Log &
				manage your teaching activities.
			</p>
		</div>
		<div class="user-info">
			<div class="user-avatar"><%=avatarLetter%></div>
			<div style="text-align: right;">
				<div style="font-weight: 600; font-size: 0.95rem;"><%=user.getUsername()%></div>
				<div
					style="font-size: 0.8rem; color: var(--text-secondary); text-transform: capitalize;"><%=user.getRole()%></div>
			</div>
			<a href="<%=request.getContextPath()%>/LogoutServlet"
				style="text-decoration: none;">
				<button class="logout-btn">
					<i class="fas fa-sign-out-alt"></i> Logout
				</button>
			</a>
		</div>
	</div>

	<div class="container">
		<!-- SUCCESS MESSAGE -->
		<%
		String successMsg = (String) session.getAttribute("successMessage");
		if (successMsg != null) {
		%>
		<div class="alert alert-success">
			<i class="fas fa-check-circle"></i>
			<%=successMsg%>
		</div>
		<%
		session.removeAttribute("successMessage");
		%>
		<%
		}
		%>

		<!-- ADD TASK CARD -->
		<div class="card">
			<div class="card-header">
				<i class="fas fa-plus-circle"></i> Add New Teaching Task
			</div>
			<div class="card-body">
				<form action="<%=request.getContextPath()%>/addTask" method="POST">
					<div class="form-grid">
						<div>
							<label>Date</label> <input type="date" name="taskDate"
								id="taskDate" class="input" required>
						</div>
						<div>
							<label>Class</label> <select name="classId" class="input"
								required>
								<option value="">Select Class</option>
								<%
								try (Connection conn = SQLConnection.getConnection();
										PreparedStatement ps = conn
										.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name ASC");
										ResultSet rs = ps.executeQuery()) {
									while (rs.next()) {
								%>
								<option value="<%=rs.getInt("class_id")%>">
									<%=rs.getString("class_name")%> -
									<%=rs.getString("section")%>
								</option>
								<%
								}
								} catch (Exception e) {
								out.print("Error loading classes");
								}
								%>
							</select>
						</div>
						<div>
							<label>Subject</label> <select name="subjectId" class="input"
								required>
								<option value="">Select Subject</option>
								<%
								try (Connection conn = SQLConnection.getConnection();
										PreparedStatement ps = conn
										.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name ASC");
										ResultSet rs = ps.executeQuery()) {
									while (rs.next()) {
								%>
								<option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
								<%
								}
								} catch (Exception e) {
								out.print("Error loading subjects");
								}
								%>
							</select>
						</div>
						<div>
							<label>Duration (minutes)</label> <input type="number"
								name="duration" class="input" min="5" max="480" placeholder="45">
						</div>
						<div class="full">
							<label>Topic</label> <input type="text" name="topic"
								class="input" required placeholder="Today's lesson topic">
						</div>
						<div class="full">
							<label>Description</label>
							<textarea name="description" class="input" rows="4"
								placeholder="What was taught? Homework? Key points?"></textarea>
						</div>
					</div>
					<div style="margin-top: 1.5rem;">
						<button type="submit" class="btn btn-primary">
							<i class="fas fa-save"></i> Save Task
						</button>
					</div>
				</form>
			</div>
		</div>

		<!-- TASKS TABLE CARD -->
		<div class="card">
			<div class="card-header">
				<i class="fas fa-list"></i> Recent Tasks
				<%
				int taskCount = 0;
				try (Connection conn = SQLConnection.getConnection();
						PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM teacher_tasks WHERE teacher_id = ?")) {
					stmt.setInt(1, user.getUserId());
					ResultSet rsCount = stmt.executeQuery();
					if (rsCount.next())
						taskCount = rsCount.getInt(1);
				} catch (Exception e) {
					taskCount = 0;
				}
				%>
				<span
					style="font-size: 0.8rem; color: var(--text-secondary); margin-left: auto;">
					Showing <%=Math.min(taskCount, 10)%> of <%=taskCount%> activity<%=taskCount != 1 ? "s" : ""%>
				</span>
			</div>
			<div class="card-body">
				<table>
					<thead>
						<tr>
							<th>Date</th>
							<th>Class</th>
							<th>Subject</th>
							<th>Topic</th>
							<th>Duration</th>
							<th>Description</th>
							<th style="text-align: center;">Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
						String sql = "SELECT t.*, c.class_name, c.section, s.subject_name " + "FROM teacher_tasks t "
								+ "JOIN classes c ON t.class_id = c.class_id " + "JOIN subjects s ON t.subject_id = s.subject_id "
								+ "WHERE t.teacher_id = ? " + "ORDER BY t.task_date DESC, t.task_id DESC LIMIT 10";

						try (Connection conn = SQLConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

							// Ensure teacher_id is valid
							int tId = (user.getUserId() != 0 ? user.getUserId() : 35);
							stmt.setInt(1, tId);
							ResultSet rs = stmt.executeQuery();

							// Use a flag to track if we found any rows
							boolean found = false;

							while (rs.next()) {
								found = true;
								int taskId = rs.getInt("task_id");
								String taskDate = rs.getString("task_date");
								String className = rs.getString("class_name") + " - " + rs.getString("section");
								String subject = rs.getString("subject_name");
								String topic = rs.getString("topic");
								String duration = rs.getString("duration");
								String desc = rs.getString("description");
								String shortDesc = (desc != null && desc.length() > 40)
								? desc.substring(0, 40) + "..."
								: (desc != null ? desc : "-");
						%>
						<tr>
							<td style="font-weight: 600; color: #6366f1;"><%=taskDate%></td>
							<td><span class="tag"><%=className%></span></td>
							<td style="font-weight: 500; color: var(--text-primary);"><%=subject%></td>
							<td><strong><%=topic%></strong></td>
							<td style="color: var(--text-secondary);"><%=duration != null ? duration + "m" : "-"%></td>
							<td class="desc-col" title="<%=desc != null ? desc : ""%>"><%=shortDesc%></td>
							<td style="text-align: center;">
								<div class="action-group">
									<button class="action-btn btn-view"
										onclick="viewTask(<%=taskId%>)">
										<i class="fas fa-eye"></i>
									</button>
									<button class="action-btn btn-edit"
										onclick="editTask(
'<%=taskId%>',
'<%=taskDate%>',
'<%=rs.getInt("class_id")%>',
'<%=rs.getInt("subject_id")%>',
'<%=topic.replace("'", "\\'")%>',
`<%=desc != null ? desc.replace("`", "'") : ""%>`,
'<%=duration != null ? duration : ""%>'
)">
										<i class="fas fa-edit"></i>
									</button>
									<button class="action-btn btn-delete"
										onclick="deleteTask(<%=taskId%>)">
										<i class="fas fa-trash"></i>
									</button>
								</div>
							</td>
						</tr>
						<%
						}

						if (!found) {
						%>
						<tr>
							<td colspan="7"
								style="text-align: center; padding: 2rem; color: var(--text-secondary);">
								No tasks found for your account.</td>
						</tr>
						<%
						}
						} catch (Exception e) {
						e.printStackTrace(); // Log the error to the server console
						%>
						<tr>
							<td colspan="7"
								style="text-align: center; padding: 2rem; color: var(--danger);">
								<i class="fas fa-exclamation-triangle"></i> Error loading tasks:
								<%=e.getMessage()%>
							</td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>
		</div>
	</div>

	<!-- VIEW MODAL -->
	<div id="viewModal" class="modal-backdrop" onclick="closeModal(this)">
		<div class="modal-container" onclick="event.stopPropagation()">
			<div class="modal-header">
				<h3 class="modal-title" id="viewTitle">Task Details</h3>
				<button class="modal-close" onclick="closeModal('viewModal')">
					<i class="fas fa-times"></i>
				</button>
			</div>
			<div class="modal-body" id="viewBody">
				<!-- Content loaded dynamically -->
			</div>
			<div class="modal-footer">
				<button class="btn btn-primary" onclick="closeModal('viewModal')">
					<i class="fas fa-check"></i> Done
				</button>
			</div>
		</div>
	</div>

	<!-- EDIT MODAL -->
	<div id="editModal" class="modal-backdrop" onclick="closeModal(this)">
		<div class="modal-container" onclick="event.stopPropagation()">
			<div class="modal-header">
				<h3 class="modal-title">Edit Task</h3>
				<button class="modal-close" onclick="closeModal('editModal')">
					<i class="fas fa-times"></i>
				</button>
			</div>
			<div class="modal-body">
				<form id="editForm" method="post">
					<input type="hidden" id="editId" name="taskId">
					<div class="form-grid">
						<div>
							<label>Date</label> <input type="date" id="editDate"
								name="taskDate" class="input" required>
						</div>
						<div>
							<label>Class</label> <select id="editClass" name="classId"
								class="input" required>
								<option value="">Select Class</option>
								<%
								try (Connection conn = SQLConnection.getConnection();
										PreparedStatement ps = conn
										.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name ASC");
										ResultSet rs = ps.executeQuery()) {
									while (rs.next()) {
								%>
								<option value="<%=rs.getInt("class_id")%>">
									<%=rs.getString("class_name")%> -
									<%=rs.getString("section")%>
								</option>
								<%
								}
								} catch (Exception e) {
								%>
								<option value="">Classes not available</option>
								<%
								}
								%>
							</select>
						</div>
						<div>
							<label>Subject</label> <select id="editSubject" name="subjectId"
								class="input" required>
								<option value="">Select Subject</option>
								<%
								try (Connection conn = SQLConnection.getConnection();
										PreparedStatement ps = conn
										.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name ASC");
										ResultSet rs = ps.executeQuery()) {
									while (rs.next()) {
								%>
								<option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
								<%
								}
								} catch (Exception e) {
								%>
								<option value="">Subjects not available</option>
								<%
								}
								%>
							</select>
						</div>
						<div>
							<label>Duration</label> <input type="number" id="editDuration"
								name="duration" class="input">
						</div>
						<div class="full">
							<label>Topic</label> <input type="text" id="editTopic"
								name="topic" class="input" required>
						</div>
						<div class="full">
							<label>Description *</label>
							<textarea id="editDesc" name="description" class="input" rows="4"
								style="min-height: 120px"></textarea>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn" onclick="closeModal('editModal')"
					style="background: #f3f4f6; color: var(--text-primary);">
					Cancel</button>
				<button type="button" onclick="saveEdit()">Update Task</button>
			</div>
		</div>
	</div>

	<!-- DELETE CONFIRM MODAL -->
	<div id="deleteModal" class="modal-backdrop" onclick="closeModal(this)">
		<div class="modal-container" onclick="event.stopPropagation()">
			<div class="modal-header">
				<h3 class="modal-title" style="color: var(--danger);">
					<i class="fas fa-exclamation-triangle"></i> Confirm Delete
				</h3>
				<button class="modal-close" onclick="closeModal('deleteModal')">
					<i class="fas fa-times"></i>
				</button>
			</div>
			<div class="modal-body">
				<p style="font-size: 1.1rem; margin-bottom: 1rem;">Delete this
					task permanently?</p>
				<div
					style="background: #fef3c7; padding: 1rem; border-radius: 0.5rem; border-left: 4px solid var(--warning);">
					<strong id="deleteTopicPreview"></strong>
				</div>
				<input type="hidden" id="deleteId">
			</div>
			<div class="modal-footer">
				<button type="button" class="btn"
					onclick="closeModal('deleteModal')"
					style="background: #f3f4f6; color: var(--text-primary);">
					Cancel</button>
				<button type="button" class="btn btn-danger"
					onclick="confirmDelete()">
					<i class="fas fa-trash"></i> Yes, Delete
				</button>
			</div>
		</div>
	</div>

	<script>
        // Init date
        document.getElementById('taskDate').valueAsDate = new Date();

        // Modal functions
        function closeModal(modal) {
    if (typeof modal === "string") {
        modal = document.getElementById(modal);
    }
    modal.classList.remove("active");
}

        function showModal(modalId) {
            document.getElementById(modalId).classList.add('active');
        }

        // VIEW TASK
        function viewTask(taskId) {
    fetch('<%=request.getContextPath()%>/getTask?id=' + taskId)
        .then(res => res.text())
        .then(html => {
            document.getElementById("viewTitle").innerText = "Task Details";
            document.getElementById("viewBody").innerHTML = html;
            showModal("viewModal");
        })
        .catch(err => {
            console.error(err);
            alert("Error loading task");
        });
}

        // EDIT TASK  
        function editTask(id,date,classId,subjectId,topic,desc,duration){

document.getElementById("editId").value = id
document.getElementById("editDate").value = date
document.getElementById("editClass").value = classId
document.getElementById("editSubject").value = subjectId
document.getElementById("editTopic").value = topic
document.getElementById("editDesc").value = desc || ""
document.getElementById("editDuration").value = duration || ""

showModal("editModal")

}


        // DELETE TASK
        function deleteTask(taskId) {
            document.getElementById('deleteId').value = taskId;
            document.getElementById('deleteTopicPreview').textContent = 'Task #' + taskId + ' details';
            showModal('deleteModal');
        }

        function saveEdit(){

            const form = document.getElementById("editForm");

            fetch('<%=request.getContextPath()%>/updateTask', {
                method:'POST',
                body:new FormData(form)
            })
            .then(res=>{
                if(res.ok){
                    alert("Task Updated Successfully");
                    location.reload();
                }else{
                    alert("Update Failed");
                }
            });

        }

        function confirmDelete() {
            const taskId = document.getElementById('deleteId').value;
            fetch('<%=request.getContextPath()%>/deleteTask?id=' + taskId, {method: 'POST'})
            .then(() => {
                showToast('Task deleted successfully!');
                closeModal(document.getElementById('deleteModal'));
                location.reload();
            }).catch(() => showToast('Delete failed', 'error'));
        }

        function showToast(message, type = 'success') {
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.textContent = message;
            document.getElementById('toastContainer').appendChild(toast);
            
            setTimeout(() => toast.classList.add('show'), 100);
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => toast.remove(), 300);
            }, 3000);
        }
    </script>
</body>
</html>