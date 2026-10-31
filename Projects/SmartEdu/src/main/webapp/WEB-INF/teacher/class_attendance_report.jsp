<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="com.seh.model.User" %>
<%@ page import="java.sql.*" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String avatarLetter = "A";
    if (user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }

    String classIdParam = (String) request.getAttribute("classId");
    String subjectIdParam = (String) request.getAttribute("subjectId");
    String sessionTypeParam = (String) request.getAttribute("sessionType");

    String className = "";
    String subjectName = "";
    String sessionTypeDisplay = "All";

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

        if (classIdParam != null && !classIdParam.isEmpty()) {
            PreparedStatement psC = conn.prepareStatement(
                "SELECT class_name, section FROM classes WHERE class_id = ?"
            );
            psC.setInt(1, Integer.parseInt(classIdParam));
            ResultSet rsC = psC.executeQuery();
            if (rsC.next()) {
                className = rsC.getString("class_name") + " - " + rsC.getString("section");
            }
        }

        if (subjectIdParam != null && !subjectIdParam.isEmpty()) {
            PreparedStatement psS = conn.prepareStatement(
                "SELECT subject_name FROM subjects WHERE subject_id = ?"
            );
            psS.setInt(1, Integer.parseInt(subjectIdParam));
            ResultSet rsS = psS.executeQuery();
            if (rsS.next()) {
                subjectName = rsS.getString("subject_name");
            }
        }

        if (sessionTypeParam != null) {
            if ("theory".equals(sessionTypeParam)) {
                sessionTypeDisplay = "Theory";
            } else if ("practical".equals(sessionTypeParam)) {
                sessionTypeDisplay = "Practical";
            } else {
                sessionTypeDisplay = "All";
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    List<Map<String, Object>> attendanceList =
        (List<Map<String, Object>>) request.getAttribute("attendanceList");
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

.class-attendance-content {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: var(--bg-light);
    color: var(--text-dark);
    line-height: 1.5;
    -webkit-font-smoothing: antialiased;
    min-height: 100vh;
    padding: 0.5rem;
}

.container {
    padding-bottom: 2.5rem;
}

/* ===== TOP BAR ===== */
.top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: var(--white);
    padding: 1.5rem 2rem;
    border-radius: var(--radius-lg);
    margin-bottom: 1.5rem;
    box-shadow: var(--shadow-sm);
    flex-wrap: wrap;
    gap: 1rem;
}

.welcome-section {
    flex: 1;
    min-width: 200px;
}

.welcome-section h1 {
    font-size: clamp(1.25rem, 4vw, 1.75rem);
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 0.25rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.welcome-section h1 i {
    color: var(--primary);
}

.welcome-section p {
    color: var(--text-muted);
    font-size: clamp(0.75rem, 2.5vw, 0.9rem);
    font-weight: 500;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
    justify-content: flex-end;
}

.user-avatar {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: var(--white);
    font-weight: 600;
    font-size: 1.125rem;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
    flex-shrink: 0;
}

.user-details {
    display: flex;
    flex-direction: column;
    text-align: right;
    min-width: 80px;
}

.user-details .name {
    font-weight: 600;
    color: var(--text-dark);
    font-size: 0.875rem;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 100px;
}

.user-details .role {
    font-size: 0.75rem;
    color: var(--text-muted);
    text-transform: capitalize;
}

.logout-btn {
    background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
    color: var(--white);
    border: none;
    border-radius: var(--radius-sm);
    padding: 10px 16px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.8125rem;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
    white-space: nowrap;
    display: flex;
    align-items: center;
    gap: 6px;
    min-height: var(--touch-target);
}

.logout-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
}

.logout-btn:active {
    transform: scale(0.98);
}

/* ===== FILTERS CONTAINER ===== */
.filters-container {
    background: var(--white);
    padding: 2rem;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-md);
    margin-bottom: 1.5rem;
    border: 1px solid #e2e8f0;
}

.filters-container h2 {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 1.25rem;
    display: flex;
    align-items: center;
    gap: 0.625rem;
}

.filters-container h2 i {
    color: var(--primary);
}

.filters-container form {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
    align-items: flex-end;
}

.form-group {
    flex: 1;
    min-width: 140px;
}

.form-group label {
    font-size: 0.875rem;
    color: var(--text-dark);
    font-weight: 600;
    display: block;
    margin-bottom: 0.5rem;
}

.form-group select {
    width: 100%;
    padding: 0.75rem 0.875rem;
    border: 2px solid #e2e8f0;
    border-radius: var(--radius-sm);
    font-size: 0.9375rem;
    color: var(--text-dark);
    background: var(--bg-light);
    transition: var(--transition);
    -webkit-appearance: none;
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%2364748b' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 14px center;
    padding-right: 36px;
    min-height: var(--touch-target);
}

.form-group select:focus {
    outline: none;
    border-color: var(--primary);
    background-color: var(--white);
    box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
}

.btn-primary {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: var(--white);
    border: none;
    border-radius: var(--radius-sm);
    padding: 0.875rem 1.25rem;
    font-weight: 600;
    font-size: 0.875rem;
    cursor: pointer;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    margin-bottom: 1.25rem;
    min-height: var(--touch-target);
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
}

.btn-primary:active {
    transform: scale(0.98);
}

/* ===== TABLE CARD ===== */
.table-card {
    background: var(--white);
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: var(--shadow-md);
    margin-bottom: 1.25rem;
    border: 1px solid #e2e8f0;
}

.table-header {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    padding: 1rem 1.25rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.625rem;
}

.table-header h2 {
    color: var(--white);
    font-size: 1.125rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 0.625rem;
}

.table-header h2 i {
    color: var(--white);
}

.table-header .meta-info {
    color: rgba(255,255,255,0.9);
    font-size: 0.8125rem;
    display: flex;
    flex-wrap: wrap;
    gap: 0.9375rem;
}

.table-header .meta-info span {
    display: flex;
    align-items: center;
    gap: 0.3125rem;
}

.table-wrapper {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
}

table {
    width: 100%;
    border-collapse: collapse;
    background: var(--white);
    min-width: 700px;
}

th {
    padding: 0.875rem 0.75rem;
    text-align: left;
    font-weight: 600;
    color: var(--text-muted);
    font-size: 0.75rem;
    text-transform: uppercase;
    background: var(--bg-light);
    border-bottom: 2px solid #e2e8f0;
    white-space: nowrap;
}

td {
    padding: 0.875rem 0.75rem;
    border-bottom: 1px solid #f1f5f9;
    color: var(--text-dark);
    vertical-align: middle;
}

tr:hover {
    background: var(--bg-light);
}

tr:last-child td {
    border-bottom: none;
}

.student-name {
    display: flex;
    align-items: center;
    gap: 0.625rem;
}

.student-name .avatar {
    width: 38px;
    height: 38px;
    border-radius: var(--radius-sm);
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    font-size: 0.875rem;
    color: var(--white);
    flex-shrink: 0;
}

.student-name span {
    font-size: 0.875rem;
    font-weight: 500;
}

/* ===== PERCENTAGE BADGES ===== */
.percentage-badge {
    font-weight: 600;
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 0.8125rem;
    white-space: nowrap;
    display: inline-block;
}

.percentage-badge.low {
    background: #fee2e2;
    color: #dc2626;
}

.percentage-badge.medium {
    background: #fef3c7;
    color: #d97706;
}

.percentage-badge.good {
    background: #d1fae5;
    color: var(--success-dark);
}

.percentage-badge.excellent {
    background: #dbeafe;
    color: #2563eb;
}

.lectures-count {
    font-weight: 600;
    color: var(--text-dark);
}

.lectures-count .present {
    color: var(--success-dark);
}

.lectures-count .absent {
    color: #dc2626;
}

/* ===== BUTTONS ===== */
.action-buttons {
    display: flex;
    gap: 0.625rem;
    padding: 0 0 1.25rem 0;
    flex-wrap: wrap;
}

.btn-secondary {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: var(--white);
    border: none;
    border-radius: var(--radius-sm);
    padding: 0.875rem 1.25rem;
    font-weight: 600;
    font-size: 0.8125rem;
    cursor: pointer;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    text-decoration: none;
    flex: 1;
    justify-content: center;
    min-width: 120px;
}

.btn-secondary:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
}

.btn-secondary:active {
    transform: scale(0.98);
}

/* ===== EMPTY STATE ===== */
.empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 3.75rem 1.25rem;
    text-align: center;
}

.empty-state i {
    font-size: 4rem;
    color: #e2e8f0;
    margin-bottom: 1.25rem;
}

.empty-state h3 {
    color: var(--text-dark);
    margin-bottom: 0.5rem;
    font-size: 1.125rem;
    font-weight: 600;
}

.empty-state p {
    color: var(--text-muted);
    font-size: 0.875rem;
}

/* ===== RESPONSIVE BREAKPOINTS ===== */

/* Tablet */
@media (max-width: 1024px) {
    .filters-container form {
        gap: 0.875rem;
    }
}

/* Mobile */
@media (max-width: 768px) {
    .class-attendance-content {
        padding: 0.5rem;
    }

    .top-bar {
        flex-direction: column;
        gap: 0.75rem;
        text-align: center;
        padding: 1rem;
        margin-bottom: 1rem;
        border-radius: var(--radius-md);
    }

    .welcome-section {
        min-width: 100%;
        text-align: center;
    }

    .welcome-section h1 {
        font-size: 1.25rem;
        justify-content: center;
    }

    .welcome-section p {
        font-size: 0.75rem;
    }

    .user-info {
        width: 100%;
        justify-content: center;
        gap: 0.625rem;
    }

    .user-details {
        display: none;
    }

    .logout-btn {
        width: 100%;
        justify-content: center;
        padding: 12px 16px;
    }

    .filters-container {
        padding: 1rem;
        margin-bottom: 1rem;
        border-radius: var(--radius-md);
    }

    .filters-container h2 {
        font-size: 1rem;
        margin-bottom: 1rem;
    }

    .filters-container form {
        flex-direction: column;
    }

    .form-group {
        width: 100%;
        min-width: 100%;
    }

    .btn-primary {
        width: 100%;
    }

    .table-header {
        flex-direction: column;
        text-align: center;
        padding: 0.875rem 1rem;
    }

    .table-header h2 {
        font-size: 1rem;
    }

    .table-header .meta-info {
        font-size: 0.75rem;
        justify-content: center;
    }

    th, td {
        padding: 0.625rem 0.5rem;
        font-size: 0.75rem;
    }

    .action-buttons {
        flex-direction: column;
    }

    .btn-secondary {
        width: 100%;
    }
}

/* Small phones */
@media (max-width: 480px) {
    .class-attendance-content {
        padding: 0.375rem;
    }

    .top-bar {
        padding: 0.875rem;
        margin-bottom: 0.75rem;
        gap: 0.625rem;
    }

    .welcome-section h1 {
        font-size: 1.125rem;
    }

    .welcome-section p {
        font-size: 0.6875rem;
    }

    .user-avatar {
        width: 36px;
        height: 36px;
        font-size: 0.875rem;
    }

    .logout-btn {
        font-size: 0.75rem;
        padding: 10px 12px;
    }

    .filters-container {
        padding: 0.875rem;
        margin-bottom: 0.75rem;
    }

    .filters-container h2 {
        font-size: 0.9375rem;
    }

    .form-group label {
        font-size: 0.8125rem;
    }

    .form-group select {
        font-size: 0.875rem;
    }

    .table-card {
        margin-bottom: 0.75rem;
        border-radius: var(--radius-md);
    }

    .empty-state {
        padding: 2.5rem 1rem;
    }

    .empty-state i {
        font-size: 3rem;
    }

    .empty-state h3 {
        font-size: 1rem;
    }
}

/* Large Desktop */
@media (min-width: 1200px) {
    .welcome-section h1 {
        font-size: 2rem;
    }

    .welcome-section p {
        font-size: 1.125rem;
    }

    .filters-container {
        padding: 2rem;
        border-radius: var(--radius-xl);
        margin-bottom: 2rem;
    }

    .filters-container h2 {
        font-size: 1.5rem;
    }

    .table-card {
        border-radius: var(--radius-xl);
        margin-bottom: 1.5rem;
    }

    .table-header {
        padding: 1.25rem 1.5rem;
    }

    th {
        padding: 1rem 0.875rem;
        font-size: 0.8125rem;
    }

    td {
        padding: 1rem 0.875rem;
    }
}

/* ===== ANIMATIONS ===== */
@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(15px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.filters-container {
    animation: fadeInUp 0.4s ease-out;
}

.table-card {
    animation: fadeInUp 0.4s ease-out 0.1s both;
}

/* ===== TOUCH IMPROVEMENTS ===== */
@media (hover: none) and (pointer: coarse) {
    .logout-btn:hover,
    .btn-primary:hover,
    .btn-secondary:hover {
        transform: none;
    }

    .logout-btn:active,
    .btn-primary:active,
    .btn-secondary:active {
        transform: scale(0.98);
    }
}
</style>

<div class="class-attendance-content">

<div class="container">

    <!-- TOP BAR -->
    <div class="top-bar">
        <div class="welcome-section">
            <h1><i class="fas fa-chart-bar"></i> Class Attendance Report</h1>
            <p>Welcome back, <%= user.getUsername() %>! View attendance summary for all students.</p>
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

    <!-- FILTER FORM -->
    <div class="filters-container">
        <h2><i class="fas fa-filter"></i> Select Filters</h2>
        <form method="get" action="<%=request.getContextPath()%>/teacher/ClassAttendanceServlet">
            <div class="form-group">
                <label>Class *</label>
                <select name="class_id" required>
                    <option value="">-- Choose Class --</option>
                    <%
                        try(Connection conn = SQLConnection.getConnection()){
                            String sql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ResultSet rs = ps.executeQuery();
                            while(rs.next()){
                                String id = rs.getString("class_id");
                                String selected = (id != null && id.equals(classIdParam)) ? "selected" : "";
                    %>
                    <option value="<%=id%>" <%=selected%>><%=rs.getString("class_name")+" - "+rs.getString("section")%></option>
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
                            String sql = "SELECT DISTINCT s.subject_id, s.subject_name " +
                                         "FROM subjects s " +
                                         "JOIN class_subjects cs ON cs.subject_id=s.subject_id " +
                                         "WHERE cs.teacher_id=?";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setInt(1, teacherId);
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

            <div class="form-group">
                <label>Session Type *</label>
                <select name="session_type" required>
                    <option value="all" <%= "all".equals(sessionTypeParam) ? "selected" : "" %>>All (Theory + Practical)</option>
                    <option value="theory" <%= "theory".equals(sessionTypeParam) ? "selected" : "" %>>Theory Only</option>
                    <option value="practical" <%= "practical".equals(sessionTypeParam) ? "selected" : "" %>>Practical Only</option>
                </select>
            </div>

            <button class="btn-primary" type="submit"><i class="fas fa-search"></i> View Report</button>
        </form>
    </div>

    <%
        if(attendanceList != null && !attendanceList.isEmpty()) {
    %>

    <!-- ACTION BUTTONS -->
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
    </div>

    <!-- ATTENDANCE TABLE -->
    <div class="table-card">
        <div class="table-header">
            <h2><i class="fas fa-users"></i> Student Attendance Summary</h2>
            <div class="meta-info">
                <span><i class="fas fa-school"></i> <%= className %></span>
                <span><i class="fas fa-book"></i> <%= subjectName %></span>
                <span><i class="fas fa-clock"></i> <%= sessionTypeDisplay %></span>
            </div>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Roll No</th>
                        <th>Student Name</th>
                        <th>Present</th>
                        <th>Absent</th>
                        <th>Total Lectures</th>
                        <th>Attendance %</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    for(Map<String, Object> row : attendanceList) {
                        double percentage = (double) row.get("percentage");
                        String percentageClass = "";
                        if(percentage < 75) {
                            percentageClass = "low";
                        } else if(percentage < 85) {
                            percentageClass = "medium";
                        } else if(percentage < 95) {
                            percentageClass = "good";
                        } else {
                            percentageClass = "excellent";
                        }

                        String firstName = (String) row.get("first_name");
                        String firstLetter = (firstName != null && firstName.length() > 0) ? firstName.substring(0, 1).toUpperCase() : "A";
                %>
                <tr>
                    <td><strong><%= row.get("roll_number") %></strong></td>
                    <td>
                        <div class="student-name">
                            <div class="avatar"><%= firstLetter %></div>
                            <span><%= row.get("full_name") %></span>
                        </div>
                    </td>
                    <td class="lectures-count"><span class="present"><%= row.get("present_lectures") %></span></td>
                    <td class="lectures-count"><span class="absent"><%= row.get("absent_lectures") %></span></td>
                    <td><strong><%= row.get("total_lectures") %></strong></td>
                    <td>
                        <span class="percentage-badge <%= percentageClass %>">
                            <%= String.format("%.2f", percentage) %>% 
                        </span>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <% } else if (classIdParam != null && subjectIdParam != null) { %>

    <!-- EMPTY STATE -->
    <div class="table-card">
        <div class="empty-state">
            <i class="fas fa-clipboard-check"></i>
            <h3>No Attendance Records Found</h3>
            <p>No attendance has been marked for this class and subject yet.</p>
        </div>
    </div>

    <% } %>

</div>

<script>
function logout() { 
    if(confirm('Are you sure you want to logout?')) {
        window.location.href = '<%=request.getContextPath()%>/LogoutServlet'; 
    }
}

function goBack() {
    window.location.href = 'Index.jsp';
}


// Prevent double-tap zoom on mobile
document.addEventListener('dblclick', function(event) {
    event.preventDefault();
}, { passive: false });
</script>

</div>
