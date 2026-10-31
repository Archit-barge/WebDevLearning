<%@ page import="com.seh.model.User" %>
<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%


User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
    avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="post-doc-content">

	<div class="top-bar">
		<div class="welcome-section">
			<h1>Post Documents</h1>
			<p>Upload syllabus, notes, or exam timetables</p>
		</div>

		<div class="user-info">
			<div class="user-avatar"><%=avatarLetter%></div>
			<div class="user-details">
				<p class="user-role-name"><%=user.getFullName()%></p>
				<p class="user-role-desc"><%=user.getRole()%></p>
			</div>
			<button class="logout-btn" onclick="logout()">Logout</button>
		</div>
	</div>

	<div class="form-container">
        <h2><i class="fas fa-cloud-upload-alt"></i> Upload Document</h2>

        <div id="docResult"></div>

        <form id="documentForm" enctype="multipart/form-data">

            <div class="form-grid">

                <div class="form-group">
                    <label>Document Title *</label>
                    <input type="text" name="title" required placeholder="e.g. Mathematics Final Revision 2024">
                </div>

                <div class="form-group">
                    <label>Document Type *</label>
                    <select name="documentType" required>
                        <option value="">Select Type</option>
                        <option value="SYLLABUS">Syllabus</option>
                        <option value="NOTES">Notes</option>
                        <option value="TIMETABLES">Timetables</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Class</label>
                    <select name="classId">
                        <option value="">Select Class</option>
                        <%
                        try (Connection conn = SQLConnection.getConnection()) {
                            PreparedStatement ps = conn.prepareStatement(
                                "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section"
                            );
                            ResultSet rs = ps.executeQuery();
                            while (rs.next()) {
                        %>
                        <option value="<%=rs.getInt("class_id")%>">
                            <%=rs.getString("class_name")%>
                            <%=rs.getString("section") != null ? " - " + rs.getString("section") : ""%>
                        </option>
                        <%
                            }
                            rs.close();
                            ps.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Subject</label>
                    <select name="subjectId">
                        <option value="">Select Subject</option>
                        <%
                        try (Connection conn = SQLConnection.getConnection()) {
                            PreparedStatement ps = conn.prepareStatement(
                                "SELECT subject_id, subject_name FROM subjects ORDER BY subject_name"
                            );
                            ResultSet rs = ps.executeQuery();
                            while (rs.next()) {
                        %>
                        <option value="<%=rs.getInt("subject_id")%>">
                            <%=rs.getString("subject_name")%>
                        </option>
                        <%
                            }
                            rs.close();
                            ps.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        %>
                    </select>
                </div>

                        <div class="form-group ux-grid-span-2">
                    <label>Description</label>
                    <textarea name="description" rows="3" placeholder="Briefly describe the document contents..."></textarea>
                </div>

                        <div class="form-group file-upload-group ux-grid-span-2">
                    <label>Select File *</label>
                    <input type="file" id="documentFileInput" name="documentFile" required>
                    <label for="documentFileInput" class="file-dropzone">
                    	<span class="file-drop-icon"><i class="far fa-file-alt"></i></span>
                    	<span class="file-drop-text">Click to upload or drag and drop</span>
                    	<span class="file-drop-name" id="selectedDocFileName">No file chosen</span>
                    </label>
                    <small class="upload-hint">Allowed formats: PDF, DOC, DOCX, PPT, PPTX, JPG, PNG. Max size: 10MB</small>
                </div>

            </div>

            <button type="button" class="btn btn-primary" onclick="uploadDocument()">
                Upload Document
            </button>

        </form>
    </div>

</div>

<script>
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = '../LogoutServlet';
    }
}
</script>

