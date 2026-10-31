<%@ page import="com.seh.model.User"%>
<%@ page import="com.seh.util.SQLConnection"%>
<%@ page import="java.sql.*"%>
<%@ page contentType="text/html; charset=UTF-8"%>

<%


User user = (User) session.getAttribute("user");
String search = request.getParameter("search");
String classId = request.getParameter("classId");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
    avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="doc-page timetable-page">

	<div class="top-bar">
		<div class="welcome-section">
			<h1>View Timetables</h1>
			<p>Preview, edit, download, and manage uploaded class timetables.</p>
		</div>

		<div class="user-info">
			<div class="user-avatar">
				<%=avatarLetter%>
			</div>
			<div class="user-details">
				<p class="user-role-name"><%=user.getFullName() %></p>
                <p class="user-role-desc"><%=user.getRole()%></p>
			</div>
			<button class="logout-btn" onclick="logout()">Logout</button>
		</div>
	</div>

	<form onsubmit="event.preventDefault(); loadTimetablesTable();" class="filters-container">
		<div class="filters-grid timetable-filters-grid">

			<div class="filter-group">
				<label>Search</label>
				<input type="text" name="search" id="timetableSearch" onkeyup="loadTimetablesTable()"
					placeholder="Search by title or uploader"
					value="<%=search != null ? search : ""%>">
			</div>

			<div class="filter-group">
				<label>Class</label>
				<select name="classId" id="timetableClassFilter" onchange="loadTimetablesTable()">
					<option value="">All Classes</option>
					<%
					try (Connection c = SQLConnection.getConnection()) {
						ResultSet rs = c.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name")
								.executeQuery();
						while (rs.next()) {
					%>
					<option value="<%=rs.getInt("class_id")%>"
						<%=String.valueOf(rs.getInt("class_id")).equals(classId) ? "selected" : ""%>>
						<%=rs.getString("class_name")%>
						<%=rs.getString("section") != null ? " - " + rs.getString("section") : ""%>
					</option>
					<%
						}
					}
					%>
				</select>
			</div>

			<div class="filter-group">
				<label>Uploader</label>
				<select name="uploaderRole" id="timetableUploaderFilter" onchange="loadTimetablesTable()">
					<option value="">All Uploaders</option>
					<option value="admin">Admin</option>
					<option value="teacher">Teacher</option>
				</select>
			</div>

			<div class="remove-filter-wrapper">
				<button type="button" id="clearTimetableFilterBtn" class="btn btn-secondary remove-filter-btn ux-hidden"
					onclick="document.getElementById('timetableSearch').value=''; document.getElementById('timetableClassFilter').value=''; document.getElementById('timetableUploaderFilter').value=''; loadTimetablesTable(); this.style.display='none';"
					title="Clear Filters">
					X Filter
				</button>
			</div>

		</div>
	</form>

	<div class="table-container timetable-results-container">
		<div class="table-header">
			<h3>Timetables</h3>
			<span id="timetablesCountText">Loading...</span>
		</div>
		<div class="timetable-grid" id="timetableGrid"></div>
	</div>

</div>

<div id="editTimetableModal" class="modal-overlay">
	<div class="modal-container">
		<div class="modal-header">
			<h2>Edit Timetable</h2>
			<button class="modal-close" onclick="closeEditTimetableModal()">&times;</button>
		</div>

		<div id="editTimetableResult" class="ux-mb-075"></div>

		<form id="editTimetableForm" onsubmit="updateTimetable(event)">
			<input type="hidden" id="editTimetableId">

			<div class="form-grid">
				<div class="form-group">
					<label>Title <span class="required">*</span></label>
					<input type="text" id="editTimetableTitle" required>
				</div>

				<div class="form-group">
					<label>Class</label>
					<select id="editTimetableClass">
						<option value="">All Classes</option>
						<%
						try (Connection c = SQLConnection.getConnection()) {
							ResultSet rs = c.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name")
									.executeQuery();
							while (rs.next()) {
						%>
						<option value="<%=rs.getInt("class_id")%>">
							<%=rs.getString("class_name")%>
							<%=rs.getString("section") != null ? " - " + rs.getString("section") : ""%>
						</option>
						<%
							}
						}
						%>
					</select>
				</div>

				<div class="form-group ux-grid-span-2">
					<label>Description</label>
					<textarea id="editTimetableDescription" rows="3" placeholder="Optional description"></textarea>
				</div>

				<div class="form-group">
					<label>Original File Name <span class="required">*</span></label>
					<input type="text" id="editTimetableOriginalFile" required>
				</div>

				<div class="form-group">
					<label>Replace File (optional)</label>
					<input type="file" id="editTimetableFile" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png">
				</div>
			</div>

			<div class="form-actions">
				<button type="button" class="btn btn-secondary" onclick="closeEditTimetableModal()">Cancel</button>
				<button type="submit" class="btn btn-primary">Update Timetable</button>
			</div>
		</form>
	</div>
</div>

