<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.seh.util.SQLConnection, com.seh.model.User" %>

<%
    // ================= SESSION CHECK =================
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("student")) {
        response.sendRedirect("../login.jsp");
        return;
    }

    User user = (User) session.getAttribute("user");
    
    String avatarLetter = "A";
    if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }

    double resultPercent = 0;
    int attendancePercent = 0;
    String latestAnnouncement = "No Recent Announcements";
    int totalCourses = 0;
    String errorMessage = null;

    try (Connection conn = SQLConnection.getConnection()) {
        int studentId = 0;
        int classId = 0;

        // Get Student ID and Class ID
        PreparedStatement psStudent = conn.prepareStatement("SELECT student_id, class_id FROM students WHERE user_id=?");
        psStudent.setInt(1, user.getUserId());
        ResultSet rsStudent = psStudent.executeQuery();
        if(rsStudent.next()){
            studentId = rsStudent.getInt("student_id");
            classId = rsStudent.getInt("class_id");
        }

        // Get Marks Average
        PreparedStatement psMarks = conn.prepareStatement("SELECT IFNULL(AVG(average),0) as avg_marks FROM marks WHERE student_id=?");
        psMarks.setInt(1, studentId);
        ResultSet rsMarks = psMarks.executeQuery();
        if (rsMarks.next()) resultPercent = rsMarks.getDouble("avg_marks");

        // Get Attendance Percentage
        PreparedStatement psAttendance = conn.prepareStatement(
            "SELECT IFNULL(ROUND((SUM(CASE WHEN status='present' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*),0))),0) as attendance FROM full_attendance WHERE student_id=?"
        );
        psAttendance.setInt(1, studentId);
        ResultSet rsAttendance = psAttendance.executeQuery();
        if (rsAttendance.next()) attendancePercent = rsAttendance.getInt("attendance");

        // Get Total Courses
        PreparedStatement psCourses = conn.prepareStatement("SELECT COUNT(DISTINCT subject_id) as course_count FROM marks WHERE student_id=?");
        psCourses.setInt(1, studentId);
        ResultSet rsCourses = psCourses.executeQuery();
        if (rsCourses.next()) totalCourses = rsCourses.getInt("course_count");

        // Latest Announcement
        if (classId > 0) {
            PreparedStatement psAnn = conn.prepareStatement("SELECT title FROM announcements WHERE class_id=? ORDER BY created_at DESC LIMIT 1");
            psAnn.setInt(1, classId);
            ResultSet rsAnn = psAnn.executeQuery();
            if(rsAnn.next()) latestAnnouncement = rsAnn.getString("title");
        }
    } catch(Exception e){
        e.printStackTrace();
        errorMessage = "Unable to load dashboard data. Please try again later.";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | Smart College</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
    --primary: #4f46e5;
    --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
    --danger: #ef4444;       /* Base Red */
    --danger-dark: #dc2626;  /* Darker Red for gradient */
    --bg-light: #f8fafc;
    --text-dark: #1e293b;
    --text-muted: #64748b;
    --white: #ffffff;
    --radius-lg: 16px;
    --radius-md: 12px;
    --radius-sm: 8px;        /* Added for logout button radius */
    --shadow-md: 0 4px 12px rgba(0,0,0,0.05);
    --transition: all 0.3s ease;
}

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: var(--bg-light); color: var(--text-dark); padding: 16px; -webkit-font-smoothing: antialiased; }
        .container { max-width: 1200px; margin: 0 auto; }

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
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-weight: 600;
    font-size: 1.2rem;
}
        .logout-btn {
            background: #ef4444; color: #fff; border: none;
            padding: 0.75rem 1.5rem; border-radius: 8px;
            cursor: pointer; transition: all 0.3s; font-weight: 500;
        }
        .logout-btn:hover { background: #dc2626; transform: translateY(-1px); }
        /* Stats Grid */
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 24px; }
        .stat-card { background: white; padding: 20px; border-radius: var(--radius-md); box-shadow: var(--shadow-md); border-left: 4px solid var(--primary); }
        .stat-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
        .stat-title { font-size: 0.75rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; }
        .stat-number { font-size: 1.8rem; font-weight: 800; color: var(--text-dark); }

        /* Dashboard Card */
        .dashboard-card { background: white; border-radius: var(--radius-lg); padding: 24px; box-shadow: var(--shadow-md); margin-bottom: 24px; }
        .card-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }

        /* Action Cards */
        .action-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
        .action-card {
            background: white;
            padding: 20px;
            border-radius: var(--radius-md);
            text-decoration: none;
            color: var(--text-dark);
            border: 1px solid #e2e8f0;
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .action-card:hover { border-color: var(--primary); transform: translateY(-4px); box-shadow: 0 10px 20px rgba(0,0,0,0.05); }
        .action-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; color: white; font-size: 1.1rem; }
        
        .icon-attendance { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
        .icon-marks { background: linear-gradient(135deg, #10b981, #059669); }
        .icon-announcement { background: linear-gradient(135deg, #f59e0b, #d97706); }
        .icon-library { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }
        .icon-timetable { background: linear-gradient(135deg, #ec4899, #be185d); }

        .action-card h3 { font-size: 0.95rem; font-weight: 700; }
        .action-card p { font-size: 0.75rem; color: var(--text-muted); line-height: 1.4; }

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
    </style>
</head>
<body>

<div class="container">
    <% if (errorMessage != null) { %>
        <div style="background: #fef2f2; color: #dc2626; padding: 12px; border-radius: 8px; margin-bottom: 20px;"><%= errorMessage %></div>
    <% } %>

    <div class="top-bar">
        <div class="welcome-section">
            <h1>Hi, <%= user.getFullName() %> 👋</h1>
            <p>Welcome to your academic portal</p>
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

    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">Courses</span>
                <i class="fas fa-book" style="color: #3b82f6;"></i>
            </div>
            <div class="stat-number"><%= totalCourses %></div>
        </div>
        <div class="stat-card" style="border-left-color: #10b981;">
            <div class="stat-header">
                <span class="stat-title">Attendance</span>
                <i class="fas fa-calendar-check" style="color: #10b981;"></i>
            </div>
            <div class="stat-number"><%= attendancePercent %>%</div>
        </div>
        <div class="stat-card" style="border-left-color: #f59e0b;">
            <div class="stat-header">
                <span class="stat-title">Average Marks</span>
                <i class="fas fa-chart-bar" style="color: #f59e0b;"></i>
            </div>
            <div class="stat-number"><%= String.format("%.1f", resultPercent) %>%</div>
        </div>
    </div>

    <div class="dashboard-card">
        <h2 class="card-title"><i class="fas fa-bullhorn" style="color: #f59e0b;"></i> Latest Announcement</h2>
        <div style="background: #fffbeb; padding: 15px; border-radius: 10px; color: #92400e; font-size: 0.95rem; font-weight: 500;">
            <%= latestAnnouncement %>
        </div>
    </div>

    <div class="dashboard-card">
        <h2 class="card-title"><i class="fas fa-bolt" style="color: #4f46e5;"></i> Quick Actions</h2>
        <div class="action-grid">
            <a href="javascript:void(0)" onclick="loadPage('view_attendance.jsp')" class="action-card">
    <div class="action-icon icon-attendance">
        <i class="fas fa-calendar-alt"></i>
    </div>
    <h3>My Attendance</h3>
    <p>Track your daily presence and percentages.</p>
</a>

<a href="javascript:void(0)" onclick="loadPage('my_marks.jsp')" class="action-card">
    <div class="action-icon icon-marks">
        <i class="fas fa-file-invoice"></i>
    </div>
    <h3>Academic Marks</h3>
    <p>View your performance in unit tests and exams.</p>
</a>

<a href="javascript:void(0)" onclick="loadPage('view_Announcement.jsp')" class="action-card">
    <div class="action-icon icon-announcement">
        <i class="fas fa-bell"></i>
    </div>
    <h3>Notices</h3>
    <p>Check all college and class announcements.</p>
</a>

<a href="javascript:void(0)" onclick="loadPage('student_document_library.jsp')" class="action-card">
    <div class="action-icon icon-library">
        <i class="fas fa-folder-open"></i>
    </div>
    <h3>Resources</h3>
    <p>Access Syllabus and Question Banks.</p>
</a>

<a href="javascript:void(0)" onclick="loadPage('student_timetable.jsp')" class="action-card">
    <div class="action-icon icon-timetable">
        <i class="fas fa-clock"></i>
    </div>
    <h3>Timetable</h3>
    <p>Check your daily class schedule.</p>
</a>
        </div>
    </div>
</div>

<script>
    function logout(){
        if(confirm('Are you sure you want to logout?')) {
            window.location.href="<%=request.getContextPath()%>/LogoutServlet";
        }
    }
</script>

</body>
</html>