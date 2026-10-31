<%@ page import="com.seh.model.User"%>
<%@ page import="com.seh.util.SQLConnection"%>
<%@ page import="java.sql.*"%>
<%@ page contentType="text/html; charset=UTF-8"%>

<%
User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}

String search = request.getParameter("search");
String classId = request.getParameter("classId");
String subjectId = request.getParameter("subjectId");
String docType = request.getParameter("docType");
String uploaderRole = request.getParameter("uploaderRole");
%>

<div class="doc-page">


	<div class="top-bar">
		<div class="welcome-section">
			<h1>Document Library</h1>
			<p>Browse academic documents</p>
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
	<form onsubmit="event.preventDefault(); loadDocumentsTable();" class="filters-container">
		<div class="filters-grid">

			<div class="filter-group">
				<label>Search</label> <input type="text" name="search" id="docSearch" onkeyup="loadDocumentsTable()"
					placeholder="Search by document or uploader name"
					value="<%=search != null ? search : ""%>">
			</div>

			<div class="filter-group">
				<label>Class</label> <select name="classId" id="docClassFilter" onchange="loadDocumentsTable()">
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
				<label>Subject</label> <select name="subjectId" id="docSubjectFilter" onchange="loadDocumentsTable()">
					<option value="">All Subjects</option>
					<%
					try (Connection c = SQLConnection.getConnection()) {
						ResultSet rs = c.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name")
						.executeQuery();
						while (rs.next()) {
					%>
					<option value="<%=rs.getInt("subject_id")%>"
						<%=String.valueOf(rs.getInt("subject_id")).equals(subjectId) ? "selected" : ""%>>
						<%=rs.getString("subject_name")%>
					</option>
					<%
					}
					}
					%>
				</select>
			</div>

			<div class="filter-group">
				<label>Type</label> <select name="docType" id="docTypeFilter" onchange="loadDocumentsTable()">
					<option value="">All Types</option>
					<option value="SYLLABUS">Syllabus</option>
					<option value="NOTES">Notes</option>
				</select>
			</div>

			<div class="filter-group">
				<label>Uploader</label> <select name="uploaderRole" id="docUploaderFilter" onchange="loadDocumentsTable()">
					<option value="">All Uploaders</option>
					<option value="admin">Admin</option>
					<option value="teacher">Teacher</option>
				</select>
			</div>

			<div class="remove-filter-wrapper">
                    <button type="button" id="clearDocFilterBtn" class="btn btn-secondary remove-filter-btn ux-hidden" onclick="document.getElementById('docSearch').value=''; document.getElementById('docClassFilter').value=''; document.getElementById('docSubjectFilter').value=''; document.getElementById('docTypeFilter').value=''; document.getElementById('docUploaderFilter').value=''; loadDocumentsTable(); this.style.display='none';" title="Clear Filters">
					X Filter
				</button>
			</div>
		</div>
	</form>

	<div class="table-container doc-results-container">
		<div class="table-header">
			<h3>Documents</h3>
			<span id="documentsCountText">Loading...</span>
		</div>
		<div class="doc-grid" id="docGrid">
		<%
		StringBuilder sql = new StringBuilder("SELECT d.*, c.class_name, c.section, s.subject_name, u.role, "
				+ "CASE WHEN u.role='admin' THEN CONCAT(a.first_name,' ',a.last_name) "
				+ "WHEN u.role='teacher' THEN CONCAT(t.first_name,' ',t.last_name) END uploader " + "FROM documents d "
				+ "LEFT JOIN classes c ON d.class_id=c.class_id " + "LEFT JOIN subjects s ON d.subject_id=s.subject_id "
				+ "JOIN users u ON d.uploaded_by=u.user_id " + "LEFT JOIN admins a ON u.user_id=a.user_id "
				+ "LEFT JOIN teachers t ON u.user_id=t.user_id WHERE d.document_type != 'TIMETABLES' ");

		if (search != null && !search.isBlank())
			sql.append("AND (d.title LIKE ? OR a.first_name LIKE ? OR t.first_name LIKE ?) ");

		if (classId != null && !classId.isBlank())
			sql.append("AND (d.class_id=? OR d.class_id IS NULL OR d.class_id=0) ");

		if (subjectId != null && !subjectId.isBlank())
			sql.append("AND d.subject_id=? ");

		if (docType != null && !docType.isBlank())
			sql.append("AND d.document_type=? ");

		if (uploaderRole != null && !uploaderRole.isBlank())
			sql.append("AND u.role=? ");

		sql.append("ORDER BY d.upload_date DESC");

		try (Connection c = SQLConnection.getConnection()) {
			PreparedStatement ps = c.prepareStatement(sql.toString());
			int i = 1;

			if (search != null && !search.isBlank()) {
				ps.setString(i++, "%" + search + "%");
				ps.setString(i++, "%" + search + "%");
				ps.setString(i++, "%" + search + "%");
			}
			if (classId != null && !classId.isBlank())
				ps.setInt(i++, Integer.parseInt(classId));
			if (subjectId != null && !subjectId.isBlank())
				ps.setInt(i++, Integer.parseInt(subjectId));
			if (docType != null && !docType.isBlank())
				ps.setString(i++, docType);
			if (uploaderRole != null && !uploaderRole.isBlank())
				ps.setString(i++, uploaderRole);

			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
                String className = rs.getString("class_name");
                String section = rs.getString("section");
                String displayClass = className != null ? className : "All Classes";
                if (section != null && !section.isEmpty() && !displayClass.equals("All Classes")) {
                    displayClass += " - " + section;
                }
		%>

		<div class="doc-card doc-library-card" onclick="openDocModal(this)"
			data-doc-id="<%=rs.getInt("document_id")%>"
			data-title="<%=rs.getString("title")%>"
			data-desc="<%=rs.getString("description")%>"
			data-class-id="<%=rs.getObject("class_id")%>"
			data-class-name="<%=rs.getString("class_name")%>"
			data-class-section="<%=rs.getString("section")%>"
			data-subject-id="<%=rs.getObject("subject_id")%>"
			data-subject-name="<%=rs.getString("subject_name")%>"
			data-type="<%=rs.getString("document_type")%>"
			data-uploader="<%=rs.getString("uploader")%> (<%=rs.getString("role")%>)"
			data-original-file="<%=rs.getString("original_file_name")%>"
			data-stored-file="<%=rs.getString("file_name")%>">



<div class="doc-card-top">
    <div class="doc-type-icon type-<%=rs.getString("document_type").toLowerCase()%>">
        <i class="fas fa-file-alt"></i>
    </div>
    <span class="doc-type-badge"><%=rs.getString("document_type")%></span>
</div>

<h3 class="doc-title"><%=rs.getString("title")%></h3>

<p class="doc-sub"><%=rs.getString("subject_name") != null ? rs.getString("subject_name") : "General"%> - <%=displayClass%></p>

<div class="doc-uploader-row">
    <span class="doc-uploader-dot"></span>
    <p class="doc-uploader">Uploaded by: <strong><%=rs.getString("uploader")%></strong></p>
</div>

<div class="doc-actions doc-actions-row">
				<a href="../downloadDocument?id=<%=rs.getInt("document_id")%>"
					class="btn btn-primary"
					onclick="event.stopPropagation(); return true;"> Download </a>
			</div>
		</div>


		<%
		}
		}
		%>
	</div>
	</div>

	<div id="docDetailsModal" class="modal-overlay"
		onclick="closeDocModalOnOverlay(event)">

		<div class="modal-container">

			<div class="modal-header">
				<h2 id="docModalTitle">Document Title</h2>
				<button class="modal-close" onclick="closeDocModal()">&times;</button>
			</div>

			<div class="details-content">

				<div class="detail-section">
					<div class="detail-grid doc-details-grid">

						<div class="detail-col">
							<div class="detail-item">
								<label>Description</label>
								<p id="docModalDescription">-</p>
							</div>

							<div class="detail-item">
								<label>Uploaded By</label>
								<p id="docModalUploader">-</p>
							</div>
						</div>

						<div class="vertical-divider"></div>

						<div class="detail-col">
							<div class="detail-item">
								<label>Subject</label>
								<p id="docModalSubject">-</p>
							</div>

							<div class="detail-item">
								<label>Class</label>
								<p id="docModalClass">-</p>
							</div>
						</div>

						<div class="vertical-divider"></div>

						<div class="detail-col">
							<div class="detail-item">
								<label>Type</label>
								<p id="docModalType">-</p>
							</div>

							<div class="detail-item">
								<label>File Name</label>
								<p id="docModalFileName" class="file-name">-</p>
							</div>
						</div>

					</div>
				</div>

			</div>

			<div class="form-actions">
				<button class="btn btn-secondary" id="docModalEditBtn"
					onclick="openEditDocumentModal()">Edit</button>

				<button class="btn btn-danger" onclick="openDeleteDocumentModal()">
					Delete</button>

	
	
				<a id="docModalDownload" class="btn btn-primary"
					onclick="downloadDocument()"> Download </a>

				<button class="btn btn-secondary" onclick="closeDocModal()">
					Close</button>
			</div>

		</div>
	</div>
	<div id="deleteDocumentModal" class="modal-overlay">
		<div class="modal-container">

			<div class="modal-header">
				<h2>Delete Document</h2>
				<button class="modal-close" onclick="closeDeleteDocumentModal()">&times;</button>
			</div>

			<p>Are you sure you want to delete this document?</p>

			<div class="form-actions">
				<button class="btn btn-danger" onclick="confirmDeleteDocument()">Delete</button>
				<button class="btn btn-secondary"
					onclick="closeDeleteDocumentModal()">Cancel</button>
			</div>

			<div id="deleteDocumentResult"></div>
		</div>
	</div>
	<div id="editDocumentModal" class="modal-overlay">
		<div class="modal-container">

			<div class="modal-header">
				<h2>Edit Document</h2>
				<button class="modal-close" onclick="closeEditDocumentModal()">&times;</button>
			</div>

			<div id="editDocumentResult"></div>

			<form id="editDocumentForm" onsubmit="updateDocument(event)">

				<input type="hidden" id="editDocId">

				<div class="form-grid">

					<div class="form-group">
						<label>Title <span class="required">*</span></label> <input
							type="text" id="editDocTitle" required>
					</div>

					<div class="form-group">
						<label>Document Type <span class="required">*</span></label> <select
							id="editDocType" required>
							<option value="SYLLABUS">Syllabus</option>
							<option value="NOTES">Notes</option>
						</select>
					</div>

					<div class="form-group">
						<label>Class</label> <select id="editDocClass">
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

					<div class="form-group">
						<label>Subject</label> <select id="editDocSubject">
							<option value="">All Subjects</option>
							<%
							try (Connection c = SQLConnection.getConnection()) {
								ResultSet rs = c.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name")
								.executeQuery();
								while (rs.next()) {
							%>
							<option value="<%=rs.getInt("subject_id")%>">
								<%=rs.getString("subject_name")%>
							</option>
							<%
							}
							}
							%>
						</select>
					</div>

					<div class="form-group">
						<label>Description</label>
						<textarea id="editDocDescription"></textarea>
					</div>

					<div class="form-group">
						<label>File Name <span class="required">*</span></label> <input
							type="text" id="editDocFileName" required>
					</div>

					<div class="form-group">
						<label>Replace File</label>
						<input type="file" id="editDocFile"
							accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png">
					</div>


				</div>

				<div class="form-actions">
					<button type="button" class="btn btn-secondary"
						onclick="closeEditDocumentModal()">Cancel</button>
					<button type="submit" class="btn btn-primary">Update</button>
				</div>

			</form>
		</div>
	</div>
</div>

