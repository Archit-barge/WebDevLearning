<%@ page import="com.seh.model.User" %>
<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        response.sendRedirect("../login.jsp");
        return;
    }
    User user = (User) session.getAttribute("user");
    String avatarLetter = user.getFullName() != null && user.getFullName().length() > 0
        ? String.valueOf(user.getFullName().charAt(0)).toUpperCase() : "T";
%>

<style>
/* ===== CSS VARIABLES FOR CONSISTENT THEMING ===== */
:root {
    --primary: #10b981;
    --primary-light: #34d399;
    --primary-dark: #059669;
    --success: #10b981;
    --success-light: #34d399;
    --success-dark: #059669;
    --danger: #ef4444;
    --danger-dark: #dc2626;
    --text-dark: #1e293b;
    --text-muted: #64748b;
    --bg-light: #f8fafc;
    --white: #ffffff;
    --shadow-sm: 0 4px 12px rgba(0,0,0,0.05);
    --shadow-md: 0 4px 20px rgba(0,0,0,0.08);
    --shadow-lg: 0 16px 40px rgba(0,0,0,0.16);
    --radius-sm: 8px;
    --radius-md: 12px;
    --radius-lg: 16px;
    --radius-xl: 20px;
    --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    --touch-target: 48px;
}

/* ===== RESET & BASE STYLES ===== */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    -webkit-tap-highlight-color: transparent;
}

html {
    -webkit-text-size-adjust: 100%;
}

.post-doc-content {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: var(--bg-light);
    color: var(--text-dark);
    line-height: 1.5;
    -webkit-font-smoothing: antialiased;
    min-height: 100vh;
    padding: 0.5rem;
}

/* ===== TOP BAR ===== */
.post-doc-content .top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
    margin-bottom: 1.5rem;
    padding: 1.5rem 2rem;
    background: var(--white);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    flex-wrap: wrap;
    gap: 1rem;
}

.post-doc-content .welcome-section {
    flex: 1;
    min-width: 200px;
}

.post-doc-content .welcome-section h1 {
    font-size: clamp(1.25rem, 4vw, 2rem);
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 0.25rem;
}

.post-doc-content .welcome-section p {
    color: var(--text-muted);
    font-size: clamp(0.75rem, 2.5vw, 0.9rem);
}

.post-doc-content .user-info {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
    justify-content: flex-end;
}

.post-doc-content .user-avatar {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: linear-gradient(135deg) 0%,, var(--primary var(--primary-dark) 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--white);
    font-weight: 600;
    font-size: 1.2rem;
    flex-shrink: 0;
}

.post-doc-content .user-details {
    display: flex;
    flex-direction: column;
    text-align: right;
}

.post-doc-content .user-details .name {
    font-weight: 600;
    color: var(--text-dark);
    font-size: 0.9rem;
}

.post-doc-content .user-details .role {
    font-size: 0.8rem;
    color: var(--text-muted);
    text-transform: capitalize;
}

.post-doc-content .logout-btn {
    background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
    color: var(--white);
    border: none;
    border-radius: var(--radius-sm);
    padding: 10px 16px;
    cursor: pointer;
    transition: var(--transition);
    font-weight: 600;
    font-size: 0.875rem;
    box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
    white-space: nowrap;
    display: flex;
    align-items: center;
    gap: 6px;
    min-height: var(--touch-target);
}

.post-doc-content .logout-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
}

.post-doc-content .logout-btn:active {
    transform: scale(0.98);
}

/* ===== FORM CONTAINER ===== */
.post-doc-content .form-container {
    background: var(--white);
    border-radius: var(--radius-lg);
    padding: 2rem;
    box-shadow: var(--shadow-md);
    border: 1px solid #e2e8f0;
}

.post-doc-content .form-container h2 {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e2e8f0;
}

/* ===== FORM GRID & GROUPS ===== */
.post-doc-content .form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 1.5rem;
    margin-bottom: 1.5rem;
}

.post-doc-content .form-group {
    display: flex;
    flex-direction: column;
}

.post-doc-content .form-group label {
    font-weight: 600;
    color: var(--text-dark);
    margin-bottom: 0.5rem;
    font-size: 0.9rem;
}

.post-doc-content .form-group input,
.post-doc-content .form-group select,
.post-doc-content .form-group textarea {
    padding: 0.75rem;
    border: 2px solid #e5e7eb;
    border-radius: var(--radius-sm);
    font-size: 0.95rem;
    font-family: inherit;
    background: var(--white);
    transition: var(--transition);
    min-height: var(--touch-target);
}

.post-doc-content .form-group input:focus,
.post-doc-content .form-group select:focus,
.post-doc-content .form-group textarea:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
}

.post-doc-content .form-group textarea {
    resize: vertical;
    min-height: 100px;
}

.post-doc-content .form-group small {
    display: block;
    margin-top: 0.35rem;
    color: var(--text-muted);
    font-size: 0.8rem;
}

.post-doc-content .required {
    color: var(--danger);
}

/* ===== BUTTONS ===== */
.post-doc-content .btn {
    padding: 0.875rem 1.5rem;
    border-radius: var(--radius-sm);
    font-size: 0.95rem;
    font-weight: 500;
    cursor: pointer;
    transition: var(--transition);
    border: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.4rem;
    text-decoration: none;
    min-height: var(--touch-target);
}

.post-doc-content .btn-primary {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: var(--white);
    box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
}

.post-doc-content .btn-primary:hover {
    background: var(--primary-dark);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
}

.post-doc-content .btn-primary:active {
    transform: scale(0.98);
}

/* ===== RESULT ALERTS ===== */
.post-doc-content .alert {
    padding: 1rem;
    border-radius: var(--radius-sm);
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    font-size: 0.95rem;
    animation: fadeIn 0.3s ease-out;
}

.post-doc-content .alert-success {
    background: linear-gradient(135deg, #d1fae5 0%, #ecfdf5 100%);
    color: #065f46;
    border: 1px solid #a7f3d0;
}

.post-doc-content .alert-error {
    background: linear-gradient(135deg, #fee2e2 0%, #fef2f2 100%);
    color: #991b1b;
    border: 1px solid #fecaca;
}

/* ===== RESPONSIVE BREAKPOINTS ===== */

/* Mobile */
@media (max-width: 768px) {
    .post-doc-content {
        padding: 0.5rem;
    }

    .post-doc-content .top-bar {
        padding: 1rem;
        margin-bottom: 1rem;
        flex-direction: column;
        gap: 0.75rem;
        text-align: center;
        border-radius: var(--radius-md);
    }

    .post-doc-content .welcome-section {
        min-width: 100%;
        text-align: center;
    }

    .post-doc-content .welcome-section h1 {
        font-size: 1.25rem;
    }

    .post-doc-content .user-info {
        width: 100%;
        justify-content: center;
    }

    .post-doc-content .user-details {
        display: none;
    }

    .post-doc-content .logout-btn {
        width: 100%;
        justify-content: center;
    }

    .post-doc-content .form-container {
        padding: 1rem;
        margin-bottom: 1rem;
        border-radius: var(--radius-md);
    }

    .post-doc-content .form-container h2 {
        font-size: 1rem;
        margin-bottom: 1rem;
    }

    .post-doc-content .form-grid {
        grid-template-columns: 1fr;
        gap: 0.75rem;
    }

    .post-doc-content .form-group input,
    .post-doc-content .form-group select,
    .post-doc-content .form-group textarea {
        font-size: 0.95rem;
        padding: 12px 14px;
    }

    .post-doc-content .btn {
        width: 100%;
    }
}

/* Small phones */
@media (max-width: 480px) {
    .post-doc-content {
        padding: 0.375rem;
    }

    .post-doc-content .top-bar {
        padding: 0.875rem;
        margin-bottom: 0.75rem;
        gap: 0.625rem;
    }

    .post-doc-content .welcome-section h1 {
        font-size: 1.125rem;
    }

    .post-doc-content .welcome-section p {
        font-size: 0.8rem;
    }

    .post-doc-content .user-avatar {
        width: 36px;
        height: 36px;
        font-size: 0.875rem;
        border-radius: 8px;
    }

    .post-doc-content .logout-btn {
        font-size: 0.8125rem;
        padding: 10px 12px;
    }

    .post-doc-content .form-container {
        padding: 0.875rem;
        margin-bottom: 0.75rem;
    }

    .post-doc-content .form-container h2 {
        font-size: 0.9375rem;
    }

    .post-doc-content .form-group label {
        font-size: 0.8125rem;
    }

    .post-doc-content .alert {
        padding: 0.75rem 0.875rem;
        font-size: 0.8125rem;
    }
}

/* Large Desktop */
@media (min-width: 1200px) {
    .post-doc-content .welcome-section h1 {
        font-size: 2rem;
    }

    .post-doc-content .welcome-section p {
        font-size: 1.125rem;
    }

    .post-doc-content .form-container {
        padding: 2.5rem;
        border-radius: var(--radius-xl);
    }

    .post-doc-content .form-container h2 {
        font-size: 1.75rem;
    }
}

/* ===== ANIMATIONS ===== */
@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.post-doc-content .top-bar {
    animation: fadeIn 0.4s ease-out;
}

.post-doc-content .form-container {
    animation: fadeIn 0.4s ease-out 0.1s both;
}

/* ===== TOUCH IMPROVEMENTS ===== */
@media (hover: none) and (pointer: coarse) {
    .post-doc-content .logout-btn:hover,
    .post-doc-content .btn-primary:hover {
        transform: none;
    }

    .post-doc-content .logout-btn:active,
    .post-doc-content .btn-primary:active {
        transform: scale(0.98);
    }
}
</style>

<div class="post-doc-content">

    <div class="top-bar">
        <div class="welcome-section">
            <h1>Post Documents</h1>
            <p>Upload syllabus or notes for your students</p>
        </div>
        <div class="user-info">
            <div class="user-avatar"><%=avatarLetter%></div>
            <div>
                <div style="font-weight:600;color:#1e293b;font-size:0.9rem;"><%=user.getUsername()%></div>
                <div style="font-size:0.8rem;color:#64748b;text-transform: capitalize;"><%=user.getRole()%></div>
            </div>
            <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> <span>Logout</span></button>
     </div>
    </div>

    <div class="form-container">
        <h2>Upload Document</h2>

        <div id="docResult"></div>

        <form id="documentForm" enctype="multipart/form-data">
            <div class="form-grid">

                <div class="form-group">
                    <label>Document Title <span class="required">*</span></label>
                    <input type="text" name="title" required placeholder="e.g. Grade 8 Math Syllabus">
                </div>

                <div class="form-group">
                    <label>Document Type <span class="required">*</span></label>
                    <select name="documentType" required>
                        <option value="">Select Type</option>
                        <option value="SYLLABUS">Syllabus</option>
                        <option value="NOTES">Notes</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Class</label>
                    <select name="classId">
                        <option value="">Select Class</option>
                        <%
                        try (Connection conn = SQLConnection.getConnection()) {
                            PreparedStatement ps = conn.prepareStatement(
                                "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section");
                            ResultSet rs = ps.executeQuery();
                            while (rs.next()) { %>
                        <option value="<%=rs.getInt("class_id")%>">
                            <%=rs.getString("class_name")%><%=rs.getString("section")!=null ? " - "+rs.getString("section") : ""%>
                        </option>
                        <% } } catch (Exception e) { e.printStackTrace(); } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Subject</label>
                    <select name="subjectId">
                        <option value="">Select Subject</option>
                        <%
                        try (Connection conn = SQLConnection.getConnection()) {
                            PreparedStatement ps = conn.prepareStatement(
                                "SELECT subject_id, subject_name FROM subjects ORDER BY subject_name");
                            ResultSet rs = ps.executeQuery();
                            while (rs.next()) { %>
                        <option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
                        <% } } catch (Exception e) { e.printStackTrace(); } %>
                    </select>
                </div>

                <div class="form-group" style="grid-column: 1 / -1;">
                    <label>Description</label>
                    <textarea name="description" rows="3" placeholder="Enter document description..."></textarea>
                </div>

                <div class="form-group" style="grid-column: 1 / -1;">
                    <label>Select File <span class="required">*</span></label>
                    <input type="file" name="documentFile" required
                           accept=".pdf,.doc,.docx,.ppt,.pptx,.jpg,.jpeg,.png">
                    <small>PDF, DOC, DOCX, PPT, PPTX, JPG, PNG (Max 10MB)</small>
                </div>

            </div>

            <button type="button" class="btn btn-primary" onclick="uploadDocument()">
                <i class="fas fa-cloud-upload-alt"></i> Upload Document
            </button>
        </form>
    </div>

</div>

<script>
function uploadDocument() {
    var form = document.getElementById('documentForm');
    if (!form) return;
    
    var title = form.title.value.trim();
    var docType = form.documentType.value;
    var fileInput = form.querySelector('input[type="file"]');
    var file = fileInput ? fileInput.files[0] : null;
    
    if (!title) {
        document.getElementById('docResult').innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please enter a document title.</div>';
        return;
    }
    if (!docType) {
        document.getElementById('docResult').innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please select a document type.</div>';
        return;
    }
    if (!file) {
        document.getElementById('docResult').innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please select a file to upload.</div>';
        return;
    }

    var submitBtn = form.querySelector('.btn-primary');
    var originalHTML = submitBtn.innerHTML;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Uploading...';
    submitBtn.disabled = true;

    var formData = new FormData(form);

    fetch('<%=request.getContextPath()%>/teacherUploadDocument', {
        method: 'POST',
        body: formData
    })
    .then(function(response) { return response.text(); })
    .then(function(html) {
        var resultDiv = document.getElementById('docResult');
        if (html.includes('success')) {
            resultDiv.innerHTML = '<div class="alert alert-success"><i class="fas fa-check-circle"></i> Document uploaded successfully!</div>';
            form.reset();
        } else if (html.includes('error')) {
            resultDiv.innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Upload failed. Please try again.</div>';
        } else {
            resultDiv.innerHTML = html;
        }
    })
    .catch(function(error) {
        console.error('Error:', error);
        document.getElementById('docResult').innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> An error occurred during upload.</div>';
    })
    .finally(function() {
        submitBtn.innerHTML = originalHTML;
        submitBtn.disabled = false;
    });
}

// Prevent double-tap zoom on mobile
document.addEventListener('dblclick', function(event) {
    event.preventDefault();
}, { passive: false });
</script>
