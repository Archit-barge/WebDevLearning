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

<div class="add_admin-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Add New Admin</h1>
			<p>Register a new administrator for the system</p>
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

	<div class="admin-form-shell">
		<div class="admin-form-header">
			<i class="fas fa-user-plus"></i>
			<h2>Admin Information</h2>
		</div>

		<div class="admin-form-body">
			<div id="addAdminResult" class="admin-result"></div>

			<form name="adminForm" onsubmit="addAdmin(event); return false;">
				<div class="section-title-row"><span>Account Information</span></div>
				<div class="admin-grid two-col">
				<div class="form-group">
					<label for="adminUsername">Username <span class="required">*</span></label>
					<input type="text" id="adminUsername" name="username" required placeholder="e.g. jdoe_admin">
				</div>
				<div class="form-group">
					<label for="adminEmail">Email Address <span class="required">*</span></label>
					<input type="email" id="adminEmail" name="email" required placeholder="jdoe@smartedu.hub">
				</div>
				</div>

				<div class="admin-grid section-gap">
					<div class="form-group">
						<label for="adminPassword">Password <span class="required">*</span></label>
						<input type="text" id="adminPassword" name="password" required placeholder="Enter password">
					</div>
				</div>

				<div class="section-title-row section-gap"><span>Personal Information</span></div>
				<div class="admin-grid three-col">
				<div class="form-group">
					<label for="adminFirstName">First Name <span class="required">*</span></label> 
					<input type="text" id="adminFirstName" name="firstName" required placeholder="Johnathan">
				</div>
				<div class="form-group">
					<label for="adminLastName">Last Name <span class="required">*</span></label>
					<input type="text" id="adminLastName" name="lastName" required placeholder="Doe">
				</div>
				<div class="form-group">
					<label for="adminPhone">Phone Number</label> 
					<input type="tel" id="adminPhone" name="phone" placeholder="9876543210" pattern="\d{10}" maxlength="10" inputmode="numeric">
				</div>
				</div>
			
				<div class="section-title-row section-gap"><span>Additional Information</span></div>
				<div class="admin-grid">
				<div class="form-group">
					<label for="adminAddress">Home Address</label>
					<textarea id="adminAddress" name="address" rows="3" placeholder="Enter complete residential address..."></textarea>
				</div>
				</div>

				<div class="form-actions">
					<button type="reset" class="btn btn-secondary">
						Cancel / Reset
					</button>
					<button type="submit" class="btn btn-primary">
						<i class="fas fa-check-circle"></i> Add Admin
					</button>
				</div>
			</form>
		</div>
	</div>
</div>
