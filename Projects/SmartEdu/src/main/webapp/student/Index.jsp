<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.seh.model.User"%>


<%
// Role check
String role = (String) session.getAttribute("role");
if (role == null || !role.equals("student")) {
	response.sendRedirect("../login.jsp");
	return;
}

User user = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta name="viewport"
	content="width=device-width, initial-scale=1, maximum-scale=1">

<meta charset="UTF-8">
<title>Student Dashboard</title>

<!-- Bootstrap & Font Awesome -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css">
<link
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
	rel="stylesheet">

<!-- Custom CSS -->
<link rel="stylesheet" href="static/css/style.css">
</head>
<body>

	<div class="main-body">

		<!-- Mobile Toggle -->
		<div class="mobile-toggle">
			<button class="hamburger-btn" id="sidebarToggle">
				<span></span><span></span><span></span>
			</button>
		</div>

		<!-- Sidebar -->
		<nav class="sidebar">
			<div class="sidebar-header">
				<h2>
					<i class="fas fa-user-graduate"></i> SmartEdu
				</h2>
				<p>Smart College Utility Hub</p>
			</div>
			<ul class="sidebar-menu">
				<li><a href="javascript:void(0)"
					onclick="loadPage('dashboard.jsp')"><i class="fas fa-home"></i>
						Dashboard</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('student_timetable.jsp')"><i
						class="fas fa-chalkboard"></i> My Classes</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('view_attendance.jsp')"><i
						class="fas fa-calendar-check"></i> Attendance</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('my_marks.jsp')"><i
						class="fas fa-clipboard-list"></i> My Marks</a></li>


				<li><a href="javascript:void(0)"
					onclick="loadPage('view_Announcement.jsp')"><i
						class="fas fa-bullhorn"></i> Announcements</a></li>

				<li><a href="javascript:void(0)"
					onclick="loadPage('student_document_library.jsp')"><i
						class="fas fa-book-open"></i> Document Library</a></li>

			</ul>
		</nav>

		<!-- Main Content -->
		<div class="main-content" id="main-content"></div>

	</div>

	<!-- Scripts -->
	<script src="static/js/script.js"></script>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
