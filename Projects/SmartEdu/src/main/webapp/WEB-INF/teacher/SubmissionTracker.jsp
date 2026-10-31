<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="com.seh.model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String avatarLetter = "A";
    if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }

    String classIdParam = request.getParameter("classId");
    String subjectIdParam = request.getParameter("subjectId");
    String activity = request.getParameter("activity");
    
    // Practical range parameters
    String practicalFromParam = request.getParameter("practicalFrom");
    String practicalToParam = request.getParameter("practicalTo");
    String practicalMaxMarksParam = request.getParameter("practicalMaxMarks");
    
    int practicalFrom = 1;
    int practicalTo = 5;
    int practicalMaxMarks = 10;
    
    if (practicalFromParam != null && !practicalFromParam.isEmpty()) {
        practicalFrom = Integer.parseInt(practicalFromParam);
    }
    if (practicalToParam != null && !practicalToParam.isEmpty()) {
        practicalTo = Integer.parseInt(practicalToParam);
    }
    if (practicalMaxMarksParam != null && !practicalMaxMarksParam.isEmpty()) {
        practicalMaxMarks = Integer.parseInt(practicalMaxMarksParam);
    }
    
    if (activity == null || activity.isEmpty()) {
        activity = "Assignment";
    }
    
    boolean isAssignment = activity.equalsIgnoreCase("Assignment");
    boolean isSLA = activity.equalsIgnoreCase("SLA");
    
    Set<Integer> submittedStudents = new HashSet<>();
    Map<String, Integer> practicalMarks = new HashMap<>();
    int totalRows = 0;
    
    if (classIdParam != null && !classIdParam.isEmpty() && 
        subjectIdParam != null && !subjectIdParam.isEmpty()) {
        
        try (Connection conn = SQLConnection.getConnection()) {
            int classId = Integer.parseInt(classIdParam);
            int subjectId = Integer.parseInt(subjectIdParam);
            
            // Get submitted students
            String checkSql = "SELECT student_id FROM submissions WHERE class_id = ? AND subject_id = ? AND activity_name = ? AND submitted = 1";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, classId);
            psCheck.setInt(2, subjectId);
            psCheck.setString(3, activity);
            ResultSet rsCheck = psCheck.executeQuery();
            
            while (rsCheck.next()) {
                submittedStudents.add(rsCheck.getInt("student_id"));
            }
            rsCheck.close();
            psCheck.close();
            
            // Get practical marks
            if (practicalFrom <= practicalTo) {
                String marksSql = "SELECT student_id, practical_no, marks FROM practical_marks WHERE class_id = ? AND subject_id = ? AND activity_name = ? AND practical_no BETWEEN ? AND ?";
                PreparedStatement psMarks = conn.prepareStatement(marksSql);
                psMarks.setInt(1, classId);
                psMarks.setInt(2, subjectId);
                psMarks.setString(3, activity);
                psMarks.setInt(4, practicalFrom);
                psMarks.setInt(5, practicalTo);
                ResultSet rsMarks = psMarks.executeQuery();
                
                while (rsMarks.next()) {
                    String key = rsMarks.getInt("student_id") + "_P" + rsMarks.getInt("practical_no");
                    practicalMarks.put(key, rsMarks.getInt("marks"));
                }
                rsMarks.close();
                psMarks.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="description" content="Submission Tracker - Teacher Dashboard">
    <title>Submission Tracker - SmartEdu</title>
    
    <link rel="preconnect" href="https://cdnjs.cloudflare.com" crossorigin>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <style>
        :root {
            --primary: #667eea;
            --primary-light: #818cf8;
            --primary-dark: #5a67d8;
            --success: #10b981;
            --success-dark: #059669;
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
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            -webkit-tap-highlight-color: transparent;
        }

        html {
            -webkit-text-size-adjust: 100%;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-light);
            color: var(--text-dark);
            min-height: 100vh;
            padding: 16px;
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
        }

        .container {
            max-width: 1600px;
            margin: 0 auto;
        }

        /* Top Bar */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            padding: 20px;
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-md);
            flex-wrap: wrap;
            gap: 16px;
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
        }

        .welcome-section p {
            color: var(--text-muted);
            font-size: clamp(0.8rem, 2.5vw, 1rem);
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .welcome-section p::before {
            content: '';
            width: 8px;
            height: 8px;
            background: var(--success);
            border-radius: 50%;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            font-weight: 600;
            font-size: 1.25rem;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .user-details {
            text-align: right;
        }

        .user-details .name {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.95rem;
        }

        .user-details .role {
            font-size: 0.85rem;
            color: var(--text-muted);
            text-transform: capitalize;
        }

        .logout-btn {
            background: linear-gradient(135deg, var(--danger) 0%, #dc2626 100%);
            color: white;
            border: none;
            border-radius: var(--radius-sm);
            padding: 12px 20px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .logout-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(239, 68, 68, 0.4);
        }

        /* Quick Links */
        .quick-links {
            display: flex;
            gap: 12px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .quick-link {
            padding: 12px 20px;
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 0.875rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
            border: none;
            cursor: pointer;
        }

        .quick-link.primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            box-shadow: var(--shadow-sm);
        }

        .quick-link.primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .quick-link.success {
            background: linear-gradient(135deg, var(--success) 0%, var(--success-dark) 100%);
            color: white;
            box-shadow: var(--shadow-sm);
        }

        .quick-link.success:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4);
        }

        /* Filter Card */
        .card {
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: 24px;
            box-shadow: var(--shadow-md);
            margin-bottom: 24px;
        }

        .card-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .card-title i {
            color: var(--primary);
        }

        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            align-items: flex-end;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-weight: 600;
            color: var(--text-muted);
            font-size: 0.875rem;
            margin-bottom: 8px;
        }

        .form-group select {
            padding: 14px 16px;
            border: 2px solid #e2e8f0;
            border-radius: var(--radius-sm);
            font-size: 1rem;
            color: var(--text-dark);
            background: #f8fafc;
            transition: var(--transition);
            cursor: pointer;
        }

        .form-group select:focus {
            outline: none;
            border-color: var(--primary);
            background: var(--white);
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }

        /* Activity Toggle */
        .activity-toggle {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .toggle-btn {
            padding: 14px 24px;
            border: 2px solid #e2e8f0;
            background: var(--white);
            border-radius: var(--radius-sm);
            cursor: pointer;
            font-weight: 600;
            font-size: 0.95rem;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--text-muted);
        }

        .toggle-btn:hover {
            border-color: var(--primary-light);
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.15);
        }

        .toggle-btn.active {
            color: white;
            border-color: transparent;
        }

        .toggle-btn.assignment.active {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
        }

        .toggle-btn.sla.active {
            background: linear-gradient(135deg, var(--warning) 0%, #d97706 100%);
            box-shadow: 0 4px 20px rgba(245, 158, 11, 0.4);
        }

        .btn {
            padding: 14px 24px;
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            border: none;
            text-decoration: none;
            white-space: nowrap;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            box-shadow: var(--shadow-sm);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        /* Table Card */
        .table-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            display: none;
        }

        .table-card.show {
            display: block;
        }

        .table-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            padding: 20px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
        }

        .table-header h2 {
            color: white;
            font-size: 1.125rem;
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 0;
        }

        .table-count {
            color: rgba(255,255,255,0.9);
            font-size: 0.9rem;
            font-weight: 500;
            background: rgba(255,255,255,0.2);
            padding: 6px 14px;
            border-radius: 20px;
        }

        .table-wrapper {
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 600px;
        }

        th {
            background: #f8fafc;
            padding: 16px 20px;
            text-align: left;
            font-weight: 600;
            color: var(--text-muted);
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
            white-space: nowrap;
        }

        td {
            padding: 16px 20px;
            border-bottom: 1px solid #f1f5f9;
            color: var(--text-dark);
            font-size: 0.95rem;
            vertical-align: middle;
        }

        tr:hover {
            background: #f8fafc;
        }

        tr:last-child td {
            border-bottom: none;
        }

        .student-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .student-avatar {
            width: 42px;
            height: 42px;
            border-radius: var(--radius-md);
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            font-weight: 600;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .roll-badge {
            background: #e2e8f0;
            padding: 4px 10px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 0.85rem;
            color: var(--text-dark);
        }

        td input[type="checkbox"] {
            width: 22px;
            height: 22px;
            cursor: pointer;
            accent-color: var(--primary);
            border-radius: 6px;
        }

        /* Stats & Actions */
        .footer-flex {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e2e8f0;
        }

        .stats-group {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }

        .stat-tag {
            padding: 12px 20px;
            border-radius: var(--radius-md);
            font-size: 0.95rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: var(--shadow-sm);
        }

        .stat-tag.done {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #059669;
        }

        .stat-tag.pending {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            color: #dc2626;
        }

        .action-group {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn-success {
            background: linear-gradient(135deg, var(--success) 0%, var(--success-dark) 100%);
            color: white;
            box-shadow: var(--shadow-sm);
        }

    .btn-download {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            box-shadow: var(--shadow-sm);
        }

        .btn-download:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4);
        }

        .btn-ghost {
            background: transparent;
            color: var(--text-muted);
            border: 2px solid #e2e8f0;
        }

        .btn-ghost:hover {
            background: #f8fafc;
            border-color: var(--primary);
            color: var(--primary);
        }

        /* Message Box */
        .message-box {
            background: var(--white);
            padding: 60px 30px;
            border-radius: var(--radius-lg);
            text-align: center;
            box-shadow: var(--shadow-md);
            margin-bottom: 24px;
        }

        .message-box i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.3;
            color: var(--text-muted);
        }

        .message-box h3 {
            font-size: 1.25rem;
            color: var(--text-dark);
            margin-bottom: 8px;
        }

        .message-box p {
            font-size: 1rem;
            color: var(--text-muted);
            font-weight: 500;
        }

        /* Animations */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .top-bar, .quick-links, .card, .table-card, .message-box {
            animation: fadeInUp 0.5s ease-out;
        }

        /* Responsive */
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
            .filter-grid {
                grid-template-columns: 1fr;
            }
            
            .quick-links {
                justify-content: center;
            }
            
            .footer-flex {
                flex-direction: column;
                align-items: stretch;
            }
            
            .stats-group {
                justify-content: center;
            }
            
            .action-group {
                justify-content: center;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>

<div class="container">

    <!-- TOP BAR -->
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Submission Tracker</h1>
            <p>Welcome back, <%= user.getFullName() %>! Track and manage student submissions</p>
        </div>
        <div class="user-info">
            <div class="user-avatar"><%= avatarLetter %></div>
            <div class="user-details">
                <div class="name"><%= user.getUsername() %></div>
                <div class="role"><%= user.getRole() %></div>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i>
                <span>Logout</span>
            </button>
        </div>
    </div>

    <!-- Quick Access Links -->
   

    <!-- Filter Card -->
    <div class="card">
        <div class="card-title">
            <i class="fas fa-filter"></i> Select Class, Subject & Activity
        </div>
        
        <form action="<%= request.getContextPath() %>/teacher/SubmissionServlet" method="get">
            <div class="filter-grid">
                <div class="form-group">
                    <label for="classId">Class & Section</label>
                    <select name="classId" id="classId" required>
                        <option value="">-- Select Class --</option>
                        <%
                            try (Connection conn = SQLConnection.getConnection()) {
                                ResultSet rs = conn.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name, section").executeQuery();
                                while (rs.next()) {
                                    String id = String.valueOf(rs.getInt("class_id"));
                                    String selected = (classIdParam != null && classIdParam.equals(id)) ? "selected" : "";
                        %>
                        <option value="<%= id %>" <%= selected %>><%= rs.getString("class_name") %> - <%= rs.getString("section") %></option>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="subjectId">Subject</label>
                    <select name="subjectId" id="subjectId" required>
                        <option value="">-- Select Subject --</option>
                        <%
                            try (Connection conn = SQLConnection.getConnection()) {
                                ResultSet rs = conn.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name").executeQuery();
                                while (rs.next()) {
                                    String id = String.valueOf(rs.getInt("subject_id"));
                                    String selected = (subjectIdParam != null && subjectIdParam.equals(id)) ? "selected" : "";
                        %>
                        <option value="<%= id %>" <%= selected %>><%= rs.getString("subject_name") %></option>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="activityInput">Activity Name</label>
                    <input type="text" name="activity" id="activityInput" value="<%= activity %>" list="activityOptions" placeholder="e.g. Assignment, SLA, Quiz" required autocomplete="off" style="padding: 14px 16px; border: 2px solid #e2e8f0; border-radius: var(--radius-sm); font-size: 1rem; color: var(--text-dark); background: #f8fafc; width: 100%;">
                    <datalist id="activityOptions">
                        <option value="Assignment">
                        <option value="SLA">
                    </datalist>
                </div>

                <div class="form-group">
                    <label>Practical Range</label>
                    <div style="display: flex; gap: 8px; align-items: center;">
                        <input type="number" name="practicalFrom" id="practicalFrom" value="<%= practicalFrom %>" min="1" max="20" style="width: 70px; padding: 10px; border: 2px solid #e2e8f0; border-radius: 6px; font-size: 0.9rem;" placeholder="From">
                        <span style="color: var(--text-muted);">to</span>
                        <input type="number" name="practicalTo" id="practicalTo" value="<%= practicalTo %>" min="1" max="20" style="width: 70px; padding: 10px; border: 2px solid #e2e8f0; border-radius: 6px; font-size: 0.9rem;" placeholder="To">
                    </div>
                </div>

                <div class="form-group">
                    <label>Max Marks</label>
                    <input type="number" name="practicalMaxMarks" id="practicalMaxMarks" value="<%= practicalMaxMarks %>" min="1" max="100" style="width: 100px; padding: 10px; border: 2px solid #e2e8f0; border-radius: 6px; font-size: 0.9rem;">
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-search"></i> Load List
                </button>
            </div>
        </form>
    </div>

    <% if (classIdParam != null && !classIdParam.isEmpty() && subjectIdParam != null && !subjectIdParam.isEmpty()) { %>
    
    <form method="post" action="<%= request.getContextPath() %>/teacher/SubmissionServlet">
        <input type="hidden" name="classId" value="<%= classIdParam %>">
        <input type="hidden" name="subjectId" value="<%= subjectIdParam %>">
        <input type="hidden" name="activity" value="<%= activity %>">
        <input type="hidden" name="practicalFrom" value="<%= practicalFrom %>">
        <input type="hidden" name="practicalTo" value="<%= practicalTo %>">
        <input type="hidden" name="practicalMaxMarks" value="<%= practicalMaxMarks %>">

        <div class="table-card show">
            <div class="table-header">
                <h2>
                    <i class="fas fa-clipboard-list"></i>
                    Student Submissions: <%= activity %>
                </h2>
            </div>
            
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th style="width: 60px;">#</th>
                            <th style="width: 100px;">Roll</th>
                            <th>Student Name</th>
                            <th style="text-align: center; width: 120px;">Submitted</th>
                            <%
                            // Generate dynamic practical columns
                            if (practicalFrom <= practicalTo) {
                                for (int i = practicalFrom; i <= practicalTo; i++) {
                            %>
                            <th style="text-align: center; width: 100px; background: #dbeafe; color: #1e40af;">P<%= i %><br><span style="font-size: 0.7rem; font-weight: 400;">(<%= practicalMaxMarks %>)</span></th>
                            <%
                                }
                            }
                            %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            int rowCount = 0;
                            try (Connection conn = SQLConnection.getConnection()) {
                                String sql = "SELECT student_id, roll_number, first_name, last_name FROM students WHERE class_id = ? ORDER BY roll_number ASC";
                                PreparedStatement ps = conn.prepareStatement(sql);
                                ps.setInt(1, Integer.parseInt(classIdParam));
                                ResultSet rs = ps.executeQuery();
                                
                                while (rs.next()) {
                                    rowCount++;
                                    int studentId = rs.getInt("student_id");
                                    boolean isSubmitted = submittedStudents.contains(studentId);
                                    String firstLetter = rs.getString("first_name").substring(0, 1).toUpperCase();
                        %>
                        <tr>
                            <td><%= rowCount %></td>
                            <td><span class="roll-badge"><%= rs.getString("roll_number") %></span></td>
                            <td>
                                <div class="student-info">
                                    <div class="student-avatar"><%= firstLetter %></div>
                                    <span><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></span>
                                </div>
                            </td>
                            <td style="text-align: center;">
                                <input type="checkbox" name="student_<%= rowCount %>" value="<%= studentId %>" 
                                       <%= isSubmitted ? "checked" : "" %> 
                                       onchange="updateCount()" 
                                       style="width: 20px; height: 20px; accent-color: var(--primary);">
                            </td>
                            <%
                            // Generate dynamic practical marks input fields
                            if (practicalFrom <= practicalTo) {
                                for (int i = practicalFrom; i <= practicalTo; i++) {
                                    String markKey = studentId + "_P" + i;
                                    Integer savedMark = practicalMarks.get(markKey);
                                    String markValue = savedMark != null ? String.valueOf(savedMark) : "";
                            %>
                            <td style="text-align: center;">
                               <input type="number"
value="<%= markValue %>"
min="0"
max="<%= practicalMaxMarks %>"
onchange="saveMarks(<%= studentId %>, <%= i %>, this)"
style="width:60px;padding:8px;border:2px solid #e2e8f0;border-radius:6px;text-align:center;">
                            </td>
                            <%
                                }
                            }
                            %>
                        </tr>
                        <% 
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <input type="hidden" name="rows" value="<%= rowCount %>">

            <div class="footer-flex">
                <div class="stats-group">
                    <div class="stat-tag done">
                        <i class="fas fa-check-circle"></i> Done: <span id="doneCount"><%= submittedStudents.size() %></span>
                    </div>
                    <div class="stat-tag pending">
                        <i class="fas fa-clock"></i> Pending: <span id="remainingCount"><%= rowCount - submittedStudents.size() %></span>
                    </div>
                </div>
                <div class="action-group">
                    
                    <button type="button" class="btn btn-ghost"
        onclick="window.location.href='Index.jsp';"
       >
        <i class="fa-solid fa-arrow-left"></i>
        Back
    </button>
                    <a href="<%= request.getContextPath() %>/teacher/DownloadSubmissionExcel?classId=<%= classIdParam %>&subjectId=<%= subjectIdParam %>&activity=<%= activity %>" class="btn btn-download">
<i class="fas fa-file-excel"></i> Download Excel
</a>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                </div>
            </div>
        </div>
    </form>

    <% } else { %>
    
    <div class="message-box">
        <i class="fas fa-folder-open"></i>
        <h3>No Class Selected</h3>
        <p>Please select a class and subject above to view the student submission tracker.</p>
    </div>

    <% } %>

</div>

<script>
    function logout() {
        if (confirm("Are you sure you want to log out?")) {
            window.location.href = "<%= request.getContextPath() %>/LogoutServlet";
        }
    }

    function setActivity(type) {
        document.getElementById('activityInput').value = type;
        
        document.querySelectorAll('.toggle-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        const selectedBtn = document.querySelector('.toggle-btn.' + type.toLowerCase());
        if (selectedBtn) {
            selectedBtn.classList.add('active');
        }
        
        // Submit the form to reload with new activity
        document.querySelector('form').submit();
    }

    function updateCount() {
        const checkboxes = document.querySelectorAll("input[type=checkbox]");
        let done = 0;
        checkboxes.forEach(function(c) {
            if (c.checked) done++;
        });
        
        document.getElementById("doneCount").innerText = done;
        document.getElementById("remainingCount").innerText = checkboxes.length - done;
    }

    function goBack() {
        window.location.href = 'Index.jsp';
    }

    // Initialize counts on load
    window.onload = function() {
        updateCount();
    };

    // Prevent double-tap zoom on mobile
    document.addEventListener('dblclick', function(event) {
        event.preventDefault();
    }, { passive: false });
    
    function saveMarks(studentId, practicalNo, input){

        let marks = input.value;

        fetch("<%=request.getContextPath()%>/teacher/PracticalMarksServlet",{
            method:"POST",
            headers:{
                "Content-Type":"application/x-www-form-urlencoded"
            },
            body:
            "studentId="+studentId+
            "&classId=<%=classIdParam%>"+
            "&subjectId=<%=subjectIdParam%>"+
            "&activity=<%=activity%>"+
            "&practicalNo="+practicalNo+
            "&marks="+marks
        })
        .then(response=>response.text())
        .then(data=>{
            console.log("Saved:",data);
        })
        .catch(error=>{
            console.error("Error:",error);
        });

    }
</script>

</body>
</html>

