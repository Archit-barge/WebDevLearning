
<%@ page import="com.seh.model.User" %>

<%
User user = (User) session.getAttribute("user");

if(user == null){
    response.sendRedirect(request.getContextPath()+"/login.jsp");
    return;
}

String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
    avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
<title>Result Analysis - Eduverse</title>
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
    background: var(--bg-light);
}

/* ===== CONTAINER ===== */
.container { max-width: 1400px; margin: 0 auto; padding-bottom: 40px; }

/* ===== TOP BAR (EnterMarks Style) ===== */
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
.user-info { margin-left: auto; display: flex; align-items: center; gap: 12px; flex-shrink: 0; }

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

/* ===== CONTENT CARDS ===== */
.content-section { display: flex; flex-direction: column; gap: 24px; }

.card {
    background: var(--white);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-md);
    overflow: hidden;
    border: 1px solid #e2e8f0;
}
.card-header {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    padding: 20px 24px;
    color: var(--white);
}
.card-header h2 {
    font-size: clamp(1.1rem, 3vw, 1.3rem);
    display: flex;
    align-items: center;
    gap: 12px;
    font-weight: 600;
}
.card-body { padding: 24px; }

/* ===== LINK SECTION ===== */
.link-section {
    background: var(--bg-light);
    padding: 20px 24px;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
}
.link-info {
    display: flex;
    align-items: center;
    gap: 12px;
    color: var(--text-dark);
    font-weight: 500;
}
.link-info i { font-size: 1.25rem; color: var(--primary); width: 24px; }

.link-btn {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: var(--white);
    border: none;
    padding: 12px 24px;
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    font-size: 0.95rem;
    display: flex;
    align-items: center;
    gap: 10px;
    transition: var(--transition);
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
    text-decoration: none;
    min-height: var(--touch-target);
}
.link-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4); }

/* ===== IFRAME CONTAINER ===== */
.iframe-container {
    position: relative;
    height: 70vh;
    min-height: 500px;
    border-radius: var(--radius-md);
    overflow: hidden;
    box-shadow: inset 0 2px 8px rgba(0,0,0,0.1);
}
.iframe-container iframe {
    width: 100%;
    height: 100%;
    border: none;
    display: block;
}

/* ===== RESPONSIVE BREAKPOINTS ===== */
@media (max-width: 992px) {
    .top-bar { padding: 18px; }
    .welcome-section h1 { font-size: 20px; }
    .top-bar-row { flex-direction: column; gap: 16px; }
}

@media (max-width: 768px) {
    body { padding: 12px; }
    .top-bar { 
        flex-direction: column; 
        gap: 16px; 
        padding: 16px; 
        text-align: center; 
    }
    .user-info { 
        flex-direction: column; 
        width: 100%; 
        gap: 12px; 
    }
    .user-details { text-align: center; }
    .logout-btn { width: 100%; justify-content: center; }
    .card-body { padding: 20px; }
    .link-section { flex-direction: column; align-items: stretch; gap: 16px; text-align: center; }
    .link-btn { width: 100%; justify-content: center; }
    .iframe-container { height: 60vh; }
}

@media (max-width: 576px) {
    .top-bar { padding: 14px; border-radius: var(--radius-md); }
    .card { border-radius: var(--radius-md); }
    .card-header, .card-body { padding: 16px; }
    .iframe-container { height: 50vh; min-height: 400px; }
}

@media (max-width: 400px) {
    .iframe-container { height: 45vh; }
}

/* ===== TOUCH IMPROVEMENTS ===== */
@media (hover: none) and (pointer: coarse) {
    .btn-primary:hover, .logout-btn:hover, .link-btn:hover { transform: none; }
    .btn-primary:active, .logout-btn:active, .link-btn:active { transform: scale(0.98); }
}

/* ===== ANIMATIONS ===== */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}
.card { animation: fadeIn 0.5s ease-out; }
</style>
</head>
<body>

<div class="container">

<!-- TOP BAR (EnterMarks Style) -->
<div class="top-bar">
    <div class="welcome-section">
        <h1><i class="fas fa-clipboard-list"></i> Result Analysis</h1>
        <p>Welcome back, <%= user.getUsername() %>! Record student performance</p>
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

<!-- CONTENT -->
<div class="card">
    <div class="card-header">
        <h2><i class="fas fa-external-link-alt"></i> MSBTE Result Analyzer</h2>
    </div>
    <div class="card-body">
        <div class="link-section">
            <div class="link-info">
                <i class="fas fa-globe"></i>
                <span>External Tool - Opens in new tab</span>
            </div>
            <a href="https://msbte-result-analyzer-psi.vercel.app/" target="_blank" rel="noopener" class="link-btn">
                <i class="fas fa-external-link-alt"></i>
                Open Analyzer
            </a>
        </div>
        <div class="iframe-container">
            <iframe 
                src="https://msbte-result-analyzer-psi.vercel.app/" 
                title="MSBTE Result Analyzer"
                allowfullscreen
                loading="lazy">
            </iframe>
        </div>
    </div>
</div>

</div>

<script>
function goBack() { window.history.back(); }
</script>

</body>
</html>
