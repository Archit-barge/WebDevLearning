<%@page import="com.seh.util.SQLConnection"%>
<%@page import="java.sql.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.seh.model.User"%>
<%
User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="import_users-content">
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Import Users</h1>
            <p>Welcome back, <%=user.getFullName() %>! Mass enroll users via CSV or Excel file.</p>
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

    <div class="section-card ux-section-card-compact">
        <div class="role-tabs" id="roleTabs">
            <button class="role-tab active" data-role="student" onclick="switchRole('student')">
                <i class="fas fa-user-graduate"></i> Student
            </button>
            <button class="role-tab" data-role="teacher" onclick="switchRole('teacher')">
                <i class="fas fa-chalkboard-teacher"></i> Teacher
            </button>
            <button class="role-tab" data-role="parent" onclick="switchRole('parent')">
                <i class="fas fa-user-friends"></i> Parent
            </button>
            <button class="role-tab" data-role="admin" onclick="switchRole('admin')">
                <i class="fas fa-user-shield"></i> Admin
            </button>
        </div>
    </div>

    <div class="section-card" id="uploadSection">
        <div class="upload-zone" id="dropZone" onclick="document.getElementById('fileInput').click()">
            <div class="upload-icon"><i class="fas fa-cloud-upload-alt"></i></div>
            <p class="ux-upload-zone-title">Drag & drop your file here, or click to browse</p>
            <p class="file-types">Accepts .csv, .xls, .xlsx</p>
            <div class="selected-file ux-hidden" id="selectedFileName"></div>
        </div>
        <input type="file" id="fileInput" class="ux-hidden" accept=".csv,.xls,.xlsx" onchange="onFileSelected(this)">
        <div class="upload-actions">
            <button class="btn btn-primary" id="scanBtn" onclick="scanFile()" disabled>
                <i class="fas fa-search"></i> Scan File
            </button>
            <button class="btn btn-secondary ux-hidden" id="clearBtn" onclick="clearUpload()">
                <i class="fas fa-times"></i> Clear
            </button>
        </div>
    </div>

    <div class="summary-section" id="summarySection">
        <div class="summary-card">
            <div class="loading-overlay" id="loadingOverlay">
                <div class="spinner"></div>
                <p id="loadingText">Processing your file... please wait.</p>
            </div>
            <div id="summaryResult" class="ux-hidden">
                <div class="summary-header">
                    <h3><i class="fas fa-chart-bar"></i> Import Summary</h3>
                    <span id="summaryBadge" class="badge"></span>
                </div>
                <div class="progress-bar-wrapper">
                    <div class="progress-bar-fill ux-w-0" id="progressBarFill"></div>
                </div>
                <div class="progress-text" id="progressText">0 / 0 users added</div>
                <div class="summary-table-wrapper" id="summaryTableWrapper">
                    <table>
                        <thead>
                            <tr><th>#</th><th>Name</th><th>Username</th><th>Status</th><th>Details</th></tr>
                        </thead>
                        <tbody id="summaryTableBody"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="preview-section" id="previewSection">
        <div class="section-card">
            <div class="preview-header">
                <h3><i class="fas fa-table"></i> Preview</h3>
                <div class="preview-stats" id="previewStats"></div>
            </div>
            <div class="preview-table-wrapper" id="previewTableWrapper">
                <table>
                    <thead id="previewTableHead"></thead>
                    <tbody id="previewTableBody"></tbody>
                </table>
            </div>
            <div class="preview-actions">
                <button class="btn btn-secondary" onclick="resetAll()">
                    <i class="fas fa-redo"></i> Upload New File
                </button>
                <button class="btn btn-primary" id="confirmBtn" onclick="startBulkInsert()">
                    <i class="fas fa-user-plus"></i> Confirm & Add Users
                </button>
            </div>
        </div>
    </div>
</div>


<div id="importLinkStudentModal" class="modal-overlay ux-hidden">
    <div class="modal-container ux-modal-wide">
        <div class="modal-header">
            <h2>Link Student to Parent</h2>
            <button class="modal-close" onclick="closeImportLinkStudentModal()">&times;</button>
        </div>

        <div class="filters-container ux-filters-panel">
            <div class="filters-grid ux-filters-row">
                <div class="filter-group ux-filter-group-flex">
                    <label for="linkStudentSearch" class="ux-filter-label">Search Students</label>
                    <input type="text" id="linkStudentSearch"
                        class="ux-filter-input"
                        placeholder="Search by name, roll number..."
                        onkeyup="searchImportLinkStudents()">
                </div>
                <div class="filter-group ux-filter-group-flex">
                    <label for="linkClassFilter" class="ux-filter-label">Filter by Class</label>
                    <select id="linkClassFilter" onchange="searchImportLinkStudents()"
                        class="ux-filter-select">
                        <option value="">All Classes</option>
                        <%
                        try (Connection clsConn = SQLConnection.getConnection()) {
                            PreparedStatement clsStmt = clsConn.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name, section ASC");
                            ResultSet clsRs = clsStmt.executeQuery();
                            while (clsRs.next()) {
                                int cId = clsRs.getInt("class_id");
                                String cName = clsRs.getString("class_name");
                                String cSec = clsRs.getString("section");
                                String cDisplay = cName + (cSec != null ? " - " + cSec : "");
                        %>
                        <option value="<%=cId%>"><%=cDisplay%></option>
                        <%
                            }
                            clsRs.close(); clsStmt.close();
                        } catch (SQLException e) { e.printStackTrace(); }
                        %>
                    </select>
                </div>
                <button type="button" class="btn btn-primary ux-search-btn" onclick="searchImportLinkStudents()">
                    <i class="fas fa-search"></i> Search
                </button>
            </div>
        </div>

        <div class="table-wrapper ux-table-scroll-300">
            <table>
                <thead>
                    <tr><th>Roll No</th><th>Student Name</th><th>Class</th><th>Action</th></tr>
                </thead>
                <tbody id="linkStudentSearchResults">
                    <%
                    try (Connection stuConn = SQLConnection.getConnection()) {
                        PreparedStatement stuStmt = stuConn.prepareStatement(
                            "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, c.class_name, c.section " +
                            "FROM students s LEFT JOIN classes c ON s.class_id = c.class_id ORDER BY s.roll_number ASC");
                        ResultSet stuRs = stuStmt.executeQuery();
                        boolean hasStudents = false;
                        while (stuRs.next()) {
                            hasStudents = true;
                            int sid = stuRs.getInt("student_id");
                            String roll = stuRs.getString("roll_number") != null ? stuRs.getString("roll_number") : "-";
                            String fname = stuRs.getString("first_name") != null ? stuRs.getString("first_name") : "";
                            String lname = stuRs.getString("last_name") != null ? stuRs.getString("last_name") : "";
                            String sName = (fname + " " + lname).trim();
                            String cName2 = stuRs.getString("class_name");
                            String sec2 = stuRs.getString("section");
                            String classDisplay2 = cName2 != null ? cName2 + (sec2 != null ? " - " + sec2 : "") : "Unassigned";
                    %>
                    <tr>
                        <td><%=roll%></td>
                        <td><%=sName%></td>
                        <td><%=classDisplay2%></td>
                        <td>
                            <button type="button" class="action-btn view"
                                onclick="selectStudentForParent(<%=sid%>, '<%=sName.replace("'", "\\'")%>', '<%=roll.replace("'", "\\'")%>', 'import')">
                                <i class="fas fa-link"></i> Select
                            </button>
                        </td>
                    </tr>
                    <%
                        }
                        if (!hasStudents) {
                    %>
                    <tr><td colspan="4" class="ux-text-empty-muted">No students found</td></tr>
                    <%
                        }
                        stuRs.close(); stuStmt.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    %>
                    <tr><td colspan="4" class="ux-text-empty-danger">Error loading students</td></tr>
                    <%
                    }
                    %>
                </tbody>
            </table>
        </div>

        <div class="form-actions ux-actions-gap-top">
            <button type="button" class="btn btn-secondary" onclick="closeImportLinkStudentModal()">Close</button>
        </div>
    </div>
</div>

<%!
private String escapeJsImport(String value) {
    if (value == null) return "";
    return value.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
}
%>


<script>
    if (typeof initImportUsersDragDrop === 'function') {
        initImportUsersDragDrop();
    }
    if (typeof loadImportDropdowns === 'function') {
        loadImportDropdowns();
    }
</script>
