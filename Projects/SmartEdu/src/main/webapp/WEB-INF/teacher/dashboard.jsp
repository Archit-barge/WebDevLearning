<%@ page import="java.sql.SQLException"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.seh.model.User"%>
<%@ page import="com.seh.util.SQLConnection"%>
<%
User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect("../login.jsp");
    return;
}
String avatarLetter = "A";
if (user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>
<style>
        /* CSS Variables for consistent theming */
        :root {
            --primary: #10b981;
            --primary-light: #34d399;
            --primary-dark: #059669;
            --danger: #ef4444;
            --danger-dark: #dc2626;
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

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            -webkit-text-size-adjust: 100%;
            -webkit-tap-highlight-color: transparent;
        }

        .dashboard-content {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-light);
            color: var(--text-dark);
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        /* Top Bar */
        .top-bar {
            display: flex; justify-content: space-between; align-items: center;
            width: 100%; margin-bottom: 2rem; padding: 1.5rem 2rem;
            background: #fff; border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .welcome-section h1 { font-size: 2rem; font-weight: 700; color: #1e293b; margin-bottom: 0.5rem; line-height: 1.2; }
        .welcome-section p  { color: #64748b; font-size: 1rem;}
        
        .user-info { display: flex; align-items: center; gap: 1rem; }
        .user-avatar {
            width: 50px; height: 50px; border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-weight: 600; font-size: 1.2rem;
        }
         .logout-btn {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 10px 16px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
            white-space: nowrap;
        }
        .logout-btn:hover { background: #dc2626; transform: translateY(-1px); }

        /* Stats Grid */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: #fff;
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07);
            border: 1px solid #e2e8f0;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            contain: layout style paint;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }

        .stat-card:active {
            transform: scale(0.98);
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }

        .stat-title {
            font-weight: 600;
            font-size: 0.8rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            color: white;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        }

        .stat-icon.students { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
        .stat-icon.parents { background: linear-gradient(135deg, #8b5cf6, #6d28d9); }
        .stat-icon.classes { background: linear-gradient(135deg, #10b981, #059669); }

        .stat-number {
            font-size: clamp(1.75rem, 5vw, 2.25rem);
            font-weight: 900;
            color: var(--text-dark);
            margin-bottom: 4px;
            line-height: 1;
        }

        .stat-label {
            color: var(--text-muted);
            font-size: 0.875rem;
            font-weight: 500;
        }

        /* Dashboard Card */
        .dashboard-card {
            background: #fff;
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07);
            border: 1px solid #e2e8f0;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 12px;
        }

        .card-title {
            font-size: 1.125rem;
            font-weight: 700;
            color: var(--text-dark);
        }

        .view-all-btn {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.875rem;
            padding: 8px 16px;
            border-radius: var(--radius-sm);
            transition: var(--transition);
            background: #f0fdf4;
        }

        .view-all-btn:hover {
            background: var(--primary);
            color: white;
        }

        /* Quick Actions Grid */
        .quick-actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
        }

        .action-card {
            background: var(--white);
            padding: 20px;
            border-radius: var(--radius-md);
            text-align: center;
            border: 2px solid #e2e8f0;
            transition: var(--transition);
            text-decoration: none;
            color: var(--text-dark);
            display: block;
        }

        .action-card:hover {
            border-color: var(--primary);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(16, 185, 129, 0.15);
            text-decoration: none;
            color: var(--text-dark);
        }

        .action-card:active {
            transform: scale(0.98);
        }

        .action-icon {
            width: 56px;
            height: 56px;
            margin: 0 auto 12px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
        }

        .action-card h3 {
            font-size: 0.95rem;
            font-weight: 600;
            margin-bottom: 6px;
            color: var(--text-dark);
        }

        .action-card p {
            font-size: 0.8rem;
            color: var(--text-muted);
            line-height: 1.4;
        }

        /* Content Grid */
        .content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
            margin-bottom: 24px;
        }

        /* Schedule Table */
        .schedule-table {
            width: 100%;
            border-collapse: collapse;
        }

        .schedule-table th,
        .schedule-table td {
            padding: 14px 12px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        .schedule-table th {
            background: #f8fafc;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.8rem;
            text-transform: uppercase;
        }

        .schedule-table tr:hover td {
            background: #f9fafb;
        }

        .schedule-table tr:last-child td {
            border-bottom: none;
        }

        .time-slot {
            color: var(--primary);
            font-weight: 700;
            font-size: 0.875rem;
        }

        .class-info {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .class-name {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.9rem;
        }

        .class-details {
            font-size: 0.8rem;
            color: var(--text-muted);
        }

        /* Recent Activities */
        .activity-item {
            padding: 14px;
            background: #f8fafc;
            border-radius: var(--radius-sm);
            border-left: 4px solid;
            margin-bottom: 12px;
        }

        .activity-item:last-child {
            margin-bottom: 0;
        }

        .activity-item.blue { border-left-color: #3b82f6; }
        .activity-item.green { border-left-color: #10b981; }
        .activity-item.amber { border-left-color: #f59e0b; }
        .activity-item.purple { border-left-color: #8b5cf6; }

        .activity-item h4 {
            color: var(--text-dark);
            font-size: 0.875rem;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .activity-item p {
            color: var(--text-muted);
            font-size: 0.8rem;
            margin-bottom: 4px;
        }

        .activity-item .time {
            color: #94a3b8;
            font-size: 0.75rem;
        }

        /* Tablet */
        @media (max-width: 1024px) {
            .stat-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 16px;
            }
            
            .quick-actions-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .content-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Enhanced Mobile Responsive */
        @media (max-width: 768px) {
            .dashboard-content {
                padding: 8px;
            }

            .top-bar {
                padding: 16px;
                border-radius: var(--radius-lg);
                margin-bottom: 16px;
                gap: 12px;
            }

            .welcome-section h2 {
                font-size: 1.25rem;
            }

            .user-info {
                flex-wrap: wrap;
                justify-content: center;
            }

            .user-details {
                display: none;
            }

            .logout-btn { width: 100%; justify-content: center; }

            .stat-grid {
                gap: 12px;
                margin-bottom: 16px;
            }

            .stat-card {
                padding: 16px;
            }

            .stat-number {
                font-size: 1.5rem;
            }

            .stat-icon {
                width: 42px;
                height: 42px;
                font-size: 1.1rem;
            }

            .dashboard-card {
                padding: 16px;
                margin-bottom: 16px;
            }

            .quick-actions-grid {
                gap: 12px;
            }

            .action-card {
                padding: 16px 12px;
            }

            .action-icon {
                width: 48px;
                height: 48px;
                font-size: 1.25rem;
            }

            .action-card h3 {
                font-size: 0.875rem;
            }

            .action-card p {
                font-size: 0.75rem;
            }

            .schedule-table th,
            .schedule-table td {
                padding: 10px 8px;
            }

            .class-name {
                font-size: 0.85rem;
            }

            .activity-item {
                padding: 12px;
            }

            .activity-item h4 {
                font-size: 0.8rem;
            }

            .activity-item p {
                font-size: 0.75rem;
            }
        }

        @media (max-width: 480px) {
            body {
                padding: 6px;
            }

            .top-bar {
                flex-direction: column;
                text-align: center;
                padding: 14px;
                gap: 10px;
                border-radius: var(--radius-md);
                margin-bottom: 12px;
            }

            .welcome-section {
                min-width: 100%;
                text-align: center;
            }

            .welcome-section h2 {
                font-size: 1.125rem;
            }

            .welcome-section p {
                font-size: 0.8rem;
            }

            .user-info {
                width: 100%;
                justify-content: center;
            }

            .stat-grid {
                grid-template-columns: 1fr;
                gap: 10px;
                margin-bottom: 12px;
            }

            .stat-card {
                padding: 14px;
                border-radius: var(--radius-md);
                display: flex;
                align-items: center;
                gap: 14px;
            }

            .stat-header {
                margin-bottom: 0;
                flex: 1;
            }

            .stat-title {
                font-size: 0.7rem;
            }

            .stat-number {
                font-size: 1.25rem;
                min-width: 50px;
                text-align: right;
            }

            .stat-label {
                font-size: 0.7rem;
            }

            .stat-icon {
                width: 40px;
                height: 40px;
                font-size: 1rem;
            }

            .dashboard-card {
                padding: 14px;
                border-radius: var(--radius-md);
                margin-bottom: 12px;
            }

            .card-title {
                font-size: 1rem;
            }

            .quick-actions-grid {
                grid-template-columns: 1fr 1fr;
                gap: 10px;
            }

            .action-card {
                padding: 14px 10px;
                border-radius: var(--radius-sm);
            }

            .action-icon {
                width: 40px;
                height: 40px;
                font-size: 1rem;
                margin-bottom: 8px;
            }

            .action-card h3 {
                font-size: 0.75rem;
                margin-bottom: 4px;
            }

            .action-card p {
                font-size: 0.65rem;
                display: none;
            }

            .schedule-table {
                display: block;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }

            .schedule-table th,
            .schedule-table td {
                padding: 8px 6px;
                font-size: 0.75rem;
            }

            .time-slot {
                font-size: 0.75rem;
            }

            .class-name {
                font-size: 0.75rem;
            }

            .class-details {
                font-size: 0.65rem;
            }

            .activity-item {
                padding: 10px;
                border-radius: var(--radius-sm);
                margin-bottom: 8px;
            }

            .activity-item h4 {
                font-size: 0.75rem;
            }

            .activity-item p {
                font-size: 0.7rem;
            }

            .activity-item .time {
                font-size: 0.65rem;
            }
        }

        @media (max-width: 360px) {
            .quick-actions-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Desktop Enhancements */
        @media (min-width: 1200px) {
            .welcome-section h2 {
                font-size: 2rem;
            }

            .welcome-section p {
                font-size: 1.125rem;
            }

            .stat-grid {
                gap: 24px;
                margin-bottom: 2rem;
            }

            .stat-card {
                padding: 24px;
                border-radius: 20px;
            }

            .stat-number {
                font-size: 2.5rem;
            }

            .dashboard-card {
                padding: 28px;
                border-radius: 20px;
                margin-bottom: 2rem;
            }

            .quick-actions-grid {
                gap: 20px;
            }

            .action-card {
                padding: 24px 20px;
                border-radius: 16px;
            }
        }

        /* Animation for smooth loading */
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

        .top-bar { animation: fadeInUp 0.4s ease-out; }
        .stat-card:nth-child(1) { animation: fadeInUp 0.4s ease-out 0.1s both; }
        .stat-card:nth-child(2) { animation: fadeInUp 0.4s ease-out 0.15s both; }
        .stat-card:nth-child(3) { animation: fadeInUp 0.4s ease-out 0.2s both; }
        .dashboard-card:nth-child(1) { animation: fadeInUp 0.4s ease-out 0.25s both; }
        .dashboard-card:nth-child(2) { animation: fadeInUp 0.4s ease-out 0.3s both; }
        .action-card:nth-child(1) { animation: fadeInUp 0.4s ease-out 0.35s both; }
        .action-card:nth-child(2) { animation: fadeInUp 0.4s ease-out 0.4s both; }
        .action-card:nth-child(3) { animation: fadeInUp 0.4s ease-out 0.45s both; }
        .action-card:nth-child(4) { animation: fadeInUp 0.4s ease-out 0.5s both; }
        .action-card:nth-child(5) { animation: fadeInUp 0.4s ease-out 0.55s both; }

        /* Touch feedback */
        @media (hover: none) {
            .stat-card:hover { transform: none; }
            .action-card:hover { 
                transform: none;
                border-color: #e2e8f0;
                box-shadow: none;
                color: var(--text-dark);
            }
        }
</style>

<div class="dashboard-content">

<div class="container">
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Welcome, <%=user.getFullName()%></h1>
            <p>Here's what's happening today</p>
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

    <%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    int totalStudents = 0, totalParents = 0, totalClasses = 0;

    try {
        conn = SQLConnection.getConnection();

        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM students");
        rs = pstmt.executeQuery();
        if (rs.next())
            totalStudents = rs.getInt(1);
        rs.close();
        pstmt.close();

        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM parents");
        rs = pstmt.executeQuery();
        if (rs.next())
            totalParents = rs.getInt(1);
        rs.close();
        pstmt.close();

        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM classes");
        rs = pstmt.executeQuery();
        if (rs.next())
            totalClasses = rs.getInt(1);

    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    %>

    <!-- Stats Grid -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-title">Total Students</div>
                <div class="stat-icon students">
                    <i class="fas fa-users"></i>
                </div>
            </div>
            <div class="stat-number"><%=totalStudents%></div>
            <div class="stat-label">Active Students</div>
        </div>
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-title">Total Parents</div>
                <div class="stat-icon parents">
                    <i class="fas fa-user-friends"></i>
                </div>
            </div>
            <div class="stat-number"><%=totalParents%></div>
            <div class="stat-label">Registered Parents</div>
        </div>
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-title">Total Classes</div>
                <div class="stat-icon classes">
                    <i class="fas fa-school"></i>
                </div>
            </div>
            <div class="stat-number"><%=totalClasses%></div>
            <div class="stat-label">Active Classes</div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="dashboard-card">
        <div class="card-header">
            <h2 class="card-title">Quick Actions</h2>
        </div>
        <div class="quick-actions-grid">
            <a href="javascript:void(0)" onclick="loadPage('mark_attendance.jsp')" class="action-card">
                <div class="action-icon" style="background: linear-gradient(135deg, #3b82f6, #1d4ed8);">
                    <i class="fas fa-user-check"></i>
                </div>
                <h3>Mark Attendance</h3>
                <p>Take attendance for your classes today</p>
            </a>
            <a href="javascript:void(0)" onclick="loadPage('enter_marks.jsp')" class="action-card">
                <div class="action-icon" style="background: linear-gradient(135deg, #10b981, #059669);">
                    <i class="fas fa-star"></i>
                </div>
                <h3>Enter Grades</h3>
                <p>Grade assignments and enter student marks</p>
            </a>
            <a href="javascript:void(0)" onclick="loadPage('teacher_upload_timetable.jsp')" class="action-card">
                <div class="action-icon" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                    <i class="fas fa-tasks"></i>
                </div>
                <h3>Post TimeTable</h3>
                <p>Post TimeTable For Students</p>
            </a>
            <a href="javascript:void(0)" onclick="loadPage('announcements.jsp')" class="action-card">
                <div class="action-icon" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">
                    <i class="fas fa-bullhorn"></i>
                </div>
                <h3>Make Announcement</h3>
                <p>Send messages to your classes</p>
            </a>
            <a href="javascript:void(0)" onclick="loadPage('defaulter_list.jsp')" class="action-card">
                <div class="action-icon" style="background: linear-gradient(135deg, #ef4444, #dc2626);">
                    <i class="fas fa-user-times"></i>
                </div>
                <h3>View Defaulter List</h3>
                <p>Students below 75% attendance</p>
            </a>
        </div>
    </div>

    <!-- Content Grid -->
    <div class="content-grid">
        <!-- Today's Schedule -->
        <div class="dashboard-card">
            <div class="card-header">
                <h2 class="card-title">Today's Schedule</h2>
            </div>
            <table class="schedule-table">
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Class</th>
                        <th>Subject</th>
                        <th>Room</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="time-slot">09:00 - 09:50</td>
                        <td>
                            <div class="class-info">
                                <div class="class-name">Grade 10-A</div>
                                <div class="class-details">30 students</div>
                            </div>
                        </td>
                        <td>Mathematics</td>
                        <td>Room 201</td>
                    </tr>
                    <tr>
                        <td class="time-slot">10:00 - 10:50</td>
                        <td>
                            <div class="class-info">
                                <div class="class-name">Grade 9-B</div>
                                <div class="class-details">25 students</div>
                            </div>
                        </td>
                        <td>Mathematics</td>
                        <td>Room 201</td>
                    </tr>
                    <tr>
                        <td class="time-slot">11:10 - 12:00</td>
                        <td>
                            <div class="class-info">
                                <div class="class-name">Grade 10-B</div>
                                <div class="class-details">28 students</div>
                            </div>
                        </td>
                        <td>Mathematics</td>
                        <td>Room 201</td>
                    </tr>
                    <tr>
                        <td class="time-slot">14:00 - 14:50</td>
                        <td>
                            <div class="class-info">
                                <div class="class-name">Grade 11-A</div>
                                <div class="class-details">32 students</div>
                            </div>
                        </td>
                        <td>Advanced Math</td>
                        <td>Room 201</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- Recent Activities -->
        <div class="dashboard-card">
            <div class="card-header">
                <h2 class="card-title">Recent Activities</h2>
            </div>
            <div class="activity-item blue">
                <h4>Attendance Marked</h4>
                <p>Grade 10-A - Mathematics</p>
                <p class="time">2 hours ago</p>
            </div>
            <div class="activity-item green">
                <h4>Grades Entered</h4>
                <p>Midterm Exam - Grade 9-B</p>
                <p class="time">Yesterday</p>
            </div>
            <div class="activity-item amber">
                <h4>Assignment Created</h4>
                <p>Algebra Practice Problems</p>
                <p class="time">2 days ago</p>
            </div>
            <div class="activity-item purple">
                <h4>Parent Meeting</h4>
                <p>Scheduled for next Tuesday</p>
                <p class="time">3 days ago</p>
            </div>
        </div>
    </div>
</div>

<script>
    function logout() {
        if(confirm('Are you sure you want to logout?')) {
            window.location.href = '<%=request.getContextPath()%>/LogoutServlet';
        }
    }

    // Prevent double-tap zoom on mobile
    document.addEventListener('dblclick', function(event) {
        event.preventDefault();
    }, { passive: false });

    // Add touch support for better mobile experience
    document.addEventListener('touchstart', function() {}, { passive: true });
</script>
</div>
