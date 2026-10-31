<%@ page import="java.util.*" %>
<%@ page import="com.seh.model.User" %>

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
/* GET TIMETABLE DATA */
List<Map<String,Object>> timetables =
(List<Map<String,Object>>) request.getAttribute("timetables");
%>

<!DOCTYPE html>
<html>
<head>
<title>My Timetables</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta charset="UTF-8">

<style>
*{
margin:0;
padding:0;
box-sizing:border-box;
}

:root {
    --primary: #4f46e5;
    --primary-light: #667eea;
    --danger: #dc3545;
    --text-dark: #1e293b;
    --text-muted: #64748b;
    --bg-light: #f8fafc;
    --white: #ffffff;
    --shadow-sm: 0 2px 8px rgba(0,0,0,0.1);
    --shadow-md: 0 5px 15px rgba(0,0,0,0.1);
    --shadow-lg: 0 15px 30px rgba(0,0,0,0.2);
    --radius-sm: 8px;
    --radius-md: 12px;
    --radius-lg: 16px;
    --radius-xl: 20px;
    --transition: all 0.3s ease;
    --touch-target: 48px;
}

html {
    -webkit-text-size-adjust: 100%;
    -webkit-tap-highlight-color: transparent;
}

body{
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
background:var(--bg-light);
padding: 16px;
min-height: 100vh;
-webkit-font-smoothing: antialiased;
}

.container{
max-width: 1400px;
margin: 0 auto;
}

/* Top Bar */
.top-bar{
display:flex;
justify-content:space-between;
align-items:center;
margin-bottom: 24px;
background: var(--white);
padding: 20px;
border-radius: var(--radius-xl);
box-shadow: var(--shadow-md);
flex-wrap: wrap;
gap: 16px;
contain: layout style;
}

.welcome-section{
flex: 1;
min-width: 200px;
}

.welcome-section h1 {
    font-size: clamp(1.25rem, 3vw, 1.75rem);
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 4px;
}

.welcome-section p {
    color: var(--text-muted);
    font-size: clamp(0.875rem, 2vw, 1rem);
}

.user-info{
display: flex;
align-items: center;
gap: 16px;
flex-wrap: wrap;
}

.user-details {
    text-align: right;
}

.user-name {
    font-weight: 600;
    color: var(--text-dark);
    font-size: 0.9375rem;
}

.user-role {
    font-size: 0.8125rem;
    color: var(--text-muted);
    text-transform: capitalize;
}

.logout-btn{
padding: 12px 20px;
border: none;
background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
color: white;
border-radius: var(--radius-sm);
cursor: pointer;
font-size: 14px;
font-weight: 600;
transition: var(--transition);
min-height: var(--touch-target);
display: flex;
align-items: center;
gap: 8px;
will-change: transform, box-shadow;
}

.logout-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(239, 68, 68, 0.4);
}

.logout-btn:active {
    transform: translateY(0);
}

/* Cards Grid */
.cards-container{
display: grid;
grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
gap: 20px;
}

.card{
background: var(--white);
padding: 20px;
border-radius: var(--radius-lg);
box-shadow: var(--shadow-md);
transition: var(--transition);
}

.card:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-lg);
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
    flex-wrap: wrap;
    gap: 8px;
}

.card-title{
font-weight: 700;
color: var(--primary);
font-size: 1rem;
}

.card-date{
font-size: 0.8125rem;
color: var(--text-muted);
}

.file-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    padding-bottom: 12px;
    border-bottom: 1px solid #e2e8f0;
    flex-wrap: wrap;
    gap: 8px;
}

.file-name {
    font-weight: 600;
    color: var(--text-dark);
    font-size: 0.875rem;
    word-break: break-all;
}

.file-type-badge {
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.6875rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.file-type-badge.image {
    background: #dbeafe;
    color: #2563eb;
}

.file-type-badge.pdf {
    background: #fce7f3;
    color: #db2777;
}

.file-type-badge.doc {
    background: #dcfce7;
    color: #16a34a;
}

.file-type-badge.other {
    background: #f3f4f6;
    color: #6b7280;
}

.embed-container{
width:100%;
height: 350px;
border-radius: var(--radius-md);
border: 1px solid #e2e8f0;
margin-top: 12px;
object-fit: contain;
background: #f8fafc;
cursor: pointer;
transition: var(--transition);
}

.embed-container:hover {
    border-color: var(--primary-light);
    box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.view-btn{
padding: 10px 18px;
background: var(--primary);
color: white;
text-decoration: none;
border-radius: var(--radius-sm);
display: inline-flex;
align-items: center;
gap: 8px;
font-weight: 600;
font-size: 0.875rem;
transition: var(--transition);
min-height: var(--touch-target);
}

.view-btn:hover {
    background: var(--primary-light);
    transform: translateY(-2px);
}

/* Empty State */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    background: var(--white);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-md);
}

.empty-state-icon {
    font-size: 4rem;
    margin-bottom: 16px;
    opacity: 0.5;
}

.empty-state h3 {
    color: var(--text-dark);
    font-size: 1.25rem;
    margin-bottom: 8px;
}

.empty-state p {
    color: var(--text-muted);
}

/* Lightbox Modal */
.lightbox {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.9);
    z-index: 9999;
    justify-content: center;
    align-items: center;
    padding: 20px;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.lightbox.active {
    display: flex;
    opacity: 1;
}

.lightbox-content {
    max-width: 95%;
    max-height: 95%;
    border-radius: var(--radius-md);
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
    transform: scale(0.9);
    transition: transform 0.3s ease;
}

.lightbox.active .lightbox-content {
    transform: scale(1);
}

.lightbox-close {
    position: absolute;
    top: 20px;
    right: 30px;
    color: white;
    font-size: 40px;
    font-weight: bold;
    cursor: pointer;
    transition: var(--transition);
    width: 48px;
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.1);
}

.lightbox-close:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: scale(1.1);
}

.lightbox-nav {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    color: white;
    font-size: 30px;
    font-weight: bold;
    cursor: pointer;
    padding: 20px;
    transition: var(--transition);
    background: rgba(255, 255, 255, 0.1);
    border-radius: var(--radius-sm);
    min-width: 56px;
    min-height: 56px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.lightbox-nav:hover {
    background: rgba(255, 255, 255, 0.2);
}

.lightbox-prev {
    left: 20px;
}

.lightbox-next {
    right: 20px;
}

/* Mobile Responsiveness */
@media (max-width: 1024px) {
    .cards-container {
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 16px;
    }
}

@media (max-width: 768px) {
    body {
        padding: 10px;
    }
    
    .top-bar {
        flex-direction: column;
        align-items: stretch;
        padding: 16px;
        border-radius: var(--radius-lg);
        margin-bottom: 16px;
    }
    
    .welcome-section {
        width: 100%;
        text-align: center;
    }
    
    .welcome-section h1 {
        font-size: 1.25rem;
    }
    
    .user-info {
        width: 100%;
        justify-content: space-between;
    }
    
    .user-details {
        text-align: left;
    }
    
    .cards-container {
        grid-template-columns: 1fr;
        gap: 14px;
    }
    
    .embed-container {
        height: 280px;
    }
    
    .card {
        padding: 16px;
    }
    
    .card-title {
        font-size: 0.9375rem;
    }
}

@media (max-width: 480px) {
    body {
        padding: 8px;
    }
    
    .top-bar {
        padding: 12px;
        border-radius: var(--radius-md);
        margin-bottom: 12px;
        gap: 12px;
    }
    
    .welcome-section h1 {
        font-size: 1.125rem;
    }
    
    .welcome-section p {
        font-size: 0.8125rem;
    }
    
    .logout-btn {
        padding: 10px 16px;
        font-size: 13px;
    }
    
    .user-name {
        font-size: 0.8125rem;
    }
    
    .user-role {
        font-size: 0.6875rem;
    }
    
    .cards-container {
        gap: 10px;
    }
    
    .card {
        padding: 14px;
        border-radius: var(--radius-md);
    }
    
    .card-title {
        font-size: 0.875rem;
    }
    
    .embed-container {
        height: 220px;
    }
    
    .file-name {
        font-size: 0.75rem;
    }
    
    .view-btn {
        padding: 8px 14px;
        font-size: 0.8125rem;
    }
    
    .lightbox-nav {
        padding: 14px;
        font-size: 24px;
    }
    
    .lightbox-prev {
        left: 10px;
    }
    
    .lightbox-next {
        right: 10px;
    }
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

.card {
    animation: fadeInUp 0.4s ease-out both;
}

.cards-container .card:nth-child(1) { animation-delay: 0.05s; }
.cards-container .card:nth-child(2) { animation-delay: 0.1s; }
.cards-container .card:nth-child(3) { animation-delay: 0.15s; }
.cards-container .card:nth-child(4) { animation-delay: 0.2s; }
.cards-container .card:nth-child(5) { animation-delay: 0.25s; }
.cards-container .card:nth-child(6) { animation-delay: 0.3s; }

/* Touch feedback */
@media (hover: none) {
    .card:hover {
        transform: none;
    }
    .embed-container:hover {
        border-color: #e2e8f0;
        box-shadow: none;
    }
    .view-btn:hover {
        background: var(--primary);
        transform: none;
    }
}
</style>

</head>

<body>

<div class="container">

<!-- TOP BAR -->
<div class="top-bar">
    <div class="welcome-section">
        <h1>My Timetables</h1>
        <p>Welcome back, <%=user.getFullName()%></p>
    </div>

    <div class="user-info">
        <div class="user-details">
            <div class="user-name"><%=user.getUsername()%></div>
            <div class="user-role"><%=user.getRole()%></div>
        </div>
        <button class="logout-btn" onclick="logout()">
            <span>Logout</span>
        </button>
    </div>
</div>
<div class="top-bar">
		<div class="welcome-section">
			<h2>
				Welcome,
				<%=user.getFullName()%></h2>
			<p>Here's what's happening today</p>
		</div>
		<div class="user-info">
			<div class="user-avatar"><%=avatarLetter%></div>
			<div>
				<div style="font-weight: 600; color: #1e293b;"><%=user.getUsername()%></div>
				<div style="font-size: 0.9rem; color: #64748b;"><%=user.getRole()%></div>
			</div>
			<button class="logout-btn" onclick="logout()">
				<i class="fas fa-sign-out-alt"></i> Logout
			</button>
		</div>
	</div>

<!-- TIMETABLE DATA -->
<%
if(timetables==null || timetables.isEmpty()){
%>

<div class="empty-state">
    <div class="empty-state-icon">📅</div>
    <h3>No Timetable Uploaded</h3>
    <p>No timetable has been uploaded for your class yet.</p>
</div>

<%
}else{
%>

<div class="cards-container">

<%
int index = 0;
for(Map<String,Object> t : timetables){

String fileName=(String)t.get("file");
String fileUrl=request.getContextPath()+"/uploads/timetables/"+fileName;

String fileType="";

if(fileName.toLowerCase().endsWith(".pdf")){
    fileType="pdf";
}
else if(fileName.toLowerCase().endsWith(".doc") || fileName.toLowerCase().endsWith(".docx")){
    fileType="doc";
}
else if(fileName.toLowerCase().endsWith(".png") || fileName.toLowerCase().endsWith(".jpg") || fileName.toLowerCase().endsWith(".jpeg") || fileName.toLowerCase().endsWith(".gif") || fileName.toLowerCase().endsWith(".webp")){
    fileType="image";
}
%>

<div class="card">

    <div class="card-header">
        <div class="card-title">Timetable</div>
        <div class="card-date"><%= t.get("date") %></div>
    </div>

    <div class="file-info">
        <div class="file-name"><%= fileName %></div>
        <span class="file-type-badge <%= fileType %>"><%= fileType %></span>
    </div>

<%
if("pdf".equals(fileType)){
%>

<embed src="<%= fileUrl %>" class="embed-container" type="application/pdf">

<%
}else if("doc".equals(fileType)){
%>

<iframe
src="https://docs.google.com/gview?url=<%= java.net.URLEncoder.encode(fileUrl,"UTF-8") %>&embedded=true"
class="embed-container">
</iframe>

<%
}else if("image".equals(fileType)){
%>

<img src="<%= fileUrl %>" class="embed-container" 
     onclick="openLightbox(<%= index %>)" 
     alt="Timetable Image"
     data-index="<%= index %>">

<%
}else{
%>

<a class="view-btn" href="<%= fileUrl %>" target="_blank">
    <span>View File</span>
</a>

<%
}
%>

</div>

<%
index++;
}
%>

</div>

<%
}
%>

</div>

<!-- Lightbox Modal -->
<div class="lightbox" id="lightbox" onclick="closeLightbox(event)">
    <span class="lightbox-close" onclick="closeLightboxBtn()">&times;</span>
    <span class="lightbox-nav lightbox-prev" onclick="navigateLightbox(-1)">&#10094;</span>
    <img class="lightbox-content" id="lightbox-img" src="" alt="Full size image">
    <span class="lightbox-nav lightbox-next" onclick="navigateLightbox(1)">&#10095;</span>
</div>

<script>
function logout(){
    if(confirm('Are you sure you want to logout?')) {
        window.location.href="<%=request.getContextPath()%>/LogoutServlet";
    }
}

// Lightbox functionality
let currentImageIndex = 0;
const imageElements = document.querySelectorAll('.embed-container[data-index]');
const totalImages = imageElements.length;

function openLightbox(index) {
    currentImageIndex = index;
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightbox-img');
    
    if (imageElements[index]) {
        lightboxImg.src = imageElements[index].src;
        lightbox.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeLightbox(event) {
    if (event.target === event.currentTarget) {
        closeLightboxBtn();
    }
}

function closeLightboxBtn() {
    const lightbox = document.getElementById('lightbox');
    lightbox.classList.remove('active');
    document.body.style.overflow = '';
}

function navigateLightbox(direction) {
    currentImageIndex += direction;
    
    if (currentImageIndex < 0) {
        currentImageIndex = totalImages - 1;
    } else if (currentImageIndex >= totalImages) {
        currentImageIndex = 0;
    }
    
    const lightboxImg = document.getElementById('lightbox-img');
    if (imageElements[currentImageIndex]) {
        lightboxImg.src = imageElements[currentImageIndex].src;
    }
}

// Keyboard navigation
document.addEventListener('keydown', function(e) {
    const lightbox = document.getElementById('lightbox');
    if (!lightbox.classList.contains('active')) return;
    
    if (e.key === 'Escape') {
        closeLightboxBtn();
    } else if (e.key === 'ArrowLeft') {
        navigateLightbox(-1);
    } else if (e.key === 'ArrowRight') {
        navigateLightbox(1);
    }
});

// Prevent double-tap zoom on mobile
document.addEventListener('dblclick', function(event) {
    event.preventDefault();
}, { passive: false });
</script>

</body>
</html>

