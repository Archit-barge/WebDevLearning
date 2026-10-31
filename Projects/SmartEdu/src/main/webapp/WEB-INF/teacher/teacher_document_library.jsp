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
    int currentUserId = user.getUserId();
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
    --secondary: #64748b;
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

.doc-page {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: var(--bg-light);
    color: var(--text-dark);
    line-height: 1.5;
    -webkit-font-smoothing: antialiased;
    min-height: 100vh;
    padding: 0.5rem;
}

/* ===== TOP BAR ===== */
.doc-page .top-bar {
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

.doc-page .welcome-section {
    flex: 1;
    min-width: 200px;
}

.doc-page .welcome-section h1 {
    font-size: clamp(1.25rem, 4vw, 2rem);
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 0.25rem;
}

.doc-page .welcome-section p {
    color: var(--text-muted);
    font-size: clamp(0.75rem, 2.5vw, 0.9rem);
}

.doc-page .user-info {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
    justify-content: flex-end;
}

.doc-page .user-avatar {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--white);
    font-weight: 600;
    font-size: 1.2rem;
    flex-shrink: 0;
}

.doc-page .user-details {
    display: flex;
    flex-direction: column;
    text-align: right;
}

.doc-page .user-details .name {
    font-weight: 600;
    color: var(--text-dark);
    font-size: 0.9rem;
}

.doc-page .user-details .role {
    font-size: 0.8rem;
    color: var(--text-muted);
    text-transform: capitalize;
}

.doc-page .logout-btn {
    background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
    color: var(--white);
    border: none;
    border-radius: var(--radius-sm);
    padding: 0.75rem 1.5rem;
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

.doc-page .logout-btn:hover {
    background: var(--danger-dark);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
}

.doc-page .logout-btn:active {
    transform: scale(0.98);
}

/* ===== FILTERS ===== */
.doc-page .filters-container {
    background: var(--white);
    padding: 1.5rem;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    margin-bottom: 1.5rem;
    border: 1px solid #e2e8f0;
}

.doc-page .filters-grid {
    display: grid;
    grid-template-columns: 2.5fr 1.4fr 1.4fr 1.3fr 1.3fr auto;
    gap: 1rem;
    align-items: end;
}

.doc-page .filter-group {
    display: flex;
    flex-direction: column;
}

.doc-page .filter-group label {
    font-weight: 600;
    color: var(--text-dark);
    margin-bottom: 0.5rem;
    font-size: 0.9rem;
}

.doc-page .filter-group input,
.doc-page .filter-group select {
    padding: 0.75rem;
    border: 2px solid #e5e7eb;
    border-radius: var(--radius-sm);
    font-size: 0.9rem;
    background: var(--bg-light);
    transition: var(--transition);
    height: 44px;
    font-family: inherit;
    min-height: var(--touch-target);
}

.doc-page .filter-group input:focus,
.doc-page .filter-group select:focus {
    outline: none;
    border-color: var(--primary);
    background: var(--white);
    box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

/* ===== DOC GRID & CARDS ===== */
.doc-page .doc-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.5rem;
}

.doc-page .doc-card {
    background: var(--white);
    border-radius: var(--radius-lg);
    padding: 1.5rem;
    box-shadow: var(--shadow-md);
    cursor: pointer;
    display: flex;
    flex-direction: column;
    transition: var(--transition);
    border: 1px solid #e2e8f0;
}

.doc-page .doc-card:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-lg);
    border-color: var(--primary);
}

.doc-page .doc-title {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 0.25rem;
}

.doc-page .doc-sub {
    font-size: 0.95rem;
    color: var(--text-muted);
    margin-bottom: 0.75rem;
}

.doc-page .doc-uploader {
    font-size: 0.9rem;
    color: var(--text-muted);
    margin-bottom: 1.25rem;
}

.doc-page .doc-actions {
    margin-top: auto;
}

.doc-page .empty-state {
    text-align: center;
    padding: 3rem;
    color: #94a3b8;
    grid-column: 1 / -1;
}

.doc-page .empty-state i {
    font-size: 3rem;
    display: block;
    margin-bottom: 1rem;
    opacity: 0.5;
}

/* ===== MINE BADGE ===== */
.doc-page .mine-badge {
    display: inline-block;
    margin-bottom: 0.4rem;
    padding: 0.15rem 0.55rem;
    border-radius: 999px;
    background: #dcfce7;
    color: #16a34a;
    font-size: 0.72rem;
    font-weight: 700;
    text-transform: uppercase;
}

/* ===== BUTTONS ===== */
.doc-page .btn {
    padding: 0.75rem 1.5rem;
    border-radius: var(--radius-sm);
    font-size: 0.95rem;
    font-weight: 500;
    cursor: pointer;
    transition: var(--transition);
    border: none;
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    text-decoration: none;
    min-height: var(--touch-target);
}

.doc-page .btn-primary {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: var(--white);
    box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
}

.doc-page .btn-primary:hover {
    background: var(--primary-dark);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
}

.doc-page .btn-secondary {
    background: #e5e7eb;
    color: #374151;
}

.doc-page .btn-secondary:hover {
    background: #d1d5db;
}

.doc-page .btn-danger {
    background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
    color: var(--white);
    box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
}

.doc-page .btn-danger:hover {
    background: var(--danger-dark);
    transform: translateY(-2px);
}

.doc-page .btn-outline-primary {
    background: transparent;
    border: 1.5px solid var(--primary);
    color: var(--primary);
}

.doc-page .btn-outline-primary:hover {
    background: var(--primary);
    color: var(--white);
}

/* ===== ALERTS ===== */
.doc-page .alert {
    padding: 1rem;
    border-radius: var(--radius-sm);
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    animation: fadeIn 0.3s ease-out;
}

.doc-page .alert-success {
    background: linear-gradient(135deg, #d1fae5 0%, #ecfdf5 100%);
    color: #065f46;
    border: 1px solid #a7f3d0;
}

.doc-page .alert-error {
    background: linear-gradient(135deg, #fee2e2 0%, #fef2f2 100%);
    color: #991b1b;
    border: 1px solid #fecaca;
}

/* ===== MODALS ===== */
.doc-page .modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    z-index: 1000;
    align-items: center;
    justify-content: center;
    backdrop-filter: blur(4px);
}

.doc-page .modal-overlay.active {
    display: flex;
}

.doc-page .modal-container {
    background: var(--white);
    border-radius: var(--radius-lg);
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
    max-height: 90vh;
    overflow-y: auto;
    width: 90%;
    max-width: 900px;
    padding: 2rem;
}

.doc-page #deleteDocModal .modal-container {
    max-width: 500px;
}

.doc-page .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e5e7eb;
}

.doc-page .modal-header h2 {
    margin: 0;
    color: var(--text-dark);
    font-size: 1.5rem;
    font-weight: 700;
}

.doc-page .modal-close {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: var(--text-muted);
    width: 2rem;
    height: 2rem;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    transition: var(--transition);
}

.doc-page .modal-close:hover {
    color: var(--text-dark);
    background: var(--bg-light);
}

/* ===== DETAIL GRID ===== */
.doc-page .details-content {
    margin-bottom: 1.5rem;
}

.doc-page .detail-section {
    margin-bottom: 2rem;
    padding-bottom: 1.5rem;
    border-bottom: 1px solid #e5e7eb;
}

.doc-page .detail-section:last-child {
    border-bottom: none;
}

.doc-page .doc-details-grid {
    display: grid;
    grid-template-columns: 1fr auto 1fr auto 1fr;
    gap: 2rem;
    align-items: start;
}

.doc-page .detail-col {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
}

.doc-page .vertical-divider {
    width: 1px;
    background: #e5e7eb;
    height: 100%;
}

.doc-page .detail-item {
    display: flex;
    flex-direction: column;
}

.doc-page .detail-item label {
    font-weight: 600;
    color: #374151;
    font-size: 0.9rem;
    margin-bottom: 0.5rem;
}

.doc-page .detail-item p {
    color: var(--text-muted);
    margin: 0;
    padding: 0.5rem 0;
    word-break: break-word;
}

.doc-page .file-name {
    word-break: break-all;
    font-weight: 500;
    color: #475569;
}

/* ===== FORM INSIDE EDIT MODAL ===== */
.doc-page .form-actions {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
    margin-top: 2rem;
    padding-top: 1.5rem;
    border-top: 1px solid #e5e7eb;
}

.doc-page .form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin-bottom: 1.5rem;
}

.doc-page .form-group {
    display: flex;
    flex-direction: column;
}

.doc-page .form-group label {
    font-weight: 600;
    margin-bottom: 0.5rem;
    color: var(--text-dark);
    font-size: 0.9rem;
}

.doc-page .form-group input,
.doc-page .form-group select,
.doc-page .form-group textarea {
    padding: 0.75rem;
    border: 1px solid #e5e7eb;
    border-radius: var(--radius-sm);
    font-size: 0.95rem;
    font-family: inherit;
    transition: var(--transition);
}

.doc-page .form-group input:focus,
.doc-page .form-group select:focus,
.doc-page .form-group textarea:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

.doc-page .form-group textarea {
    resize: vertical;
    min-height: 100px;
}

.doc-page .form-group small {
    display: block;
    margin-top: 0.35rem;
    color: var(--text-muted);
    font-size: 0.8rem;
}

.doc-page .required {
    color: var(--danger);
}

/* ===== RESPONSIVE BREAKPOINTS ===== */

/* Large tablet */
@media (max-width: 1200px) {
    .doc-page .filters-grid {
        grid-template-columns: 2fr 1fr 1fr;
        row-gap: 1.25rem;
    }
}

/* Mobile */
@media (max-width: 768px) {
    .doc-page {
        padding: 0.5rem;
    }

    .doc-page .top-bar {
        padding: 1rem;
        border-radius: var(--radius-md);
        margin-bottom: 1rem;
        flex-direction: column;
        gap: 0.75rem;
        text-align: center;
    }

    .doc-page .welcome-section {
        min-width: 100%;
        text-align: center;
    }

    .doc-page .welcome-section h1 {
        font-size: 1.25rem;
    }

    .doc-page .user-info {
        width: 100%;
        justify-content: center;
    }

    .doc-page .user-details {
        display: none;
    }

    .doc-page .logout-btn {
        width: 100%;
        justify-content: center;
    }

    .doc-page .filters-container {
        padding: 1rem;
        margin-bottom: 1rem;
        border-radius: var(--radius-md);
    }

    .doc-page .filters-grid {
        grid-template-columns: 1fr;
        gap: 0.75rem;
    }

    .doc-page .filter-group input,
    .doc-page .filter-group select {
        width: 100%;
        font-size: 0.95rem;
        padding: 12px 14px;
    }

    .doc-page .btn {
        width: 100%;
        justify-content: center;
    }

    .doc-page .doc-grid {
        gap: 1rem;
    }

    .doc-page .doc-card {
        padding: 1rem;
        border-radius: var(--radius-md);
    }

    .doc-page .doc-details-grid {
        grid-template-columns: 1fr;
    }

    .doc-page .vertical-divider {
        display: none;
    }

    .doc-page .modal-container {
        width: 95%;
        padding: 1.5rem;
    }
}

/* Small phones */
@media (max-width: 480px) {
    .doc-page {
        padding: 0.375rem;
    }

    .doc-page .top-bar {
        padding: 0.875rem;
        border-radius: var(--radius-md);
        margin-bottom: 0.75rem;
        gap: 0.625rem;
    }

    .doc-page .welcome-section h1 {
        font-size: 1.125rem;
    }

    .doc-page .welcome-section p {
        font-size: 0.8rem;
    }

    .doc-page .user-avatar {
        width: 36px;
        height: 36px;
        font-size: 0.875rem;
        border-radius: 8px;
    }

    .doc-page .logout-btn {
        font-size: 0.8125rem;
        padding: 10px 12px;
    }

    .doc-page .filters-container {
        padding: 0.875rem;
        margin-bottom: 0.75rem;
    }
}

/* Large Desktop */
@media (min-width: 1200px) {
    .doc-page .welcome-section h1 {
        font-size: 2rem;
    }

    .doc-page .welcome-section p {
        font-size: 1.125rem;
    }

    .doc-page .filters-container {
        padding: 2rem;
        border-radius: var(--radius-xl);
    }

    .doc-page .doc-card {
        padding: 1.75rem;
        border-radius: var(--radius-xl);
    }

    .doc-page .modal-container {
        padding: 2.5rem;
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

.doc-page .top-bar {
    animation: fadeIn 0.4s ease-out;
}

.doc-page .filters-container {
    animation: fadeIn 0.4s ease-out 0.1s both;
}

.doc-page .doc-card {
    animation: fadeIn 0.4s ease-out;
}

/* ===== TOUCH IMPROVEMENTS ===== */
@media (hover: none) and (pointer: coarse) {
    .doc-page .doc-card:hover,
    .doc-page .logout-btn:hover,
    .doc-page .btn-primary:hover,
    .doc-page .btn-secondary:hover,
    .doc-page .btn-danger:hover,
    .doc-page .btn-outline-primary:hover {
        transform: none;
    }

    .doc-page .doc-card:active,
    .doc-page .logout-btn:active,
    .doc-page .btn:active {
        transform: scale(0.98);
    }
}
</style>

<div class="doc-page">

    <div class="top-bar">
        <div class="welcome-section">
            <h1>Document Library</h1>
            <p>Browse documents — edit or delete only your own uploads</p>
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

    <form onsubmit="event.preventDefault(); dlLoad();" class="filters-container">
        <div class="filters-grid">
            <div class="filter-group">
                <label>Search</label>
                <input type="text" id="dlSearch" placeholder="Search by title or uploader" oninput="dlLoad()">
            </div>
            <div class="filter-group">
                <label>Class</label>
                <select id="dlClass" onchange="dlLoad()">
                    <option value="">All Classes</option>
                    <%
                    try (Connection c = SQLConnection.getConnection()) {
                        ResultSet rs = c.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name").executeQuery();
                        while (rs.next()) { %>
                    <option value="<%=rs.getInt("class_id")%>"><%=rs.getString("class_name")%><%=rs.getString("section")!=null?" - "+rs.getString("section"):""%></option>
                    <% } } %>
                </select>
            </div>
            <div class="filter-group">
                <label>Subject</label>
                <select id="dlSubject" onchange="dlLoad()">
                    <option value="">All Subjects</option>
                    <%
                    try (Connection c = SQLConnection.getConnection()) {
                        ResultSet rs = c.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name").executeQuery();
                        while (rs.next()) { %>
                    <option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
                    <% } } %>
                </select>
            </div>
            <div class="filter-group">
                <label>Type</label>
                <select id="dlType" onchange="dlLoad()">
                    <option value="">All Types</option>
                    <option value="SYLLABUS">Syllabus</option>
                    <option value="NOTES">Notes</option>
                </select>
            </div>
            <div class="filter-group">
                <label>Show</label>
                <select id="dlOwner" onchange="dlLoad()">
                    <option value="">All Uploaders</option>
                    <option value="mine">My Documents</option>
                </select>
            </div>
            <div class="filter-group">
                <label>&nbsp;</label>
                <button type="button" class="btn btn-primary" onclick="loadPage('teacher_post_doc.jsp')" style="height:44px;padding:0 1.5rem;white-space:nowrap;">
                    <i class="fas fa-plus"></i> Post Document
                </button>
            </div>
        </div>
    </form>

    <div class="doc-grid" id="docGrid">
        <div class="empty-state"><i class="fas fa-spinner fa-spin"></i><p>Loading…</p></div>
    </div>

    <!-- Details Modal -->
    <div id="docDetailsModal" class="modal-overlay" onclick="closeDocModalOnOverlay(event)">
        <div class="modal-container">
            <div class="modal-header">
                <h2 id="docModalTitle">—</h2>
                <button class="modal-close" onclick="closeDocModal()">×</button>
            </div>
            <div class="details-content">
                <div class="detail-section">
                    <div class="detail-grid doc-details-grid">
                        <div class="detail-col">
                            <div class="detail-item"><label>Description</label><p id="docModalDescription">—</p></div>
                            <div class="detail-item"><label>Uploaded By</label><p id="docModalUploader">—</p></div>
                        </div>
                        <div class="vertical-divider"></div>
                        <div class="detail-col">
                            <div class="detail-item"><label>Subject</label><p id="docModalSubject">—</p></div>
                            <div class="detail-item"><label>Class</label><p id="docModalClass">—</p></div>
                        </div>
                        <div class="vertical-divider"></div>
                        <div class="detail-col">
                            <div class="detail-item"><label>Type</label><p id="docModalType">—</p></div>
                            <div class="detail-item"><label>File Name</label><p id="docModalFileName" class="file-name">—</p></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-actions" id="docModalActions"></div>
        </div>
    </div>

    <!-- Delete Modal -->
    <div id="deleteDocModal" class="modal-overlay">
        <div class="modal-container">
            <div class="modal-header">
                <h2>Delete Document</h2>
                <button class="modal-close" onclick="closeDeleteModal()">×</button>
            </div>
            <p style="color:#64748b;margin-bottom:1rem;">Are you sure you want to delete this document?</p>
            <div id="deleteDocResult"></div>
            <div class="form-actions">
                <button class="btn btn-danger" onclick="confirmDelete()">Delete</button>
                <button class="btn btn-secondary" onclick="closeDeleteModal()">Cancel</button>
            </div>
        </div>
    </div>

    <!-- Edit Modal -->
    <div id="editDocModal" class="modal-overlay" onclick="closeEditModalOuter(event)">
        <div class="modal-container">
            <div class="modal-header">
                <h2>Edit Document</h2>
                <button class="modal-close" onclick="closeEditModal()">×</button>
            </div>
            <div id="editDocResult"></div>
            <form id="editDocumentForm" enctype="multipart/form-data" onsubmit="updateDocument(event)">
                <input type="hidden" id="editDocId">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Title <span class="required">*</span></label>
                        <input type="text" id="editDocTitle" required>
                    </div>
                    <div class="form-group">
                        <label>Document Type <span class="required">*</span></label>
                        <select id="editDocType" required>
                            <option value="SYLLABUS">Syllabus</option>
                            <option value="NOTES">Notes</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Class</label>
                        <select id="editDocClass">
                            <option value="">All Classes</option>
                            <%
                            try (Connection c = SQLConnection.getConnection()) {
                                ResultSet rs = c.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name").executeQuery();
                                while (rs.next()) { %>
                            <option value="<%=rs.getInt("class_id")%>"><%=rs.getString("class_name")%><%=rs.getString("section")!=null?" - "+rs.getString("section"):""%></option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Subject</label>
                        <select id="editDocSubject">
                            <option value="">All Subjects</option>
                            <%
                            try (Connection c = SQLConnection.getConnection()) {
                                ResultSet rs = c.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name").executeQuery();
                                while (rs.next()) { %>
                            <option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <textarea id="editDocDescription"></textarea>
                    </div>
                    <div class="form-group">
                        <label>Replace File</label>
                        <input type="file" id="editDocFile" name="documentFile" accept=".pdf,.doc,.docx,.ppt,.pptx,.jpg,.jpeg,.png">
                        <small>Leave empty to keep current file</small>
                    </div>
                </div>
                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update</button>
                </div>
            </form>
        </div>
    </div>

</div>

<script>
// Set the current teacher's user ID so script.js functions can check ownership
window.DL_MY_USER_ID = <%=currentUserId%>;
// Trigger initial load — function defined in script.js
dlLoad();
</script>
