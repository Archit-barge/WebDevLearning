<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*"%>
<%@ page import="com.seh.model.User"%>
<%@ page import="com.seh.util.SQLConnection"%>

<%
User user = (User) session.getAttribute("user");
String role = (String) session.getAttribute("role");

if (user == null || !"teacher".equals(role)) {
	response.sendRedirect("../login.jsp");
	return;
}

String avatarLetter = "T";
if (user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}

List<Map<String, Object>> classes = new ArrayList<>();

try (Connection conn = SQLConnection.getConnection()) {
	int teacherId = -1;
	try (PreparedStatement ps = conn.prepareStatement("SELECT teacher_id FROM teachers WHERE user_id=?")) {
		ps.setInt(1, user.getUserId());
		ResultSet rs = ps.executeQuery();
		if (rs.next())
			teacherId = rs.getInt("teacher_id");
	}

	if (teacherId != -1) {
		try (PreparedStatement ps = conn
				.prepareStatement("SELECT c.class_id, c.class_name, c.section, COUNT(s.student_id) as student_count "
						+ "FROM classes c LEFT JOIN students s ON c.class_id=s.class_id "
						+ "WHERE c.teacher_id=? GROUP BY c.class_id, c.class_name, c.section ORDER BY c.class_name")) {
			ps.setInt(1, teacherId);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Map<String, Object> cls = new HashMap<>();
				cls.put("class_id", rs.getInt("class_id"));
				cls.put("class_name", rs.getString("class_name"));
				cls.put("section", rs.getString("section"));
				cls.put("student_count", rs.getInt("student_count"));
				classes.add(cls);
			}
		}
	}
} catch (SQLException e) {
	e.printStackTrace();
}
%>


<style>

		
        /* CSS Variables for consistent theming */
        :root {
            --primary: #3b82f6;
            --primary-light: #60a5fa;
            --primary-dark: #2563eb;
            --success: #10b981;
            --success-light: #34d399;
            --success-dark: #059669;
            --info: #06b6d4;
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
		
		
        .my-classes-content {
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
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: #fff;
            padding: 1.5rem;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07);
            border: 1px solid #e2e8f0;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
        }

        .stat-card.success {
            border-left-color: var(--success);
        }

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
            text-transform: uppercase;
        }

        /* Class Cards Grid */
        .class-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }

        .class-card {
            background: #fff;
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07);
            border: 1px solid #e2e8f0;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .class-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
        }

        .class-card:active {
            transform: scale(0.98);
        }

        .class-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
            gap: 10px;
        }

        .class-name {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-dark);
            margin: 0;
            line-height: 1.3;
        }

        .class-section {
            background: var(--primary);
            color: white;
            padding: 4px 12px;
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            font-weight: 600;
            white-space: nowrap;
        }

        .student-count {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-muted);
            margin-bottom: 16px;
            font-size: 0.95rem;
        }

        .student-count i {
            color: var(--primary);
        }

        /* Action Buttons */
        .class-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .action-btn {
            padding: 10px 14px;
            border: none;
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 0.8rem;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 6px;
            flex: 1;
            justify-content: center;
            min-height: var(--touch-target);
            white-space: nowrap;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-dark);
        }

        .btn-success {
            background: var(--success);
            color: white;
        }

        .btn-success:hover {
            background: var(--success-dark);
        }

        .btn-info {
            background: var(--info);
            color: white;
        }

        .btn-info:hover {
            background: #0891b2;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
        }

        .empty-state i {
            font-size: 4rem;
            color: var(--text-muted);
            margin-bottom: 16px;
            opacity: 0.5;
        }

        .empty-state h4 {
            font-size: 1.25rem;
            color: var(--text-dark);
            margin-bottom: 8px;
        }

        .empty-state p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        /* Tablet */
        @media (max-width: 1024px) {
            .class-grid {
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 16px;
            }
        }

        /* Enhanced Mobile Responsive */
        @media (max-width: 768px) {
            .my-classes-content {
                padding: 8px;
            }

            .top-bar {
                padding: 16px;
                border-radius: var(--radius-lg);
                margin-bottom: 16px;
                gap: 12px;
            }

            .welcome-section h1 {
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

            .stats-grid {
                gap: 12px;
                margin-bottom: 16px;
            }

            .stat-card {
                padding: 16px;
            }

            .stat-number {
                font-size: 1.5rem;
            }

            .class-grid {
                gap: 12px;
            }

            .class-card {
                padding: 16px;
            }

            .class-name {
                font-size: 1.1rem;
            }

            .class-actions {
                flex-direction: column;
                gap: 8px;
            }

            .action-btn {
                padding: 12px 14px;
                font-size: 0.85rem;
            }
        }

        @media (max-width: 480px) {
            .my-classes-content {
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

            .welcome-section h1 {
                font-size: 1.125rem;
            }

            .welcome-section p {
                font-size: 0.8rem;
            }

            .user-info {
                width: 100%;
                justify-content: center;
            }

            .stats-grid {
                grid-template-columns: 1fr;
                gap: 10px;
                margin-bottom: 12px;
            }

            .stat-card {
                padding: 14px;
                border-radius: var(--radius-md);
                display: flex;
                align-items: center;
                justify-content: space-between;
            }

            .stat-number {
                font-size: 1.25rem;
                min-width: 50px;
                text-align: right;
            }

            .stat-label {
                font-size: 0.75rem;
            }

            .class-grid {
                grid-template-columns: 1fr;
                gap: 10px;
            }

            .class-card {
                padding: 14px;
                border-radius: var(--radius-md);
            }

            .class-header {
                flex-direction: column;
                gap: 8px;
            }

            .class-name {
                font-size: 1rem;
            }

            .class-section {
                align-self: flex-start;
                font-size: 0.75rem;
            }

            .student-count {
                font-size: 0.875rem;
                margin-bottom: 12px;
            }

            .action-btn {
                font-size: 0.8rem;
                padding: 10px 12px;
            }

            .empty-state {
                padding: 40px 16px;
            }

            .empty-state i {
                font-size: 3rem;
            }

            .empty-state h4 {
                font-size: 1.1rem;
            }
        }

        @media (max-width: 360px) {
            .class-card {
                padding: 12px;
            }

            .action-btn {
                font-size: 0.75rem;
                padding: 8px 10px;
            }
        }

        /* Desktop Enhancements */
        @media (min-width: 1200px) {
            .welcome-section h1 {
                font-size: 2rem;
            }

            .stats-grid {
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

            .class-grid {
                gap: 24px;
            }

            .class-card {
                padding: 24px;
                border-radius: 20px;
            }

            .class-name {
                font-size: 1.5rem;
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
        .class-card { animation: fadeInUp 0.4s ease-out 0.2s both; }

        /* Touch feedback */
        @media (hover: none) {
            .stat-card:hover { transform: none; }
            .class-card:hover { transform: none; }
        }
</style>

<div class="my-classes-content">

<div class="container">
    <div class="top-bar">
        <div class="welcome-section">
            <h1>My Classes</h1>
            <p>Welcome back, <%= user.getUsername() %>! Here's your class overview for today</p>
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

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-number"><%=classes.size()%></div>
            <div class="stat-label">Total Classes</div>
        </div>
        <div class="stat-card success">
            <div class="stat-number"><%=classes.stream().mapToInt(c -> (int) c.get("student_count")).sum()%></div>
            <div class="stat-label">Total Students</div>
        </div>
    </div>

    <%
    if (!classes.isEmpty()) {
    %>
    <div class="class-grid">
        <%
        for (Map<String, Object> cls : classes) {
            int classId = (int) cls.get("class_id");
            String className = (String) cls.get("class_name");
            String section = (String) cls.get("section");
            int studentCount = (int) cls.get("student_count");
        %>
        <div class="class-card">
            <div class="class-header">
                <h3 class="class-name"><%=className%></h3>
                <%
                if (section != null && !section.trim().isEmpty()) {
                %>
                <span class="class-section"><%=section%></span>
                <%
                }
                %>
            </div>

            <div class="student-count">
                <i class="fas fa-users"></i>
                <span><%=studentCount%> Students</span>
            </div>

            <div class="class-actions">
                <button class="action-btn btn-primary" onclick="loadPage('view_students.jsp?class_id=<%=classId%>')">
                    <i class="fas fa-eye"></i> View
                </button>
                <button class="action-btn btn-success" onclick="loadPage('mark_attendance.jsp?class_id=<%=classId%>')">
                    <i class="fas fa-calendar-check"></i> Attendance
                </button>
                <button class="action-btn btn-info" onclick="loadPage('manage_grades.jsp?class_id=<%=classId%>')">
                    <i class="fas fa-chart-line"></i> Grades
                </button>
            </div>
        </div>
        <%
        }
        %>
    </div>
    <%
    } else {
    %>
    <div class="empty-state">
        <i class="fas fa-chalkboard-teacher"></i>
        <h4>No Classes Assigned</h4>
        <p>You don't have any classes assigned to you yet. Contact the administrator.</p>
    </div>
    <%
    }
    %>
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
