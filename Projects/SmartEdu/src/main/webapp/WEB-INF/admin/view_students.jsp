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

<div class="view_students-content">
	<div class="top-bar">
		<div class="welcome-section">
			<h1>Students Management</h1>
			<p>
				Welcome back,
				<%=user.getFullName()%>
				! Manage and view all student records.
			</p>
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

	<div class="stats-grid" id="studentStats">
		<%
		int totalStudents = 0;
		int activeStudents = 0;
		int totalClasses = 0;
		try (Connection conn = SQLConnection.getConnection()) {

			ResultSet rs1 = conn.prepareStatement("SELECT COUNT(*) AS total FROM students").executeQuery();
			if (rs1.next())
				totalStudents = rs1.getInt("total");
			rs1.close();

			ResultSet rs2 = conn.prepareStatement(
			"SELECT COUNT(*) AS active FROM students s JOIN users u ON s.user_id = u.user_id WHERE u.status='active'")
			.executeQuery();
			if (rs2.next())
				activeStudents = rs2.getInt("active");
			rs2.close();

			ResultSet rs3 = conn.prepareStatement("SELECT COUNT(*) AS total_classes FROM classes").executeQuery();
			if (rs3.next())
				totalClasses = rs3.getInt("total_classes");
			rs3.close();

		} catch (SQLException e) {
			e.printStackTrace();
		}
		%>
		<div class="stat-card">
			<div class="stat-number"><%=totalStudents%></div>
			<div class="stat-label">Total Students</div>
		</div>
		<div class="stat-card">
			<div class="stat-number"><%=totalClasses%></div>
			<div class="stat-label">Total Classes</div>
		</div>
	</div>

	<div class="filters-container">
		<form method="get" onsubmit="return false;">
			<div class="filters-grid">
				<div class="filter-group">
					<label for="search">Search Students</label> <input type="text"
						id="search" name="search"
						placeholder="Search by name, roll number, or email..." onkeyup="loadStudentsTable()">
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

				<div class="remove-filter-wrapper ux-mb-4">
					<button type="button" id="clearStudentsFilterBtn" class="btn btn-secondary remove-filter-btn ux-hidden" onclick="document.getElementById('search').value=''; document.getElementById('classFilter').value=''; document.getElementById('genderFilter').value=''; loadStudentsTable(); this.style.display='none';" title="Clear Filters">
						X Filter
					</button>
				</div>
			</div>
		</form>
	</div>

	<div class="table-container">
		<div class="table-container">
			<div class="table-header">
				<h3>Students List</h3>
				<%
				int studentCount = 0;
				try (Connection conn = SQLConnection.getConnection()) {
					PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) AS total FROM students");
					ResultSet countRs = countStmt.executeQuery();
					if (countRs.next())
						studentCount = countRs.getInt("total");
					countRs.close();
					countStmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
				%>
				<span><%=studentCount%> students found</span>
			</div>


			<div class="table-wrapper student-list-scroll split-table">
				<table class="table-head-table">
					<colgroup>
						<col class="col-stu-roll">
						<col class="col-stu-name">
						<col class="col-stu-user">
						<col class="col-stu-class">
						<col class="col-stu-phone">
						<col class="col-actions-lg">
					</colgroup>
					<thead>
						<tr>
							<th>Roll Number</th>
							<th>Student Name</th>
							<th>Username</th>
							<th>Class</th>
							<th>Phone</th>
							<th>Actions</th>
						</tr>
					</thead>
				</table>
				<div class="table-body-scroll">
					<table class="table-body-table">
						<colgroup>
							<col class="col-stu-roll">
							<col class="col-stu-name">
							<col class="col-stu-user">
							<col class="col-stu-class">
							<col class="col-stu-phone">
							<col class="col-actions-lg">
						</colgroup>
						<tbody id="studentTableBody">
						<%
						try (Connection conn = SQLConnection.getConnection()) {

							String sql = "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, s.phone, s.gender, s.date_of_birth, s.address, s.admission_date, s.class_id, "
							+ "c.class_name, c.section, u.username, u.email, u.password, u.status " +
							"FROM students s JOIN users u ON s.user_id = u.user_id " + "LEFT JOIN classes c ON s.class_id = c.class_id "
							+ "ORDER BY s.roll_number ASC";

							PreparedStatement stmt = conn.prepareStatement(sql);
							ResultSet rs = stmt.executeQuery();

							while (rs.next()) {
								int studentId = rs.getInt("student_id");
								String rollNumber = rs.getString("roll_number");
								String firstName = rs.getString("first_name");
								String lastName = rs.getString("last_name");
								String fullName = firstName + " " + lastName;
								String className = rs.getString("class_name");
								String section = rs.getString("section");
								String classDisplay = (className != null && section != null) ? className + "-" + section : "-";
								String username = rs.getString("username");
								String password = rs.getString("password") != null ? rs.getString("password") : "";
								String email = rs.getString("email") != null ? rs.getString("email") : "";
								String phone = rs.getString("phone") != null ? rs.getString("phone") : "-";
								String gender = rs.getString("gender") != null ? rs.getString("gender") : "";
								String dateOfBirth = rs.getString("date_of_birth") != null ? rs.getString("date_of_birth") : "";
								String address = rs.getString("address") != null ? rs.getString("address") : "";
								String admissionDate = rs.getString("admission_date") != null ? rs.getString("admission_date") : "";
								String status = rs.getString("status") != null ? rs.getString("status") : "";
								int classId = rs.getInt("class_id");
						%>

						<tr>
							<td><%=rollNumber%></td>
							<td>
								<div class="student-info">
									<div class="student-avatar"><%=firstName.substring(0, 1).toUpperCase()%></div>
									<div class="student-details">
										<h6><%=fullName%></h6>
									</div>
								</div>
							</td>
							<td><%=username%></td>
							<td><%=classDisplay%></td>
							<td><%=phone%></td>

							<td>
								<button type="button" class="action-btn edit"
									onclick="openEditStudentModal(<%=studentId%>, '<%=escapeJsAttr(fullName)%>', '<%=escapeJsAttr(rollNumber)%>', '<%=escapeJsAttr(username)%>', '<%=escapeJsAttr(email)%>', '<%=escapeJsAttr(dateOfBirth)%>', '<%=escapeJsAttr(gender)%>', '<%=escapeJsAttr(phone)%>', <%=classId%>, '<%=escapeJsAttr(address)%>', '<%=escapeJsAttr(admissionDate)%>', '<%=escapeJsAttr(password)%>')">
									<i class="fas fa-edit"></i> Edit
								</button>

								<button type="button" class="action-btn view"
									onclick="openViewModal(<%=studentId%>,'<%=escapeJsAttr(fullName)%>', '<%=escapeJsAttr(username)%>', '<%=escapeJsAttr(email)%>', '<%=escapeJsAttr(rollNumber)%>', '<%=escapeJsAttr(dateOfBirth)%>', '<%=escapeJsAttr(gender)%>', '<%=escapeJsAttr(phone)%>', '<%=escapeJsAttr(classDisplay)%>', '<%=escapeJsAttr(address)%>', '<%=escapeJsAttr(admissionDate)%>', '<%=escapeJsAttr(status)%>', '<%=escapeJsAttr(password)%>')">
									<i class="fas fa-eye"></i> View
								</button>
								<button type="button" class="action-btn delete"
									onclick="deleteStudent(<%=studentId%>, '<%=escapeJsAttr(fullName)%>')">
									<i class="fas fa-trash"></i> Delete
								</button>
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

	<div id="editStudentModal" class="modal-overlay ux-hidden">
		<div class="modal-container">
			<div class="modal-header">
				<h2>Edit Student</h2>
				<button class="modal-close" onclick="closeEditStudentModal()">×</button>
			</div>

			<form name="editStudentForm">
				<input type="hidden" id="editStudentId">

				<h3 class="ux-modal-section-title">Account
					Information</h3>
				<div class="form-grid">
					<div class="form-group">
						<label>Username <span class="required">*</span></label> <input
							type="text" id="editUsername" required>
					</div>

					<div class="form-group">
						<label>Password<span class="required">*</span></label><input
							type="text" id="editPassword" required>
					</div>

					<div class="form-group">
						<label>Email Address <span class="required">*</span></label> <input
							type="email" id="editEmail" required>
					</div>

					<div class="form-group">
						<label>Roll Number <span class="required">*</span></label> <input
							type="text" id="editRollNumber" required>
					</div>
				</div>

				<h3 class="ux-modal-section-title-spaced">Personal
					Information</h3>
				<div class="form-grid">
					<div class="form-group">
						<label>First Name <span class="required">*</span></label> <input
							type="text" id="editFirstName" required>
					</div>

					<div class="form-group">
						<label>Last Name <span class="required">*</span></label> <input
							type="text" id="editLastName" required>
					</div>

					<div class="form-group">
						<label>Date of Birth</label> <input type="date"
							id="editDateOfBirth">
					</div>

					<div class="form-group">
						<label>Gender</label> <select id="editGender">
							<option value="">Select Gender</option>
							<option value="Male">Male</option>
							<option value="Female">Female</option>
							<option value="Other">Other</option>
						</select>
					</div>

					<div class="form-group">
						<label>Phone Number</label> <input type="tel" id="editPhone">
					</div>

					<div class="form-group">
						<label>Class</label> <select id="editClassId">
							<option value="">Select Class</option>
							<%
							try (Connection conn = SQLConnection.getConnection()) {
								String sql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section ASC";
								PreparedStatement stmt = conn.prepareStatement(sql);
								ResultSet rs2 = stmt.executeQuery();
								while (rs2.next()) {
									int classId = rs2.getInt("class_id");
									String className = rs2.getString("class_name");
									String section = rs2.getString("section");
									String displayName = className + (section != null ? " - " + section : "");
							%>
							<option value="<%=classId%>"><%=displayName%></option>
							<%
							}
							rs2.close();
							stmt.close();
							} catch (SQLException e) {
							e.printStackTrace();
							}
							%>
						</select>
					</div>
				</div>

				<h3 class="ux-modal-section-title-spaced">Additional
					Information</h3>
				<div class="form-grid">
					<div class="form-group ux-grid-span-full">
						<label>Address</label>
						<textarea id="editAddress" placeholder="Enter full address"></textarea>
					</div>

					<div class="form-group ux-grid-span-full">
						<label>Admission Date</label> <input type="date"
							id="editAdmissionDate">
					</div>
				</div>

				<div id="editStudentResult" class="ux-result-space"></div>

				<div class="form-actions">
					<button type="button" class="btn btn-secondary"
						onclick="closeEditStudentModal()">Cancel</button>
					<button type="button" class="btn btn-primary"
						onclick="updateStudent()">Save Changes</button>
				</div>
			</form>
		</div>
	</div>

	<div id="viewDetailsModal" class="modal-overlay ux-hidden">
		<div class="modal-container">
			<div class="modal-header">
				<h2>Student Details</h2>
				<button class="modal-close" onclick="closeViewDetailsModal()">×</button>
			</div>

			<div class="details-content">
				<div class="detail-section">
					<h3 class="ux-modal-section-title">Account
						Information</h3>
					<div class="detail-grid">
						<div class="detail-item">
							<label>Username</label>
							<p id="detailUsername"></p>
						</div>
						<div class="detail-item">
							<label>Password</label>
							<p id="detailPassword"></p>
						</div>

						<div class="detail-item">
							<label>Email</label>
							<p id="detailEmail"></p>
						</div>
						<div class="detail-item">
							<label>Roll Number</label>
							<p id="detailRollNumber"></p>
						</div>
					</div>
				</div>

				<div class="detail-section">
					<h3 class="ux-modal-section-title">Personal
						Information</h3>
					<div class="detail-grid">
						<div class="detail-item">
							<label>First Name</label>
							<p id="detailFirstName"></p>
						</div>
						<div class="detail-item">
							<label>Last Name</label>
							<p id="detailLastName"></p>
						</div>
						<div class="detail-item">
							<label>Date of Birth</label>
							<p id="detailDateOfBirth"></p>
						</div>
						<div class="detail-item">
							<label>Gender</label>
							<p id="detailGender"></p>
						</div>
						<div class="detail-item">
							<label>Phone Number</label>
							<p id="detailPhone"></p>
						</div>
					</div>
				</div>

				<div class="detail-section">
					<h3 class="ux-modal-section-title">Academic
						Information</h3>
					<div class="detail-grid">
						<div class="detail-item">
							<label>Class</label>
							<p id="detailClass"></p>
						</div>
						<div class="detail-item">
							<label>Admission Date</label>
							<p id="detailAdmissionDate"></p>
						</div>
					</div>
				</div>

				<div class="detail-section">
					<h3 class="ux-modal-section-title">Additional
						Information</h3>
					<div class="detail-grid">
						<div class="detail-item ux-grid-span-full">
							<label>Address</label>
							<p id="detailAddress"></p>
						</div>
					</div>
				</div>
			</div>

			<div class="form-actions">
				<button type="button" class="btn btn-secondary"
					onclick="closeViewDetailsModal()">Close</button>
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
		return value.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r",
				"\\r");
	}

	private String escapeJsAttr(String value) {
		String jsEscaped = escapeJs(value);
		return jsEscaped.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}%>

