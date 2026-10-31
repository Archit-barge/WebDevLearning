<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.seh.model.User"%>
<%@ page import="com.seh.util.PageLoaderServlet"%>

<%
String role = (String) session.getAttribute("role");
if (role == null || !role.equals("teacher")) {
	System.out.println("❌ Redirecting back to login.jsp cause role=" + role);
	response.sendRedirect("../login.jsp");
	return;
}
%>

<%
User user = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<meta charset="UTF-8">
<title>SMS Teacher</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css">
<link
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
	rel="stylesheet">
<link rel="stylesheet" href="static/css/style.css">
</head>

<body>

	<div class="main-body">
		<!-- Mobile Toggle -->
		<div class="mobile-toggle">
			<button class="hamburger-btn" id="sidebarToggle">
				<span></span> <span></span> <span></span>
			</button>
		</div>
		
		<!-- Sidebar -->
		<nav class="sidebar">
			<div class="sidebar-header">
				<h2>
					<i class="fas fa-book-open"></i> SmartEdu
				</h2>
				<p>Smart College Utility Hub</p>
			</div>

			<ul class="sidebar-menu">
				<li><a href="javascript:void(0)"
					onclick="loadPage('dashboard.jsp')"><i class="fas fa-home"></i>
						Dashboard</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('my_classes.jsp')"><i class="fas fa-book"></i>
						My Classes</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('mark_attendance.jsp')"><i
						class="fas fa-clipboard-check"></i> Mark Attendance</a></li>

				<li><a href="javascript:void(0)"
					onclick="loadPage('view_students.jsp')"><i class="fas fa-users"></i>
						View Students</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('defaulter_list.jsp')"><i
						class="fas fa-exclamation-triangle"></i> Defaulters</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('announcements.jsp')"><i
						class="fas fa-bullhorn"></i> Announcements</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('enter_marks.jsp')"><i class="fas fa-pen"></i>
						Enter Marks</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('view_attendance.jsp')"><i
						class="fas fa-calendar-check"></i> View Attendance</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('teacher_upload_timetable.jsp')"><i
						class="fas fa-clock"></i> Post TimeTable</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('class_attendance_report.jsp')"><i
						class="fas fa-calendar-check"></i>Subject Wise</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('teacher_document_library.jsp')"><i
						class="fas fa-book-open"></i> Document Library</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('teacher_post_doc.jsp')"><i
						class="fas fa-file-upload"></i> Post Document</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('resultAnalysis.jsp')"><i
						class="fas fa-file-upload"></i> Result Analysis</a></li>
				<li><a href="javascript:void(0)"
					onclick="loadPage('academicPlanning.jsp')"><i
						class="fas fa-file-upload"></i> Academic Planning</a></li>
				
				<li><a href="javascript:void(0)"
					onclick="loadPage('SubmissionTracker.jsp')"><i
						class="fas fa-file-upload"></i> Submission</a></li>
						
			</ul>
		</nav>

		<!-- Main Content -->
		<div class="main-content" id="main-content"></div>

	</div>

	<!-- Overlay for mobile sidebar -->
	<div class="sidebar-overlay" id="sidebarOverlay"></div>


	<!-- Scripts -->
	<script src="static/js/script.js"></script>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
		<script>
function setExamType(type){

    const urlParams = new URLSearchParams(window.location.search);

    let classId = urlParams.get("classId");
    let subjectId = urlParams.get("subjectId");

    if(!classId) classId="";
    if(!subjectId) subjectId="";

    window.location.href =
    "Index.jsp?examType="+type+
    "&classId="+classId+
    "&subjectId="+subjectId;
}
</script>
</body>

</html>