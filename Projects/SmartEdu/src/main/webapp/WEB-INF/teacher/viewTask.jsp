<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.seh.util.SQLConnection, com.seh.model.User, java.sql.*" %>

<%
    // 1. Session & Security Check
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // 2. Get the Task ID from the URL
    String taskIdStr = request.getParameter("id");
    if (taskIdStr == null || taskIdStr.isEmpty()) {
        response.sendRedirect("academicPlanning.jsp");
        return;
    }

    int taskId = Integer.parseInt(taskIdStr);
    
    // Variables to hold the data
    String date = "", className = "", subjectName = "", topic = "", description = "";
    int duration = 0;

    // 3. Fetch specific task details
    String query = "SELECT t.*, c.class_name, c.section, s.subject_name FROM teacher_tasks t " +
                   "JOIN classes c ON t.class_id = c.class_id " +
                   "JOIN subjects s ON t.subject_id = s.subject_id " +
                   "WHERE t.task_id = ? AND t.teacher_id = ?";

    try (Connection con = SQLConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(query)) {
        
        ps.setInt(1, taskId);
        ps.setInt(2, user.getUserId()); // Security: Ensure teacher can only see their own tasks
        
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            date = rs.getString("task_date");
            className = rs.getString("class_name") + " (" + rs.getString("section") + ")";
            subjectName = rs.getString("subject_name");
            topic = rs.getString("topic");
            description = rs.getString("description");
            duration = rs.getInt("duration");
        } else {
            // Task not found or doesn't belong to this teacher
            response.sendRedirect("academicPlanning.jsp");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Task Details | SmartEdu Hub</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root { --primary: #4f46e5; --bg: #f8fafc; --text-main: #1f2937; --text-muted: #6b7280; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text-main); margin: 0; padding: 20px; }
        
        .detail-card { 
            max-width: 700px; margin: 40px auto; background: white; 
            border-radius: 12px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); overflow: hidden; 
        }
        .detail-header { 
            background: var(--primary); color: white; padding: 25px; 
            display: flex; justify-content: space-between; align-items: center; 
        }
        .detail-body { padding: 30px; }
        
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px; }
        .info-item label { display: block; font-size: 12px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; margin-bottom: 5px; }
        .info-item span { font-size: 16px; font-weight: 500; }
        
        .description-box { background: #f9fafb; padding: 20px; border-radius: 8px; border-left: 4px solid var(--primary); line-height: 1.6; }
        .back-btn { 
            display: inline-flex; align-items: center; gap: 8px; text-decoration: none; 
            color: var(--text-muted); font-weight: 600; font-size: 14px; margin-bottom: 20px; 
            transition: color 0.2s;
        }
        .back-btn:hover { color: var(--primary); }
    </style>
</head>
<body>

    <div style="max-width: 700px; margin: 0 auto;">
        <button type="button" class="btn-secondary" onclick="goBack()">
        <i class="fas fa-arrow-left"></i> Back
    </button>

        <div class="detail-card">
            <div class="detail-header">
                <div>
                    <h2 style="margin: 0; font-size: 20px;">Task Details</h2>
                    <small style="opacity: 0.8;">Ref ID: #<%= taskId %></small>
                </div>
                <i class="fas fa-clipboard-check fa-2x" style="opacity: 0.3;"></i>
            </div>
            
            <div class="detail-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Date</label>
                        <span><%= date %></span>
                    </div>
                    <div class="info-item">
                        <label>Duration</label>
                        <span><%= duration %> Minutes</span>
                    </div>
                    <div class="info-item">
                        <label>Class</label>
                        <span><%= className %></span>
                    </div>
                    <div class="info-item">
                        <label>Subject</label>
                        <span><%= subjectName %></span>
                    </div>
                </div>

                <div class="info-item" style="margin-bottom: 20px;">
                    <label>Topic Covered</label>
                    <span style="font-size: 18px; color: var(--primary); font-weight: 700;"><%= topic %></span>
                </div>

                <div class="info-item">
                    <label>Description & Remarks</label>
                    <div class="description-box">
                        <%= (description == null || description.isEmpty()) ? "No additional remarks provided." : description %>
                    </div>
                </div>
            </div>
        </div>
    </div>
<script>
function goBack() {
    window.history.back();
}
</script>
</body>
</html>