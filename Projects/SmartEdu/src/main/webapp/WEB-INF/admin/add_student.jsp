<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.seh.util.SQLConnection"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.seh.model.User"%>
<%
User user = (User) session.getAttribute("user");
String avatarLetter = "A";

if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="add_student-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Add New Student</h1>
			<p>Register a new student account in the system</p>
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
	String error = (String) request.getAttribute("error");
	String success = (String) request.getAttribute("success");
	if (error != null && !error.isEmpty()) {
	%>
	<div class="alert alert-error">
		<i class="fas fa-exclamation-triangle"></i>
		<%=error%>
	</div>
	<%
	}
	%>

	<%
	if (success != null && !success.isEmpty()) {
	%>
	<div class="alert alert-success">
		<i class="fas fa-check-circle"></i>
		<%=success%>
	</div>
	<%
	}
	%>

	<div class="form-container">
		<div class="form-header">
			<h2>Student Information</h2>
			<p>
				Please fill in all required fields marked with <span
					class="required">*</span>
			</p>
		</div>

		<form action="../addStudent" method="post"
			onsubmit="return validateForm()">
			<h3 class="section-title-first">Account
				Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label for="username">Username <span class="required">*</span></label>
					<input type="text" id="username" name="username" required>
				</div>

				<div class="form-group">
					<label for="password">Password <span class="required">*</span></label>
					<input type="text" id="password" name="password" required>
				</div>

				<div class="form-group">
					<label for="email">Email Address <span class="required">*</span></label>
					<input type="email" id="email" name="email" required>
				</div>

				<div class="form-group">
					<label for="rollNumber">Roll Number <span class="required">*</span></label>
					<input type="text" id="rollNumber" name="rollNumber" required>
				</div>
			</div>

			<h3>Personal
				Information</h3>
			<div class="form-grid">
				<div class="form-group">
					<label for="firstName">First Name <span class="required">*</span></label>
					<input type="text" id="firstName" name="firstName" required>
				</div>

				<div class="form-group">
					<label for="lastName">Last Name <span class="required">*</span></label>
					<input type="text" id="lastName" name="lastName" required>
				</div>

				<div class="form-group">
					<label for="dateOfBirth">Date of Birth <span
						class="required">*</span></label> <input type="date" id="dateOfBirth"
						name="dateOfBirth" required>
				</div>

				<div class="form-group">
					<label for="gender">Gender <span class="required">*</span></label>
					<select id="gender" name="gender" required>
						<option value="">Select Gender</option>
						<option value="Male">Male</option>
						<option value="Female">Female</option>
						<option value="Other">Other</option>
					</select>
				</div>

				<div class="form-group">
					<label for="phone">Phone Number</label> <input type="tel"
						id="phone" name="phone" placeholder="9876543210" pattern="\d{10}" maxlength="10" inputmode="numeric">
				</div>

				<div class="form-group">
					<label for="classId">Class</label> <select id="classId"
						name="classId">
						<option value="">Select Class</option>
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
			</div>

			<h3>Additional
				Information</h3>
			<div class="form-grid">
				<div class="form-group full-span">
					<label for="address">Address</label>
					<textarea id="address" name="address"
						placeholder="Enter full address"></textarea>
				</div>

				<div class="form-group full-span">
					<label for="admissionDate">Admission Date</label> <input
						type="date" id="admissionDate" name="admissionDate">
				</div>
			</div>

			<div class="form-actions">
				<button type="button" class="btn btn-secondary"
					onclick="loadPage('dashboard.jsp')">
					<i class="fas fa-arrow-left"></i> Back to Dashboard
				</button>
				<button type="submit" class="btn btn-primary">
					<i class="fas fa-user-plus"></i> Add Student
				</button>
			</div>
		</form>
	</div>
</div>
