<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.seh.util.SQLConnection, com.seh.model.User, java.util.*" %>
<%
String role = (String) session.getAttribute("role");
if(role == null || !role.equals("teacher")){
    response.sendRedirect("../login.jsp");
    return;
}

User user = (User) session.getAttribute("user");
String avatarLetter = "T";
if (user != null && user.getUsername() != null && user.getUsername().length() > 0) {
    avatarLetter = String.valueOf(user.getUsername().charAt(0)).toUpperCase();
}

String successMsg = (String) request.getAttribute("success");
String errorMsg   = (String) request.getAttribute("error");

List<Map<String, Object>> timetables = new ArrayList<>();
try (Connection conn = SQLConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(
         "SELECT d.document_id, d.original_file_name, d.upload_date, c.class_name, c.section " +
         "FROM documents d JOIN classes c ON d.class_id = c.class_id " +
         "WHERE d.document_type = 'TIMETABLES' AND d.uploaded_by = ? " +
         "ORDER BY d.upload_date DESC")) {
    ps.setInt(1, user.getUserId());
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        Map<String, Object> t = new HashMap<>();
        t.put("id",          rs.getInt("document_id"));
        t.put("file_path",   rs.getString("original_file_name"));
        t.put("uploaded_at", rs.getTimestamp("upload_date"));
        t.put("class_name",  rs.getString("class_name"));
        t.put("section",     rs.getString("section"));
        timetables.add(t);
    }
} catch (Exception e) {
    e.printStackTrace();
}
%>

<style>
/* ===== CSS VARIABLES FOR CONSISTENT THEMING ===== */
:root {
    --primary: #3b82f6;
    --primary-light: #60a5fa;
    --primary-dark: #2563eb;
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

.tt-content {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: var(--bg-light);
    color: var(--text-dark);
    line-height: 1.5;
    -webkit-font-smoothing: antialiased;
    min-height: 100vh;
    padding: 0.5rem;
}

/* ===== TOP BAR ===== */
.tt-content .top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
    margin-bottom: 1.5rem;
    padding: 1.25rem 1.5rem;
    background: var(--white);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    flex-wrap: wrap;
    gap: 1rem;
}

.tt-content .welcome-section {
    flex: 1;
    min-width: 200px;
}

.tt-content .welcome-section h1 {
    font-size: clamp(1.25rem, 4vw, 1.75rem);
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 0.25rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.tt-content .welcome-section h1 i {
    color: var(--primary);
}

.tt-content .welcome-section p {
    color: var(--text-muted);
    font-size: clamp(0.75rem, 2.5vw, 0.9rem);
    font-weight: 500;
}

.tt-content .user-info {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
    justify-content: flex-end;
}

.tt-content .user-avatar {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--white);
    font-weight: 600;
    font-size: 1.1rem;
    flex-shrink: 0;
}

.tt-content .user-details {
    display: flex;
    flex-direction: column;
    text-align: right;
    min-width: 80px;
}

.tt-content .user-details .name {
    font-weight: 600;
    color: var(--text-dark);
    font-size: 0.9rem;
    line-height: 1.2;
}

.tt-content .user-details .role {
    font-size: 0.8rem;
    color: var(--text-muted);
    text-transform: capitalize;
}

.tt-content .logout-btn {
    background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
    color: var(--white);
    border: none;
    border-radius: var(--radius-sm);
    padding: 10px 16px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.85rem;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
    white-space: nowrap;
    display: flex;
    align-items: center;
    gap: 6px;
    min-height: var(--touch-target);
}

.tt-content .logout-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
}

.tt-content .logout-btn:active {
    transform: scale(0.98);
}

/* ===== UPLOAD CARD ===== */
.tt-content .upload-card {
    background: var(--white);
    border-radius: var(--radius-lg);
    padding: 1.75rem;
    box-shadow: var(--shadow-md);
    border: 1px solid #e2e8f0;
    margin-bottom: 1.5rem;
}

.tt-content .upload-card h2 {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 1.25rem;
    padding-bottom: 0.75rem;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.tt-content .upload-card h2 i {
    color: var(--primary);
}

.tt-content .form-group {
    margin-bottom: 1rem;
}

.tt-content .form-group label {
    display: block;
    font-weight: 600;
    color: var(--text-dark);
    margin-bottom: 0.5rem;
    font-size: 0.875rem;
}

.tt-content .form-group select,
.tt-content .form-group input[type="file"] {
    width: 100%;
    padding: 0.75rem 0.875rem;
    border: 2px solid #e2e8f0;
    border-radius: var(--radius-sm);
    font-size: 0.9rem;
    color: var(--text-dark);
    background: var(--bg-light);
    transition: var(--transition);
    min-height: var(--touch-target);
}

.tt-content .form-group select:focus,
.tt-content .form-group input:focus {
    outline: none;
    border-color: var(--primary);
    background: var(--white);
    box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
}

.tt-content .form-group small {
    display: block;
    margin-top: 0.35rem;
    color: var(--text-muted);
    font-size: 0.8rem;
}

.tt-content .btn-upload {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: var(--white);
    border: none;
    border-radius: var(--radius-sm);
    padding: 0.875rem 1.5rem;
    font-size: 0.95rem;
    font-weight: 600;
    cursor: pointer;
    width: 100%;
    margin-top: 0.5rem;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
}

.tt-content .btn-upload:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
}

.tt-content .btn-upload:active {
    transform: scale(0.98);
}

/* ===== FLASH ALERTS ===== */
.tt-content .alert {
    padding: 0.875rem 1rem;
    border-radius: var(--radius-sm);
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    gap: 0.65rem;
    font-size: 0.9rem;
    animation: fadeIn 0.3s ease-out;
}

.tt-content .alert-success {
    background: linear-gradient(135deg, #d1fae5 0%, #ecfdf5 100%);
    color: #065f46;
    border: 1px solid #a7f3d0;
}

.tt-content .alert-error {
    background: linear-gradient(135deg, #fee2e2 0%, #fef2f2 100%);
    color: #991b1b;
    border: 1px solid #fecaca;
}

.tt-content .alert-info {
    background: linear-gradient(135deg, #dbeafe 0%, #eff6ff 100%);
    color: #1e40af;
    border: 1px solid #bfdbfe;
}

/* ===== LIST CARD ===== */
.tt-content .list-card {
    background: var(--white);
    border-radius: var(--radius-lg);
    padding: 1.75rem;
    box-shadow: var(--shadow-md);
    border: 1px solid #e2e8f0;
}

.tt-content .list-card h2 {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 1.25rem;
    padding-bottom: 0.75rem;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.tt-content .list-card h2 i {
    color: var(--primary);
}

.tt-content .timetable-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 1rem;
}

.tt-content .timetable-card {
    background: var(--bg-light);
    border: 2px solid #e2e8f0;
    border-radius: var(--radius-md);
    padding: 1rem;
    transition: var(--transition);
}

.tt-content .timetable-card:hover {
    border-color: var(--primary);
    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.12);
}

.tt-content .timetable-card h4 {
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--text-dark);
    margin-bottom: 0.5rem;
    display: flex;
    align-items: center;
    gap: 0.4rem;
}

.tt-content .timetable-card h4 i {
    color: var(--primary);
}

.tt-content .timetable-card p {
    font-size: 0.8rem;
    color: var(--text-muted);
    margin-bottom: 0.3rem;
    display: flex;
    align-items: center;
    gap: 0.4rem;
}

.tt-content .timetable-card p i {
    width: 14px;
}

.tt-content .card-actions {
    display: flex;
    gap: 0.5rem;
    margin-top: 0.75rem;
}

.tt-content .delete-btn {
    background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
    color: #991b1b;
    border: none;
    border-radius: 6px;
    padding: 0.5rem 0.75rem;
    font-size: 0.8rem;
    font-weight: 600;
    cursor: pointer;
    flex: 1;
    transition: var(--transition);
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.4rem;
}

.tt-content .delete-btn:hover {
    background: #fecaca;
    transform: translateY(-1px);
}

.tt-content .delete-btn:active {
    transform: scale(0.98);
}

.tt-content .no-data {
    text-align: center;
    padding: 2.5rem 1rem;
    color: #94a3b8;
}

.tt-content .no-data i {
    font-size: 2.5rem;
    margin-bottom: 0.75rem;
    display: block;
    opacity: 0.5;
}

.tt-content .no-data p {
    font-size: 0.95rem;
}

/* ===== RESPONSIVE BREAKPOINTS ===== */

/* Tablet */
@media (max-width: 1024px) {
    .tt-content .timetable-grid {
        grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
        gap: 0.875rem;
    }
}

/* Mobile */
@media (max-width: 768px) {
    .tt-content {
        padding: 0.5rem;
    }

    .tt-content .top-bar {
        padding: 1rem;
        border-radius: var(--radius-md);
        margin-bottom: 1rem;
        flex-direction: column;
        gap: 0.75rem;
        text-align: center;
    }

    .tt-content .welcome-section {
        min-width: 100%;
        text-align: center;
    }

    .tt-content .welcome-section h1 {
        font-size: 1.25rem;
        justify-content: center;
    }

    .tt-content .welcome-section p {
        font-size: 0.75rem;
    }

    .tt-content .user-info {
        width: 100%;
        justify-content: center;
        gap: 0.625rem;
    }

    .tt-content .user-details {
        display: none;
    }

    .tt-content .logout-btn {
        padding: 10px 14px;
        font-size: 0.8rem;
        width: 100%;
        justify-content: center;
    }

    .tt-content .upload-card {
        padding: 1rem;
        margin-bottom: 1rem;
        border-radius: var(--radius-md);
    }

    .tt-content .upload-card h2 {
        font-size: 1rem;
        margin-bottom: 1rem;
    }

    .tt-content .form-group input,
    .tt-content .form-group select {
        font-size: 0.95rem;
        padding: 12px 14px;
    }

    .tt-content .btn-upload {
        padding: 14px 16px;
        font-size: 0.9rem;
    }

    .tt-content .list-card {
        padding: 1rem;
        margin-bottom: 1rem;
        border-radius: var(--radius-md);
    }

    .tt-content .list-card h2 {
        font-size: 1rem;
        margin-bottom: 1rem;
    }

    .tt-content .timetable-grid {
        grid-template-columns: 1fr;
        gap: 0.75rem;
    }

    .tt-content .timetable-card {
        padding: 0.875rem;
    }

    .tt-content .timetable-card h4 {
        font-size: 0.9rem;
    }

    .tt-content .timetable-card p {
        font-size: 0.75rem;
    }

    .tt-content .no-data {
        padding: 2rem 0.75rem;
    }

    .tt-content .no-data i {
        font-size: 2rem;
    }
}

/* Small phones */
@media (max-width: 480px) {
    .tt-content {
        padding: 0.375rem;
    }

    .tt-content .top-bar {
        padding: 0.875rem;
        margin-bottom: 0.75rem;
        gap: 0.625rem;
    }

    .tt-content .welcome-section h1 {
        font-size: 1.125rem;
    }

    .tt-content .welcome-section p {
        font-size: 0.6875rem;
    }

    .tt-content .user-avatar {
        width: 36px;
        height: 36px;
        font-size: 0.875rem;
    }

    .tt-content .logout-btn {
        padding: 10px 12px;
        font-size: 0.75rem;
    }

    .tt-content .upload-card,
    .tt-content .list-card {
        padding: 0.875rem;
        margin-bottom: 0.75rem;
    }

    .tt-content .upload-card h2,
    .tt-content .list-card h2 {
        font-size: 0.9375rem;
    }

    .tt-content .form-group label {
        font-size: 0.8125rem;
    }

    .tt-content .alert {
        padding: 0.75rem 0.875rem;
        font-size: 0.8125rem;
    }
}

/* Large Desktop */
@media (min-width: 1200px) {
    .tt-content .welcome-section h1 {
        font-size: 2rem;
    }

    .tt-content .welcome-section p {
        font-size: 1.125rem;
    }

    .tt-content .upload-card {
        padding: 2rem;
        border-radius: var(--radius-xl);
        margin-bottom: 2rem;
    }

    .tt-content .upload-card h2 {
        font-size: 1.5rem;
    }

    .tt-content .list-card {
        padding: 2rem;
        border-radius: var(--radius-xl);
    }

    .tt-content .list-card h2 {
        font-size: 1.5rem;
    }

    .tt-content .timetable-grid {
        gap: 1.5rem;
    }

    .tt-content .timetable-card {
        padding: 1.25rem;
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

.tt-content .top-bar {
    animation: fadeIn 0.4s ease-out;
}

.tt-content .upload-card {
    animation: fadeIn 0.4s ease-out 0.1s both;
}

.tt-content .list-card {
    animation: fadeIn 0.4s ease-out 0.15s both;
}

/* ===== TOUCH IMPROVEMENTS ===== */
@media (hover: none) and (pointer: coarse) {
    .tt-content .logout-btn:hover,
    .tt-content .btn-upload:hover,
    .tt-content .delete-btn:hover,
    .tt-content .timetable-card:hover {
        transform: none;
    }

    .tt-content .logout-btn:active,
    .tt-content .btn-upload:active,
    .tt-content .delete-btn:active {
        transform: scale(0.98);
    }
}
</style>

<div class="tt-content">

    <div class="top-bar">
        <div class="welcome-section">
            <h1><i class="fas fa-clock"></i> Timetable Management</h1>
            <p>Welcome back, <%=user.getUsername()%>! Upload and manage class timetables</p>
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

    <div class="upload-card">
        <h2><i class="fas fa-upload"></i> Upload Class Timetable</h2>

        <div id="ttResult">
            <% if (successMsg != null) { %>
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=successMsg%></div>
            <% } else if (errorMsg != null) { %>
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=errorMsg%></div>
            <% } %>
        </div>

        <form id="ttUploadForm" enctype="multipart/form-data">
            <div class="form-group">
                <label>Select Class</label>
                <select name="classId" required>
                    <option value="">-- Choose Class --</option>
                    <%
                    try (Connection conn2 = SQLConnection.getConnection();
                         PreparedStatement ps2 = conn2.prepareStatement(
                             "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section")) {
                        ResultSet rs2 = ps2.executeQuery();
                        while (rs2.next()) { %>
                    <option value="<%=rs2.getInt("class_id")%>"><%=rs2.getString("class_name")%> - <%=rs2.getString("section")%></option>
                    <% } } catch (Exception e) { e.printStackTrace(); } %>
                </select>
            </div>
            <div class="form-group">
                <label>Select File (PDF / Image)</label>
                <input type="file" name="timetableFile" accept=".pdf,.png,.jpg,.jpeg" required>
                <small>PDF, PNG, JPG (Max 10MB)</small>
            </div>
            <button type="button" class="btn-upload" onclick="uploadTimetable()">
                <i class="fas fa-cloud-upload-alt"></i> Upload Timetable
            </button>
        </form>
    </div>

    <div class="list-card">
        <h2><i class="fas fa-list"></i> Uploaded Timetables</h2>
        <% if (!timetables.isEmpty()) { %>
        <div class="timetable-grid">
            <% for (Map<String,Object> t : timetables) {
                int ttId = (Integer) t.get("id");
                String ttCtx = request.getContextPath();
            %>
            <div class="timetable-card">
                <h4><i class="fas fa-calendar-alt"></i> <%=t.get("class_name")%> - <%=t.get("section")%></h4>
                <p><i class="fas fa-file"></i> <%=t.get("file_path")%></p>
                <p><i class="fas fa-clock"></i> <%=t.get("uploaded_at")%></p>
                <div class="card-actions">
                    <button type="button" class="delete-btn"
                        onclick="deleteTimetable('<%=ttCtx%>', <%=ttId%>)">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                </div>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="no-data">
            <i class="fas fa-folder-open"></i>
            <p>No timetables uploaded yet.</p>
        </div>
        <% } %>
    </div>

</div>

<script>
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = '<%=request.getContextPath()%>/LogoutServlet';
    }
}

function deleteTimetable(ctx, docId) {
    if (!confirm('Are you sure you want to delete this timetable?')) return;
    fetch(ctx + '/deleteDocument', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'documentId=' + docId
    }).then(function() {
        loadPage('teacher_upload_timetable.jsp');
    }).catch(function() {
        alert('Delete failed. Please try again.');
    });
}

function uploadTimetable() {
    var form = document.getElementById('ttUploadForm');
    if (!form) return;
    var fd   = new FormData(form);
    var res  = document.getElementById('ttResult');

    if (!fd.get('classId')) {
        res.innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please select a class.</div>';
        return;
    }
    var fileInput = form.querySelector('input[type="file"]');
    if (!fileInput || !fileInput.files.length) {
        res.innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Please select a file.</div>';
        return;
    }

    res.innerHTML = '<div class="alert alert-info"><i class="fas fa-spinner fa-spin"></i> Uploading...</div>';

    fetch('<%=request.getContextPath()%>/teacher/UploadTimetableServlet', { method: 'POST', body: fd })
        .then(function(r) {
            return r.text();
        })
        .then(function(html) {
            loadPage('teacher_upload_timetable.jsp');
        })
        .catch(function() {
            res.innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Upload failed. Please try again.</div>';
        });
}

// Prevent double-tap zoom on mobile
document.addEventListener('dblclick', function(event) {
    event.preventDefault();
}, { passive: false });
</script>
