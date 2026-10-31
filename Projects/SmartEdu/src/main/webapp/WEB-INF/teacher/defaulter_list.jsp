<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.seh.model.User" %>
<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="java.sql.*" %>
<%
    User user = (User) session.getAttribute("user");
    if(user == null){
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String avatarLetter = "A";
    if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }

    String classIdParam = request.getParameter("class_id");
    String className = "";
    String section = "";
    
    // Get filter parameters
    String filterType = (String) request.getAttribute("filter_type");
    String startDateParam = (String) request.getAttribute("start_date");
    String endDateParam = (String) request.getAttribute("end_date");
    
    if (filterType == null) filterType = "overall";
    if (startDateParam == null || startDateParam.isEmpty()) {
        java.time.LocalDate now = java.time.LocalDate.now();
        startDateParam = now.withDayOfMonth(1).toString();
    }
    if (endDateParam == null || endDateParam.isEmpty()) {
        endDateParam = java.time.LocalDate.now().toString();
    }

    if(classIdParam != null && !classIdParam.isEmpty()){
        try(Connection conn = SQLConnection.getConnection()){
            PreparedStatement ps = conn.prepareStatement("SELECT class_name, section FROM classes WHERE class_id=?");
            ps.setInt(1, Integer.parseInt(classIdParam));
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                className = rs.getString("class_name");
                section = rs.getString("section");
            }
        } catch(Exception e){ e.printStackTrace(); }
    }

    List<Map<String, Object>> defaulters = (List<Map<String, Object>>) request.getAttribute("defaulters");
    
    // Build period display string
    String periodDisplay = "overall".equals(filterType) ? "Overall (All Time)" : startDateParam + " to " + endDateParam;
%>

<style>
        /* ===== CSS VARIABLES FOR CONSISTENT THEMING ===== */
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
        }

        /* ===== RESET & BASE STYLES ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            -webkit-text-size-adjust: 100%;
            -webkit-tap-highlight-color: transparent;
        }

        .defaulter-content {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            min-height: 100vh;
            color: var(--text-dark);
            background: var(--bg-light);
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        /* ===== TOP BAR ===== */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            width: 100%;
            margin-bottom: 2rem;
            padding: 1.5rem 2rem;
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            gap: 1rem;
        }

        .welcome-section {
            flex: 1;
            min-width: 200px;
        }

        .welcome-section h1 {
            font-size: clamp(1.25rem, 4vw, 2rem);
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 0.5rem;
            line-height: 1.2;
        }

        .welcome-section p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .user-details {
            display: flex;
            flex-direction: column;
            text-align: right;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-weight: 600;
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        .logout-btn {
            background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
            color: var(--white);
            border: none;
            border-radius: var(--radius-sm);
            padding: 10px 16px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: var(--transition);
            box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
            white-space: nowrap;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .logout-btn:hover {
            background: var(--danger-dark);
            transform: translateY(-1px);
        }

        .logout-btn:active {
            transform: scale(0.98);
        }

        /* ===== FILTER CARD ===== */
        .filter-card {
            background: var(--white);
            padding: 2rem;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            margin-bottom: 2rem;
            border: 1px solid #e2e8f0;
        }

        .filter-card h2 {
            font-size: 1.125rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .filter-card h2 i {
            color: var(--primary);
        }

        .filter-form {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            align-items: stretch;
            width: 100%;
        }

        .form-group {
            flex: 1 1 200px;
            min-width: 160px;
            display: flex;
            flex-direction: column;
        }

        .form-group.full-width {
            flex: 1 1 100%;
        }

        .form-group label {
            display: block;
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 8px;
        }

        .form-group select,
        .form-group input[type="date"] {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e2e8f0;
            border-radius: var(--radius-md);
            font-size: 15px;
            color: var(--text-dark);
            background: var(--bg-light);
            transition: var(--transition);
            cursor: pointer;
            -webkit-appearance: none;
            appearance: none;
            height: 50px;
            line-height: 1.5;
        }

        .form-group select {
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%2364748b' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 14px center;
            padding-right: 40px;
        }

        .form-group input[type="date"] {
            padding-right: 16px;
        }

        .form-group select:focus,
        .form-group input[type="date"]:focus {
            outline: none;
            border-color: var(--primary);
            background-color: var(--white);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
        }

        .form-group-inline {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            flex-shrink: 0;
        }

        .form-group-inline span {
            color: var(--text-muted);
            font-weight: 600;
            white-space: nowrap;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: var(--white);
            border: none;
            border-radius: var(--radius-md);
            padding: 14px 28px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            transition: var(--transition);
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            -webkit-tap-highlight-color: transparent;
            white-space: nowrap;
            height: 50px;
            flex: 0 0 auto;
            align-self: flex-end;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
        }

        .btn-primary:active {
            transform: scale(0.98);
        }

        /* ===== FILTER TYPE TOGGLE ===== */
        .filter-type-toggle {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }

        .filter-type-btn {
            padding: 10px 18px;
            border: 2px solid #e2e8f0;
            background: var(--white);
            border-radius: var(--radius-sm);
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            color: var(--text-muted);
            transition: var(--transition);
            flex: 1 1 auto;
            min-width: 120px;
            text-align: center;
        }

        .filter-type-btn.active {
            background: var(--primary);
            border-color: var(--primary);
            color: var(--white);
        }

        .filter-type-btn:hover:not(.active) {
            border-color: var(--primary);
            color: var(--primary);
        }

        .date-range-section {
            display: none;
            width: 100%;
        }

        .date-range-section.active {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: flex-end;
        }

        /* ===== MESSAGE BOXES ===== */
        .message-box {
            background: var(--white);
            padding: 30px;
            border-radius: var(--radius-lg);
            text-align: center;
            box-shadow: var(--shadow-md);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .message-box.warning {
            border-left: 5px solid #f59e0b;
            background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
        }

        .message-box.success {
            border-left: 5px solid var(--primary);
            background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
        }

        .message-box i {
            font-size: 48px;
            margin-bottom: 15px;
        }

        .message-box.warning i {
            color: #f59e0b;
        }

        .message-box.success i {
            color: var(--primary);
        }

        .message-box p {
            font-size: 1rem;
            color: var(--text-dark);
            font-weight: 500;
        }

        /* ===== TABLE CARD ===== */
        .table-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            margin-bottom: 2rem;
            border: 1px solid #e2e8f0;
        }

        .table-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        .table-header h2 {
            color: var(--white);
            font-size: 1.125rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .table-header .class-info {
            color: rgba(255, 255, 255, 0.9);
            font-size: 0.875rem;
            font-weight: 500;
        }

        /* ===== TABLE STYLES ===== */
        .table-wrapper {
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            background: var(--bg-light);
            padding: 14px 12px;
            text-align: left;
            font-weight: 600;
            color: var(--text-muted);
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
            white-space: nowrap;
        }

        td {
            padding: 12px;
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

        .student-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .student-avatar {
            width: 36px;
            height: 36px;
            border-radius: var(--radius-sm);
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: var(--white);
            font-weight: 600;
            font-size: 13px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .attendance-percentage {
            font-weight: 700;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 13px;
            display: inline-block;
        }

        .attendance-percentage.low {
            background: #fef2f2;
            color: #dc2626;
        }

        .attendance-percentage.medium {
            background: #fef3c7;
            color: #d97706;
        }

        .attendance-percentage.good {
            background: #d1fae5;
            color: var(--primary-dark);
        }

        .roll-number {
            font-weight: 600;
            color: var(--text-muted);
            font-size: 0.875rem;
        }

        .days-count {
            font-weight: 600;
            color: var(--text-dark);
        }

        /* ===== DOWNLOAD SECTION ===== */
        .download-section {
            background: var(--white);
            padding: 2rem;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 15px;
            border: 1px solid #e2e8f0;
            flex-wrap: wrap;
        }

        .download-section form {
            margin: 0;
        }

        .btn-download {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 12px 25px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-download:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #64748b 0%, #475569 100%);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 12px 25px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(100, 116, 139, 0.3);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(100, 116, 139, 0.4);
        }

        /* ===== RESPONSIVE BREAKPOINTS ===== */
        
        /* Large tablets */
        @media (max-width: 992px) {
            .top-bar {
                padding: 1.125rem 1.5rem;
            }
            
            .welcome-section h1 {
                font-size: 1.25rem;
            }
        }

        /* Tablets */
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

            .filter-card {
                padding: 1rem;
                border-radius: var(--radius-md);
                margin-bottom: 1rem;
            }

            .filter-card h2 {
                font-size: 1rem;
                text-align: center;
                justify-content: center;
            }

            .filter-type-toggle {
                width: 100%;
            }

            .filter-type-btn {
                flex: 1;
            }

            .filter-form {
                flex-direction: column;
                gap: 12px;
            }

            .form-group {
                width: 100%;
                min-width: 100%;
                flex: none;
            }

            .form-group-inline {
                width: 100%;
                justify-content: center;
                padding-bottom: 0;
            }

            .date-range-section.active {
                flex-direction: column;
                align-items: stretch;
            }

            .date-range-section.active .form-group {
                width: 100%;
            }

            .btn-primary {
                width: 100%;
            }

            .table-header {
                flex-direction: row;
                justify-content: space-between;
                gap: 10px;
                text-align: left;
                padding: 0.875rem 1rem;
            }

            .table-header h2 {
                font-size: 1rem;
            }

            th, td {
                padding: 10px 8px;
                font-size: 0.75rem;
            }

            .download-section {
                flex-direction: row;
                justify-content: center;
                padding: 1rem;
                gap: 10px;
            }

            .btn-download, .btn-secondary {
                flex: 1;
                justify-content: center;
                padding: 10px 15px;
                font-size: 13px;
            }
        }

        /* Large phones */
        @media (max-width: 600px) {
            .defaulter-content {
                padding-bottom: 1.875rem;
            }

            .top-bar {
                padding: 0.875rem;
                border-radius: var(--radius-md);
                margin-bottom: 0.9375rem;
            }

            .welcome-section h1 {
                font-size: 1.125rem;
            }

            .welcome-section p {
                font-size: 0.6875rem;
            }

            .user-info {
                flex-direction: column;
                width: 100%;
                gap: 10px;
            }

            .user-details {
                text-align: center;
            }

            .user-avatar {
                width: 40px;
                height: 40px;
                font-size: 1rem;
            }

            .filter-card {
                padding: 0.875rem;
                border-radius: var(--radius-md);
                margin-bottom: 0.9375rem;
            }

            .filter-card h2 {
                font-size: 0.9375rem;
                margin-bottom: 0.75rem;
            }

            .form-group label {
                font-size: 0.6875rem;
            }

            .form-group select,
            .form-group input[type="date"] {
                padding: 12px 14px;
                font-size: 15px;
            }

            .btn-primary {
                padding: 0.875rem 1.125rem;
                font-size: 0.875rem;
            }

            .message-box {
                padding: 1.5rem 1rem;
            }

            .message-box i {
                font-size: 2.25rem;
            }

            .message-box p {
                font-size: 0.875rem;
            }

            .table-card {
                border-radius: var(--radius-md);
                margin-bottom: 0.9375rem;
            }

            .table-header {
                padding: 0.75rem 0.875rem;
            }

            .table-header h2 {
                font-size: 0.9375rem;
            }

            th {
                padding: 10px 6px;
                font-size: 0.625rem;
            }

            td {
                padding: 8px 6px;
            }

            .student-info {
                gap: 8px;
            }

            .student-avatar {
                width: 32px;
                height: 32px;
                font-size: 0.75rem;
            }

            .attendance-percentage {
                padding: 5px 10px;
                font-size: 0.75rem;
            }

            .download-section {
                padding: 0.875rem;
                gap: 10px;
            }

            .btn-download, .btn-secondary {
                padding: 0.875rem 1rem;
                font-size: 0.8125rem;
            }
        }

        /* Small phones */
        @media (max-width: 400px) {
            .welcome-section h1 {
                font-size: 1rem;
            }

            th:nth-child(4),
            td:nth-child(4),
            th:nth-child(5),
            td:nth-child(5) {
                display: none;
            }
        }

        /* Desktop enhancements */
        @media (min-width: 1200px) {
            .welcome-section h1 {
                font-size: 2rem;
            }

            .welcome-section p {
                font-size: 1.125rem;
            }

            .filter-card {
                padding: 2rem;
                border-radius: var(--radius-xl);
            }

            .table-card {
                border-radius: var(--radius-xl);
            }

            .table-header {
                padding: 1.25rem 1.5rem;
            }
        }

        /* ===== TOUCH IMPROVEMENTS ===== */
        @media (hover: none) and (pointer: coarse) {
            .btn-success:hover,
            .btn-secondary:hover,
            .btn-primary:hover,
            .logout-btn:hover {
                transform: none;
            }

            .btn-success:active,
            .btn-secondary:active,
            .btn-primary:active,
            .logout-btn:active {
                transform: scale(0.98);
            }
        }

        /* ===== ANIMATIONS ===== */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .filter-card, .table-card, .message-box, .download-section {
            animation: fadeIn 0.5s ease-out;
        }

        .table-card {
            animation-delay: 0.1s;
        }

        .download-section {
            animation-delay: 0.2s;
        }
    </style>
<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<div class="defaulter-content">

<div class="container">

    <!-- TOP BAR -->
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Defaulter Management</h1>
            <p>Welcome back, <%= user.getFullName() %>! View and manage attendance defaulters.</p>
        </div>
        <div class="user-info">
            <div class="user-avatar"><%= avatarLetter %></div>
             <div>
                <div style="font-weight:600;color:#1e293b;font-size:0.9rem;"><%=user.getUsername()%></div>
                <div style="font-size:0.8rem;color:#64748b;text-transform: capitalize;"><%=user.getRole()%></div>
            </div>
            <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> <span>Logout</span></button>
        </div>
    </div>

    <!-- FILTER CARD -->
    <div class="filter-card">
        <h2><i class="fas fa-filter"></i> Filter by Class & Date Range</h2>
        
        <!-- Filter Type Toggle -->
        <div class="filter-type-toggle">
            <button type="button" class="filter-type-btn <%= "overall".equals(filterType) ? "active" : "" %>" onclick="setFilterType('overall')">Overall (All Time)</button>
            <button type="button" class="filter-type-btn <%= "custom".equals(filterType) ? "active" : "" %>" onclick="setFilterType('custom')">Custom Date Range</button>
        </div>
        
        <form action="<%=request.getContextPath()%>/teacher/DefaulterListServlet" method="get" class="filter-form" id="filterForm">
            <div class="form-group">
                <label for="class_id">Select Class</label>
                <select name="class_id" id="class_id" required>
                    <option value="">--Select Class--</option>
                    <%
                        try(Connection conn = SQLConnection.getConnection()){
                            ResultSet rs = conn.prepareStatement(
                                "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section"
                            ).executeQuery();

                            while(rs.next()){
                                int id = rs.getInt("class_id");
                                String name = rs.getString("class_name");
                                String sec = rs.getString("section");
                                String selected = (classIdParam != null && classIdParam.equals(String.valueOf(id))) ? "selected" : "";
                    %>
                    <option value="<%= id %>" <%= selected %>><%= name %> - <%= sec %></option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>
            
            <!-- Hidden field for filter type -->
            <input type="hidden" name="filter_type" id="filterType" value="<%= filterType %>">
            
            <!-- Date Range Section -->
            <div class="date-range-section <%= "custom".equals(filterType) ? "active" : "" %>" id="dateRangeSection">
                <div class="form-group">
                    <label for="start_date">Start Date</label>
                    <input type="date" name="start_date" id="start_date" value="<%= startDateParam %>">
                </div>
                <div class="form-group-inline">
                    <span>to</span>
                </div>
                <div class="form-group">
                    <label for="end_date">End Date</label>
                    <input type="date" name="end_date" id="end_date" value="<%= endDateParam %>">
                </div>
            </div>
            
            <button type="submit" class="btn-primary">
                <i class="fas fa-search"></i> Show Defaulters
            </button>
        </form>
    </div>

    <%
        if(classIdParam == null || classIdParam.isEmpty()) {
    %>
    <!-- NO SELECTION MESSAGE -->
    <div class="message-box warning">
        <i class="fas fa-exclamation-triangle"></i>
        <p>Please select a class to view defaulters.</p>
    </div>

    <%
        } else if(defaulters == null || defaulters.isEmpty()) {
    %>
    <!-- NO DATA MESSAGE -->
    <div class="message-box success">
        <i class="fas fa-check-circle"></i>
        <p>No defaulters found for Class <%= className %> - <%= section %>!</p>
    </div>

    <%
        } else {
    %>

    <!-- RESULT TABLE -->
    <div class="table-card">
        <div class="table-header">
            <h2><i class="fas fa-users"></i> Defaulter List</h2>
            <span class="class-info"><%= className %> - <%= section %> (<%= periodDisplay %>)</span>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Roll Number</th>
                        <th>Student Name</th>
                        <th>Present Classes</th>
                        <th>Total Classes</th>
                        <th>Attendance %</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for(Map<String,Object> row : defaulters) {
                            double percentage = (double) row.get("percentage");
                            String percentageClass = "";
                            if(percentage < 75) {
                                percentageClass = "low";
                            } else if(percentage < 85) {
                                percentageClass = "medium";
                            } else {
                                percentageClass = "good";
                            }
                            
                            String fullName = (String) row.get("full_name");
                            String firstLetter = fullName != null && !fullName.isEmpty() ? fullName.substring(0, 1).toUpperCase() : "?";
                    %>
                    <tr>
                        <td><span class="roll-number"><%= row.get("roll_number") %></span></td>
                        <td>
                            <div class="student-info">
                                <div class="student-avatar"><%= firstLetter %></div>
                                <span><%= row.get("full_name") %></span>
                            </div>
                        </td>
                        <td><span class="days-count"><%= row.get("present_classes") %></span></td>
                        <td><span class="days-count"><%= row.get("total_classes") %></span></td>
                        <td>
                            <span class="attendance-percentage <%= percentageClass %>">
                                <%= String.format("%.2f", percentage) %> %
                            </span>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- DOWNLOAD SECTION -->
    <div class="download-section">
        <button type="button"
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
        <form action="<%=request.getContextPath()%>/teacher/DefaulterExcelServlet" method="get" id="downloadForm">
            <input type="hidden" name="class_id" value="<%= classIdParam %>">
            <input type="hidden" name="filter_type" id="downloadFilterType" value="<%= filterType %>">
            <% if ("custom".equals(filterType)) { %>
            <input type="hidden" name="start_date" value="<%= startDateParam %>">
            <input type="hidden" name="end_date" value="<%= endDateParam %>">
            <% } %>
            <button type="submit" class="btn-download">
                <i class="fas fa-file-excel"></i> Download Excel
            </button>
        </form>
    </div>

    <% } %>

</div>

<script>
    function setFilterType(type) {
        document.getElementById('filterType').value = type;
        
        // Update button styles
        document.querySelectorAll('.filter-type-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');
        
        // Show/hide date range section
        const dateRangeSection = document.getElementById('dateRangeSection');
        if (type === 'custom') {
            dateRangeSection.classList.add('active');
        } else {
            dateRangeSection.classList.remove('active');
        }
    }

    function logout() {
        if(confirm('Are you sure you want to logout?')) {
            window.location.href = '<%=request.getContextPath()%>/LogoutServlet';
        }
    }

    function goBack() {
        window.location.href = 'Index.jsp';
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
