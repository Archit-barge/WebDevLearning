<%@ page import="com.seh.model.User" %>
<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("student")) {
        response.sendRedirect("../login.jsp");
        return;
    }
    User user = (User) session.getAttribute("user");
    String avatarLetter = user.getFullName() != null && user.getFullName().length() > 0
        ? String.valueOf(user.getFullName().charAt(0)).toUpperCase() : "S";
%>
<style>
/* ── Blue student palette overrides ── */
.sd-page .top-bar {
    display: flex; justify-content: space-between; align-items: center;
    width: 100%; margin-bottom: 2rem; padding: 1.5rem 2rem;
    background: #fff; border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}
.sd-page .welcome-section h1 { font-size: 2rem; font-weight: 700; color: #1e293b; margin-bottom: 0.5rem; }
.sd-page .welcome-section p  { color: #64748b; }
.sd-page .user-info  { display: flex; align-items: center; gap: 1rem; }
.sd-page .user-avatar {
    width: 50px; height: 50px; border-radius: 50%;
    background: linear-gradient(135deg, #1e3a8a, #1e40af);
    display: flex; align-items: center; justify-content: center;
    color: #fff; font-weight: 600; font-size: 1.2rem;
}
.sd-page .logout-btn {
    background: #ef4444; color: #fff; border: none;
    padding: 0.75rem 1.5rem; border-radius: 8px;
    cursor: pointer; transition: all 0.3s; font-weight: 500;
}
.sd-page .logout-btn:hover { background: #dc2626; transform: translateY(-1px); }

/* Filters */
.sd-page .filters-container {
    background: #fff; padding: 1.5rem; border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    margin-bottom: 2rem; border: 1px solid #e2e8f0;
}
.sd-page .filters-grid {
    display: grid;
    grid-template-columns: 2.5fr 1.4fr 1.4fr;
    gap: 1rem; align-items: end;
}
.sd-page .filter-group { display: flex; flex-direction: column; }
.sd-page .filter-group label {
    font-weight: 600; color: #374151; margin-bottom: 0.5rem; font-size: 0.9rem;
}
.sd-page .filter-group input,
.sd-page .filter-group select {
    padding: 0.75rem; border: 2px solid #e5e7eb; border-radius: 8px;
    font-size: 0.9rem; background: #f9fafb; transition: all 0.3s;
    height: 44px; font-family: inherit;
}
.sd-page .filter-group input:focus,
.sd-page .filter-group select:focus {
    outline: none; border-color: #1e3a8a; background: #fff;
    box-shadow: 0 0 0 3px rgba(30,58,138,0.1);
}

/* Doc grid & cards */
.sd-page .doc-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.8rem;
}
.sd-page .doc-card {
    background: #fff; border-radius: 18px; padding: 1.5rem;
    box-shadow: 0 12px 28px rgba(15,23,42,0.08);
    cursor: pointer; display: flex; flex-direction: column;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.sd-page .doc-card:hover { transform: translateY(-3px); box-shadow: 0 18px 40px rgba(15,23,42,0.12); }
.sd-page .doc-title    { font-size: 1.25rem; font-weight: 700; color: #1e293b; margin-bottom: 0.4rem; }
.sd-page .doc-sub      { font-size: 0.95rem; color: #64748b; margin-bottom: 0.9rem; }
.sd-page .doc-uploader { font-size: 0.9rem; color: #475569; margin-bottom: 1.2rem; }
.sd-page .doc-actions  { margin-top: auto; }
.sd-page .empty-state  { text-align: center; padding: 3rem; color: #94a3b8; grid-column: 1 / -1; }
.sd-page .empty-state i { font-size: 3rem; display: block; margin-bottom: 1rem; opacity: 0.5; }

/* Buttons */
.sd-page .btn {
    padding: 0.75rem 1.5rem; border-radius: 6px;
    font-size: 0.95rem; font-weight: 500;
    cursor: pointer; transition: all 0.2s; border: none;
    display: inline-flex; align-items: center; gap: 0.4rem;
    text-decoration: none;
}
.sd-page .btn-primary      { background: #1e3a8a; color: #fff; }
.sd-page .btn-primary:hover { background: #1e40af; }
.sd-page .btn-secondary     { background: #e5e7eb; color: #374151; }
.sd-page .btn-secondary:hover { background: #d1d5db; }

/* Modal */
.sd-page .modal-overlay {
    display: none; position: fixed; top: 0; left: 0;
    width: 100%; height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 1000; align-items: center; justify-content: center;
}
.sd-page .modal-overlay.active { display: flex; }
.sd-page .modal-container {
    background: #fff; border-radius: 12px;
    box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
    max-height: 90vh; overflow-y: auto;
    width: 90%; max-width: 900px; padding: 2rem;
}
.sd-page .modal-header {
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 1.5rem; padding-bottom: 1rem;
    border-bottom: 1px solid #e5e7eb;
}
.sd-page .modal-header h2 { margin: 0; color: #1e293b; font-size: 1.5rem; }
.sd-page .modal-close {
    background: none; border: none; font-size: 1.5rem;
    cursor: pointer; color: #64748b;
    width: 2rem; height: 2rem;
    display: flex; align-items: center; justify-content: center;
}
.sd-page .modal-close:hover { color: #1e293b; }
.sd-page .details-content { margin-bottom: 1.5rem; }
.sd-page .detail-section  { margin-bottom: 2rem; padding-bottom: 1.5rem; border-bottom: 1px solid #e5e7eb; }
.sd-page .detail-section:last-child { border-bottom: none; }
.sd-page .doc-details-grid {
    display: grid;
    grid-template-columns: 1fr auto 1fr auto 1fr;
    gap: 2rem; align-items: start;
}
.sd-page .detail-col     { display: flex; flex-direction: column; gap: 1.5rem; }
.sd-page .vertical-divider { width: 1px; background: #e5e7eb; height: 100%; }
.sd-page .detail-item    { display: flex; flex-direction: column; }
.sd-page .detail-item label { font-weight: 600; color: #374151; font-size: 0.9rem; margin-bottom: 0.5rem; }
.sd-page .detail-item p  { color: #64748b; margin: 0; padding: 0.5rem 0; word-break: break-word; }
.sd-page .file-name      { word-break: break-all; font-weight: 500; color: #475569; }
.sd-page .form-actions {
    display: flex; gap: 1rem; justify-content: flex-end;
    margin-top: 1.5rem; padding-top: 1.5rem; border-top: 1px solid #e5e7eb;
}
@media (max-width: 768px) {
            body {
                padding: 12px;
            }

            .top-bar {
                flex-direction: column;
                text-align: center;
                padding: 16px;
                gap: 14px;
                border-radius: var(--radius-lg);
                margin-bottom: 16px;
            }

            .welcome-section {
                min-width: 100%;
            }

            .welcome-section h1 {
                font-size: 1.35rem;
            }

            .user-info {
                width: 100%;
                justify-content: center;
                flex-wrap: wrap;
            }

            .user-details {
                text-align: center;
            }

            .logout-btn {
                width: 100%;
                justify-content: center;
            }

            .header {
                flex-direction: column;
                text-align: center;
                padding: 18px;
                border-radius: var(--radius-md);
                margin-bottom: 18px;
            }

            .header-icon {
                margin-right: 0;
                margin-bottom: 12px;
                width: 50px;
                height: 50px;
                font-size: 1.25rem;
            }
@media (max-width: 1024px) { .sd-page .filters-grid { grid-template-columns: 2fr 1fr; row-gap: 1rem; } }
@media (max-width: 768px)  {
    .sd-page .filters-grid      { grid-template-columns: 1fr; }
    .sd-page .doc-details-grid  { grid-template-columns: 1fr; }
    .sd-page .modal-container   { width: 95%; padding: 1.5rem; }
}
</style>

<div class="sd-page">

    
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Document Library</h1>
            <p>Syllabus and notes for your class</p>
        </div>
        <div class="user-info">
            <div class="user-avatar"><%= avatarLetter %></div>
            <div >
                <div style="font-weight: 700; font-size: 0.85rem;"><%= user.getUsername() %></div>
                <div style="font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase;"><%= user.getRole() %></div>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </div>

    <form onsubmit="event.preventDefault(); sdLoad();" class="filters-container">
        <div class="filters-grid">
            <div class="filter-group">
                <label>Search</label>
                <input type="text" id="sdSearch" placeholder="Search by title or uploader" oninput="sdLoad()">
            </div>
            <div class="filter-group">
                <label>Subject</label>
                <select id="sdSubject" onchange="sdLoad()">
                    <option value="">All Subjects</option>
                    <%
                    try (Connection conn = SQLConnection.getConnection()) {
                        ResultSet rs = conn.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name").executeQuery();
                        while (rs.next()) { %>
                    <option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
                    <% } } catch (Exception e) { e.printStackTrace(); } %>
                </select>
            </div>
            <div class="filter-group">
                <label>Type</label>
                <select id="sdType" onchange="sdLoad()">
                    <option value="">All Types</option>
                    <option value="SYLLABUS">Syllabus</option>
                    <option value="NOTES">Notes</option>
                </select>
            </div>
        </div>
    </form>

    <div class="doc-grid" id="sdGrid">
        <div class="empty-state"><i class="fas fa-spinner fa-spin"></i><p>Loading…</p></div>
    </div>

    <!-- Details Modal -->
    <div id="sdDetailsModal" class="modal-overlay" onclick="closeSdModalOnOverlay(event)">
        <div class="modal-container">
            <div class="modal-header">
                <h2 id="sdModalTitle">—</h2>
                <button class="modal-close" onclick="closeSdModal()">×</button>
            </div>
            <div class="details-content">
                <div class="detail-section">
                    <div class="detail-grid doc-details-grid">
                        <div class="detail-col">
                            <div class="detail-item"><label>Description</label><p id="sdModalDesc">—</p></div>
                            <div class="detail-item"><label>Uploaded By</label><p id="sdModalUploader">—</p></div>
                        </div>
                        <div class="vertical-divider"></div>
                        <div class="detail-col">
                            <div class="detail-item"><label>Subject</label><p id="sdModalSubject">—</p></div>
                            <div class="detail-item"><label>Class</label><p id="sdModalClass">—</p></div>
                        </div>
                        <div class="vertical-divider"></div>
                        <div class="detail-col">
                            <div class="detail-item"><label>Type</label><p id="sdModalType">—</p></div>
                            <div class="detail-item"><label>File Name</label><p id="sdModalFile" class="file-name">—</p></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-actions">
                <a id="sdDownloadBtn" class="btn btn-primary" href="#">Download</a>
                <button class="btn btn-secondary" onclick="closeSdModal()">Close</button>
            </div>
        </div>
    </div>

</div>
<script>sdLoad();</script>
