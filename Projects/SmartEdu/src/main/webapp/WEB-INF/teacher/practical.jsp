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
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String classIdParam = request.getParameter("classId");
String subjectIdParam = request.getParameter("subjectId");
String examIdParam = request.getParameter("examId");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="description" content="Practical Marks Entry - Teacher Dashboard">
    <title>Practical & SLA Marks Entry - Eduverse</title>
    <link rel="preconnect" href="https://cdnjs.cloudflare.com" crossorigin>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <style>
        :root {
            --primary: #667eea;
            --primary-light: #818cf8;
            --primary-dark: #5a67d8;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --secondary: #64748b;
            --text-dark: #1e293b;
            --text-muted: #64748b;
            --bg-light: #f8fafc;
            --white: #ffffff;
            --shadow-sm: 0 4px 12px rgba(0,0,0,0.08);
            --shadow-md: 0 8px 24px rgba(0,0,0,0.12);
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-xl: 20px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            --touch-target: 48px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        html { -webkit-text-size-adjust: 100%; }
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: var(--bg-light); color: var(--text-dark); min-height: 100vh; padding: 16px; line-height: 1.5; -webkit-font-smoothing: antialiased; }
        .container { max-width: 100%; margin: 0 auto; }
        
        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; padding: 20px; background: var(--white); border-radius: var(--radius-xl); box-shadow: var(--shadow-md); flex-wrap: wrap; gap: 16px; }
        .welcome-section { flex: 1; min-width: 200px; }
        .welcome-section h1 { font-size: clamp(1.25rem, 4vw, 1.75rem); font-weight: 700; color: var(--text-dark); margin-bottom: 4px; }
        .welcome-section p { color: var(--text-muted); font-size: clamp(0.8rem, 2.5vw, 1rem); font-weight: 500; }
        .user-info { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .user-avatar { width: 50px; height: 50px; border-radius: 50%; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%); color: white; font-weight: 600; font-size: 1.25rem; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .logout-btn { background: linear-gradient(135deg, var(--danger) 0%, #dc2626 100%); color: white; border: none; border-radius: var(--radius-sm); padding: 12px 20px; cursor: pointer; font-weight: 600; font-size: 14px; transition: var(--transition); min-height: var(--touch-target); display: flex; align-items: center; gap: 8px; }
        .logout-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(239, 68, 68, 0.4); }

        .filters-container { background: var(--white); padding: 24px; border-radius: var(--radius-lg); box-shadow: var(--shadow-md); margin-bottom: 24px; }
        .filters-container h2 { font-size: 1.25rem; color: var(--text-dark); margin-bottom: 20px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .filters-container h2 i { color: var(--primary); }
        .filters-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; align-items: end; }
        .filter-group { display: flex; flex-direction: column; }
        .filter-group label { font-weight: 600; color: var(--text-muted); font-size: 0.875rem; margin-bottom: 8px; }
        .filter-group select, .filter-group input { padding: 14px 16px; border: 2px solid #e2e8f0; border-radius: var(--radius-sm); font-size: 1rem; color: var(--text-dark); background: #f8fafc; transition: var(--transition); min-height: var(--touch-target); cursor: pointer; }
        .filter-group select:focus, .filter-group input:focus { outline: none; border-color: var(--primary); background: var(--white); box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1); }

        .btn { padding: 14px 24px; border-radius: var(--radius-sm); font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: var(--transition); min-height: var(--touch-target); display: inline-flex; align-items: center; justify-content: center; gap: 8px; border: none; text-decoration: none; white-space: nowrap; }
        .btn-primary { background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%); color: white; box-shadow: var(--shadow-sm); }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4); }
        .btn-success { background: linear-gradient(135deg, var(--success) 0%, #059669 100%); color: white; box-shadow: var(--shadow-sm); }
        .btn-success:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4); }
        .btn-danger { background: linear-gradient(135deg, var(--danger) 0%, #dc2626 100%); color: white; box-shadow: var(--shadow-sm); }
        .btn-danger:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(239, 68, 68, 0.4); }
        .btn-sm { padding: 8px 12px; font-size: 0.8rem; min-height: 36px; }
        .btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none !important; }
        .btn-add-exam { background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); }

        .component-section { background: var(--white); padding: 20px; border-radius: var(--radius-lg); box-shadow: var(--shadow-md); margin-bottom: 24px; }
        .component-section h3 { font-size: 1.1rem; color: var(--text-dark); margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px; }
        .component-list { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 16px; }
        .component-item { display: flex; align-items: center; gap: 8px; padding: 10px 16px; background: #f1f5f9; border-radius: var(--radius-sm); font-weight: 500; font-size: 0.9rem; flex-wrap: wrap; }
        .component-item .max-marks { color: var(--text-muted); font-size: 0.8rem; }
        .component-item .delete-btn { background: none; border: none; color: var(--danger); cursor: pointer; padding: 4px; font-size: 0.9rem; }
        .component-item .delete-btn:hover { color: #dc2626; }
        .add-component-form { display: flex; gap: 12px; flex-wrap: wrap; align-items: end; }
        .add-component-form .filter-group { min-width: 140px; }
        .add-component-form .filter-group input { width: 100%; }

        /* Excel-like Table Styles */
        .excel-container { background: var(--white); border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-md); margin-bottom: 24px; }
        .excel-header { padding: 16px 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%); color: white; }
        .excel-header h3 { font-size: 1.125rem; }
        .excel-count { opacity: 0.9; font-size: 0.9rem; }
        .excel-wrapper { overflow-x: auto; -webkit-overflow-scrolling: touch; }
        .excel-table { width: 100%; border-collapse: collapse; min-width: 1200px; table-layout: fixed; }
        .excel-table th { background: #f8fafc; padding: 12px 8px; text-align: center; font-weight: 600; color: #475569; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 2px solid #e2e8f0; border-right: 1px solid #e2e8f0; white-space: nowrap; position: sticky; top: 0; z-index: 10; }
        .excel-table th:first-child { position: sticky; left: 0; z-index: 20; background: #f8fafc; text-align: left; min-width: 200px; }
        .excel-table th.practical-header { background: #dbeafe; color: #1e40af; }
        .excel-table th.sla-header { background: #f3e8ff; color: #6b21a8; }
        .excel-table th.avg-header { background: #fef3c7; color: #92400e; }
        .excel-table th.sla-total-header { background: #fce7f3; color: #9d174d; }
        .excel-table th.final-header { background: #d1fae5; color: #065f46; }
        .excel-table td { padding: 8px; border-bottom: 1px solid #f1f5f9; border-right: 1px solid #f1f5f9; text-align: center; font-size: 0.85rem; }
        .excel-table td:first-child { position: sticky; left: 0; z-index: 5; background: var(--white); text-align: left; font-weight: 600; min-width: 200px; }
        .excel-table tr:hover td { background: #f8fafc; }
        .excel-table tr:hover td:first-child { background: #f1f5f9; }
        
        .student-cell { display: flex; align-items: center; gap: 10px; padding: 4px 0; }
        .student-avatar { width: 32px; height: 32px; border-radius: 8px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%); display: flex; align-items: center; justify-content: center; color: white; font-weight: 600; font-size: 0.75rem; flex-shrink: 0; }
        .student-details { overflow: hidden; }
        .student-name { font-weight: 600; font-size: 0.85rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .student-roll { font-size: 0.75rem; color: var(--text-muted); font-weight: 400; }

        .marks-input { width: 100%; padding: 8px 4px; border: 2px solid #e2e8f0; border-radius: 4px; text-align: center; font-size: 0.85rem; font-weight: 500; transition: var(--transition); background: var(--white); }
        .marks-input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.15); background: #fafbff; }
        .marks-input.invalid { border-color: var(--danger); background: #fef2f2; }
        .marks-input.valid { border-color: var(--success); background: #f0fdf4; }
        .marks-input.calculated { background: #f8fafc; font-weight: 600; border: none; }
        
        .calc-cell { font-weight: 700; font-size: 0.9rem; padding: 8px; }
        .avg-cell { color: #d97706; background: #fffbeb; }
        .sla-total-cell { color: #db2777; background: #fdf2f8; }
        .final-cell { color: #059669; background: #ecfdf5; font-size: 1rem; }

        .message-box { background: var(--white); padding: 40px 30px; border-radius: var(--radius-lg); text-align: center; box-shadow: var(--shadow-md); margin-bottom: 24px; }
        .message-box.info { border-left: 5px solid var(--primary); }
        .message-box.success { border-left: 5px solid var(--success); }
        .message-box.warning { border-left: 5px solid var(--warning); }
        .message-box.error { border-left: 5px solid var(--danger); }
        .message-box i { font-size: 52px; margin-bottom: 15px; }
        .message-box.info i { color: var(--primary); }
        .message-box.success i { color: var(--success); }
        .message-box.warning i { color: var(--warning); }
        .message-box.error i { color: var(--danger); }
        .message-box p { font-size: 16px; color: #475569; font-weight: 500; }

        .loading { text-align: center; padding: 40px; color: var(--text-muted); display: none; }
        .loading i { font-size: 2rem; animation: spin 1s linear infinite; }
        @keyframes spin { 100% { transform: rotate(360deg); } }

        /* Modal Styles */
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; display: none; justify-content: center; align-items: center; padding: 20px; }
        .modal-overlay.show { display: flex; }
        .modal { background: var(--white); border-radius: var(--radius-lg); max-width: 600px; width: 100%; max-height: 90vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.3); animation: modalSlideIn 0.3s ease; }
        @keyframes modalSlideIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        .modal-header { padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .modal-header h3 { font-size: 1.25rem; color: var(--text-dark); display: flex; align-items: center; gap: 10px; }
        .modal-header h3 i { color: var(--primary); }
        .modal-close { background: none; border: none; font-size: 1.5rem; color: var(--text-muted); cursor: pointer; padding: 4px; line-height: 1; }
        .modal-close:hover { color: var(--danger); }
        .modal-body { padding: 24px; }
        .modal-footer { padding: 16px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 12px; flex-wrap: wrap; }

        .form-section { margin-bottom: 24px; }
        .form-section h4 { font-size: 1rem; color: var(--text-dark); margin-bottom: 12px; display: flex; align-items: center; gap: 8px; }
        .form-section h4 i { color: var(--primary); }
        .range-inputs { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .range-inputs .filter-group { flex: 1; min-width: 100px; }
        .range-arrow { color: var(--text-muted); font-size: 1.2rem; }

        .sla-items { display: flex; flex-direction: column; gap: 12px; }
        .sla-item { display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
        .sla-item input[type="checkbox"] { width: 18px; height: 18px; cursor: pointer; }
        .sla-item label { flex: 1; font-weight: 500; cursor: pointer; }
        .sla-item .filter-group { flex: 0 0 100px; }

        .toast { position: fixed; top: 20px; right: 20px; padding: 16px 24px; border-radius: var(--radius-sm); color: white; font-weight: 500; z-index: 1001; animation: slideIn 0.3s ease; display: none; min-width: 250px; }
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }
        .toast.warning { background: var(--warning); }
        @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }

        .inline-actions { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
        .add-exam-btn { margin-left: auto; }

        @media (max-width: 768px) {
            .top-bar { flex-direction: column; text-align: center; }
            .user-info { justify-content: center; }
            .filters-grid { grid-template-columns: 1fr; }
            .btn { width: 100%; }
            .add-component-form { flex-direction: column; }
            .add-component-form .filter-group { width: 100%; }
            .modal { max-height: 95vh; }
            .range-inputs { flex-direction: column; }
            .range-arrow { transform: rotate(90deg); }
            .toast { left: 20px; right: 20px; }
        }
        
        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .top-bar, .filters-container, .component-section, .excel-container, .message-box { animation: fadeIn 0.5s ease-out; }
    </style>
</head>
<body>

<div class="container">

    <!-- TOP BAR -->
    <div class="top-bar">
        <div class="welcome-section">
            <h1><i class="fas fa-clipboard-check"></i> Practical & SLA Marks Entry</h1>
            <p>Welcome back, <%=user.getFullName()%>! Select class, subject, and exam to enter marks.</p>
        </div>
        <div class="user-info">
            <div class="user-avatar"><%=avatarLetter%></div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i>
                <span>Logout</span>
            </button>
        </div>
    </div>

    <!-- Filters -->
    <div class="filters-container">
        <h2>
            <i class="fas fa-filter"></i> Select Assessment Details
            <button type="button" class="btn btn-sm btn-add-exam" onclick="openAddExamModal()">
                <i class="fas fa-plus"></i> Add New Exam
            </button>
        </h2>
        <form method="get" action="practical_marks.jsp" class="filters-grid">
            <div class="filter-group">
                <label>Class:</label>
                <select name="classId" id="classSelect" onchange="loadSubjects()">
                    <option value="">--Select Class--</option>
                    <%
                        try(Connection conn = SQLConnection.getConnection()) {
                            ResultSet rs = conn.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_id").executeQuery();
                            while(rs.next()) {
                                String id = String.valueOf(rs.getInt("class_id"));
                                String selected = (classIdParam != null && classIdParam.equals(id)) ? "selected" : "";
                    %>
                    <option value="<%=id%>" <%=selected%>><%=rs.getString("class_name")%> - <%=rs.getString("section")%></option>
                    <%
                            }
                        } catch(Exception e){ e.printStackTrace(); }
                    %>
                </select>
            </div>
            <div class="filter-group">
                <label>Subject:</label>
                <select name="subjectId" id="subjectSelect" onchange="loadExams()" <%= (classIdParam == null || classIdParam.isEmpty()) ? "disabled" : "" %>>
                    <option value="">--Select Subject--</option>
                    <%
                        if(classIdParam != null && !classIdParam.isEmpty()) {
                            try(Connection conn = SQLConnection.getConnection()) {
                                String sql = "SELECT s.subject_id, s.subject_name FROM subjects s " +
                                             "LEFT JOIN class_subjects cs ON s.subject_id = cs.subject_id AND cs.class_id = ? " +
                                             "WHERE cs.class_id IS NOT NULL OR NOT EXISTS (SELECT 1 FROM class_subjects) " +
                                             "ORDER BY s.subject_name";
                                PreparedStatement ps = conn.prepareStatement(sql);
                                ps.setInt(1, Integer.parseInt(classIdParam));
                                ResultSet rs = ps.executeQuery();
                                while(rs.next()) {
                                    String id = String.valueOf(rs.getInt("subject_id"));
                                    String selected = (subjectIdParam != null && subjectIdParam.equals(id)) ? "selected" : "";
                    %>
                    <option value="<%=id%>" <%=selected%>><%=rs.getString("subject_name")%></option>
                    <%
                                }
                            } catch(Exception e){ e.printStackTrace(); }
                        }
                    %>
                </select>
            </div>
            <div class="filter-group">
                <label>Exam:</label>
                <select name="examId" id="examSelect" onchange="loadMarksEntry()" <%= (subjectIdParam == null || subjectIdParam.isEmpty()) ? "disabled" : "" %>>
                    <option value="">--Select Exam--</option>
                    <%
                        if(subjectIdParam != null && !subjectIdParam.isEmpty()) {
                            // Get exams that have practicals or SLA components
                            try(Connection conn = SQLConnection.getConnection()) {
                                String sql = "SELECT DISTINCT e.exam_id, e.exam_name FROM exams e " +
                                             "LEFT JOIN practicals p ON e.exam_id = p.exam_id " +
                                             "LEFT JOIN sla_components sc ON e.exam_id = sc.exam_id " +
                                             "WHERE p.practical_id IS NOT NULL OR sc.component_id IS NOT NULL " +
                                             "ORDER BY e.exam_id DESC";
                                ResultSet rs = conn.prepareStatement(sql).executeQuery();
                                while(rs.next()) {
                                    String id = String.valueOf(rs.getInt("exam_id"));
                                    String selected = (examIdParam != null && examIdParam.equals(id)) ? "selected" : "";
                    %>
                    <option value="<%=id%>" <%=selected%>><%=rs.getString("exam_name")%></option>
                    <%
                                }
                            } catch(Exception e){ e.printStackTrace(); }
                        }
                    %>
                </select>
            </div>
            <button type="button" class="btn btn-primary" id="loadBtn" onclick="loadMarksEntry()" <%= (classIdParam == null || subjectIdParam == null || examIdParam == null || classIdParam.isEmpty() || subjectIdParam.isEmpty() || examIdParam == null || examIdParam.isEmpty()) ? "disabled" : "" %>>
                <i class="fas fa-search"></i> Load
            </button>
        </form>
    </div>

    <!-- Component Management -->
    <div class="component-section" id="practicalSection" style="display: none;">
        <h3>
            <span><i class="fas fa-flask"></i> Practical Components</span>
        </h3>
        <div class="component-list" id="practicalList"></div>
    </div>

    <div class="component-section" id="slaSection" style="display: none;">
        <h3>
            <span><i class="fas fa-tasks"></i> SLA Components</span>
        </h3>
        <div class="component-list" id="slaList"></div>
    </div>

    <!-- Message Box -->
    <div class="message-box info" id="messageBox">
        <i class="fas fa-info-circle"></i>
        <p>Please select a class, subject, and exam to enter marks.</p>
    </div>

    <!-- Loading -->
    <div class="loading" id="loading">
        <i class="fas fa-spinner"></i>
        <p>Loading data...</p>
    </div>

    <!-- Excel-like Marks Entry Table -->
    <div class="excel-container" id="excelContainer" style="display: none;">
        <div class="excel-header">
            <h3><i class="fas fa-table"></i> Marks Entry</h3>
            <div class="inline-actions">
                <span class="excel-count" id="studentCount">0 students</span>
                <button type="button" class="btn btn-success btn-sm" onclick="saveMarks()">
                    <i class="fas fa-save"></i> Save
                </button>
            </div>
        </div>
        <div class="excel-wrapper">
            <table class="excel-table">
                <thead id="marksTableHead"></thead>
                <tbody id="marksTableBody"></tbody>
            </table>
        </div>
    </div>

</div>

<!-- Add Exam Modal -->
<div class="modal-overlay" id="addExamModal">
    <div class="modal">
        <div class="modal-header">
            <h3><i class="fas fa-calendar-plus"></i> Add New Exam</h3>
            <button class="modal-close" onclick="closeAddExamModal()">&times;</button>
        </div>
        <div class="modal-body">
            <div class="form-section">
                <h4><i class="fas fa-file-signature"></i> Exam Name</h4>
                <div class="filter-group">
                    <input type="text" id="newExamName" placeholder="e.g., Unit Test 1, Mid Term, Final Exam">
                </div>
            </div>
            
            <div class="form-section">
                <h4><i class="fas fa-flask"></i> Practicals Configuration</h4>
                <div class="range-inputs">
                    <div class="filter-group">
                        <label>From (P1)</label>
                        <input type="number" id="practicalFrom" min="1" value="1">
                    </div>
                    <span class="range-arrow"><i class="fas fa-arrow-right"></i></span>
                    <div class="filter-group">
                        <label>To (Pn)</label>
                        <input type="number" id="practicalTo" min="1" value="5">
                    </div>
                    <div class="filter-group">
                        <label>Max Marks</label>
                        <input type="number" id="practicalMaxMarks" min="1" value="10">
                    </div>
                </div>
            </div>
            
            <div class="form-section">
                <h4><i class="fas fa-tasks"></i> SLA Components</h4>
                <div class="sla-items">
                    <div class="sla-item">
                        <input type="checkbox" id="slaManual" checked>
                        <label for="slaManual">Manual</label>
                        <div class="filter-group">
                            <input type="number" id="slaManualMax" value="20" min="1">
                        </div>
                    </div>
                    <div class="sla-item">
                        <input type="checkbox" id="slaViva" checked>
                        <label for="slaViva">Viva</label>
                        <div class="filter-group">
                            <input type="number" id="slaVivaMax" value="10" min="1">
                        </div>
                    </div>
                    <div class="sla-item">
                        <input type="checkbox" id="slaJournal" checked>
                        <label for="slaJournal">Journal</label>
                        <div class="filter-group">
                            <input type="number" id="slaJournalMax" value="10" min="1">
                        </div>
                    </div>
                    <div class="sla-item">
                        <input type="checkbox" id="slaAssignment">
                        <label for="slaAssignment">Assignment</label>
                        <div class="filter-group">
                            <input type="number" id="slaAssignmentMax" value="10" min="1">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn" onclick="closeAddExamModal()">Cancel</button>
            <button type="button" class="btn btn-success" onclick="createExam()">
                <i class="fas fa-plus"></i> Create Exam
            </button>
        </div>
    </div>
</div>

<!-- Toast Notification -->
<div class="toast" id="toast"></div>

<script>
let students = [];
let practicals = [];
let slaComponents = [];
let existingMarks = {};

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    const classSelect = document.getElementById('classSelect');
    if (classSelect.options.length <= 1) {
        showMessage('warning', 'No classes found! Please contact administrator.', 'fa-exclamation-triangle');
    }
    
    // Auto-load if parameters are present
    const classId = classSelect.value;
    const subjectId = document.getElementById('subjectSelect').value;
    const examId = document.getElementById('examSelect').value;
    
    if (classId && subjectId && examId) {
        loadMarksEntry();
    }
});

function logout() {
    if (confirm("Are you sure you want to log out?")) {
        localStorage.clear();
        window.location.href = "<%=request.getContextPath()%>/LogoutServlet";
    }
}

function showMessage(type, message, icon) {
    const messageBox = document.getElementById('messageBox');
    messageBox.style.display = 'block';
    messageBox.className = 'message-box ' + type;
    messageBox.innerHTML = '<i class="fas fa-' + icon + '"></i><p>' + message + '</p>';
}

function hideMessage() {
    document.getElementById('messageBox').style.display = 'none';
}

function showToast(message, type) {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = 'toast ' + type;
    toast.style.display = 'block';
    setTimeout(function() {
        toast.style.display = 'none';
    }, 3000);
}

function openAddExamModal() {
    document.getElementById('addExamModal').classList.add('show');
}

function closeAddExamModal() {
    document.getElementById('addExamModal').classList.remove('show');
}

function createExam() {
    const examName = document.getElementById('newExamName').value.trim();
    const practicalFrom = parseInt(document.getElementById('practicalFrom').value) || 1;
    const practicalTo = parseInt(document.getElementById('practicalTo').value) || 5;
    const practicalMaxMarks = parseInt(document.getElementById('practicalMaxMarks').value) || 10;
    
    if (!examName) {
        showToast('Please enter exam name', 'warning');
        return;
    }
    
    if (practicalTo < practicalFrom) {
        showToast('Invalid practical range', 'error');
        return;
    }
    
    // Build SLA components JSON
    let slaComponentsList = [];
    if (document.getElementById('slaManual').checked) {
        slaComponentsList.push({name: 'Manual', max_marks: parseInt(document.getElementById('slaManualMax').value) || 20});
    }
    if (document.getElementById('slaViva').checked) {
        slaComponentsList.push({name: 'Viva', max_marks: parseInt(document.getElementById('slaVivaMax').value) || 10});
    }
    if (document.getElementById('slaJournal').checked) {
        slaComponentsList.push({name: 'Journal', max_marks: parseInt(document.getElementById('slaJournalMax').value) || 10});
    }
    if (document.getElementById('slaAssignment').checked) {
        slaComponentsList.push({name: 'Assignment', max_marks: parseInt(document.getElementById('slaAssignmentMax').value) || 10});
    }
    
    const formData = new FormData();
    formData.append('action', 'addExam');
    formData.append('exam_name', examName);
    formData.append('practical_count', (practicalTo - practicalFrom + 1));
    formData.append('practical_max_marks', practicalMaxMarks);
    formData.append('sla_components', JSON.stringify(slaComponentsList));
    
    fetch('<%=request.getContextPath()%>/MarksEntryServlet', {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        if (data.success) {
            showToast('Exam created successfully!', 'success');
            closeAddExamModal();
            // Reset form
            document.getElementById('newExamName').value = '';
            // Refresh exams dropdown
            loadExams();
        } else {
            showToast(data.message || 'Error creating exam', 'error');
        }
    })
    .catch(error => {
        console.error('Error creating exam:', error);
        showToast('Error creating exam: ' + error.message, 'error');
    });
}

function loadSubjects() {
    const classId = document.getElementById('classSelect').value;
    const subjectSelect = document.getElementById('subjectSelect');
    const examSelect = document.getElementById('examSelect');
    const loadBtn = document.getElementById('loadBtn');
    
    subjectSelect.innerHTML = '<option value="">-- Select Subject --</option>';
    subjectSelect.disabled = true;
    examSelect.innerHTML = '<option value="">-- Select Exam --</option>';
    examSelect.disabled = true;
    loadBtn.disabled = true;
    
    hideMarksTable();
    hideMessage();
    
    if (!classId) {
        return;
    }
    
    // Show loading
    showMessage('info', 'Loading subjects...', 'fa-spinner');
    
    const url = '<%=request.getContextPath()%>/MarksEntryServlet?action=getSubjects&class_id=' + classId;
    console.log('Loading subjects from:', url);
    
    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            console.log('Subjects loaded:', data);
            
            if (data.error) {
                showToast('Error: ' + data.error, 'error');
                return;
            }
            
            if (!data || data.length === 0) {
                showMessage('warning', 'No subjects found for this class! Make sure class_subjects table has entries or contact administrator.', 'fa-exclamation-triangle');
                return;
            }
            
            // Clear and populate subjects
            subjectSelect.innerHTML = '<option value="">-- Select Subject --</option>';
            data.forEach(subject => {
                const option = document.createElement('option');
                option.value = subject.subject_id;
                option.textContent = subject.subject_name + (subject.subject_code ? ' (' + subject.subject_code + ')' : '');
                subjectSelect.appendChild(option);
            });
            subjectSelect.disabled = false;
            
            // Hide message box after successful load
            hideMessage();
        })
        .catch(error => {
            console.error('Error loading subjects:', error);
            showMessage('error', 'Error loading subjects: ' + error.message, 'fa-exclamation-triangle');
        });
}

function loadExams() {
    const subjectId = document.getElementById('subjectSelect').value;
    const examSelect = document.getElementById('examSelect');
    const loadBtn = document.getElementById('loadBtn');
    
    examSelect.innerHTML = '<option value="">-- Select Exam --</option>';
    examSelect.disabled = true;
    loadBtn.disabled = true;
    
    hideMarksTable();
    hideMessage();
    
    if (!subjectId) {
        return;
    }
    
    // Show loading
    showMessage('info', 'Loading exams...', 'fa-spinner');
    
    // Get all available exams (exams that have practicals or SLA components)
    fetch('<%=request.getContextPath()%>/MarksEntryServlet?action=getExams')
        .then(response => {
            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            console.log('Exams loaded:', data);
            
            if (data.error) {
                showToast('Error: ' + data.error, 'error');
                return;
            }
            
            if (!data || data.length === 0) {
                showMessage('warning', 'No exams found! Click "Add New Exam" to create one.', 'fa-exclamation-triangle');
                return;
            }
            
            // Clear and populate exams
            examSelect.innerHTML = '<option value="">-- Select Exam --</option>';
            data.forEach(exam => {
                const option = document.createElement('option');
                option.value = exam.exam_id;
                option.textContent = exam.exam_name;
                examSelect.appendChild(option);
            });
            examSelect.disabled = false;
            
            // Hide message box
            hideMessage();
        })
        .catch(error => {
            console.error('Error loading exams:', error);
            showMessage('error', 'Error loading exams: ' + error.message, 'fa-exclamation-triangle');
        });
}

function loadMarksEntry() {
    const classId = document.getElementById('classSelect').value;
    const subjectId = document.getElementById('subjectSelect').value;
    const examId = document.getElementById('examSelect').value;
    
    if (!classId || !subjectId || !examId) {
        showMessage('info', 'Please select class, subject, and exam', 'fa-info-circle');
        return;
    }
    
    hideMessage();
    document.getElementById('loading').style.display = 'block';
    document.getElementById('excelContainer').style.display = 'none';
    
    Promise.all([
        fetch('<%=request.getContextPath()%>/MarksEntryServlet?action=getStudents&class_id=' + classId).then(r => {
            if (!r.ok) throw new Error('Failed to load students');
            return r.json();
        }),
        fetch('<%=request.getContextPath()%>/MarksEntryServlet?action=getPracticals&subject_id=' + subjectId + '&exam_id=' + examId).then(r => {
            if (!r.ok) throw new Error('Failed to load practicals');
            return r.json();
        }),
        fetch('<%=request.getContextPath()%>/MarksEntryServlet?action=getSLAComponents&subject_id=' + subjectId + '&exam_id=' + examId).then(r => {
            if (!r.ok) throw new Error('Failed to load SLA components');
            return r.json();
        }),
        fetch('<%=request.getContextPath()%>/MarksEntryServlet?action=getExistingMarks&subject_id=' + subjectId + '&exam_id=' + examId).then(r => {
            if (!r.ok) throw new Error('Failed to load existing marks');
            return r.json();
        })
    ])
    .then(([studentsData, practicalsData, slaData, marksData]) => {
        console.log('Data loaded:', { students: studentsData.length, practicals: practicalsData, sla: slaData });
        
        students = studentsData;
        practicals = practicalsData;
        slaComponents = slaData;
        existingMarks = marksData;
        
        document.getElementById('practicalSection').style.display = 'block';
        document.getElementById('slaSection').style.display = 'block';
        
        renderPracticalList();
        renderSLAComponentList();
        
        buildMarksTable();
        
        document.getElementById('loading').style.display = 'none';
        document.getElementById('excelContainer').style.display = 'block';
    })
    .catch(error => {
        console.error('Error loading marks entry:', error);
        document.getElementById('loading').style.display = 'none';
        showMessage('error', 'Error loading data: ' + error.message, 'fa-exclamation-triangle');
    });
}

function hideMarksTable() {
    document.getElementById('excelContainer').style.display = 'none';
    document.getElementById('practicalSection').style.display = 'none';
    document.getElementById('slaSection').style.display = 'none';
}

function renderPracticalList() {
    const list = document.getElementById('practicalList');
    list.innerHTML = '';
    
    if (!practicals || practicals.length === 0) {
        list.innerHTML = '<span style="color: var(--text-muted);">No practicals configured for this exam.</span>';
        return;
    }
    
    practicals.forEach(p => {
        const item = document.createElement('div');
        item.className = 'component-item';
        item.innerHTML = '<span>P' + p.practical_no + '</span><span class="max-marks">(Max: ' + p.max_marks + ')</span>';
        list.appendChild(item);
    });
}

function renderSLAComponentList() {
    const list = document.getElementById('slaList');
    list.innerHTML = '';
    
    if (!slaComponents || slaComponents.length === 0) {
        list.innerHTML = '<span style="color: var(--text-muted);">No SLA components configured for this exam.</span>';
        return;
    }
    
    slaComponents.forEach(s => {
        const item = document.createElement('div');
        item.className = 'component-item';
        item.innerHTML = '<span>' + s.component_name + '</span><span class="max-marks">(Max: ' + s.max_marks + ')</span>';
        list.appendChild(item);
    });
}

function buildMarksTable() {
    const thead = document.getElementById('marksTableHead');
    const tbody = document.getElementById('marksTableBody');
    
    // Build header
    let headerHtml = '<tr><th>Student Details</th>';
    
    // Practical columns
    if (practicals && practicals.length > 0) {
        practicals.forEach(p => {
            headerHtml += '<th class="practical-header" title="Max: ' + p.max_marks + '">P' + p.practical_no + '</th>';
        });
        headerHtml += '<th class="avg-header">Avg</th>';
    }
    
    // SLA columns
    if (slaComponents && slaComponents.length > 0) {
        slaComponents.forEach(s => {
            headerHtml += '<th class="sla-header" title="Max: ' + s.max_marks + '">' + s.component_name + '</th>';
        });
        headerHtml += '<th class="sla-total-header">Total</th>';
    }
    
    headerHtml += '<th class="final-header">Final</th></tr>';
    
    thead.innerHTML = headerHtml;
    
    if (!students || students.length === 0) {
        tbody.innerHTML = '<tr><td colspan="100" style="text-align: center; padding: 40px;">No students found</td></tr>';
        return;
    }
    
    document.getElementById('studentCount').textContent = students.length + ' students';
    
    // Build body
    let bodyHtml = '';
    students.forEach(student => {
        const key = student.student_id;
        const firstLetter = student.full_name ? student.full_name.charAt(0).toUpperCase() : '?';
        
        bodyHtml += '<tr data-student-id="' + student.student_id + '">';
        
        // Student column
        bodyHtml += '<td><div class="student-cell"><div class="student-avatar">' + firstLetter + '</div><div class="student-details"><div class="student-name">' + student.full_name + '</div><div class="student-roll">' + student.roll_number + '</div></div></td>';
        
        // Practical inputs
        if (practicals && practicals.length > 0) {
            practicals.forEach(p => {
                const markKey = key + '_PRACTICAL_' + p.practical_id;
                const savedMark = existingMarks && existingMarks[markKey] !== undefined ? existingMarks[markKey] : '';
                bodyHtml += '<td><input type="number" class="marks-input practical-input" data-type="PRACTICAL" data-id="' + p.practical_id + '" data-max="' + p.max_marks + '" value="' + savedMark + '" min="0" max="' + p.max_marks + '" onchange="validateAndCalculate(this)" oninput="validateAndCalculate(this)"></td>';
            });
            
            // Average
            bodyHtml += '<td class="calc-cell avg-cell" id="avg_' + key + '">0</td>';
        }
        
        // SLA inputs
        if (slaComponents && slaComponents.length > 0) {
            slaComponents.forEach(s => {
                const markKey = key + '_SLA_' + s.component_id;
                const savedMark = existingMarks && existingMarks[markKey] !== undefined ? existingMarks[markKey] : '';
                bodyHtml += '<td><input type="number" class="marks-input sla-input" data-type="SLA" data-id="' + s.component_id + '" data-max="' + s.max_marks + '" value="' + savedMark + '" min="0" max="' + s.max_marks + '" onchange="validateAndCalculate(this)" oninput="validateAndCalculate(this)"></td>';
            });
            
            // SLA Total
            bodyHtml += '<td class="calc-cell sla-total-cell" id="slaTotal_' + key + '">0</td>';
        }
        
        // Final
        bodyHtml += '<td class="calc-cell final-cell" id="final_' + key + '">0</td>';
        
        bodyHtml += '</tr>';
    });
    
    tbody.innerHTML = bodyHtml;
    
    // Calculate initial values
    calculateAllRows();
}

function validateAndCalculate(input) {
    const max = parseInt(input.dataset.max);
    const value = parseInt(input.value);
    
    if (isNaN(value) || value < 0) {
        input.classList.remove('valid');
        input.classList.add('invalid');
    } else if (value > max) {
        input.classList.remove('valid');
        input.classList.add('invalid');
        input.value = max;
    } else {
        input.classList.remove('invalid');
        input.classList.add('valid');
    }
    
    calculateAllRows();
}

function calculateAllRows() {
    students.forEach(student => {
        const row = document.querySelector('tr[data-student-id="' + student.student_id + '"]');
        if (!row) return;
        
        // Calculate practical average
        let practicalSum = 0;
        let practicalCount = 0;
        const practicalInputs = row.querySelectorAll('.practical-input');
        practicalInputs.forEach(input => {
            const value = parseInt(input.value);
            if (!isNaN(value) && value >= 0) {
                practicalSum += value;
                practicalCount++;
            }
        });
        
        const avg = practicalCount > 0 ? (practicalSum / practicalCount).toFixed(2) : '0';
        const avgCell = document.getElementById('avg_' + student.student_id);
        if (avgCell) {
            avgCell.textContent = avg;
        }
        
        // Calculate SLA total
        let slaTotal = 0;
        const slaInputs = row.querySelectorAll('.sla-input');
        slaInputs.forEach(input => {
            const value = parseInt(input.value);
            if (!isNaN(value) && value >= 0) {
                slaTotal += value;
            }
        });
        
        const slaTotalCell = document.getElementById('slaTotal_' + student.student_id);
        if (slaTotalCell) {
            slaTotalCell.textContent = slaTotal;
        }
        
        // Calculate final
        const final = (parseFloat(avg) + slaTotal).toFixed(2);
        const finalCell = document.getElementById('final_' + student.student_id);
        if (finalCell) {
            finalCell.textContent = final;
        }
    });
}

function saveMarks() {
    const subjectId = document.getElementById('subjectSelect').value;
    const examId = document.getElementById('examSelect').value;
    
    if (!subjectId || !examId) {
        showToast('Please select subject and exam', 'error');
        return;
    }
    
    let marksData = [];
    const rows = document.querySelectorAll('#marksTableBody tr');
    
    rows.forEach(row => {
        const studentId = row.dataset.studentId;
        if (!studentId) return;
        
        // Practical marks
        const practicalInputs = row.querySelectorAll('.practical-input');
        practicalInputs.forEach(input => {
            const type = input.dataset.type;
            const componentId = input.dataset.id;
            const marks = input.value !== '' ? parseInt(input.value) : 0;
            marksData.push(studentId + '_' + type + '_' + componentId + '=' + marks);
        });
        
        // SLA marks
        const slaInputs = row.querySelectorAll('.sla-input');
        slaInputs.forEach(input => {
            const type = input.dataset.type;
            const componentId = input.dataset.id;
            const marks = input.value !== '' ? parseInt(input.value) : 0;
            marksData.push(studentId + '_' + type + '_' + componentId + '=' + marks);
        });
    });
    
    if (marksData.length === 0) {
        showToast('No marks to save', 'warning');
        return;
    }
    
    const formData = new FormData();
    formData.append('action', 'saveMarks');
    formData.append('subject_id', subjectId);
    formData.append('exam_id', examId);
    formData.append('marksData', marksData.join(';'));
    
    fetch('<%=request.getContextPath()%>/MarksEntryServlet', {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        if (data.success) {
            showToast('Marks saved successfully!', 'success');
            loadMarksEntry();
        } else {
            showToast(data.message || 'Error saving marks', 'error');
        }
    })
    .catch(error => {
        console.error('Error saving marks:', error);
        showToast('Error saving marks: ' + error.message, 'error');
    });
}

// Close modal on outside click
document.getElementById('addExamModal').addEventListener('click', function(e) {
    if (e.target === this) {
        closeAddExamModal();
    }
});

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeAddExamModal();
    }
});

document.addEventListener('dblclick', function(event) {
    event.preventDefault();
}, { passive: false });
</script>

</body>
</html>

