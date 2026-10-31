<%@ page import="java.util.*" %>
<%@ page import="com.seh.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
/* ================= SESSION + USER FIX ================= */

User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
String role = (String) session.getAttribute("role");

if(user == null || role == null || !role.equals("student")){
    response.sendRedirect("../login.jsp");
    return;
}
/* ====================================================== */
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<meta charset="UTF-8">
<meta name="description" content="Student Attendance Dashboard - View your attendance records">
<title>Student Attendance Dashboard</title>

<link rel="preconnect" href="https://cdnjs.cloudflare.com" crossorigin>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap" rel="stylesheet">

<style>
/* CSS Variables for consistent theming */
:root {
    --primary: #4f46e5;
    --primary-light: #667eea;
    --primary-dark: #3730a3;
    --danger: #dc3545;
    --danger-dark: #b02a37;
    --success: #16a34a;
    --warning: #f59e0b;
    --text-dark: #1e293b;
    --text-muted: #64748b;
    --bg-light: #f8fafc;
    --white: #ffffff;
    --shadow-sm: 0 5px 15px rgba(0,0,0,0.1);
    --shadow-md: 0 10px 30px rgba(0,0,0,0.1);
    --shadow-lg: 0 20px 40px rgba(0,0,0,0.15);
    --radius-sm: 10px;
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

body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    min-height: 100vh;
    color: #333;
    line-height: 1.6;
    padding: 10px;
    background: var(--bg-light);
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
}

.container { 
    max-width: 1200px; 
    margin: 0 auto; 
}

/* Top Bar */
.top-bar {
    background: var(--white);
    backdrop-filter: blur(15px);
    border-radius: var(--radius-xl);
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: var(--shadow-md);
    border: 1px solid rgba(255, 255, 255, 0.2);
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
    animation: fadeInUp 0.5s ease-out;
    contain: layout style;
}

.welcome-section {
    flex: 1;
    min-width: 200px;
}

.welcome-section h1 {
    font-size: clamp(1.25rem, 4vw, 1.8rem);
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 4px;
    line-height: 1.2;
}

.welcome-section p {
    color: var(--text-muted);
    font-size: clamp(0.875rem, 2.5vw, 1rem);
    font-weight: 500;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 12px;
}

.user-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 1rem;
}

.user-details {
    display: flex;
    flex-direction: column;
}

.user-name {
    font-weight: 600;
    color: var(--text-dark);
    font-size: 0.9375rem;
}

.user-role {
    font-size: 0.8125rem;
    color: var(--text-muted);
}

.logout-btn {
    padding: 12px 20px;
    border: none;
    background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
    color: white;
    border-radius: var(--radius-sm);
    cursor: pointer;
    font-weight: 600;
    font-size: 14px;
    transition: var(--transition);
    min-height: var(--touch-target);
    display: flex;
    align-items: center;
    gap: 8px;
    will-change: transform, box-shadow;
}

.logout-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(220, 53, 69, 0.4);
}

.logout-btn:active {
    transform: translateY(0);
}

/* Overall Attendance Card */
.overall-card {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
    color: #fff;
    text-align: center;
    padding: 30px 20px;
    margin-bottom: 24px;
    border-radius: var(--radius-xl);
    box-shadow: var(--shadow-lg);
    animation: fadeInUp 0.5s ease-out 0.1s both;
}

.overall-card h2 {
    font-size: clamp(1.125rem, 3vw, 1.5rem);
    margin-bottom: 16px;
    font-weight: 700;
}

.overall-percentage {
    font-size: clamp(2.5rem, 8vw, 4rem);
    font-weight: 900;
    line-height: 1;
    margin-bottom: 16px;
}

.overall-stats {
    display: flex;
    justify-content: center;
    gap: 24px;
    flex-wrap: wrap;
    font-size: clamp(0.875rem, 2.5vw, 1rem);
}

.overall-stats p {
    margin: 4px 0;
}

.stats-divider {
    width: 1px;
    background: rgba(255,255,255,0.3);
}

/* Section Title */
h2.section-title {
    font-size: clamp(1.125rem, 3vw, 1.5rem);
    color: var(--text-dark);
    margin-bottom: 16px;
    font-weight: 700;
}

/* Card Container - Responsive Grid */
.card-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
}

/* Individual Card */
.card {
    background: var(--white);
    border-radius: var(--radius-lg);
    padding: 20px;
    box-shadow: var(--shadow-sm);
    transition: var(--transition);
    animation: fadeInUp 0.5s ease-out both;
    contain: layout style paint;
}

.card:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-lg);
}

.card:active {
    transform: scale(0.98);
}

.card h3 {
    font-size: clamp(1rem, 2.5vw, 1.25rem);
    color: var(--text-dark);
    margin-bottom: 12px;
    font-weight: 700;
}

.card p {
    color: var(--text-muted);
    font-size: 0.875rem;
    margin: 6px 0;
    font-weight: 500;
}

/* Percentage Bar */
.percentage-bar {
    height: 20px;
    border-radius: 10px;
    background: #e5e7eb;
    overflow: hidden;
    margin-top: 16px;
    position: relative;
}

.percentage-fill {
    height: 100%;
    border-radius: 10px;
    text-align: center;
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    line-height: 20px;
    transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
    min-width: fit-content;
    padding: 0 8px;
    white-space: nowrap;
}

.percentage-fill[data-perc="excellent"] { 
    background: linear-gradient(90deg, #16a34a, #22c55e); 
}

.percentage-fill[data-perc="good"] { 
    background: linear-gradient(90deg, var(--primary), var(--primary-light)); 
}

.percentage-fill[data-perc="average"] { 
    background: linear-gradient(90deg, #f59e0b, #fbbf24); 
}

.percentage-fill[data-perc="poor"] { 
    background: linear-gradient(90deg, #dc2626, #ef4444); 
}

/* No Records */
.no-records {
    background: var(--white);
    border-radius: var(--radius-xl);
    padding: 40px 20px;
    text-align: center;
    box-shadow: var(--shadow-sm);
    animation: fadeInUp 0.5s ease-out;
}

.no-records p {
    color: var(--text-muted);
    font-size: 1rem;
    font-weight: 500;
}

/* Animation */
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

/* Tablet */
@media (max-width: 1024px) {
    .top-bar {
        padding: 16px;
        margin-bottom: 16px;
    }
    
    .card-container {
        gap: 16px;
    }
    
    .overall-card {
        padding: 24px 16px;
        margin-bottom: 20px;
    }
}

/* Mobile Landscape */
@media (max-width: 768px) {
    body {
        padding: 8px;
    }
    
    .top-bar {
        padding: 14px;
        border-radius: var(--radius-lg);
        margin-bottom: 14px;
    }
    
    .welcome-section {
        min-width: 100%;
    }
    
    .welcome-section h1 {
        font-size: 1.25rem;
    }
    
    .user-info {
        width: 100%;
        justify-content: space-between;
    }
    
    .user-details {
        display: none;
    }
    
    .logout-btn {
        padding: 10px 16px;
        font-size: 13px;
    }
    
    .overall-card {
        padding: 20px 14px;
        margin-bottom: 16px;
        border-radius: var(--radius-lg);
    }
    
    .overall-percentage {
        font-size: 2.5rem;
    }
    
    .overall-stats {
        gap: 16px;
    }
    
    .stats-divider {
        display: none;
    }
    
    .card-container {
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 12px;
    }
    
    .card {
        padding: 16px;
        border-radius: var(--radius-md);
    }
    
    .percentage-bar {
        height: 18px;
        margin-top: 12px;
    }
    
    .percentage-fill {
        font-size: 10px;
        line-height: 18px;
    }
}

/* Mobile Portrait */
@media (max-width: 480px) {
    body {
        padding: 6px;
    }
    
    .top-bar {
        flex-direction: column;
        text-align: center;
        padding: 12px;
        gap: 12px;
        border-radius: var(--radius-md);
        margin-bottom: 10px;
    }
    
    .welcome-section {
        min-width: 100%;
    }
    
    .welcome-section h1 {
        font-size: 1.125rem;
    }
    
    .welcome-section p {
        font-size: 0.8125rem;
    }
    
    .user-info {
        width: 100%;
        justify-content: center;
        gap: 10px;
    }
    
    .user-avatar {
        width: 36px;
        height: 36px;
        font-size: 0.875rem;
    }
    
    .logout-btn {
        width: 100%;
        justify-content: center;
        padding: 12px;
        border-radius: var(--radius-sm);
    }
    
    .overall-card {
        padding: 16px 12px;
        margin-bottom: 12px;
        border-radius: var(--radius-md);
    }
    
    .overall-card h2 {
        font-size: 1rem;
        margin-bottom: 12px;
    }
    
    .overall-percentage {
        font-size: 2rem;
        margin-bottom: 12px;
    }
    
    .overall-stats {
        font-size: 0.8125rem;
        gap: 12px;
    }
    
    h2.section-title {
        font-size: 1rem;
        margin-bottom: 12px;
    }
    
    .card-container {
        grid-template-columns: 1fr;
        gap: 10px;
    }
    
    .card {
        padding: 14px;
        border-radius: var(--radius-sm);
    }
    
    .card h3 {
        font-size: 1rem;
        margin-bottom: 10px;
    }
    
    .card p {
        font-size: 0.8125rem;
        margin: 4px 0;
    }
    
    .percentage-bar {
        height: 16px;
        margin-top: 10px;
        border-radius: 8px;
    }
    
    .percentage-fill {
        font-size: 9px;
        line-height: 16px;
        border-radius: 8px;
    }
    
    .no-records {
        padding: 30px 16px;
        border-radius: var(--radius-md);
    }
    
    .no-records p {
        font-size: 0.9375rem;
    }
}

/* Small Mobile */
@media (max-width: 360px) {
    .top-bar {
        padding: 10px;
    }
    
    .welcome-section h1 {
        font-size: 1rem;
    }
    
    .overall-card {
        padding: 14px 10px;
    }
    
    .overall-percentage {
        font-size: 1.75rem;
    }
    
    .overall-stats {
        font-size: 0.75rem;
    }
    
    .card {
        padding: 12px;
    }
}

/* Large Desktop */
@media (min-width: 1200px) {
    body {
        padding: 24px;
    }
    
    .top-bar {
        padding: 28px 32px;
        border-radius: 24px;
        margin-bottom: 28px;
    }
    
    .welcome-section h1 {
        font-size: 2rem;
    }
    
    .welcome-section p {
        font-size: 1.125rem;
    }
    
    .overall-card {
        padding: 40px 32px;
        margin-bottom: 32px;
        border-radius: 24px;
    }
    
    .overall-card h2 {
        font-size: 1.75rem;
    }
    
    .overall-percentage {
        font-size: 4.5rem;
    }
    
    .overall-stats {
        font-size: 1.125rem;
    }
    
    .card-container {
        gap: 24px;
    }
    
    .card {
        padding: 28px;
        border-radius: 20px;
    }
    
    .card h3 {
        font-size: 1.375rem;
    }
    
    .percentage-bar {
        height: 24px;
        margin-top: 20px;
    }
    
    .percentage-fill {
        font-size: 13px;
        line-height: 24px;
    }
}

/* Touch feedback for mobile */
@media (hover: none) {
    .card:hover {
        transform: none;
    }
    
    .logout-btn:hover {
        transform: none;
        box-shadow: none;
    }
}
</style>
</head>

<body>

<div class="container">

<!-- TOP BAR -->

<div class="top-bar">
		<div class="welcome-section">
			<h1>View Attendance</h1>
        	<p>Welcome back, <%=user.getFullName()%></p>
		</div>
		<div class="user-info">
			<div class="user-avatar"><%=avatarLetter%></div>
			<div >
                <div style="font-weight: 700; font-size: 0.85rem;"><%= user.getUsername() %></div>
                <div style="font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase;"><%= user.getRole() %></div>
            </div>
			<button class="logout-btn" onclick="logout()">
				<i class="fas fa-sign-out-alt"></i> Logout
			</button>
		</div>
	</div>

<!-- OVERALL ATTENDANCE -->
<div class="overall-card">
    <h2>Overall Attendance</h2>

    <%
    int total = 0, present = 0, absent = 0;

    Object totalObj = request.getAttribute("total_classes");
    Object presentObj = request.getAttribute("total_present");
    Object absentObj = request.getAttribute("total_absent");

    if(totalObj != null) total = ((Number) totalObj).intValue();
    if(presentObj != null) present = ((Number) presentObj).intValue();
    if(absentObj != null) absent = ((Number) absentObj).intValue();

    double perc = (total > 0) ? (present * 100.0 / total) : 0;
    %>

    <div class="overall-percentage"><%= String.format("%.2f%%", perc) %></div>
    
    <div class="overall-stats">
        <p>Total Classes: <%= total %></p>
        <span class="stats-divider"></span>
        <p>Present: <%= present %></p>
        <span class="stats-divider"></span>
        <p>Absent: <%= absent %></p>
    </div>

</div>

<h2 class="section-title">Subject-wise Attendance</h2>

<div class="card-container">

<%
List<Map<String, Object>> list =
(List<Map<String, Object>>) request.getAttribute("subjectAttendance");

if(list != null && !list.isEmpty()){

    int cardIndex = 0;
    for(Map<String, Object> row : list){
        cardIndex++;
        
        int totalCls = row.get("total_classes") != null ?
        ((Number)row.get("total_classes")).intValue() : 0;

        int pres = row.get("total_present") != null ?
        ((Number)row.get("total_present")).intValue() : 0;

        int abs = row.get("total_absent") != null ?
        ((Number)row.get("total_absent")).intValue() : 0;

        double percSub = totalCls > 0 ? (pres * 100.0 / totalCls) : 0;

        String dataPerc="";
        if(percSub >= 85) dataPerc="excellent";
        else if(percSub >= 75) dataPerc="good";
        else if(percSub >= 60) dataPerc="average";
        else dataPerc="poor";
%>

    <div class="card" style="animation-delay: <%=cardIndex * 0.05%>s">
        <h3><%= row.get("subject_name") %></h3>
        <p>Total Classes: <%= totalCls %></p>
        <p>Present: <%= pres %> | Absent: <%= abs %></p>

        <div class="percentage-bar">
            <div class="percentage-fill"
            data-perc="<%= dataPerc %>"
            style="width:<%= Math.min(percSub, 100) %>%;">
            <%= String.format("%.1f%%", percSub) %>
            </div>
        </div>
    </div>

<%
    }
}else{
%>

    <div class="no-records">
        <p>No attendance records found.</p>
    </div>

<%
}
%>

</div>
</div>

<script>
function logout(){
    if(confirm('Are you sure you want to logout?')) {
        window.location.href="<%=request.getContextPath()%>/LogoutServlet";
    }
}

// Prevent double-tap zoom on mobile
document.addEventListener('dblclick', function(event) {
    event.preventDefault();
}, { passive: false });
</script>

</body>
</html>
