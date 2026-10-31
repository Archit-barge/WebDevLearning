<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Fetching attributes set by the Servlet
    String title = (String) request.getAttribute("title");
    String description = (String) request.getAttribute("description");
    Object createdAt = request.getAttribute("created_at");

    // Fallback if the user tries to access the JSP directly without the Servlet
    if (title == null) {
        title = "No Title Available";
    }
    if (description == null) {
        description = "No description provided.";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Announcement</title>
    <style>
        /* Body styles removed to prevent leaks */
        .container { max-width: 800px; margin: 40px auto; padding: 20px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;}
        .card { background: #fff; padding: 2rem; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.07); border: 1px solid #e2e8f0; }
        h2 { font-size: 1.5rem; color: #1e293b; margin-bottom: 1.5rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; }
        .date { font-size: 0.85rem; color: #64748b; margin-bottom: 20px; display: block; font-style: italic; }
        .content { color: #1e293b; line-height: 1.8; white-space: pre-wrap; font-size: 1.05rem; }
        .actions { margin-top: 30px; border-top: 1px solid #e2e8f0; padding-top: 20px; }
        .btn { display: inline-block; background: #3b82f6; color: white; text-decoration: none; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; transition: 0.3s; }
        .btn:hover { background: #2563eb; transform: translateY(-1px); }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <h2><%= title %></h2>
        <span class="date">📅 Posted on: <%= (createdAt != null) ? createdAt.toString() : "Unknown Date" %></span>
        
        <div class="content"><%= description %></div>
        
        <div class="actions">
            <a class="btn" href="<%= request.getContextPath() %>/teacher/Index.jsp">
                ← Back to All Announcements
            </a>
        </div>
    </div>
</div>

</body>
</html>