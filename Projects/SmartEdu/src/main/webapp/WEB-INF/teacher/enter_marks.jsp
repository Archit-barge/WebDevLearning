<%@
 page import="com.seh.util.SQLConnection" %>
<%@ page import="com.seh.model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    User user = (User) session.getAttribute("user");

String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
    if(user == null){
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String classIdParam = request.getParameter("classId");
    String subjectIdParam = request.getParameter("subjectId");
    
    // Get exam type parameter - default to "ut" (Unit Tests)
    String examType = request.getParameter("examType");
    if (examType == null) examType = "ut";

    // Calculate stats (for stats grid)
    int totalStudents = 0;
    float ut1Avg = 0, ut2Avg = 0, overallAvg = 0;
    try(Connection conn = SQLConnection.getConnection()) {
        if(classIdParam != null && !classIdParam.isEmpty() && subjectIdParam != null && !subjectIdParam.isEmpty()) {
            int classId = Integer.parseInt(classIdParam);
            int subjectId = Integer.parseInt(subjectIdParam);
            String sql = "SELECT COUNT(*) as total FROM students WHERE class_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) totalStudents = rs.getInt("total");
        }
    } catch(Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
<title>Enter Marks - Eduverse</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* ===== CSS VARIABLES (matching ViewAttendance) ===== */
:root {
    --primary: #667eea;
    --primary-dark: #5a67d8;
    --primary-light: #818cf8;
    --success: #10b981;
    --success-light: #34d399;
    --warning: #f59e0b;
    --warning-dark: #d97706;
    --danger: #ef4444;
    --danger-dark: #dc2626;
    --secondary: #64748b;
    --secondary-dark: #475569;
    --text-dark: #1e293b;
    --text-muted: #64748b;
    --bg-light: #f8fafc;
    --white: #ffffff;
    --shadow-sm: 0 4px 12px rgba(0,0,0,0.08);
    --shadow-md: 0 8px 24px rgba(0,0,0,0.12);
    --shadow-lg: 0 16px 40px rgba(0,0,0,0.16);
    --radius-sm: 8px;
    --radius-md: 12px;
    --radius-lg: 16px;
    --radius-xl: 20px;
    --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    --touch-target: 48px;
}

/* ===== RESET & BASE STYLES ===== */
* { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
html { -webkit-text-size-adjust: 100%; }

body { 
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif; 
    min-height: 100vh;
    padding: 16px;
    color: var(--text-dark); 
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    background: var(--bg-light);
}

/* ===== CONTAINER ===== */
.container { max-width: 1400px; margin: 0 auto; padding-bottom: 40px; }

/* ===== TOP BAR ===== */
.top-bar { 
    display: flex; 
    justify-content: space-between; 
    align-items: center; 
    background: var(--white); 
    padding: 20px; 
    border-radius: var(--radius-lg); 
    margin-bottom: 20px; 
    box-shadow: var(--shadow-md); 
    gap: 15px;
}
.welcome-section { flex: 1; min-width: 0; }
.welcome-section h1 { font-size: clamp(1.25rem, 4vw, 1.75rem); color: var(--text-dark); margin-bottom: 4px; font-weight: 700; }
.welcome-section p { color: var(--text-muted); font-size: clamp(0.8rem, 2vw, 0.9rem); line-height: 1.4; }
.user-info { display: flex; align-items: center; gap: 12px; flex-shrink: 0; }

.user-avatar {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: white;
    font-weight: 600;
    font-size: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
    flex-shrink: 0;
}

.user-details { text-align: right; }
.user-details .name { font-weight: 600; color: var(--text-dark); font-size: 14px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100px; }
.user-details .role { font-size: 12px; color: var(--text-muted); text-transform: capitalize; }

.logout-btn {
    background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
    color: white;
    border: none;
    border-radius: var(--radius-sm);
    padding: 10px 16px;
    cursor: pointer;
    font-weight: 600;
    font-size: 13px;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
    white-space: nowrap;
    min-height: var(--touch-target);
    display: flex;
    align-items: center;
}
.logout-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4); }

/* ===== STATS GRID ===== */
.stats-grid { 
    display: grid; 
    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); 
    gap: 12px; 
    margin-bottom: 20px; 
}
.stat-card { 
    background: var(--white); 
    padding: 16px; 
    border-radius: var(--radius-md); 
    box-shadow: var(--shadow-sm); 
    text-align: center;
    transition: var(--transition);
}
.stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
.stat-number { 
    font-size: clamp(1.25rem, 3vw, 1.75rem); 
    font-weight: bold; 
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%); 
    -webkit-background-clip: text; 
    -webkit-text-fill-color: transparent; 
}
.stat-label { color: var(--text-muted); font-size: clamp(0.7rem, 1.5vw, 0.8rem); margin-top: 4px; font-weight: 600; }

/* ===== FILTERS CONTAINER ===== */
.filters-container { 
    background: var(--white); 
    padding: 24px; 
    border-radius: var(--radius-lg); 
    box-shadow: var(--shadow-md); 
    margin-bottom: 20px; 
}
.filters-container h2 {
    font-size: clamp(1rem, 3vw, 1.25rem);
    color: var(--text-dark);
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
}
.filters-container h2 i { color: var(--primary); }

/* ===== EXAM TYPE TABS ===== */
.exam-type-tabs {
    display: flex;
    gap: 12px;
    margin-bottom: 24px;
    flex-wrap: wrap;
}
.exam-type-tab {
    padding: 14px 24px;
    border: 2px solid #e2e8f0;
    background: var(--white);
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    font-size: 14px;
    color: var(--text-muted);
    transition: var(--transition);
    display: flex;
    align-items: center;
    gap: 8px;
    white-space: nowrap;
    min-height: var(--touch-target);
}
.exam-type-tab:hover:not(.active) {
    border-color: var(--primary-light);
    color: var(--primary);
}
.exam-type-tab.active {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: white;
    border-color: var(--primary);
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

/* ===== FORM STYLES ===== */
.filter-form { 
    display: flex; 
    flex-wrap: wrap; 
    gap: 16px; 
    align-items: flex-end; 
}
.form-group { flex: 1; min-width: 160px; }
.form-group label { 
    font-size: 12px; 
    color: var(--text-muted); 
    font-weight: 600; 
    display: block; 
    margin-bottom: 8px; 
}

.form-group select {
    width: 100%;
    padding: 14px 40px 14px 16px;
    border: 2px solid #e2e8f0;
    border-radius: var(--radius-md);
    font-size: 15px;
    color: var(--text-dark);
    background: var(--bg-light) url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%2364748b' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E") no-repeat right 14px center;
    transition: var(--transition);
    cursor: pointer;
    min-height: var(--touch-target);
}
.form-group select:focus {
    outline: none;
    border-color: var(--primary);
    background-color: var(--white);
    box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
    transform: scale(1.02);
}

/* ===== BUTTONS ===== */
.btn-primary {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: white;
    border: none;
    border-radius: var(--radius-md);
    padding: 14px 24px;
    font-weight: 600;
    font-size: 14px;
    cursor: pointer;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    min-height: var(--touch-target);
}
.btn-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4); }

.btn-secondary, .btn-success {
    background: linear-gradient(135deg, var(--secondary) 0%, var(--secondary-dark) 100%);
    color: white;
    border: none;
    border-radius: var(--radius-md);
    padding: 14px 24px;
    font-weight: 600;
    font-size: 13px;
    cursor: pointer;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(100, 116, 139, 0.3);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    text-decoration: none;
    flex: 1;
    min-width: 140px;
    min-height: var(--touch-target);
}
.btn-success {
    background: linear-gradient(135deg, var(--success) 0%, #059669 100%);
    box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
}
.btn-success:hover, .btn-secondary:hover { 
    transform: translateY(-2px); 
    box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4); 
}

/* ===== TABLE CARD ===== */
.table-card { 
    background: var(--white); 
    border-radius: var(--radius-lg); 
    overflow: hidden; 
    box-shadow: var(--shadow-md); 
    margin-bottom: 20px;
}
.table-header {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    padding: 20px;
}
.table-header h2 { 
    color: white; 
    font-size: clamp(1.1rem, 3vw, 1.3rem); 
    display: flex; 
    align-items: center; 
    gap: 12px; 
    font-weight: 600; 
}

.table-wrapper { overflow-x: auto; -webkit-overflow-scrolling: touch; }

table { width: 100%; border-collapse: collapse; background: var(--white); min-width: 700px; }
th { 
    padding: 16px 12px; 
    text-align: left; 
    font-weight: 600; 
    color: var(--text-muted); 
    font-size: 12px; 
    text-transform: uppercase; 
    background: var(--bg-light); 
    border-bottom: 2px solid #e2e8f0; 
    white-space: nowrap;
}
td { padding: 16px 12px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }

tr:hover { background: var(--bg-light); }

.student-name { display: flex; align-items: center; gap: 12px; }
.student-avatar { 
    width: 40px; 
    height: 40px; 
    border-radius: var(--radius-md); 
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: white; 
    font-weight: 600; 
    font-size: 14px;
    display: flex; 
    align-items: center; 
    justify-content: center; 
    flex-shrink: 0;
}
.student-name span { font-size: 15px; font-weight: 500; }

/* ===== MARKS INPUTS ===== */
input.form-control { 
    width: 72px; 
    padding: 12px 10px; 
    border-radius: var(--radius-sm); 
    border: 2px solid #e2e8f0; 
    text-align: center; 
    font-size: 15px; 
    font-weight: 500;
    transition: var(--transition);
    min-height: var(--touch-target);
}
input.form-control:focus { 
    outline: none; 
    border-color: var(--primary); 
    box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
    transform: scale(1.05);
}
input.form-control[readonly] { 
    background: #f1f5f9; 
    font-weight: 700; 
    border-color: #cbd5e1; 
    color: var(--text-dark);
}

/* ===== UT/SEM SPECIFIC STYLING ===== */
.ut-header { background: #dbeafe !important; color: #1e40af !important; }
.ut-avg-cell { background: #eff6ff !important; color: #1d4ed8; font-weight: 700; }
.sem-header { background: #fef3c7 !important; color: #92400e !important; }
.sem-avg-cell { background: #fffbeb !important; color: #d97706; font-weight: 700; }

/* ===== ACTION BUTTONS ===== */
.action-buttons { 
    display: flex; 
    gap: 12px; 
    padding: 0 0 24px 0; 
    flex-wrap: wrap; 
}

/* ===== RESPONSIVE BREAKPOINTS ===== */
@media (max-width: 992px) {
    .top-bar { padding: 18px; }
    .welcome-section h1 { font-size: 20px; }
}

@media (max-width: 768px) {
    body { padding: 12px; }
    .top-bar { flex-direction: column; gap: 16px; text-align: center; padding: 16px; }
    .stats-grid { grid-template-columns: 1fr; gap: 12px; }
    .filter-form { flex-direction: column; }
    .form-group { width: 100%; min-width: 100%; }
    .btn-primary { width: 100%; }
    .exam-type-tabs { justify-content: center; flex-direction: column; }
    .exam-type-tab { width: 100%; justify-content: center; }
    th, td { padding: 12px 8px; font-size: 13px; }
    input.form-control { width: 64px; }
}
@media (max-width: 768px) {

    .top-bar{
        flex-direction: column;
        align-items: center;
        text-align: center;
        gap: 16px;
    }

    .user-info{
        width: 100%;
        justify-content: center;
        flex-wrap: wrap;
        gap: 10px;
    }

    .user-details{
        text-align: center;
    }

    .logout-btn{
        width: 100%;
        justify-content: center;
    }

}
@media (max-width: 576px) {
    .filters-container { padding: 16px; }
    .filters-container h2 { font-size: 18px; margin-bottom: 16px; }
    .table-header { padding: 16px; }
    .table-header h2 { font-size: 16px; }
    th { padding: 10px 6px; font-size: 11px; }
    td { padding: 10px 6px; }
    .student-name { gap: 8px; }
    .student-avatar { width: 36px; height: 36px; font-size: 13px; }
    .action-buttons { flex-direction: column; }
    .btn-secondary, .btn-success { width: 100%; }
}

@media (max-width: 400px) {
    .welcome-section h1 { font-size: 20px; }
    input.form-control { width: 58px; font-size: 14px; }
}

/* ===== TOUCH IMPROVEMENTS ===== */
@media (hover: none) and (pointer: coarse) {
    .btn-secondary:hover, .btn-primary:hover, .logout-btn:hover, .exam-type-tab:hover { transform: none; }
    .btn-secondary:active, .btn-primary:active, .logout-btn:active, .exam-type-tab.active:active { transform: scale(0.98); }
}

/* ===== ANIMATIONS ===== */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}
.filters-container, .table-card, .stat-card { animation: fadeIn 0.5s ease-out; }

</style>
</head>
<body>

<div class="container">

<!-- TOP BAR -->

<div class="top-bar">
    <div class="welcome-section">
        <h1><i class="fas fa-clipboard-list"></i> Enter Marks</h1>
        <p>Welcome back, <%= user.getUsername() %>! Record student performance</p>
    </div>
    <div class="user-info">
        <div class="user-avatar"><%= avatarLetter %></div>
        <div class="user-details">
            <div class="name"><%= user.getUsername() %></div>
            <div class="role"><%= user.getRole() %></div>
        </div>
        <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> <span>Logout</span></button>
    </div>
</div>

<!-- STATS GRID -->
<% if(totalStudents > 0) { %>
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-number"><%= totalStudents %></div>
        <div class="stat-label">Total Students</div>
    </div>
   
</div>
<% } %>

<!-- FILTERS CONTAINER -->
<div class="filters-container">
    <h2><i class="fas fa-filter"></i> Select Class & Exam Type</h2>
    
    <!-- Exam Type Tabs -->
    <div class="exam-type-tabs">
        <button type="button" class="exam-type-tab <%= "ut".equals(examType) ? "active" : "" %>"
                onclick="setExamType('ut', this)">
            <i class="fas fa-flask"></i> Unit Tests (UT1+UT2)
        </button>
        <button type="button" class="exam-type-tab <%= "sem".equals(examType) ? "active" : "" %>"
                onclick="setExamType('sem', this)">
            <i class="fas fa-graduation-cap"></i> Semesters (SEM1+SEM2)
        </button>
    </div>
    
    <!-- Filter Form -->
    <form action="<%=request.getContextPath()%>/teacher/EnterMarksServlet" method="get" class="filter-form" id="filterForm">
        <input type="hidden" name="examType" id="examType" value="<%= examType %>">
        
        <div class="form-group">
            <label>Class *</label>
            <select name="classId">
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

        <div class="form-group">
            <label>Subject *</label>
            <select name="subjectId">
                <option value="">--Select Subject--</option>
                <%
                    try(Connection conn = SQLConnection.getConnection()) {
                        ResultSet rs = conn.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name").executeQuery();
                        while(rs.next()) {
                            String id = String.valueOf(rs.getInt("subject_id"));
                            String selected = (subjectIdParam != null && subjectIdParam.equals(id)) ? "selected" : "";
                %>
                <option value="<%=id%>" <%=selected%>><%=rs.getString("subject_name")%></option>
                <%
                        }
                    } catch(Exception e){ e.printStackTrace(); }
                %>
            </select>
        </div>

        <button type="submit" class="btn-primary">
            <i class="fas fa-search"></i> Load Students
        </button>
    </form>
</div>

<%
    if(classIdParam != null && !classIdParam.isEmpty() &&
       subjectIdParam != null && !subjectIdParam.isEmpty()) {

        int classId = Integer.parseInt(classIdParam);
        int subjectId = Integer.parseInt(subjectIdParam);
%>

<!-- MARKS ENTRY FORM -->
<form method="post" action="EnterMarksServlet">
<input type="hidden" name="classId" value="<%=classId%>">
<input type="hidden" name="subjectId" value="<%=subjectId%>">
<input type="hidden" name="examType" value="<%=examType%>">

<div class="table-card">
    <div class="table-header">
        <h2>
            <i class="fas fa-edit"></i> 
            <%= "ut".equals(examType) ? "Unit Test Marks Entry" : "Semester Marks Entry" %>
        </h2>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Roll</th>
                    <th>Student</th>
                    <% if ("ut".equals(examType)) { %>
                    <th class="ut-header">UT1 (30)</th>
                    <th class="ut-header">UT2 (30)</th>
                    <th class="ut-header">Average</th>
                    <% } else { %>
                    <th class="sem-header">SEM1 (100)</th>
                    <th class="sem-header">SEM2 (100)</th>
                    <th class="sem-header">Average</th>
                    <% } %>
                </tr>
            </thead>
            <tbody>
            <%
                try(Connection conn = SQLConnection.getConnection()) {
                    String sql = "";
                    if ("ut".equals(examType)) {
                        sql = "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, " +
                             "m.ut1, m.ut2, m.average " +
                             "FROM students s " +
                             "LEFT JOIN marks m ON s.student_id = m.student_id AND m.subject_id=? " +
                             "WHERE s.class_id=? ORDER BY s.roll_number ASC";
                    } else {
                        sql = "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, " +
                             "m.sem1, m.sem2, m.sem_average " +
                             "FROM students s " +
                             "LEFT JOIN marks m ON s.student_id = m.student_id AND m.subject_id=? " +
                             "WHERE s.class_id=? ORDER BY s.roll_number ASC";
                    }

                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setInt(1, subjectId);
                    ps.setInt(2, classId);
                    ResultSet rs = ps.executeQuery();

                    int index = 0;
                    while(rs.next()) {
                        index++;
                        String firstLetter = rs.getString("first_name").substring(0,1).toUpperCase();
            %>
                <tr>
                    <td><%=index%></td>
                    <td><strong><%=rs.getString("roll_number")%></strong></td>
                    <td>
                        <div class="student-name">
                            <div class="student-avatar"><%= firstLetter %></div>
                            <span><%= rs.getString("first_name")%> <%=rs.getString("last_name")%></span>
                        </div>
                    </td>
                    
                    <% if ("ut".equals(examType)) { %>
                    <td>
    <input type="hidden" name="studentId_<%=index%>" value="<%=rs.getInt("student_id")%>">
    <input type="number" min="0" max="30" step="0.5" id="mark1_<%=index%>" name="ut1_<%=index%>" class="form-control"
           value="<%= rs.getObject("ut1") != null ? rs.getObject("ut1").toString() : "" %>"
           oninput="calculateAverage(<%=index%>)">
</td>
<td>
    <input type="number" min="0" max="30" step="0.5" id="mark2_<%=index%>" name="ut2_<%=index%>" class="form-control"
           value="<%= rs.getObject("ut2") != null ? rs.getObject("ut2").toString() : "" %>"
           oninput="calculateAverage(<%=index%>)">
</td>
<td>
    <input type="text" readonly id="avg_<%=index%>" name="avg_<%=index%>" class="form-control ut-avg-cell"
           value="<%= rs.getObject("average") != null ? String.format("%.1f", rs.getFloat("average")) : "" %>">
</td>
                    <% } else { %>
                    <td>
                        <input type="hidden" name="studentId_<%=index%>" value="<%=rs.getInt("student_id")%>">
                        <input type="number" min="0" max="100" step="0.5" id="mark1_<%=index%>" name="sem1_<%=index%>" class="form-control"
                               value="<%= rs.getObject("sem1") != null ? rs.getInt("sem1") : "" %>"
                               oninput="calculateAverage(<%=index%>)">
                    </td>
                    <td>
                        <input type="number" min="0" max="100" step="0.5" id="mark2_<%=index%>" name="sem2_<%=index%>" class="form-control"
                               value="<%= rs.getObject("sem2") != null ? rs.getInt("sem2") : "" %>"
                               oninput="calculateAverage(<%=index%>)">
                    </td>
                    <td>
                        <input type="text" readonly id="avg_<%=index%>" name="avg_<%=index%>" class="form-control sem-avg-cell"
                               value="<%= rs.getObject("sem_average") != null ? String.format("%.1f", rs.getFloat("sem_average")) : "" %>">
                    </td>
                    <% } %>
                </tr>
            <%
                    }
                    request.setAttribute("rows", index);
                } catch(Exception e){ e.printStackTrace(); }
            %>
            </tbody>
        </table>
    </div>
</div>

<input type="hidden" name="rows" value="<%=request.getAttribute("rows")%>">

<div class="action-buttons">
    
    <button type="button" class="btn-secondary"
        onclick="window.location.href='Index.jsp';"
        style="background-color:#6c757d;
               color:white;
               padding:8px 16px;
               border:none;
               border-radius:5px;
               cursor:pointer;
               font-size:14px;
               display:inline-flex;
               align-items:center;
               gap:6px;">
        <i class="fa-solid fa-arrow-left"></i>
        Back
    </button>
    <button type="submit" class="btn-success">
        <i class="fas fa-save"></i> Save All Marks
    </button>
    <a href="<%=request.getContextPath()%>/teacher/DownloadMarksServlet?classId=<%=classId%>&subjectId=<%=subjectId%>&examType=<%=examType%>" 
       class="btn-success">
        <i class="fas fa-file-excel"></i> Download Excel
    </a>
</div>

</form>

<% } %>

<script>
// Original JavaScript preserved + enhanced
function setExamType(type, btn){
    document.getElementById("examType").value = type;
    
    // Update tabs
    document.querySelectorAll(".exam-type-tab").forEach(function(tab){
        tab.classList.remove("active");
    });
    btn.classList.add("active");
    
    // Submit form
    document.getElementById("filterForm").submit();
}

function calculateAverage(index){
    let m1 = parseFloat(document.getElementById("mark1_" + index)?.value) || 0;
    let m2 = parseFloat(document.getElementById("mark2_" + index)?.value) || 0;
    
    let avg = (m1 + m2) / 2;
    
    let avgField = document.getElementById("avg_" + index);
    if(avgField){
        avgField.value = avg ? avg.toFixed(1) : "";
    }
}

function goBack() {
    window.location.href = 'Index.jsp';
}

// iOS zoom prevention
if (/iPad|iPhone|iPod/.test(navigator.userAgent)) {
    document.querySelectorAll('input, select').forEach(function(input) {
        input.addEventListener('focus', function() {
            this.style.fontSize = '16px';
        });
    });
}
</script>

</div>
</body>
</html>

