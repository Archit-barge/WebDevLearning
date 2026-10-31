<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.seh.model.User" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    // --- Session check ---
    HttpSession session2 = request.getSession(false);
    User user = (session != null) ? (User) session.getAttribute("user") : null;
    if (user == null || !"teacher".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<style>
        :root {
            --primary: #3b82f6;
            --primary-light: #60a5fa;
            --primary-dark: #2563eb;
            --text-dark: #1e293b;
            --text-muted: #64748b;
            --bg-light: #f8fafc;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        .events-content {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-light);
            padding: 20px;
            color: var(--text-dark);
            -webkit-font-smoothing: antialiased;
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

        .form-card {
            background: #fff;
            padding: 2rem;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07);
            margin-bottom: 2rem;
            border: 1px solid #e2e8f0;
            max-width: 800px;
        }
        .form-card h2 {
            font-size: 1.5rem; color: #1e293b; margin-bottom: 1.5rem;
            padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0;
        }
        .events-content label {
            display: block; font-weight: 600; margin-bottom: 0.5rem; font-size: 0.95rem; color: #475569;
        }
        .events-content input, .events-content select, .events-content textarea {
            width: 100%; padding: 0.75rem 1rem; margin-bottom: 1.25rem;
            border-radius: 8px; border: 1px solid #e2e8f0; font-size: 1rem; color: #1e293b;
        }
        .events-content button.btn-primary {
            background: var(--primary); color: #fff; border: none; padding: 0.75rem 1.5rem;
            border-radius: 6px; cursor: pointer; font-size: 1rem; font-weight: 600; transition: background 0.3s;
        }
        .events-content button.btn-primary:hover { background: var(--primary-dark); }
    </style>

    <script>
        function changeTemplate() {
            var type = document.getElementById("eventType").value;
            var messageBox = document.getElementById("message");

            if (type === "holiday") {
                messageBox.value =
                    "📢 Holiday Notice\n\n" +
                    "Dear Students,\n" +
                    "The college will remain closed on [DATE] due to a holiday.\n\n" +
                    "Regards,\nCollege Administration";

            } else if (type === "festival") {
                messageBox.value =
                    "🎉 Festival Celebration\n\n" +
                    "Dear Students,\n" +
                    "We are pleased to inform you that [FESTIVAL NAME] will be celebrated on [DATE].\n\n" +
                    "Regards,\nCollege Administration";

            } else if (type === "emergency") {
                messageBox.value =
                    "🚨 Emergency Holiday\n\n" +
                    "Due to unforeseen circumstances, the college will remain closed today.\n\n" +
                    "Stay Safe,\nCollege Administration";

            } else {
                messageBox.value = "";
            }
        }
    </script>

<div class="events-content">
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Manage Events</h1>
            <p>Welcome back, <%= user.getUsername() %>! Create new events or holidays.</p>
        </div>
        <div class="user-info">
            <div class="user-avatar"><%= (user.getFullName() != null && user.getFullName().length() > 0) ? String.valueOf(user.getFullName().charAt(0)).toUpperCase() : "A" %></div>
            <div>
                <div style="font-weight:600;color:#1e293b;font-size:0.9rem;"><%=user.getUsername()%></div>
                <div style="font-size:0.8rem;color:#64748b;text-transform: capitalize;"><%=user.getRole()%></div>
            </div>
            <button class="logout-btn" onclick="if(confirm('Logout?')) window.location.href='../LogoutServlet'">Logout</button>
        </div>
    </div>

<div class="form-card">
    <h2>Create Event</h2>

    <%-- Optional: show success/error messages --%>
    <% if (request.getParameter("success") != null) { %>
        <p style="color:green;">✅ Event created successfully!</p>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        <p style="color:red;">❌ Error: <%= request.getParameter("error") %></p>
    <% } %>

    <form action="<%= request.getContextPath() %>/teacher/CreateEventServlet" method="post">
        <!-- Event Title -->
        <label>Event Title</label>
        <input type="text" name="title" required>

        <!-- Dropdown -->
        <label>Event Type</label>
        <select id="eventType" name="template" required>
            <option value="">-- Select Type --</option>
            <option value="holiday">Holiday</option>
            <option value="festival">Festival</option>
            <option value="emergency">Emergency Holiday</option>
        </select>

        <!-- Message Textbox -->
        <label>Message</label>
        <textarea id="message" name="description" rows="6" required></textarea>

        <!-- Event Date -->
        <label>Event Date</label>
        <input type="date" name="eventDate" required>

        <!-- Submit Button -->
        <button type="submit" class="btn-primary">Post Event</button>

    </form>
</div>

</div>
