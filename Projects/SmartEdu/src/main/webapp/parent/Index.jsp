<%@page import="com.seh.model.User"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
String role = (String) session.getAttribute("role");
if (role == null || !role.equals("parent")) {
	System.out.println("❌ Redirecting back to login.jsp cause role=" + role);
	response.sendRedirect(" ../login.jsp?forceLogout=true&reason=sessionExpired");
	return;
}
%>

<%
User user = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartEdu Hub Parent Portal</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="static/css/style.css">
</head>

<body>
    <div class="main-body">
        <div class="mobile-toggle">
            <button class="hamburger-btn" id="sidebarToggle">
                <span></span> <span></span> <span></span>
            </button>
        </div>
        <div class="sidebar-overlay"></div>
        <nav class="sidebar">

            <div class="sidebar-header">
                <h2>
                    <i class="fas fa-users-viewfinder"></i> SmartEdu
                </h2>
                <p>Parent Portal</p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="javascript:void(0)" onclick="loadPage('dashboard.jsp')"><i class="fas fa-home"></i> Dashboard</a></li>
                <li><a href="javascript:void(0)" onclick="loadPage('view_attendance.jsp')"><i class="fas fa-calendar-check"></i> View Attendance</a></li>
                <li><a href="javascript:void(0)" onclick="loadPage('view_marks.jsp')"><i class="fas fa-graduation-cap"></i> View Marks</a></li>
                <li><a href="javascript:void(0)" onclick="loadPage('view_documents.jsp')"><i class="fas fa-book-open"></i> Syllabus & Notes</a></li>
                <li><a href="javascript:void(0)" onclick="loadPage('view_timetables.jsp')"><i class="fas fa-calendar-alt"></i> Class Timetables</a></li>
                <li><a href="javascript:void(0)" onclick="loadPage('view_announcements.jsp')"><i class="fas fa-bullhorn"></i> Announcements</a></li>
            </ul>
        </nav>

        <div class="main-content" id="main-content"></div>

    </div>

    <script>
        const contextPath = '<%=request.getContextPath()%>';
        const activeRole = 'parent';
        
        window.onload = () => {
            const lastPage = localStorage.getItem("last" + activeRole.charAt(0).toUpperCase() + activeRole.slice(1) + "Page") || "dashboard.jsp";
            loadPage(lastPage);
        };
    </script>
<script src="static/js/script.js?t=<%= System.currentTimeMillis() %>"></script>

</body>

</html>
