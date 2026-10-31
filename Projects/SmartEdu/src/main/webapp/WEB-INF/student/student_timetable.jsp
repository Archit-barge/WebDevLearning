<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.seh.model.User" %>

<%
    /* ================= SESSION CHECK ================= */
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("student")) {
        response.sendRedirect("../login.jsp");
        return;
    }

    /* GET USER OBJECT */
    User user = (User) session.getAttribute("user");
    String avatarLetter = "A";
    if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }

    /* GET TIMETABLE DATA FROM SERVLET */
    List<Map<String,Object>> timetables = (List<Map<String,Object>>) request.getAttribute("timetables");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>My Timetables | Smart College</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
    --primary: #4f46e5;
    --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
    
    /* ADD THESE TWO LINES */
    --danger: #ef4444; 
    --danger-dark: #dc2626;
    
    --bg-light: #f8fafc;
    --white: #ffffff;
    --radius-lg: 16px;
    --radius-md: 12px;
    --radius-sm: 8px; /* For the button corners */
    --shadow-md: 0 5px 15px rgba(0,0,0,0.1);
    --transition: all 0.3s ease;
}

        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family: 'Inter', sans-serif; background: var(--bg-light); padding: 16px; color: var(--text-dark); }
        .container { max-width: 1200px; margin: 0 auto; }

        /* Top Bar */
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
        .welcome-section h1 { font-size: 1.5rem; font-weight: 700; }
        .welcome-section p { color: var(--text-muted); font-size: 0.9rem; }
        
        .user-info { display: flex; align-items: center; gap: 12px; }
        .user-avatar { width: 45px; height: 45px; border-radius: 50%; background: var(--primary-gradient); color: white; display: flex; align-items: center; justify-content: center; font-weight: 700; }
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

        /* Grid */
        .cards-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; }
        .card { background: var(--white); padding: 20px; border-radius: var(--radius-lg); box-shadow: var(--shadow-md); transition: var(--transition); animation: fadeInUp 0.4s ease-out both; }
        .card:hover { transform: translateY(-5px); }
        
        .card-header { display: flex; justify-content: space-between; margin-bottom: 12px; }
        .card-title { font-weight: 700; color: var(--primary); }
        .card-date { font-size: 0.8rem; color: var(--text-muted); }

        .file-info { display: flex; justify-content: space-between; align-items: center; padding-bottom: 10px; border-bottom: 1px solid #f1f5f9; margin-bottom: 15px; }
        .file-name { font-weight: 600; font-size: 0.85rem; color: var(--text-dark); max-width: 70%; overflow: hidden; text-overflow: ellipsis; }
        
        /* Media Container */
        .embed-container {
            width: 100%; height: 250px; border-radius: var(--radius-md); 
            background: #f1f5f9; border: 1px solid #e2e8f0; object-fit: cover;
            cursor: pointer; transition: var(--transition);
        }
        .embed-container:hover { opacity: 0.9; border-color: var(--primary); }

        /* Lightbox */
        .lightbox {
            display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.9);
            z-index: 9999; justify-content: center; align-items: center; padding: 20px;
        }
        .lightbox.active { display: flex; }
        .lightbox-wrapper { 
            width: 90%; max-width: 1000px; height: 85vh; background: white; 
            border-radius: 12px; display: flex; flex-direction: column; overflow: hidden; 
        }
        .lightbox-header { 
            padding: 15px 20px; background: var(--primary); color: white; 
            display: flex; justify-content: space-between; align-items: center; 
        }
        .lightbox-body { flex: 1; display: flex; align-items: center; justify-content: center; background: #000; overflow: hidden; }
        .lightbox-img { max-width: 100%; max-height: 100%; object-fit: contain; }
        .close-modal { font-size: 1.5rem; cursor: pointer; }
        
        .btn-dl { 
            padding: 6px 12px; background: rgba(255,255,255,0.2); border-radius: 6px; 
            color: white; text-decoration: none; font-size: 0.8rem; font-weight: 600; 
        }

        .empty-state { text-align: center; padding: 60px; background: white; border-radius: 16px; }

        @keyframes fadeInUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
        
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
    <div class="top-bar">
        <div class="welcome-section">
            <h1>My Timetables</h1>
            <p>Welcome, <strong><%= user.getFullName() %></strong></p>
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

    <% if(timetables == null || timetables.isEmpty()){ %>
        <div class="empty-state">
            <i class="fas fa-calendar-times" style="font-size: 3rem; color: #cbd5e1; margin-bottom: 1rem;"></i>
            <h3>No Timetable Available</h3>
            <p style="color: var(--text-muted);">Your department hasn't uploaded a schedule yet.</p>
        </div>
    <% } else { %>
        <div class="cards-container">
            <% 
            int idx = 0;
            for(Map<String,Object> t : timetables){ 
                String fileUrl = (String)t.get("file");
                String fileName = (String)t.get("fileName");
                String type = (String)t.get("type");
                if(type == null) type = "other";
            %>
            <div class="card" style="animation-delay: <%= idx * 0.1 %>s">
                <div class="card-header">
                    <span class="card-title"><i class="fas fa-calendar-alt"></i> Schedule</span>
                    <span class="card-date"><%= t.get("date") %></span>
                </div>
                <div class="file-info">
                    <span class="file-name"><%= fileName %></span>
                    <span style="font-size: 0.7rem; font-weight: 700; text-transform: uppercase; color: var(--primary);"><%= type %></span>
                </div>

                <% if("image".equals(type)) { %>
                    <img src="<%= fileUrl %>" class="embed-container" onclick="openModal('<%= fileUrl %>', '<%= fileName %>')" alt="Timetable">
                <% } else if("pdf".equals(type)) { %>
                    <embed src="<%= fileUrl %>" class="embed-container" type="application/pdf">
                <% } else { %>
                    <div class="embed-container" style="display: flex; align-items: center; justify-content: center; flex-direction: column; gap: 10px;">
                        <i class="fas fa-file-download" style="font-size: 2rem; color: var(--text-muted);"></i>
                        <a href="<%= fileUrl %>" target="_blank" style="color: var(--primary); font-weight: 600; text-decoration: none;">Download File</a>
                    </div>
                <% } %>
            </div>
            <% idx++; } %>
        </div>
    <% } %>
</div>

<div class="lightbox" id="imgModal" onclick="closeModal(event)">
    <div class="lightbox-wrapper">
        <div class="lightbox-header">
            <span id="modalTitle" style="font-weight: 600; font-size: 0.9rem;">View Timetable</span>
            <div style="display: flex; gap: 15px; align-items: center;">
                <a href="#" id="modalDl" class="btn-dl" download><i class="fas fa-download"></i> Download</a>
                <span class="close-modal" onclick="closeModalBtn()">&times;</span>
            </div>
        </div>
        <div class="lightbox-body">
            <img src="" id="modalImg" class="lightbox-img">
        </div>
    </div>
</div>

<script>
    function logout(){
        if(confirm('Are you sure you want to logout?')) {
            window.location.href="<%=request.getContextPath()%>/LogoutServlet";
        }
    }

    function openModal(url, name) {
        const modal = document.getElementById('imgModal');
        const img = document.getElementById('modalImg');
        const title = document.getElementById('modalTitle');
        const dl = document.getElementById('modalDl');

        img.src = url;
        title.innerText = name;
        dl.href = url;
        
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function closeModalBtn() {
        document.getElementById('imgModal').classList.remove('active');
        document.body.style.overflow = '';
    }

    function closeModal(e) {
        if(e.target.classList.contains('lightbox') || e.target.classList.contains('lightbox-body')) {
            closeModalBtn();
        }
    }

    // Keyboard support
    document.addEventListener('keydown', (e) => {
        if(e.key === 'Escape') closeModalBtn();
    });
</script>

</body>
</html>