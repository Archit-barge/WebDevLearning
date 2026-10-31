<%@page import="com.seh.util.SQLConnection"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="com.seh.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    String role = (String) session.getAttribute("role");

    if (user == null || !"teacher".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String avatarLetter = (user.getFullName() != null && !user.getFullName().isEmpty())
            ? String.valueOf(user.getFullName().charAt(0)).toUpperCase()
            : "A";

    List<Map<String, Object>> announcements = new ArrayList<>();

    try (Connection conn = SQLConnection.getConnection()) {
        String sql = "SELECT a.*, c.class_name, c.section " +
                     "FROM announcements a " +
                     "LEFT JOIN classes c ON a.class_id = c.class_id " +
                     "ORDER BY a.created_at DESC";
                     
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, Object> ann = new HashMap<>();
            ann.put("id", rs.getInt("id"));
            ann.put("title", rs.getString("title"));
            ann.put("description", rs.getString("description"));
            
            String className = rs.getString("class_name");
            String section = rs.getString("section");
            String displayTarget = (className != null) ? className + " - " + section : "General";
            
            ann.put("targetClass", displayTarget);
            announcements.add(ann);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<style>
        /* ===== RESET & BASE STYLES ===== */
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

        .announcements-content {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            padding: 20px;
            color: var(--text-dark);
            background: var(--bg-light);
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        /* ===== CONTAINER ===== */
        .container {
            padding-bottom: 40px;
        }

        /* ===== TOP BAR ===== */
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
            background: #ef4444; color: #fff; border: none;
            padding: 0.75rem 1.5rem; border-radius: 8px;
            cursor: pointer; transition: all 0.3s; font-weight: 500;
        }
        .logout-btn:hover { background: #dc2626; transform: translateY(-1px); }

        /* ===== FORM CARD ===== */
        .form-card {
            background: #fff;
            padding: 2rem;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07);
            margin-bottom: 2rem;
            border: 1px solid #e2e8f0;
        }

        .form-card h2 {
            font-size: 20px;
            color: #1e293b;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .form-card h2 i {
            color: #667eea;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: #475569;
            margin-bottom: 8px;
        }

        .form-control {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 16px;
            color: #1e293b;
            background: #f8fafc;
            transition: all 0.3s ease;
            box-sizing: border-box;
            -webkit-appearance: none;
            appearance: none;
        }

        .form-control:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }

        select.form-control {
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%2364748b' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 16px center;
            padding-right: 40px;
        }

        textarea.form-control {
            resize: vertical;
            min-height: 120px;
            font-family: inherit;
        }

        .char-counter {
            text-align: right;
            font-size: 12px;
            color: #64748b;
            margin-top: 5px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 16px 28px;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            -webkit-tap-highlight-color: transparent;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }

        .btn-primary:active {
            transform: translateY(0);
        }

        /* ===== ANNOUNCEMENTS GRID ===== */
        .announcements-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 20px;
        }

        .announcement-card {
            background: white;
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
        }

        .announcement-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.15);
        }

        .class-badge {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
            font-size: 12px;
            font-weight: 600;
            padding: 6px 14px;
            border-radius: 20px;
            display: inline-block;
            margin-bottom: 15px;
            width: fit-content;
        }

        .announcement-card h3 {
            font-size: 18px;
            color: #1e293b;
            margin-bottom: 10px;
            word-wrap: break-word;
        }

        .announcement-card p {
            color: #64748b;
            font-size: 14px;
            line-height: 1.6;
            flex: 1;
            word-wrap: break-word;
        }

        .card-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #f1f5f9;
            flex-wrap: wrap;
        }

        .btn {
            padding: 10px 16px;
            border: none;
            cursor: pointer;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            transition: all 0.3s ease;
            flex: 1;
            min-width: 80px;
            -webkit-tap-highlight-color: transparent;
        }

        .btn-view { 
            background: #f1f5f9; 
            color: #475569; 
            border: 1px solid #e2e8f0; 
        }
        .btn-view:hover {
            background: #e2e8f0;
        }

        .btn-edit { 
            background: #fef3c7; 
            color: #92400e; 
        }
        .btn-edit:hover {
            background: #fde68a;
        }

        .btn-delete { 
            background: #fee2e2; 
            color: #991b1b; 
        }
        .btn-delete:hover {
            background: #fecaca;
        }

        .btn-delete-form {
            margin: 0;
            padding: 0;
            flex: 1;
            min-width: 80px;
        }

        .btn-delete-form .btn {
            width: 100%;
        }

        /* ===== NO ANNOUNCEMENTS ===== */
        .no-announcements {
            background: white;
            padding: 40px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
        }

        .no-announcements i {
            font-size: 48px;
            color: #cbd5e1;
            margin-bottom: 15px;
        }

        .no-announcements p {
            color: #64748b;
            font-size: 16px;
        }

        /* ===== RESPONSIVE BREAKPOINTS ===== */
        
        /* Large tablets and small desktops */
        @media (max-width: 992px) {
            .top-bar {
                padding: 20px;
            }
            
            .welcome-section h1 {
                font-size: 24px;
            }
        }

        /* Tablets */
        @media (max-width: 768px) {
            .announcements-content {
                padding: 15px;
            }

            .top-bar {
                flex-direction: column;
                gap: 15px;
                text-align: center;
                padding: 20px 15px;
            }

            .welcome-section h1 {
                font-size: 22px;
            }

            .welcome-section p {
                font-size: 13px;
            }

            .user-info {
                flex-direction: column;
                width: 100%;
                gap: 12px;
            }

            .user-details {
                text-align: center;
            }

            .user-details .name {
                max-width: 200px;
            }

            .logout-btn {
                width: 100%;
                justify-content: center;
            }

            .form-card {
                padding: 20px 15px;
            }

            .form-card h2 {
                font-size: 18px;
                justify-content: center;
            }

            .form-control {
                padding: 14px 14px;
                font-size: 16px;
            }

            select.form-control {
                padding-right: 40px;
            }

            .btn-primary {
                padding: 16px 24px;
            }

            .announcements-grid {
                grid-template-columns: 1fr;
            }

            .announcement-card {
                padding: 20px 15px;
            }

            .card-actions {
                flex-direction: row;
            }

            .card-actions .btn {
                flex: 1;
                min-width: 70px;
                padding: 10px 8px;
                font-size: 12px;
            }
        }

        /* Large phones */
        @media (max-width: 576px) {
            .announcements-content {
                padding: 10px;
            }

            .container {
                padding-bottom: 30px;
            }

            .top-bar {
                padding: 15px;
                border-radius: 12px;
                margin-bottom: 20px;
            }

            .welcome-section h1 {
                font-size: 20px;
            }

            .welcome-section p {
                font-size: 12px;
            }

            .user-avatar {
                width: 45px;
                height: 45px;
                font-size: 18px;
            }

            .form-card {
                padding: 15px;
                border-radius: 12px;
                margin-bottom: 20px;
            }

            .form-card h2 {
                font-size: 16px;
                margin-bottom: 15px;
            }

            .form-group {
                margin-bottom: 15px;
            }

            .form-group label {
                font-size: 13px;
            }

            .form-control {
                padding: 12px 14px;
                font-size: 16px;
            }

            textarea.form-control {
                min-height: 100px;
            }

            .btn-primary {
                padding: 14px 20px;
                font-size: 15px;
            }

            .announcements-grid {
                gap: 15px;
            }

            .announcement-card {
                padding: 15px;
                border-radius: 12px;
            }

            .class-badge {
                font-size: 11px;
                padding: 5px 12px;
                margin-bottom: 12px;
            }

            .announcement-card h3 {
                font-size: 16px;
                margin-bottom: 8px;
            }

            .announcement-card p {
                font-size: 13px;
            }

            .card-actions {
                margin-top: 15px;
                padding-top: 12px;
                gap: 8px;
            }

            .card-actions .btn {
                padding: 8px 6px;
                font-size: 11px;
                min-width: 60px;
            }

            .no-announcements {
                padding: 30px 20px;
            }

            .no-announcements i {
                font-size: 40px;
            }

            .no-announcements p {
                font-size: 14px;
            }
        }

        /* Small phones */
        @media (max-width: 400px) {
            .welcome-section h1 {
                font-size: 18px;
            }

            .card-actions {
                flex-direction: column;
            }

            .card-actions .btn {
                width: 100%;
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

        .form-card, .announcement-card {
            animation: fadeIn 0.5s ease-out;
        }

        /* ===== TOUCH IMPROVEMENTS ===== */
        @media (hover: none) and (pointer: coarse) {
            .btn:hover {
                transform: none;
            }
            
            .btn:active {
                opacity: 0.8;
            }

            .announcement-card:hover {
                transform: none;
            }

            .announcement-card:active {
                transform: scale(0.98);
            }

            .logout-btn:hover {
                transform: none;
            }

            .logout-btn:active {
                transform: scale(0.98);
            }

            .btn-primary:hover {
                transform: none;
            }

            .btn-primary:active {
                transform: scale(0.98);
            }
        }
    </style>
</head>
<body>

<div class="container">

    <!-- TOP BAR -->
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Make Announcement</h1>
            <p>Welcome back, <%= user.getUsername() %>! Post announcements for students and parents</p>
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

    <!-- CREATE ANNOUNCEMENT FORM -->
    <div class="form-card">
        <h2><i class="fas fa-bullhorn"></i> Create Announcement</h2>
        <form action="<%=request.getContextPath()%>/teacher/CreateAnnouncementServlet" method="post">
            <div class="form-group">
                <label for="title">Title</label>
                <input type="text" id="title" name="title" class="form-control" placeholder="Enter title" required>
            </div>

            <div class="form-group">
                <label for="classId">Target Class</label>
                <select name="classId" id="classId" class="form-control" required>
                    <option value="">-- Select Class --</option>
                    <%
                        try (Connection conn = SQLConnection.getConnection()) {
                            ResultSet rsClasses = conn.createStatement().executeQuery("SELECT * FROM classes ORDER BY class_name ASC");
                            while(rsClasses.next()) {
                    %>
                        <option value="<%= rsClasses.getInt("class_id") %>">
                            <%= rsClasses.getString("class_name") %> - <%= rsClasses.getString("section") %>
                        </option>
                    <%
                            }
                        } catch(Exception e) {}
                    %>
                </select>
            </div>

            <div class="form-group">
                <label for="description">Description</label>
                <textarea name="description" id="description" rows="4" maxlength="256" class="form-control" placeholder="What's the news?" required></textarea>
                <div class="char-counter"><span id="charCount">0</span> / 256 characters</div>
            </div>
            
            <button type="submit" class="btn-primary">
                <i class="fas fa-paper-plane"></i> Post Announcement
            </button>
        </form>
    </div>

    <!-- ANNOUNCEMENTS LIST -->
    <% if(announcements.isEmpty()) { %>
        <div class="no-announcements">
            <i class="fas fa-bullhorn"></i>
            <p>No announcements yet. Create your first announcement above!</p>
        </div>
    <% } else { %>
        <div class="announcements-grid">
            <% for(Map<String,Object> ann : announcements){ 
                int annId = (Integer) ann.get("id");
                String ctx = request.getContextPath();
            %>
                <div class="announcement-card">
                    <span class="class-badge">
                        <i class="fas fa-users"></i> <%= ann.get("targetClass") %>
                    </span>
                    <h3><%= ann.get("title") %></h3>
                    <p><%= ann.get("description") %></p>
                    
                    <div class="card-actions">
                        <a class="btn btn-view" href="javascript:void(0)" onclick="window.top.location.href='<%=ctx%>/teacher/ViewAnnouncementServlet?id=<%=annId%>'">
                            <i class="fas fa-eye"></i> <span>View</span>
                        </a>
                        <a class="btn btn-edit" href="javascript:void(0)" onclick="window.top.location.href='<%=ctx%>/teacher/EditAnnouncementServlet?id=<%=annId%>'">
                            <i class="fas fa-edit"></i> <span>Edit</span>
                        </a>
                        <form action="<%=request.getContextPath()%>/teacher/DeleteAnnouncementServlet" method="post" onsubmit="return confirm('Delete this announcement?')" class="btn-delete-form">
                            <input type="hidden" name="id" value="<%=ann.get("id")%>">
                            <button type="submit" class="btn btn-delete">
                                <i class="fas fa-trash"></i> <span>Delete</span>
                            </button>
                        </form>
                    </div>
                </div>
            <% } %>
        </div>
    <% } %>

</div>

<script>
    function logout(){
        if(confirm("Are you sure you want to logout?")){
            window.location.href = "<%=request.getContextPath()%>/LogoutServlet";
        }
    }

    // Character counter for description
    document.getElementById('description').addEventListener('input', function() {
        var count = this.value.length;
        document.getElementById('charCount').textContent = count;
    });

    // Prevent zoom on input focus for iOS
    if (/iPad|iPhone|iPod/.test(navigator.userAgent)) {
        var inputs = document.querySelectorAll('input, select, textarea');
        inputs.forEach(function(input) {
            input.addEventListener('focus', function() {
                this.style.fontSize = '16px';
            });
        });
    }
</script>
</div>

