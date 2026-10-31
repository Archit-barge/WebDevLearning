<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Announcement</title>
<style>
/* Container for announcements */
.announcement-container {
    padding: 20px;
    max-width: 800px;
    margin: 40px auto;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

/* Form styling */
.announcement-form {
    background: #fff;
    padding: 2rem;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.07);
    border: 1px solid #e2e8f0;
}

/* Form header */
.announcement-form h2 {
    font-size: 1.5rem; color: #1e293b; margin-bottom: 1.5rem;
    padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0;
}

/* Labels */
.announcement-form label {
    display: block; font-weight: 600; margin-bottom: 0.5rem; font-size: 0.95rem; color: #475569;
}

/* Input fields and textarea */
.announcement-form input[type="text"],
.announcement-form textarea {
    width: 100%; padding: 0.75rem 1rem; margin-bottom: 1.25rem; box-sizing: border-box;
    border-radius: 8px; border: 1px solid #e2e8f0; font-size: 1rem; color: #1e293b;
}

/* Button styling */
.announcement-form button {
    background: #3b82f6; color: #fff; border: none; padding: 0.75rem 1.5rem;
    border-radius: 6px; cursor: pointer; font-size: 1rem; font-weight: 600; transition: background 0.3s;
    display: block; width: 100%;
}
.announcement-form button:hover { background: #2563eb; }

/* Optional: responsive adjustments */
@media (max-width: 600px) {
    .announcement-container { padding: 15px; }
    .announcement-form { padding: 20px; }
}
</style>
</head>
<body>
<div class="announcement-container">
    <div class="announcement-form">
        <h2>Edit Announcement</h2>
        <form action="<%= request.getContextPath() %>/teacher/EditAnnouncementServlet" method="post">
            <input type="hidden" name="id" value="<%= request.getAttribute("id") %>">
            
            <label for="title">Title</label>
            <input type="text" id="title" name="title" value="<%= request.getAttribute("title") %>" required>

            <label for="description">Description</label>
            <textarea id="description" name="description" rows="4" required><%= request.getAttribute("description") %></textarea>

            <button type="submit">Update Announcement</button>
            <a href="<%=request.getContextPath()%>/teacher/Index.jsp" style="display:block;text-align:center;margin-top:12px;color:#64748b;text-decoration:none;font-size:14px;">← Cancel &amp; Back</a>
        </form>
    </div>
</div>
</body>
</html>
