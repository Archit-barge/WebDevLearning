<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="com.seh.model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>

<%
    // ===== AUTH CHECK =====
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String avatarLetter = "A";
    if (user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }

    // ===== GET PARAMETERS FROM REQUEST ATTRIBUTE =====
    String classIdParam = (String) request.getAttribute("classId");
    String subjectIdParam = (String) request.getAttribute("subject_id");
    String viewType = (String) request.getAttribute("viewType");
    String dateParam = (String) request.getAttribute("date");
    String startDateParam = (String) request.getAttribute("startDate");
    String endDateParam = (String) request.getAttribute("endDate");
    String sessionTypeParam = (String) request.getAttribute("sessionType");
    String timeSlotParam = (String) request.getAttribute("timeSlot");
    
    // Set defaults
    if (viewType == null) viewType = "single";
    if (dateParam == null) dateParam = LocalDate.now().toString();
    if (startDateParam == null) startDateParam = LocalDate.now().withDayOfMonth(1).toString();
    if (endDateParam == null) endDateParam = LocalDate.now().toString();

    int teacherId = 0;
    try (Connection conn = SQLConnection.getConnection()) {
        PreparedStatement psT = conn.prepareStatement(
            "SELECT teacher_id FROM teachers WHERE user_id = ?"
        );
        psT.setInt(1, user.getUserId());
        ResultSet rsT = psT.executeQuery();
        if (rsT.next()) {
            teacherId = rsT.getInt("teacher_id");
        }
    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
<title>View Attendance</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* ===== CSS VARIABLES ===== */
:root {
    --primary: #667eea;
    --primary-dark: #5a67d8;
    --primary-light: #818cf8;
    --success: #10b981;
    --success-light: #34d399;
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
    grid-template-columns: repeat(4, 1fr); 
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
    font-size: clamp(1.5rem, 4vw, 2rem); 
    font-weight: bold; 
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%); 
    -webkit-background-clip: text; 
    -webkit-text-fill-color: transparent; 
}
.stat-label { color: var(--text-muted); font-size: clamp(0.7rem, 2vw, 0.8rem); margin-top: 4px; font-weight: 600; }

/* ===== FILTERS CONTAINER ===== */
.filters-container { 
    background: var(--white); 
    padding: 20px; 
    border-radius: var(--radius-lg); 
    box-shadow: var(--shadow-md); 
    margin-bottom: 20px; 
}
.filters-container h2 {
    font-size: clamp(1rem, 3vw, 1.125rem);
    color: var(--text-dark);
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
}
.filters-container h2 i { color: var(--primary); }
.filters-container form { 
    display: flex; 
    flex-wrap: wrap; 
    gap: 12px; 
    align-items: flex-end; 
}
.filters-container label { 
    font-size: 12px; 
    color: var(--text-muted); 
    font-weight: 600; 
    display: block; 
    margin-bottom: 6px; 
}

.form-group { flex: 1; min-width: 140px; }
.form-group select, .form-group input {
    width: 100%;
    padding: 12px 36px 12px 14px;
    border: 2px solid #e2e8f0;
    border-radius: var(--radius-sm);
    font-size: 15px;
    color: var(--text-dark);
    background: var(--bg-light);
    transition: var(--transition);
    -webkit-appearance: none;
    appearance: none;
    cursor: pointer;
    min-height: var(--touch-target);
}
.form-group select {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%2364748b' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 14px center;
}
.form-group select:focus, .form-group input:focus {
    outline: none;
    border-color: var(--primary);
    background-color: var(--white);
    box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15), var(--shadow-md);
    transform: scale(1.02);
}
.form-group select:hover, .form-group input:hover {
    border-color: var(--primary-light);
}

.btn-primary {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: white;
    border: none;
    border-radius: var(--radius-sm);
    padding: 12px 20px;
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
    -webkit-tap-highlight-color: transparent;
}
.btn-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4); }

/* ===== VIEW TYPE TABS ===== */
.view-tabs {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}
.view-tab {
    padding: 12px 24px;
    border: 2px solid #e2e8f0;
    background: var(--white);
    border-radius: var(--radius-sm);
    cursor: pointer;
    font-weight: 600;
    font-size: 14px;
    color: var(--text-muted);
    transition: var(--transition);
    display: flex;
    align-items: center;
    gap: 8px;
}
.view-tab:hover {
    border-color: var(--primary-light);
    color: var(--primary);
}
.view-tab.active {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: white;
    border-color: var(--primary);
}

/* ===== DATE INPUTS FOR RANGE ===== */
.date-range-inputs {
    display: none;
    gap: 12px;
    width: 100%;
    flex-wrap: wrap;
}
.date-range-inputs.show {
    display: flex;
}
.single-date-input {
    display: block;
}
.single-date-input.hide {
    display: none;
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
    padding: 16px 20px;
    display: flex;
    flex-direction: column;
    gap: 8px;
}
.table-header h2 { color: white; font-size: clamp(1rem, 3vw, 1.25rem); display: flex; align-items: center; gap: 10px; font-weight: 600; }
.table-header .meta-info { color: rgba(255,255,255,0.9); font-size: clamp(0.7rem, 2vw, 0.85rem); display: flex; flex-wrap: wrap; gap: 12px; }
.table-header .meta-info i { margin-right: 4px; }

/* ===== TABLE STYLES ===== */
.table-wrapper {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
}

table { width: 100%; border-collapse: collapse; background: var(--white); min-width: 600px; }
th { 
    padding: 12px; 
    text-align: left; 
    font-weight: 600; 
    color: var(--text-muted); 
    font-size: 11px; 
    text-transform: uppercase; 
    background: var(--bg-light); 
    border-bottom: 2px solid #e2e8f0; 
    white-space: nowrap;
}
td { padding: 12px; border-bottom: 1px solid #f1f5f9; color: #334155; vertical-align: middle; }
tr:hover { background: var(--bg-light); }

.student-name { display: flex; align-items: center; gap: 10px; }
.student-name .avatar { 
    width: 36px; 
    height: 36px; 
    border-radius: var(--radius-sm); 
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    display: flex; 
    align-items: center; 
    justify-content: center; 
    font-weight: 600; 
    font-size: 13px;
    color: white;
    flex-shrink: 0;
}
.student-name span { font-size: 14px; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 120px; }

/* ===== STATUS BADGES ===== */
.status-label {
    font-weight: 600;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    white-space: nowrap;
    display: inline-block;
}
.status-label.present { background: #dcfce7; color: #166534; }
.status-label.absent { background: #fee2e2; color: #991b1b; }
.status-notmarked { background: #e5e7eb; color: #374151; }

/* ===== MONTHLY SUMMARY TABLE ===== */
.summary-table {
    margin-bottom: 20px;
}
.summary-table th {
    background: var(--primary);
    color: white;
}
.summary-table td {
    font-weight: 500;
}
.summary-table .present-cell { color: #059669; font-weight: 700; }
.summary-table .absent-cell { color: #dc2626; font-weight: 700; }
.summary-table .notmarked-cell { color: #6b7280; font-weight: 700; }

/* ===== BUTTONS ===== */
.action-buttons { display: flex; gap: 10px; padding: 0 0 20px 0; flex-wrap: wrap; }
.btn-secondary {
    background: linear-gradient(135deg, var(--secondary) 0%, var(--secondary-dark) 100%);
    color: white;
    border: none;
    border-radius: var(--radius-sm);
    padding: 12px 20px;
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
    min-width: 120px;
    -webkit-tap-highlight-color: transparent;
}
.btn-secondary:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(100, 116, 139, 0.4); }

/* ===== RESPONSIVE BREAKPOINTS ===== */
@media (max-width: 992px) {
    .top-bar { padding: 18px; }
    .welcome-section h1 { font-size: 20px; }
}

@media (max-width: 768px) {
    body { padding: 12px; }
    .top-bar { flex-direction: column; gap: 12px; text-align: center; padding: 16px; }
    .welcome-section h1 { font-size: 20px; }
    .welcome-section p { font-size: 12px; }
    .user-info { flex-direction: column; width: 100%; gap: 10px; }
    .user-details { text-align: center; }
    .user-details .name { max-width: 150px; }
    .logout-btn { width: 100%; justify-content: center; }
    .stats-grid { grid-template-columns: repeat(2, 1fr); gap: 10px; }
    .stat-card { padding: 14px; }
    .stat-number { font-size: 24px; }
    .stat-label { font-size: 11px; }
    .filters-container { padding: 16px; }
    .filters-container h2 { font-size: 16px; }
    .filter-form { flex-direction: column; }
    .form-group { width: 100%; min-width: 100%; }
    .btn-primary { width: 100%; }
    .table-header { padding: 14px 16px; }
    .table-header h2 { font-size: 16px; }
    th, td { padding: 10px 8px; font-size: 12px; }
    .student-name span { max-width: 100px; }
    .action-buttons { flex-direction: column; }
    .btn-secondary { width: 100%; }
    .view-tabs { justify-content: center; }
    .date-range-inputs { flex-direction: column; }
}

@media (max-width: 576px) {
    body { padding: 10px; }
    .container { padding-bottom: 30px; }
    .top-bar { padding: 14px; border-radius: var(--radius-md); margin-bottom: 15px; }
    .welcome-section h1 { font-size: 18px; }
    .welcome-section p { font-size: 11px; }
    .user-avatar { width: 40px; height: 40px; font-size: 16px; }
    .stats-grid { gap: 8px; }
    .stat-card { padding: 12px; border-radius: var(--radius-sm); }
    .stat-number { font-size: 22px; }
    .stat-label { font-size: 10px; }
    .filters-container { padding: 14px; border-radius: var(--radius-md); margin-bottom: 15px; }
    .filters-container h2 { font-size: 15px; margin-bottom: 12px; }
    .filters-container label { font-size: 11px; }
    .form-group select, .form-group input { padding: 12px 36px 12px 12px; font-size: 15px; }
    .btn-primary { padding: 14px 18px; font-size: 14px; }
    .table-card { border-radius: var(--radius-md); margin-bottom: 15px; }
    .table-header { padding: 12px 14px; }
    .table-header h2 { font-size: 15px; }
    .table-header .meta-info { font-size: 11px; gap: 8px; }
    th { padding: 8px 6px; font-size: 10px; }
    td { padding: 8px 6px; }
    .student-name { gap: 8px; }
    .student-name .avatar { width: 32px; height: 32px; font-size: 12px; }
    .student-name span { font-size: 12px; max-width: 80px; }
    .status-label { padding: 5px 10px; font-size: 11px; }
    .action-buttons { gap: 8px; margin-top: 0; }
    .btn-secondary { padding: 14px 16px; font-size: 13px; min-width: auto; }
    .view-tab { padding: 10px 16px; font-size: 12px; }
}

@media (max-width: 400px) {
    .welcome-section h1 { font-size: 16px; }
    .user-details .name { max-width: 100px; }
    .student-name span { max-width: 60px; }
}

/* ===== TOUCH IMPROVEMENTS ===== */
@media (hover: none) and (pointer: coarse) {
    .btn-secondary:hover, .btn-primary:hover, .logout-btn:hover { transform: none; }
    .btn-secondary:active, .btn-primary:active, .logout-btn:active { transform: scale(0.98); }
    .stat-card:hover { transform: none; }
    .stat-card:active { transform: scale(0.98); }
}

/* ===== ANIMATIONS ===== */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}
.filters-container, .table-card, .stat-card { animation: fadeIn 0.5s ease-out; }

/* ===== TIME SLOT INPUT ===== */
.time-slot-wrapper {
    display: flex;
    align-items: center;
    gap: 0px;
    width: 100%;
}
.time-input {
    flex: 1;
    min-width: 60px;
    padding: 10px 8px;
    border: 2px solid #e2e8f0;
    border-radius: var(--radius-sm);
    font-size: 14px;
    color: var(--text-dark);
    background: #fff;
    transition: var(--transition);
    cursor: pointer;
    height: 44px;
    width: 100%;
    text-align: center;
    font-family: inherit;
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
}
.time-input::-webkit-calendar-picker-indicator {
    cursor: pointer;
    filter: invert(30%);
    opacity: 0.8;
    padding: 0px;
    height: 20px;
    width: 20px;
}
.time-input::-webkit-calendar-picker-indicator:hover {
    opacity: 1;
}
.time-input:hover {
    border-color: var(--primary);
}
.time-input:focus {
    outline: none;
    border-color: var(--primary);
    background-color: var(--white);
    box-shadow: 0 0 0 4px rgba(102,126,234,0.15);
}
.time-separator {
    color: var(--text-dark);
    font-weight: 600;
    font-size: 13px;
    flex-shrink: 0;
    white-space: nowrap;
    padding: 0 2px;
}
#timeSlotGroup {
    flex: 2 !important;
    min-width: 180px;
}
#timeSlotGroup label {
    display: block;
    font-size: 12px;
    color: var(--text-muted);
    font-weight: 600;
    margin-bottom: 6px;
}
</style>
</head>
<body>

<div class="container">

<!-- TOP BAR -->
<div class="top-bar">
    <div class="welcome-section">
        <h1><i class="fas fa-calendar-check"></i> View Attendance</h1>
        <p>Welcome back, <%= user.getUsername() %>! Review student attendance records</p>
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

<!-- STATS -->


<!-- FILTER FORM -->
<div class="filters-container">
    <h2><i class="fas fa-filter"></i> Select Filters</h2>
    
    <!-- View Type Tabs -->
    <div class="view-tabs">
        <button type="button" class="view-tab <%= "single".equals(viewType) ? "active" : "" %>" onclick="setViewType('single')">
            <i class="fas fa-calendar-day"></i> Single Date
        </button>
        <button type="button" class="view-tab <%= "monthly".equals(viewType) ? "active" : "" %>" onclick="setViewType('monthly')">
            <i class="fas fa-calendar-alt"></i> Monthly/Range
        </button>
    </div>
    
    <form method="post" action="<%=request.getContextPath()%>/teacher/ViewAttendanceServlet" id="filterForm">
        <!-- Hidden field for view type -->
        <input type="hidden" name="viewType" id="viewType" value="<%= viewType %>">
        
        <!-- Class and Subject -->
        <div class="form-group">
            <label>Class *</label>
            <select name="classId" required>
                <option value="">-- Choose Class --</option>
                <%
                    try(Connection conn = SQLConnection.getConnection()){
                        // Get ALL classes - don't filter by teacher_id as classes may be assigned via class_subjects
                        String sql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        while(rs.next()){
                            String id = rs.getString("class_id");
                            String selected = (id != null && id.equals(classIdParam)) ? "selected" : "";
                %>
                <option value="<%=id%>" <%=selected%>><%=rs.getString("class_name")+"-"+rs.getString("section")%></option>
                <%
                        }
                    }catch(Exception e){ e.printStackTrace(); }
                %>
            </select>
        </div>

        <div class="form-group">
            <label>Subject *</label>
            <select name="subject_id" required>
                <option value="">-- Choose Subject --</option>
                <%
                    try(Connection conn = SQLConnection.getConnection()){
                        // Get ALL subjects
                        String sql = "SELECT subject_id, subject_name FROM subjects ORDER BY subject_name";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        while(rs.next()){
                            String id = rs.getString("subject_id");
                            String selected = (id != null && id.equals(subjectIdParam)) ? "selected" : "";
                %>
                <option value="<%=id%>" <%=selected%>><%=rs.getString("subject_name")%></option>
                <%
                        }
                    }catch(Exception e){ e.printStackTrace(); }
                %>
            </select>
        </div>

        <!-- Single Date -->
        <div class="form-group single-date-input <%= "monthly".equals(viewType) || "daywise".equals(viewType) ? "hide" : "" %>" id="singleDateGroup">
            <label>Date *</label>
            <input type="date" name="date" value="<%= dateParam %>">
        </div>

        <!-- Date Range for Monthly -->
        <div class="date-range-inputs <%= "monthly".equals(viewType) ? "show" : "" %>" id="dateRangeGroup">
            <div class="form-group">
                <label>Start Date *</label>
                <input type="date" name="startDate" value="<%= startDateParam %>">
            </div>
            <div class="form-group">
                <label>End Date *</label>
                <input type="date" name="endDate" value="<%= endDateParam %>">
            </div>
        </div>

        <!-- Session Type and Time Slot (for single date view) -->
        <div class="form-group <%= "monthly".equals(viewType) || "daywise".equals(viewType) ? "hide" : "" %>" id="sessionGroup">
            <label>Session *</label>
            <select name="sessionType" required>
                <option value="theory" <%= "theory".equals(sessionTypeParam)?"selected":"" %>>Theory</option>
                <option value="practical" <%= "practical".equals(sessionTypeParam)?"selected":"" %>>Practical</option>
            </select>
        </div>

        <div class="form-group <%= "monthly".equals(viewType) || "daywise".equals(viewType) ? "hide" : "" %>" id="timeSlotGroup">
            <label>Time Slot *</label>
            <div class="time-slot-wrapper">
                <input type="time" id="timeStart" name="timeStart" 
                       value="<%= timeSlotParam != null && timeSlotParam.contains("-") ? timeSlotParam.split("-")[0] : "" %>"
                       onchange="updateTimeSlot()"
                       class="time-input">
                <span class="time-separator">to</span>
                <input type="time" id="timeEnd" name="timeEnd" 
                       value="<%= timeSlotParam != null && timeSlotParam.contains("-") ? timeSlotParam.split("-")[1] : "" %>"
                       onchange="updateTimeSlot()"
                       class="time-input">
                <input type="hidden" name="timeSlot" id="timeSlot" value="<%= timeSlotParam != null ? timeSlotParam : "" %>">
            </div>
        </div>

        <script>
        function updateTimeSlot() {
            const start = document.getElementById('timeStart').value;
            const end = document.getElementById('timeEnd').value;
            if (start && end) {
                document.getElementById('timeSlot').value = start + '-' + end;
            }
        }
        </script>

        <button class="btn-primary" type="submit"><i class="fas fa-search"></i> View</button>
    </form>
</div>

<script>
function setViewType(type) {
    document.getElementById('viewType').value = type;
    
    // Update tabs
    document.querySelectorAll('.view-tab').forEach(tab => tab.classList.remove('active'));
    event.currentTarget.classList.add('active');
    
    // Show/hide date inputs
    const singleDateGroup = document.getElementById('singleDateGroup');
    const sessionGroup = document.getElementById('sessionGroup');
    const timeSlotGroup = document.getElementById('timeSlotGroup');
    const dateRangeGroup = document.getElementById('dateRangeGroup');
    
    if (type === 'single') {
        singleDateGroup.classList.remove('hide');
        sessionGroup.classList.remove('hide');
        timeSlotGroup.classList.remove('hide');
        dateRangeGroup.classList.remove('show');
    } else if (type === 'daywise') {
        singleDateGroup.classList.remove('hide');
        sessionGroup.classList.add('hide');
        timeSlotGroup.classList.add('hide');
        dateRangeGroup.classList.remove('show');
    } else if (type === 'monthly') {
        singleDateGroup.classList.add('hide');
        sessionGroup.classList.add('hide');
        timeSlotGroup.classList.add('hide');
        dateRangeGroup.classList.add('show');
    }
}
</script>

<%
// Get data from request attributes
List students = (List) request.getAttribute("students");
Map attendanceBySession = (Map) request.getAttribute("attendanceBySession");
List sessionsList = (List) request.getAttribute("sessionsList");
List studentSummary = (List) request.getAttribute("studentSummary");

// Check if we should display data
boolean showSingleView = "single".equals(viewType) && classIdParam != null && subjectIdParam != null && dateParam != null && sessionTypeParam != null && timeSlotParam != null;
boolean showDayWiseView = "daywise".equals(viewType) && classIdParam != null && subjectIdParam != null && dateParam != null;
boolean showMonthlyView = "monthly".equals(viewType) && classIdParam != null && subjectIdParam != null && startDateParam != null && endDateParam != null;

if (showSingleView && students != null && !students.isEmpty()) {
%>

<div class="action-buttons">
    <a href="<%=request.getContextPath()%>/teacher/TeacherAttendanceServlet" class="btn-secondary">
        <i class="fas fa-edit"></i> Mark
    </a>
    
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
</div>

<div class="table-card">
    <div class="table-header">
        <h2><i class="fas fa-users"></i> Student Attendance - <%= dateParam %></h2>
        <div class="meta-info">
            <span><i class="fas fa-clock"></i> <%= timeSlotParam %></span>
            <span><i class="fas fa-book"></i> <%= sessionTypeParam %></span>
        </div>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Student</th>
                    <th>Roll</th>
                    <th>Class</th>
                    <th>Subject</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
            <%
            for (Object obj : students) {
                Map student = (Map) obj;
                String name = student.get("first_name") + " " + student.get("last_name");
                String firstLetter = student.get("first_name") != null ? ((String)student.get("first_name")).substring(0,1).toUpperCase() : "A";
                String status = (String) student.get("status");
                String statusClass = "status-label";
                if("present".equalsIgnoreCase(status)) statusClass="status-label present";
                else if("absent".equalsIgnoreCase(status)) statusClass="status-label absent";
                else statusClass = "status-label status-notmarked";
            %>
            <tr>
                <td>
                    <div class="student-name">
                        <div class="avatar"><%=firstLetter%></div>
                        <span><%=name%></span>
                    </div>
                </td>
                <td><strong><%= student.get("roll_number") %></strong></td>
                <td><%= student.get("class_name") + "-" + student.get("section") %></td>
                <td><%= student.get("subject_name") %></td>
                <td><span class="<%=statusClass%>"><%=status%></span></td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<% } else if (showDayWiseView && sessionsList != null && !sessionsList.isEmpty()) { %>

<div class="action-buttons">
    <a href="<%=request.getContextPath()%>/teacher/TeacherAttendanceServlet" class="btn-secondary">
        <i class="fas fa-edit"></i> Mark
    </a>
    <button type="button" class="btn-secondary" onclick="goBack()">
        <i class="fas fa-arrow-left"></i> Back
    </button>
</div>

<% 
// Get all unique students from the first session
Map firstSession = (Map) sessionsList.get(0);
String firstSessionKey = firstSession.get("session_type") + "|" + firstSession.get("time_slot");
List firstSessionStudents = (List) attendanceBySession.get(firstSessionKey);
%>

<div class="table-card">
    <div class="table-header">
        <h2><i class="fas fa-users"></i> Day-wise Attendance - <%= dateParam %></h2>
        <div class="meta-info">
            <span><i class="fas fa-calendar"></i> <%= dateParam %></span>
            <span><i class="fas fa-layer-group"></i> <%= sessionsList.size() %> Sessions</span>
        </div>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Student</th>
                    <th>Roll</th>
                    <% for (Object sess : sessionsList) { 
                        Map sessionMap = (Map) sess;
                    %>
                    <th><%= sessionMap.get("session_type") %><br><small><%= sessionMap.get("time_slot") %></small></th>
                    <% } %>
                </tr>
            </thead>
            <tbody>
            <%
            if (firstSessionStudents != null) {
                for (Object obj : firstSessionStudents) {
                    Map student = (Map) obj;
                    String name = student.get("first_name") + " " + student.get("last_name");
                    String firstLetter = student.get("first_name") != null ? ((String)student.get("first_name")).substring(0,1).toUpperCase() : "A";
                    String studentId = (String) student.get("student_id");
            %>
            <tr>
                <td>
                    <div class="student-name">
                        <div class="avatar"><%=firstLetter%></div>
                        <span><%=name%></span>
                    </div>
                </td>
                <td><strong><%= student.get("roll_number") %></strong></td>
                <%
                for (Object sess : sessionsList) { 
                    Map sessionMap = (Map) sess;
                    String sessionKey = sessionMap.get("session_type") + "|" + sessionMap.get("time_slot");
                    List sessionStudents = (List) attendanceBySession.get(sessionKey);
                    
                    String status = "N/A";
                    String statusClass = "status-label";
                    
                    if (sessionStudents != null) {
                        for (Object sObj : sessionStudents) {
                            Map s = (Map) sObj;
                            if (s.get("student_id").equals(studentId)) {
                                status = (String) s.get("status");
                                if("present".equalsIgnoreCase(status)) statusClass="status-label present";
                                else if("absent".equalsIgnoreCase(status)) statusClass="status-label absent";
                                else statusClass = "status-label status-notmarked";
                                break;
                            }
                        }
                    }
                %>
                <td><span class="<%=statusClass%>"><%= status.length() > 10 ? status.substring(0, 10) : status %></span></td>
                <% } %>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>

<% } else if (showMonthlyView && studentSummary != null && !studentSummary.isEmpty()) { %>

<div class="action-buttons">
    <a href="<%=request.getContextPath()%>/teacher/TeacherAttendanceServlet" class="btn-secondary">
        <i class="fas fa-edit"></i> Mark
    </a>
<button type="button" class="btn-secondary" onclick="downloadExcel()">
        <i class="fas fa-file-excel"></i> Excel
    </button>
    <button type="button" class="btn-secondary" onclick="goBack()">
        <i class="fas fa-arrow-left"></i> Back
    </button>
</div>

<div class="table-card">
    <div class="table-header">
        <h2><i class="fas fa-chart-bar"></i> Monthly Attendance Summary</h2>
        <div class="meta-info">
            <span><i class="fas fa-calendar"></i> <%= startDateParam %> to <%= endDateParam %></span>
            <span><i class="fas fa-users"></i> <%= studentSummary.size() %> Students</span>
        </div>
    </div>
    <div class="table-wrapper">
        <table class="summary-table">
            <thead>
                <tr>
                    <th>Student</th>
                    <th>Roll No.</th>
                    <th>Present</th>
                    <th>Absent</th>
                    <th>Not Marked</th>
                    <th>Total</th>
                    <th>Attendance %</th>
                </tr>
            </thead>
            <tbody>
            <%
            for (Object obj : studentSummary) {
                Map summary = (Map) obj;
                int present = (Integer) summary.get("present");
                int absent = (Integer) summary.get("absent");
                int notMarked = (Integer) summary.get("notMarked");
                int total = (Integer) summary.get("total");
                double percentage = total > 0 ? (present * 100.0 / total) : 0;
                
                String name = summary.get("first_name") + " " + summary.get("last_name");
                String firstLetter = summary.get("first_name") != null ? ((String)summary.get("first_name")).substring(0,1).toUpperCase() : "A";
            %>
            <tr>
                <td>
                    <div class="student-name">
                        <div class="avatar"><%=firstLetter%></div>
                        <span><%=name%></span>
                    </div>
                </td>
                <td><strong><%= summary.get("roll_number") %></strong></td>
                <td class="present-cell"><%= present %></td>
                <td class="absent-cell"><%= absent %></td>
                <td class="notmarked-cell"><%= notMarked %></td>
                <td><%= total %></td>
                <td>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <div style="flex: 1; height: 8px; background: #e5e7eb; border-radius: 4px; overflow: hidden;">
                            <div style="width: <%= percentage %>%; height: 100%; background: <%= percentage >= 75 ? "var(--success)" : (percentage >= 50 ? "#f59e0b" : "var(--danger)") %>; border-radius: 4px;"></div>
                        </div>
                        <span style="font-weight: 600; min-width: 45px;"><%= String.format("%.1f", percentage) %>%</span>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<% } else if ((showSingleView || showDayWiseView || showMonthlyView) && 
              ((students != null && students.isEmpty()) || 
               (sessionsList != null && sessionsList.isEmpty()) || 
               (studentSummary != null && studentSummary.isEmpty()))) { %>
               
<div class="table-card">
    <div class="table-header" style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);">
        <h2><i class="fas fa-info-circle"></i> No Attendance Records Found</h2>
    </div>
    <div style="padding: 40px; text-align: center;">
        <i class="fas fa-search" style="font-size: 48px; color: #d1d5db; margin-bottom: 16px;"></i>
        <p style="font-size: 16px; color: #6b7280;">No attendance records found for the selected criteria.</p>
        <p style="font-size: 14px; color: #9ca3af; margin-top: 8px;">Please check your filters or mark attendance first.</p>
    </div>
</div>

<% } %>

<script>
function logout(){ 
    if(confirm('Are you sure you want to logout?')) {
        window.location.href='<%=request.getContextPath()%>/LogoutServlet'; 
    }
}

function goBack() {
    window.location.href = 'Index.jsp';
}

function downloadExcel() {
    var classId = document.querySelector('input[name="classId"]') ? 
        document.querySelector('input[name="classId"]').value : '<%= classIdParam %>';
    var subjectId = document.querySelector('input[name="subject_id"]') ? 
        document.querySelector('input[name="subject_id"]').value : '<%= subjectIdParam %>';
    var startDate = '<%= startDateParam %>';
    var endDate = '<%= endDateParam %>';
    
    if (classId && subjectId && startDate && endDate) {
        window.location.href = '<%=request.getContextPath()%>/teacher/AttendanceExcelServlet?classId=' + 
            classId + '&subject_id=' + subjectId + '&startDate=' + startDate + '&endDate=' + endDate;
    } else {
        alert('Please select filters and view attendance first');
    }
}

// Prevent zoom on input focus for iOS
if (/iPad|iPhone|iPod/.test(navigator.userAgent)) {
    var inputs = document.querySelectorAll('input, select');
    inputs.forEach(function(input) {
        input.addEventListener('focus', function() {
            this.style.fontSize = '16px';
        });
    });
}
</script>

</div>
</body>
</html>

