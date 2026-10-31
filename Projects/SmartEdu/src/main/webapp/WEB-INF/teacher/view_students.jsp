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
if (user == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}
%>

<style>
/* CSS Variables */
:root {
	--primary: #667eea;
	--primary-light: #818cf8;
	--primary-dark: #5a67d8;
	--success: #10b981;
	--danger: #ef4444;
	--secondary: #64748b;
	--text-dark: #1e293b;
	--text-muted: #64748b;
	--bg-light: #f8fafc;
	--white: #ffffff;
	--shadow-sm: 0 2px 10px rgba(0, 0, 0, 0.05);
	--shadow-md: 0 4px 20px rgba(0, 0, 0, 0.08);
	--radius-sm: 8px;
	--radius-md: 12px;
	--radius-lg: 16px;
	--radius-xl: 20px;
	--transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	--touch-target: 48px;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	-webkit-tap-highlight-color: transparent;
}

html {
	-webkit-text-size-adjust: 100%;
}

.view-students-content {
	font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI',
		Roboto, sans-serif;
	background: var(--bg-light);
	color: var(--text-dark);
	line-height: 1.5;
	-webkit-font-smoothing: antialiased;
}

/* Top Bar */
.top-bar {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 2rem;
	padding: 1.5rem 2rem;
	background: var(--white);
	border-radius: var(--radius-md);
	box-shadow: var(--shadow-sm);
	flex-wrap: wrap;
	gap: 16px;
}

.welcome-section {
	flex: 1;
	min-width: 200px;
}

.welcome-section h1 {
	font-size: clamp(1.25rem, 4vw, 1.75rem);
	font-weight: 700;
	color: var(--text-dark);
	margin-bottom: 4px;
}

.welcome-section p {
	color: var(--text-muted);
	font-size: clamp(0.8rem, 2.5vw, 1rem);
	font-weight: 500;
}

.user-info { display: flex; align-items: center; gap: 1rem; }
        .user-avatar {
            width: 50px; height: 50px; border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-weight: 600; font-size: 1.2rem;
        }

.user-details {
	text-align: right;
}

.user-details .name {
	font-weight: 600;
	color: var(--text-dark);
	font-size: 0.95rem;
}

.user-details .role {
	font-size: 0.85rem;
	color: var(--text-muted);
}

.logout-btn {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 10px 16px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
            white-space: nowrap;
        }

.logout-btn:hover { background: #dc2626; transform: translateY(-1px); }

/* Stats Grid */
.stats-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
	gap: 16px;
	margin-bottom: 24px;
}

.stat-card {
	background: var(--white);
	padding: 20px;
	border-radius: var(--radius-lg);
	box-shadow: var(--shadow-sm);
	text-align: center;
	transition: var(--transition);
}

.stat-card:hover {
	transform: translateY(-3px);
	box-shadow: var(--shadow-md);
}

.stat-number {
	font-size: clamp(1.5rem, 5vw, 2.5rem);
	font-weight: 900;
	background: linear-gradient(135deg, var(--primary) 0%,
		var(--primary-dark) 100%);
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
	margin-bottom: 4px;
}

.stat-label {
	color: var(--text-muted);
	font-size: 0.85rem;
	font-weight: 600;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

/* Filters Container */
.filters-container {
	background: var(--white);
	padding: 2rem;
	border-radius: var(--radius-lg);
	box-shadow: var(--shadow-md);
	margin-bottom: 2rem;
}

.filters-container h2 {
	font-size: 1.25rem;
	color: var(--text-dark);
	margin-bottom: 20px;
	display: flex;
	align-items: center;
	gap: 10px;
}

.filters-container h2 i {
	color: var(--primary);
}

.filters-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
	gap: 16px;
	align-items: end;
}

.filter-group {
	display: flex;
	flex-direction: column;
}

.filter-group label {
	font-weight: 600;
	color: var(--text-muted);
	font-size: 0.875rem;
	margin-bottom: 8px;
}

.filter-group input, .filter-group select {
	padding: 14px 16px;
	border: 2px solid #e2e8f0;
	border-radius: var(--radius-sm);
	font-size: 1rem;
	color: var(--text-dark);
	background: #f8fafc;
	transition: var(--transition);
	min-height: var(--touch-target);
	cursor: pointer;
}

.filter-group input:focus, .filter-group select:focus {
	outline: none;
	border-color: var(--primary);
	background: var(--white);
	box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
}

.btn {
	padding: 14px 24px;
	border-radius: var(--radius-sm);
	font-weight: 600;
	font-size: 0.95rem;
	cursor: pointer;
	transition: var(--transition);
	min-height: var(--touch-target);
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 8px;
	border: none;
	text-decoration: none;
	white-space: nowrap;
}

.btn-primary {
	background: linear-gradient(135deg, var(--primary) 0%,
		var(--primary-dark) 100%);
	color: white;
	box-shadow: var(--shadow-sm);
}

.btn-primary:hover {
	transform: translateY(-2px);
	box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

/* Table Container */
.table-container {
	background: var(--white);
	border-radius: var(--radius-lg);
	overflow: hidden;
	box-shadow: var(--shadow-md);
}

.table-header {
	padding: 20px 24px;
	border-bottom: 1px solid #e2e8f0;
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 12px;
}

.table-header h3 {
	font-size: 1.125rem;
	color: var(--text-dark);
}

.table-count {
	color: var(--text-muted);
	font-size: 0.9rem;
	font-weight: 500;
}

.table-wrapper {
	overflow-x: auto;
	-webkit-overflow-scrolling: touch;
}

table {
	width: 100%;
	border-collapse: collapse;
	min-width: 700px;
}

th {
	background: #f8fafc;
	padding: 16px 20px;
	text-align: left;
	font-weight: 600;
	color: var(--text-muted);
	font-size: 0.8rem;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	border-bottom: 2px solid #e2e8f0;
	white-space: nowrap;
}

td {
	padding: 16px 20px;
	border-bottom: 1px solid #f1f5f9;
	color: var(--text-dark);
	font-size: 0.95rem;
}

tr:hover {
	background: #f8fafc;
}

tr:last-child td {
	border-bottom: none;
}

.student-info {
	display: flex;
	align-items: center;
	gap: 12px;
}

.student-avatar {
	width: 42px;
	height: 42px;
	border-radius: 12px;
	background: linear-gradient(135deg, var(--primary) 0%,
		var(--primary-dark) 100%);
	display: flex;
	align-items: center;
	justify-content: center;
	color: white;
	font-weight: 600;
	font-size: 0.95rem;
	flex-shrink: 0;
}

.student-details h6 {
	font-weight: 600;
	color: var(--text-dark);
	font-size: 0.95rem;
	margin-bottom: 2px;
}

.empty-state {
	text-align: center;
	padding: 60px 20px;
	color: var(--text-muted);
}

.empty-state i {
	font-size: 3rem;
	margin-bottom: 12px;
	opacity: 0.5;
}

/* Tablet */
@media ( max-width : 1024px) {
	.stats-grid {
		grid-template-columns: repeat(2, 1fr);
	}
	.filters-grid {
		grid-template-columns: repeat(2, 1fr);
	}
}

/* Mobile */
@media ( max-width : 768px) {
	.view-students-content {
		padding: 10px;
	}
	.top-bar {
		padding: 16px;
		border-radius: var(--radius-lg);
		margin-bottom: 16px;
		gap: 12px;
	}
	.welcome-section {
		min-width: 100%;
		text-align: center;
	}
	.welcome-section h1 {
		font-size: 1.25rem;
	}
	.user-info {
		width: 100%;
		justify-content: center;
	}
	.user-details {
		display: none;
	}
	.logout-btn { width: 100%; justify-content: center; }
	.stats-grid {
		grid-template-columns: repeat(2, 1fr);
		gap: 12px;
		margin-bottom: 16px;
	}
	.stat-card {
		padding: 16px;
		border-radius: var(--radius-md);
	}
	.stat-number {
		font-size: 1.5rem;
	}
	.stat-label {
		font-size: 0.75rem;
	}
	.filters-container {
		padding: 16px;
		margin-bottom: 16px;
		border-radius: var(--radius-md);
	}
	.filters-container h2 {
		font-size: 1rem;
		margin-bottom: 16px;
	}
	.filters-grid {
		grid-template-columns: 1fr;
		gap: 12px;
	}
	.filter-group {
		width: 100%;
	}
	.filter-group input, .filter-group select {
		width: 100%;
		font-size: 0.95rem;
		padding: 12px 14px;
	}
	.btn {
		width: 100%;
	}
	.table-container {
		margin-bottom: 16px;
		border-radius: var(--radius-md);
	}
	.table-header {
		padding: 14px 16px;
	}
	.table-header h3 {
		font-size: 1rem;
	}
	th, td {
		padding: 12px 14px;
		font-size: 0.85rem;
	}
	.student-avatar {
		width: 36px;
		height: 36px;
		font-size: 0.8rem;
	}
	.student-details h6 {
		font-size: 0.85rem;
	}
}

/* Small Mobile */
@media ( max-width : 480px) {
	.view-students-content {
		padding: 8px;
	}
	.top-bar {
		padding: 14px;
		border-radius: var(--radius-md);
		margin-bottom: 12px;
		gap: 10px;
	}
	.welcome-section h1 {
		font-size: 1.125rem;
	}
	.welcome-section p {
		font-size: 0.8rem;
	}
	.stats-grid {
		gap: 10px;
		margin-bottom: 12px;
	}
	.stat-card {
		padding: 14px;
	}
	.stat-number {
		font-size: 1.25rem;
	}
	.filters-container {
		padding: 14px;
		margin-bottom: 12px;
	}
	.filters-container h2 {
		font-size: 0.95rem;
	}
	.table-container {
		margin-bottom: 12px;
	}
	.table-header {
		padding: 12px 14px;
	}
	th, td {
		padding: 10px 12px;
		font-size: 0.8rem;
	}
	.student-avatar {
		width: 32px;
		height: 32px;
		border-radius: 8px;
		font-size: 0.75rem;
	}
}

/* Large Desktop */
@media ( min-width : 1200px) {
	.container {
		padding: 0 32px;
	}
	.welcome-section h1 {
		font-size: 2rem;
	}
	.stats-grid {
		gap: 24px;
		margin-bottom: 2rem;
	}
	.stat-card {
		padding: 28px;
		border-radius: 20px;
	}
	.stat-number {
		font-size: 2.5rem;
	}
	.filters-grid {
		gap: 20px;
	}
	.table-container {
		border-radius: 20px;
		margin-bottom: 2rem;
	}
	.table-header {
		padding: 24px 28px;
	}
	th {
		padding: 20px 24px;
		font-size: 0.85rem;
	}
	td {
		padding: 20px 24px;
		font-size: 1rem;
	}
	.student-avatar {
		width: 48px;
		height: 48px;
		font-size: 1.1rem;
	}
}

/* Animations */
@
keyframes fadeIn {from { opacity:0;
	transform: translateY(20px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.top-bar, .stats-grid .stat-card, .filters-container, .table-container {
	animation: fadeIn 0.5s ease-out;
}

.stats-grid .stat-card:nth-child(1) {
	animation-delay: 0.05s;
}

.stats-grid .stat-card:nth-child(2) {
	animation-delay: 0.1s;
}

/* Touch feedback */
@media ( hover : none) {
	.stat-card:hover {
		transform: none;
	}
	.logout-btn:hover {
		transform: none;
	}
	.btn-primary:hover {
		transform: none;
	}
}
</style>

<div class="view-students-content">

	<div class="container">

		<!-- TOP BAR -->
		<div class="top-bar">
			<div class="welcome-section">
				<h1>Students Management</h1>
				<p>
					Welcome back,
					<%=user.getFullName()%>! Manage and view all student records.
				</p>
			</div>
			<div class="user-info">
            <div class="user-avatar"><%=avatarLetter%></div>
            <div>
                <div style="font-weight:600;color:#1e293b;font-size:0.9rem;"><%=user.getUsername()%></div>
                <div style="font-size:0.8rem;color:#64748b;text-transform: capitalize;"><%=user.getRole()%></div>
            </div>
                <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> <span>Logout</span></button>

        </div>
		</div>

		<!-- Stats -->
		<div class="stats-grid">
			<%
			int totalStudents = 0;
			int activeStudents = 0;

			try (Connection conn = SQLConnection.getConnection()) {
				ResultSet rs1 = conn.prepareStatement("SELECT COUNT(*) AS total FROM students").executeQuery();
				if (rs1.next())
					totalStudents = rs1.getInt("total");

				ResultSet rs2 = conn.prepareStatement(
				"SELECT COUNT(*) AS active FROM students s JOIN users u ON s.user_id = u.user_id WHERE u.status='active'")
				.executeQuery();
				if (rs2.next())
					activeStudents = rs2.getInt("active");
			} catch (SQLException e) {
				e.printStackTrace();
			}
			%>

			<div class="stat-card">
				<div class="stat-number"><%=totalStudents%></div>
				<div class="stat-label">Total Students</div>
			</div>

			
		</div>

		<!-- Filters -->
		<div class="filters-container">
			<h2>
				<i class="fas fa-filter"></i> Search & Filter Students
			</h2>
			<form method="get" onsubmit="return false;">
				<div class="filters-grid">
					<div class="filter-group">
						<label for="search">Search Students</label> <input type="text"
							id="search" name="search"
							placeholder="Search by name, roll number, or email..."
							onkeyup="loadStudentsTable()">
					</div>

					<div class="filter-group">
						<label for="classFilter">Filter by Class</label> <select
							id="classFilter" name="class" onchange="loadStudentsTable()">
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
						<label for="genderFilter">Filter by Gender</label> <select
							id="genderFilter" name="gender" onchange="loadStudentsTable()">
							<option value="">All Genders</option>
							<option value="Male">Male</option>
							<option value="Female">Female</option>
							<option value="Other">Other</option>
						</select>
					</div>

					<div class="remove-filter-wrapper" style="margin-bottom: 4px;">
						<button type="button" id="clearStudentsFilterBtn"
							class="btn btn-secondary remove-filter-btn"
							style="display: none;"
							onclick="document.getElementById('search').value=''; document.getElementById('classFilter').value=''; document.getElementById('genderFilter').value=''; loadStudentsTable(); this.style.display='none';"
							title="Clear Filters">X Filter</button>
					</div>
				</div>
			</form>
		</div>

		<!-- Students Table -->
		<div class="table-container">
			<div class="table-header">
				<h3>
					<i class="fas fa-users"></i> Students List
				</h3>
				<%
				int studentCount = 0;
				try (Connection conn = SQLConnection.getConnection()) {
					ResultSet cr = conn.prepareStatement("SELECT COUNT(*) AS total FROM students").executeQuery();
					if (cr.next())
						studentCount = cr.getInt("total");
				}
				%>
				<span class="table-count"><%=studentCount%> students found</span>
			</div>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<th>Student</th>
							<th>Roll Number</th>
							<th>Class</th>
							<th>Phone</th>
							<th>Email</th>
						</tr>
					</thead>

					<tbody id="studentTableBody">
						<%
						try (Connection conn = SQLConnection.getConnection()) {
							String sql = "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, s.phone, "
							+ "c.class_name, c.section, u.email, u.status " + "FROM students s JOIN users u ON s.user_id = u.user_id "
							+ "LEFT JOIN classes c ON s.class_id = c.class_id " + "ORDER BY s.roll_number ASC";

							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();

							boolean hasData = false;

							while (rs.next()) {
								hasData = true;
								String fullName = rs.getString("first_name") + " " + rs.getString("last_name");
								String firstLetter = rs.getString("first_name").substring(0, 1).toUpperCase();
						%>

						<tr>
							<td><strong><%=rs.getString("roll_number")%></strong></td>
							<td>
								<div class="student-info">
									<div class="student-avatar"><%=firstLetter%></div>
									<div class="student-details">
										<h6><%=fullName%></h6>
									</div>
								</div>
							</td>
							<td><%=rs.getString("class_name")%>-<%=rs.getString("section")%></td>
							<td><%=rs.getString("phone")%></td>
							<td><%=rs.getString("email")%></td>
						</tr>

						<%
						}

						if (!hasData) {
						%>

						<tr>
							<td colspan="5" class="empty-state"><i
								class="fas fa-user-slash"></i>
								<p>No students found</p></td>
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

	<script>
function logout() {
    if (confirm("Are you sure you want to log out?")) {
        localStorage.clear();
        window.location.href = "<%=request.getContextPath()%>/LogoutServlet";
    }
}

// Prevent double-tap zoom on mobile
document.addEventListener('dblclick', function(event) {
    event.preventDefault();
}, { passive: false });

function loadStudentsTable() {
    const search = document.getElementById('search').value;
    const classId = document.getElementById('classFilter').value;
    const gender = document.getElementById('genderFilter').value;
    const clearBtn = document.getElementById('clearStudentsFilterBtn');

    if (search || classId || gender) {
        clearBtn.style.display = 'inline-flex';
    } else {
        clearBtn.style.display = 'none';
    }

    const xhr = new XMLHttpRequest();
    const url = "../getStudentTable?search="
        + encodeURIComponent(search)
        + "&class=" + encodeURIComponent(classId)
        + "&gender=" + encodeURIComponent(gender)
        + "&source=teacher";

			xhr.open("GET", url, true);
			xhr.onload = function() {
				if (xhr.status === 200) {
					document.getElementById("studentTableBody").innerHTML = xhr.responseText;
				} else {
					console.error("Error fetching students data");
				}
			};
			xhr.send();
		}
	</script>

</div>