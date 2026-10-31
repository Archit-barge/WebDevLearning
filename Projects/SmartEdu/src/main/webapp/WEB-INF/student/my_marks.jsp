<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<meta charset="UTF-8">
<meta name="description" content="My Marks - View Your Academic Performance">
<title>My Marks</title>

<link rel="preconnect" href="https://cdnjs.cloudflare.com" crossorigin>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

<style>
/* CSS Variables for consistent theming */
:root {
    --primary: #1e40af;
    --primary-light: #3b82f6;
    --primary-dark: #1e3a8a;
    --danger: #ef4444;
    --danger-dark: #dc2626;
    --success: #059669;
    --success-light: #d1fae5;
    --warning: #d97706;
    --warning-light: #fef3c7;
    --text-dark: #1e293b;
    --text-muted: #64748b;
    --bg-light: #f8fafc;
    --white: #ffffff;
    --shadow-sm: 0 4px 15px rgba(0,0,0,0.1);
    --shadow-md: 0 10px 40px rgba(0,0,0,0.15);
    --shadow-lg: 0 20px 50px rgba(0,0,0,0.2);
    --radius-sm: 10px;
    --radius-md: 12px;
    --radius-lg: 16px;
    --radius-xl: 20px;
    --radius-2xl: 24px;
    --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    --touch-target: 48px;
}

/* Reset and base styles */
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
    font-family: 'Outfit', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    min-height: 100vh;
    color: #f1f5f9;
    line-height: 1.6;
    padding: 10px;
    position: relative;
    overflow-x: hidden;
    background: var(--bg-light);
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
}

/* Animated background */
body::before {
    content: '';
    position: fixed;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: 
        radial-gradient(circle at 20% 80%, rgba(59, 130, 246, 0.15) 0%, transparent 50%),
        radial-gradient(circle at 80% 20%, rgba(37, 99, 235, 0.15) 0%, transparent 50%);
    animation: floatBg 15s ease-in-out infinite;
    z-index: -1;
}

@keyframes floatBg {
    0%, 100% { transform: translate(0, 0); }
    50% { transform: translate(2%, 2%); }
}

.container {
    max-width: 1100px;
    margin: 0 auto;
}

/* ===== TOP BAR ===== */
.top-bar {
    width: 100%;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px);
    padding: 20px;
    margin-bottom: 20px;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-md);
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
    animation: slideDown 0.6s ease-out;
    contain: layout style;
    color:black;
}

@keyframes slideDown {
    from { opacity: 0; transform: translateY(-20px); }
    to { opacity: 1; transform: translateY(0); }
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
}

.welcome-section p {
    font-size: clamp(0.8125rem, 2vw, 0.9rem);
    color: var(--text-muted);
    font-weight: 400;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 16px;
}

.user-avatar {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 1.125rem;
    box-shadow: 0 4px 15px rgba(30, 64, 175, 0.3);
}

.user-details {
    text-align: right;
}

.user-name {
    font-weight: 600;
    font-size: 0.9375rem;
    color: var(--text-dark);
}

.user-role {
    font-size: 0.75rem;
    color: var(--text-muted);
    background: var(--bg-light);
    padding: 4px 12px;
    border-radius: 20px;
    display: inline-block;
    margin-top: 2px;
}

.logout-btn {
    background: linear-gradient(135deg, var(--danger) 0%, var(--danger-dark) 100%);
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.875rem;
    cursor: pointer;
    transition: var(--transition);
    display: flex;
    align-items: center;
    gap: 8px;
    box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
    min-height: var(--touch-target);
    will-change: transform, box-shadow;
}

.logout-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4);
}

.logout-btn:active {
    transform: translateY(0);
}

/* Header */
.header {
    display: flex;
    align-items: center;
    margin-bottom: 24px;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px);
    padding: 20px;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-md);
    animation: fadeInUp 0.6s ease-out 0.1s both;
}

@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
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
    box-shadow: 0 6px 20px rgba(30, 64, 175, 0.4);
    flex-shrink: 0;
}

.header-text h4 {
    font-weight: 800;
    font-size: clamp(1.25rem, 3vw, 1.8rem);
    color: var(--text-dark);
    margin-bottom: 2px;
}

.header-text small {
    font-size: clamp(0.8125rem, 2vw, 0.95rem);
    color: var(--text-muted);
    font-weight: 500;
}

/* Table Container - Desktop */
.table-container {
    background: rgba(255, 255, 255, 0.98);
    backdrop-filter: blur(20px);
    border-radius: var(--radius-xl);
    box-shadow: var(--shadow-lg);
    overflow: hidden;
    animation: fadeInUp 0.6s ease-out 0.2s both;
}

.table {
    width: 100%;
    border-collapse: collapse;
    background: transparent;
}

.table thead {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
}

.table th {
    padding: 18px 16px;
    text-align: left;
    font-weight: 700;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: none;
    color: black;
}

.table td {
    padding: 16px;
    border-bottom: 1px solid #e2e8f0;
    transition: all 0.3s ease;
    font-weight: 500;
    color: #334155;
}

.table tbody tr {
    transition: all 0.3s ease;
}

.table tbody tr:hover { 
    background: rgba(59, 130, 246, 0.08); 
    transform: scale(1.005);
}

.table tbody tr:nth-child(even) { 
    background: rgba(59, 130, 246, 0.03); 
}

/* Grade badges */
.grade-excellent { 
    color: var(--success); 
    font-weight: 700; 
    background: var(--success-light);
    padding: 6px 14px;
    border-radius: 8px;
    display: inline-block;
    font-size: 0.9375rem;
}

.grade-good { 
    color: var(--primary); 
    font-weight: 700; 
    background: #e0e7ff;
    padding: 6px 14px;
    border-radius: 8px;
    display: inline-block;
    font-size: 0.9375rem;
}

.grade-average { 
    color: var(--warning); 
    font-weight: 700; 
    background: var(--warning-light);
    padding: 6px 14px;
    border-radius: 8px;
    display: inline-block;
    font-size: 0.9375rem;
}

.grade-poor { 
    color: var(--danger); 
    font-weight: 700; 
    background: #fee2e2;
    padding: 6px 14px;
    border-radius: 8px;
    display: inline-block;
    font-size: 0.9375rem;
}

.subject-cell { 
    font-weight: 600; 
    color: var(--text-dark); 
    font-size: 1rem;
}

.date-cell { 
    color: var(--text-muted); 
    font-size: 0.875rem; 
}

/* No marks */
.no-marks {
    text-align: center;
    padding: 60px 24px;
    color: var(--text-muted);
    font-size: 1.125rem;
    font-weight: 500;
    background: rgba(255, 255, 255, 0.98);
    backdrop-filter: blur(20px);
    border-radius: var(--radius-2xl);
    box-shadow: var(--shadow-lg);
    animation: fadeInUp 0.6s ease-out;
}

.no-marks-icon {
    font-size: 4rem;
    margin-bottom: 16px;
    animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% { transform: scale(1); opacity: 0.8; }
    50% { transform: scale(1.1); opacity: 1; }
}

/* Card layout for mobile */
.marks-cards {
    display: none;
}

.mark-card {
    background: var(--white);
    border-radius: var(--radius-lg);
    padding: 16px;
    margin-bottom: 12px;
    box-shadow: var(--shadow-sm);
    animation: fadeInUp 0.5s ease-out both;
    transition: var(--transition);
    color:black;
}

.mark-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.mark-card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
    padding-bottom: 12px;
    border-bottom: 1px solid #e2e8f0;
}

.mark-card-subject {
    font-weight: 700;
    font-size: 1.0625rem;
    color: var(--text-dark);
}

.mark-card-date {
    font-size: 0.8125rem;
    color: var(--text-muted);
}

.mark-card-scores {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
}

.mark-score-item {
    text-align: center;
    padding: 10px 8px;
    background: var(--bg-light);
    border-radius: var(--radius-sm);
}

.mark-score-label {
    font-size: 0.6875rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--text-muted);
    font-weight: 600;
    margin-bottom: 4px;
}

.mark-score-value {
    font-size: 1.125rem;
    font-weight: 700;
    color: var(--text-dark);
}

.mark-card-average {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid #e2e8f0;
    text-align: center;
}

.mark-card-average .mark-score-label {
    margin-bottom: 0;
}

/* ===== RESPONSIVE ===== */

/* Tablet */
@media (max-width: 1024px) {
    .top-bar {
        padding: 16px;
        color:black;
    }
    
    .header {
        padding: 16px;
    }
    
    .table th, .table td {
        padding: 14px 12px;
    }
}

/* Mobile Landscape */
@media (max-width: 768px) {
    body {
        padding: 8px;
    }
    
    .top-bar {
        flex-direction: column;
        gap: 16px;
        text-align: center;
        padding: 14px;
        border-radius: var(--radius-md);
        margin-bottom: 14px;
    }
    
    .welcome-section {
        min-width: 100%;
    }
    
    .user-info {
        width: 100%;
        justify-content: center;
    }
    
    .user-details {
        display: none;
    }
    
    .logout-btn {
        width: 100%;
        justify-content: center;
        padding: 12px;
    }
    
    .header {
        flex-direction: column;
        text-align: center;
        padding: 14px;
        border-radius: var(--radius-md);
        margin-bottom: 14px;
    }
    
    .header-icon {
        margin-right: 0;
        margin-bottom: 12px;
        width: 48px;
        height: 48px;
        font-size: 1.25rem;
    }
    
    /* Hide table, show cards on mobile */
    .table-container table {
        display: none;
    }
    
    .table-container {
        display: block;
    }
    
    .marks-cards {
        display: block;
    }
    
    .mark-card {
        border-radius: var(--radius-md);
        padding: 14px;
        margin-bottom: 10px;
    }
    
    .mark-card-scores {
        gap: 8px;
    }
    
    .mark-score-item {
        padding: 8px 6px;
    }
    
    .mark-score-value {
        font-size: 1rem;
    }
    
    .no-marks {
        padding: 40px 16px;
        border-radius: var(--radius-lg);
    }
}

/* Mobile Portrait */
@media (max-width: 480px) {
    body {
        padding: 6px;
    }
    
    .top-bar {
        padding: 12px;
        gap: 12px;
        border-radius: var(--radius-sm);
        margin-bottom: 10px;
    }
    
    .welcome-section h1 {
        font-size: 1.125rem;
    }
    
    .welcome-section p {
        font-size: 0.75rem;
    }
    
    .user-avatar {
        width: 38px;
        height: 38px;
        font-size: 0.9375rem;
    }
    
    .logout-btn {
        padding: 10px;
        font-size: 0.8125rem;
        border-radius: var(--radius-sm);
    }
    
    .header {
        padding: 12px;
        margin-bottom: 10px;
        border-radius: var(--radius-sm);
    }
    
    .header-icon {
        width: 42px;
        height: 42px;
        font-size: 1.125rem;
    }
    
    .header-text h4 {
        font-size: 1rem;
    }
    
    .header-text small {
        font-size: 0.75rem;
    }
    
    .mark-card {
        padding: 12px;
        margin-bottom: 8px;
        border-radius: var(--radius-sm);
    }
    
    .mark-card-subject {
        font-size: 0.9375rem;
    }
    
    .mark-card-date {
        font-size: 0.75rem;
    }
    
    .mark-card-scores {
        grid-template-columns: 1fr 1fr 1fr;
        gap: 6px;
    }
    
    .mark-score-item {
        padding: 8px 4px;
    }
    
    .mark-score-label {
        font-size: 0.625rem;
    }
    
    .mark-score-value {
        font-size: 0.9375rem;
    }
    
    .grade-excellent, .grade-good, .grade-average, .grade-poor {
        font-size: 0.8125rem;
        padding: 5px 10px;
    }
    
    .no-marks {
        padding: 30px 14px;
    }
    
    .no-marks-icon {
        font-size: 3rem;
    }
    
    .no-marks p {
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
    
    .header {
        padding: 10px;
    }
    
    .header-icon {
        width: 38px;
        height: 38px;
    }
    
    .header-text h4 {
        font-size: 0.9375rem;
    }
    
    .mark-card-subject {
        font-size: 0.875rem;
    }
    
    .mark-card-scores {
        gap: 4px;
    }
    
    .mark-score-value {
        font-size: 0.875rem;
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
        font-size: 1.0625rem;
    }
    
    .user-avatar {
        width: 52px;
        height: 52px;
        font-size: 1.25rem;
    }
    
    .header {
        padding: 28px 32px;
        border-radius: 24px;
        margin-bottom: 32px;
    }
    
    .header-icon {
        width: 72px;
        height: 72px;
        font-size: 2rem;
        border-radius: var(--radius-lg);
        margin-right: 24px;
    }
    
    .header-text h4 {
        font-size: 2rem;
    }
    
    .header-text small {
        font-size: 1.0625rem;
    }
    
    .table-container {
        border-radius: 24px;
    }
    
    .table th {
        padding: 22px 20px;
        font-size: 13px;
    }
    
    .table td {
        padding: 20px;
    }
    
    .subject-cell {
        font-size: 1.125rem;
    }
    
    .mark-card {
        padding: 24px;
        border-radius: 20px;
        margin-bottom: 16px;
    }
    
    .mark-card-subject {
        font-size: 1.25rem;
    }
    
    .no-marks {
        padding: 80px 40px;
        border-radius: 28px;
    }
    
    .no-marks-icon {
        font-size: 5rem;
    }
}

/* Touch feedback for mobile */
@media (hover: none) {
    .table tbody tr:hover { 
        background: rgba(59, 130, 246, 0.03); 
        transform: none;
    }
    
    .mark-card:hover {
        transform: none;
    }
    
    .logout-btn:hover {
        transform: none;
        box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
    }
}
</style>
</head>
<body>

<%
    com.seh.model.User user = (com.seh.model.User) session.getAttribute("user");
    String avatarLetter = "A";
    if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }
%>

<div class="container">

    <!-- ===== TOP BAR ===== -->
     <div class="top-bar">
		<div class="welcome-section">
			<h2>
				Welcome,
				<%=user.getFullName()%></h2>
			<p>Here's what's happening today</p>
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

    <div class="header">
        <div class="header-icon">🎓</div>
        <div class="header-text">
            <h4>My Marks</h4>
            <small>View Your Academic Performance</small>
        </div>
    </div>

<%
    List<Map<String, Object>> marksList =
            (List<Map<String, Object>>) request.getAttribute("marksList");

    if (marksList != null && !marksList.isEmpty()) {
%>

    <!-- Desktop Table View -->
    <div class="table-container">
        <table class="table">
            <thead>
                <tr>
                    <th>Subject</th>
                    <th>UT1</th>
                    <th>UT2</th>
                    <th>Average</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
                <%
                    int rowIndex = 0;
                    for (Map<String, Object> row : marksList) {
                        rowIndex++;
                        int ut1 = row.get("ut1") != null ? (int) row.get("ut1") : 0;
                        int ut2 = row.get("ut2") != null ? (int) row.get("ut2") : 0;
                        float avg = row.get("average") != null ? (float) row.get("average") : 0;

                        String gradeClass = "";
                        if (avg >= 85) gradeClass = "grade-excellent";
                        else if (avg >= 75) gradeClass = "grade-good";
                        else if (avg >= 60) gradeClass = "grade-average";
                        else gradeClass = "grade-poor";
                %>
                <tr style="animation-delay: <%=rowIndex * 0.05%>s">
                    <td class="subject-cell"><%= row.get("subject_name") %></td>
                    <td><%= ut1 %></td>
                    <td><%= ut2 %></td>
                    <td class="<%= gradeClass %>"><%= String.format("%.2f", avg) %></td>
                    <td class="date-cell"><%= row.get("created_at") %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>

        <!-- Mobile Card View -->
    <div class="marks-cards">
        <%
            int cardIndex = 0;
            for (Map<String, Object> row : marksList) {
                cardIndex++;
                int ut1 = row.get("ut1") != null ? (int) row.get("ut1") : 0;
                int ut2 = row.get("ut2") != null ? (int) row.get("ut2") : 0;
                float avg = row.get("average") != null ? (float) row.get("average") : 0;

                String gradeClass = "";
                if (avg >= 85) gradeClass = "grade-excellent";
                else if (avg >= 75) gradeClass = "grade-good";
                else if (avg >= 60) gradeClass = "grade-average";
                else gradeClass = "grade-poor";
        %>
        <div class="mark-card" style="animation-delay: <%=cardIndex * 0.05%>s">
            <div class="mark-card-header">
                <div class="mark-card-label">Subject:</div>
                <div class="mark-card-subject"><%= row.get("subject_name") %></div>
                <div class="mark-card-date"><%= row.get("created_at") %></div>
            </div>
            <div class="mark-card-scores">
                <div class="mark-score-item">
                    <div class="mark-score-label">Unit Test 1:</div>
                    <div class="mark-score-value"><%= ut1 %></div>
                </div>
                <div class="mark-score-item">
                    <div class="mark-score-label">Unit Test 2:</div>
                    <div class="mark-score-value"><%= ut2 %></div>
                </div>
                <div class="mark-score-item">
                    <div class="mark-score-label">Average:</div>
                    <div class="mark-score-value <%= gradeClass %>"><%= String.format("%.1f", avg) %></div>
                </div>
            </div>
            <div class="mark-card-average">
                <span class="mark-score-label">Final Average:</span>
                <span class="<%= gradeClass %>"><%= String.format("%.2f", avg) %></span>
            </div>
        </div>
        <% } %>
    </div>

<% } else { %>

<div class="no-marks">
    <div class="no-marks-icon">📊</div>
    <p>No marks available yet.</p>
</div>

<% } %>

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
