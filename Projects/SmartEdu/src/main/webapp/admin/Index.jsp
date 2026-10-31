<%@page import="com.seh.model.User" %>
	<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

		<% String role=(String) session.getAttribute("role"); if (role==null || !role.equals("admin")) {
			System.out.println("Redirecting back to login.jsp cause role=" + role);
	response.sendRedirect(" ../login.jsp?forceLogout=true&reason=sessionExpired"); return; } %>


			<% User user=(User) session.getAttribute("user"); %>

				<!DOCTYPE html>
				<html lang="en">

				<head>
					<meta charset="UTF-8">
					<meta name="viewport"
						content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
					<title>SmartEdu Hub Admin</title>
					<link rel="stylesheet"
						href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css">
					<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
						rel="stylesheet">
					<link rel="stylesheet" href="static/css/style.css?v=<%= System.currentTimeMillis() %>">
					<style>
					</style>
				</head>

				<body>
					<div class="main-body">
						<div class="mobile-toggle">
							<button class="hamburger-btn" id="sidebarToggle">
								<span></span> <span></span> <span></span>
							</button>
						</div>
						<div id="sidebarOverlay" class="sidebar-overlay"></div>
						<nav class="sidebar">
							<div class="sidebar-header">
								<h2>
									<i class="fas fa-book-open"></i> SmartEdu
								</h2>
								<p>Smart College Utility Hub</p>
							</div>
							<ul class="sidebar-menu">
								<li><a href="javascript:void(0)" onclick="loadPage('dashboard.jsp')"><i
											class="fas fa-home"></i>
										Dashboard</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('add_admins.jsp')"><i
											class="fas fa-user-shield"></i> Add Admins</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('add_student.jsp')"><i
											class="fas fa-user-plus"></i> Add Student</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('add_teacher.jsp')"><i
											class="fas fa-chalkboard-teacher"></i> Add Teacher</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('add_parent.jsp')"><i
											class="fas fa-user-friends"></i> Add Parent</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('import_users.jsp')"><i
											class="fas fa-file-import"></i> Import Users</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('view_admins.jsp')"><i
											class="fas fa-user-shield"></i> View Admins</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('view_students.jsp')"><i
											class="fas fa-users"></i>
										View Students</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('view_teachers.jsp')"><i
											class="fas fa-chalkboard-teacher"></i> View Teachers</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('view_parents.jsp')"><i
											class="fas fa-users-slash"></i> View Parents</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('manage_classes.jsp')"><i
											class="fas fa-school"></i> Manage Classes</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('manage_subject.jsp')"><i
											class="fas fa-book-open"></i> Manage Subject</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('manage_class_subjects.jsp')"><i
											class="fas fa-link"></i> Class Subjects</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('admin_announcements.jsp')"><i
											class="fas fa-bullhorn"></i> Announcements</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('post_doc.jsp')"><i
											class="fas fa-book"></i>Post
										Syllabus & Notes</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('document_library.jsp')"><i
											class="fas fa-book"></i>Document Library</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('view_timetable.jsp')"><i
											class="fas fa-calendar-alt"></i>View Timetables</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('manage_whatsapp_links.jsp')"><i
											class="fab fa-whatsapp"></i>Class Groups</a></li>
								<li><a href="javascript:void(0)" onclick="loadPage('teacherTasks.jsp')"><i
											class="fab fa-whatsapp"></i>Teacher Tasks</a></li>
							</ul>
						</nav>

						<div class="main-content" id="main-content"></div>

					</div>

					<script>
						window.onload = () => {
							const params = new URLSearchParams(window.location.search);
							const queryPage = params.get("page");
							const lastPage = localStorage.getItem("lastPage");
							const pageToLoad = queryPage || lastPage || "dashboard.jsp";
							loadPage(pageToLoad);
						};
						const contextPath = '<%=request.getContextPath()%>';

						function uploadDocument() {
							let form = document.getElementById("documentForm");
							let result = document.getElementById("docResult");

							let formData = new FormData(form);

							let xhr = new XMLHttpRequest();
							xhr.open("POST", "../uploadDocument", true);

							xhr.onreadystatechange = function () {
								if (xhr.readyState === 4) {
									result.innerHTML = xhr.responseText;
									if (xhr.status === 200 && xhr.responseText.includes("success")) {
										form.reset();
									}
								}
							};

							xhr.send(formData);
						}


					</script>
					<script src="static/js/script.js?v=<%= System.currentTimeMillis() %>"></script>
				</body>

				</html>
