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
    if (user == null) {
        out.print("<div class='alert alert-danger'>Session expired. Please login.</div>");
        return;
    }

    // Get avatar letter from first name
    String avatarLetter = "A";
    if (user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }

    int classId = 0;
    String className = "";
    String section = "";
    java.util.List<java.util.Map<String, Object>> announcements = new java.util.ArrayList<>();

    try (Connection conn = SQLConnection.getConnection()) {
        // Get student's class
        PreparedStatement psStudent = conn.prepareStatement(
            "SELECT s.class_id, c.class_name, c.section FROM students s " +
            "JOIN classes c ON s.class_id = c.class_id WHERE s.user_id = ?"
        );
        psStudent.setInt(1, user.getUserId());
        ResultSet rsStudent = psStudent.executeQuery();
        
        if (rsStudent.next()) {
            classId = rsStudent.getInt("class_id");
            className = rsStudent.getString("class_name");
            section = rsStudent.getString("section");
        } else {
            out.print("<div class='alert alert-warning'>No class assigned to you yet.</div>");
            return;
        }
        rsStudent.close();
        psStudent.close();

        // Get all announcements for the class
        PreparedStatement psAnn = conn.prepareStatement(
            "SELECT a.id, a.title, a.description, a.created_at, c.class_name, c.section " +
            "FROM announcements a " +
            "JOIN classes c ON a.class_id = c.class_id " +
            "WHERE a.class_id = ? " +
            "ORDER BY a.created_at DESC"
        );
        psAnn.setInt(1, classId);
        ResultSet rsAnn = psAnn.executeQuery();

        while (rsAnn.next()) {
            java.util.Map<String, Object> ann = new java.util.HashMap<>();
            ann.put("id", rsAnn.getInt("id"));
            ann.put("title", rsAnn.getString("title"));
            ann.put("description", rsAnn.getString("description"));
            ann.put("created_at", rsAnn.getTimestamp("created_at"));
            ann.put("class_name", rsAnn.getString("class_name"));
            ann.put("section", rsAnn.getString("section"));
            announcements.add(ann);
        }
        rsAnn.close();
        psAnn.close();

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
    <meta name="description" content="Student Announcements - View all class announcements">
    <title>My Announcements - Student Portal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* ===== CSS VARIABLES ===== */
        :root {
            --primary: #4f46e5;
            --primary-light: #667eea;
            --primary-dark: #4338ca;
            --success: #10b981;
            --success-light: #059669;
            --danger: #ef4444;
            --danger-dark: #dc2626;
            --warning: #f59e0b;
            --text-dark: #1e293b;
            --text-muted: #64748b;
            --text-light: #94a3b8;
            --bg-light: #f8fafc;
            --bg-card: #ffffff;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 12px rgba(0,0,0,0.1);
            --shadow-lg: 0 10px 25px rgba(0,0,0,0.15);
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-xl: 20px;
            --radius-2xl: 24px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* ===== RESET & BASE ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            -webkit-text-size-adjust: 100%;
            -webkit-tap-highlight-color: transparent;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            min-height: 100vh;
            color: var(--text-dark);
            line-height: 1.6;
            padding: 16px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        /* ===== TOP BAR ===== */
        .top-bar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: var(--radius-xl);
            padding: 20px 24px;
            margin-bottom: 20px;
            box-shadow: var(--shadow-md);
            border: 1px solid rgba(255, 255, 255, 0.8);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            animation: fadeInDown 0.5s ease-out;
        }

        .welcome-section {
            flex: 1;
            min-width: 200px;
        }

        .welcome-section h1 {
            font-size: clamp(1.25rem, 4vw, 1.75rem);
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 4px;
            line-height: 1.3;
        }

        .welcome-section p {
            font-size: clamp(0.85rem, 2vw, 0.95rem);
            color: var(--text-muted);
            font-weight: 400;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .user-avatar {
            width: 44px;
            height: 44px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.1rem;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
        }

        .user-details {
            text-align: right;
        }

        .user-name {
            font-weight: 600;
            font-size: 0.95rem;
            color: var(--text-dark);
        }

        .user-role {
            font-size: 0.8rem;
            color: var(--text-muted);
            padding: 3px 10px;
            border-radius: 20px;
            
            margin-top: 2px;
        }

        .logout-btn {
            background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
            color: white;
            border: none;
            padding: 10px 18px;
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 0.875rem;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 8px;
            min-height: 44px;
        }

        .logout-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(239, 68, 68, 0.35);
        }

        .logout-btn:active {
            transform: translateY(0);
        }

        /* ===== HEADER SECTION ===== */
        .header {
            display: flex;
            align-items: center;
            margin-bottom: 24px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 20px 24px;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            animation: fadeInUp 0.5s ease-out 0.1s both;
        }

        .header-icon {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: #fff;
            font-size: 1.5rem;
            width: 56px;
            height: 56px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: var(--radius-md);
            margin-right: 16px;
            box-shadow: 0 6px 16px rgba(79, 70, 229, 0.35);
        }

        .header-text h4 {
            font-weight: 800;
            font-size: clamp(1.25rem, 3vw, 1.5rem);
            color: var(--text-dark);
            margin-bottom: 2px;
        }

        .header-text small {
            font-size: 0.875rem;
            color: var(--text-muted);
            font-weight: 500;
        }

        /* ===== ANNOUNCEMENTS GRID ===== */
        .cards-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }

        .card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(15px);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            padding: 24px;
            transition: var(--transition);
            border: 1px solid rgba(255, 255, 255, 0.8);
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.5s ease-out both;
        }

        .card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
        }

        .card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow-lg);
        }

        .card-badge {
            display: inline-block;
            background: linear-gradient(135deg, var(--success) 0%, var(--success-light) 100%);
            color: white;
            font-size: 0.7rem;
            font-weight: 700;
            padding: 5px 12px;
            border-radius: 20px;
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .card-title {
            font-weight: 700;
            font-size: 1.15rem;
            color: var(--text-dark);
            margin-bottom: 10px;
            line-height: 1.4;
        }

        .card-class {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .card-desc {
            color: var(--text-muted);
            font-size: 0.925rem;
            margin-bottom: 16px;
            line-height: 1.7;
        }

        .card-time {
            font-size: 0.8rem;
            color: var(--text-light);
            display: flex;
            align-items: center;
            gap: 6px;
            padding-top: 14px;
            border-top: 1px solid #e2e8f0;
        }

        /* ===== EMPTY STATE ===== */
        .no-announcements {
            text-align: center;
            padding: 60px 30px;
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(15px);
            border-radius: var(--radius-2xl);
            box-shadow: var(--shadow-lg);
            animation: fadeInUp 0.5s ease-out;
        }

        .no-announcements-icon {
            font-size: 4rem;
            margin-bottom: 16px;
            opacity: 0.6;
        }

        .no-announcements h6 {
            font-size: 1.35rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 8px;
        }

        .no-announcements p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        /* ===== ALERTS ===== */
        .alert {
            padding: 14px 20px;
            border-radius: var(--radius-md);
            margin-bottom: 20px;
            font-weight: 500;
            font-size: 0.925rem;
        }

        .alert-danger {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            color: #991b1b;
            border: 1px solid #fca5a5;
        }

        .alert-warning {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            color: #92400e;
            border: 1px solid #fcd34d;
        }

        /* ===== BACK BUTTON ===== */
        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            margin-bottom: 16px;
            padding: 8px 16px;
            background: white;
            border-radius: var(--radius-sm);
            box-shadow: var(--shadow-sm);
            transition: var(--transition);
        }

        .back-btn:hover {
            background: var(--primary);
            color: white;
            transform: translateX(-4px);
        }

        /* ===== ANIMATIONS ===== */
        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Staggered animation for cards */
        .card:nth-child(1) { animation-delay: 0.1s; }
        .card:nth-child(2) { animation-delay: 0.15s; }
        .card:nth-child(3) { animation-delay: 0.2s; }
        .card:nth-child(4) { animation-delay: 0.25s; }
        .card:nth-child(5) { animation-delay: 0.3s; }
        .card:nth-child(6) { animation-delay: 0.35s; }

        /* ===== RESPONSIVE DESIGN ===== */

        /* Tablet */
        @media (max-width: 1024px) {
            .cards-container {
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 16px;
            }
        }

        /* Mobile Large */
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

            .cards-container {
                grid-template-columns: 1fr;
                gap: 14px;
            }

            .card {
                padding: 18px;
                border-radius: var(--radius-md);
            }

            .card-title {
                font-size: 1.05rem;
            }

            .card-desc {
                font-size: 0.875rem;
            }
        }

        /* Mobile Small */
        @media (max-width: 480px) {
            body {
                padding: 8px;
            }

            .top-bar {
                padding: 14px;
                margin-bottom: 12px;
                border-radius: var(--radius-md);
            }

            .welcome-section h1 {
                font-size: 1.2rem;
            }

            .welcome-section p {
                font-size: 0.8rem;
            }

            .user-avatar {
                width: 40px;
                height: 40px;
                font-size: 1rem;
            }

            .user-name {
                font-size: 0.875rem;
            }

            .user-role {
                font-size: 0.7rem;
            }

            .logout-btn {
                padding: 10px 14px;
                font-size: 0.8rem;
            }

            .header {
                padding: 14px;
                margin-bottom: 14px;
            }

            .header-icon {
                width: 44px;
                height: 44px;
                font-size: 1.1rem;
            }

            .header-text h4 {
                font-size: 1.15rem;
            }

            .header-text small {
                font-size: 0.8rem;
            }

            .card {
                padding: 14px;
            }

            .card-badge {
                font-size: 0.65rem;
                padding: 4px 10px;
            }

            .card-title {
                font-size: 1rem;
            }

            .card-class {
                font-size: 0.8rem;
            }

            .card-desc {
                font-size: 0.85rem;
                margin-bottom: 12px;
            }

            .card-time {
                font-size: 0.75rem;
                padding-top: 10px;
            }

            .no-announcements {
                padding: 40px 20px;
                border-radius: var(--radius-lg);
            }

            .no-announcements-icon {
                font-size: 3rem;
            }

            .no-announcements h6 {
                font-size: 1.15rem;
            }

            .no-announcements p {
                font-size: 0.875rem;
            }
        }

        /* Extra Small */
        @media (max-width: 360px) {
            .top-bar {
                padding: 12px;
            }

            .header {
                padding: 12px;
            }

            .card {
                padding: 12px;
            }

            .card-title {
                font-size: 0.95rem;
            }
        }

        /* Touch devices - disable hover effects */
        @media (hover: none) {
            .card:hover {
                transform: none;
                box-shadow: var(--shadow-md);
            }

            .logout-btn:hover {
                transform: none;
                box-shadow: none;
            }

            .back-btn:hover {
                background: white;
                color: var(--primary);
                transform: none;
            }
        }

        /* Desktop Large */
        @media (min-width: 1400px) {
            body {
                padding: 24px;
            }

            .top-bar {
                padding: 28px 32px;
                border-radius: var(--radius-2xl);
                margin-bottom: 28px;
            }

            .cards-container {
                gap: 24px;
            }

            .card {
                padding: 28px;
                border-radius: var(--radius-xl);
            }

            .header {
                padding: 24px 28px;
                border-radius: var(--radius-xl);
                margin-bottom: 28px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <!-- Back Button -->
    
    <!-- ===== TOP BAR ===== -->
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Welcome, <%= user.getFullName() %></h1>
            <p>Here's what's happening in your class</p>
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

    <!-- ===== HEADER ===== -->
    <div class="header">
        <div class="header-icon">
            <i class="fas fa-bullhorn"></i>
        </div>
        <div class="header-text">
            <h4>Announcements</h4>
            <small><%= className %> - <%= section %></small>
        </div>
    </div>

    <% if (announcements.isEmpty()) { %>
    <!-- Empty State -->
    <div class="no-announcements">
        <div class="no-announcements-icon">📭</div>
        <h6>No new announcements</h6>
        <p>Check back later for updates from your teachers.</p>
    </div>
    <% } else { %>
    <!-- Announcements Grid -->
    <div class="cards-container">
        <% for (java.util.Map<String, Object> ann : announcements) { %>
        <div class="card">
            <div class="card-badge">New</div>
            <div class="card-title"><%= ann.get("title") %></div>
            <div class="card-class">
                <i class="fas fa-school"></i>
                <%= ann.get("class_name") %> - <%= ann.get("section") %>
            </div>
            <div class="card-desc"><%= ann.get("description") %></div>
            <div class="card-time">
                <i class="fas fa-clock"></i>
                <%= ann.get("created_at") %>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>

</div>

<script>
    function logout() {
        if (confirm('Are you sure you want to logout?')) {
            window.location.href = '<%= request.getContextPath() %>/LogoutServlet';
        }
    }

    // Prevent double-tap zoom on mobile
    document.addEventListener('dblclick', function(event) {
        event.preventDefault();
    }, { passive: false });

    // Add active state for touch feedback
    document.addEventListener('touchstart', function() {}, { passive: true });
</script>

</body>
</html>
