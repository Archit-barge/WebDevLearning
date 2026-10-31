package com.seh.servlet;

import com.seh.util.SQLConnection;
import com.seh.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/getTask")
public class ViewTaskServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Set content type to HTML
        response.setContentType("text/html;charset=UTF-8");

        // Get task ID
        String idStr = request.getParameter("id");
        int taskId = 0;
        try {
            taskId = Integer.parseInt(idStr);
        } catch (Exception e) {
            response.getWriter().write("<p style='color:red;'>Invalid task ID</p>");
            return;
        }

        // Get user session
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.getWriter().write("<p style='color:red;'>Unauthorized access</p>");
            return;
        }

        String sql = "SELECT t.*, c.class_name, c.section, s.subject_name " +
                     "FROM teacher_tasks t " +
                     "JOIN classes c ON t.class_id = c.class_id " +
                     "JOIN subjects s ON t.subject_id = s.subject_id " +
                     "WHERE t.task_id = ? AND t.teacher_id = ?";

        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, taskId);
            stmt.setInt(2, user.getUserId());

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                // Build HTML output
                StringBuilder html = new StringBuilder();
                html.append("<div style='display:grid; gap:15px;'>");
                html.append("<div><b>Date:</b> ").append(rs.getString("task_date")).append("</div>");
                html.append("<div><b>Class:</b> ").append(rs.getString("class_name"))
                    .append(" - ").append(rs.getString("section")).append("</div>");
                html.append("<div><b>Subject:</b> ").append(rs.getString("subject_name")).append("</div>");
                html.append("<div><b>Duration:</b> ")
                    .append(rs.getString("duration") != null ? rs.getString("duration") + " minutes" : "-")
                    .append("</div>");
                html.append("<div><b>Topic:</b> ").append(rs.getString("topic")).append("</div>");
                html.append("<div><b>Description:</b><p style='margin-top:6px;color:#64748b;'>")
                    .append(rs.getString("description") != null ? rs.getString("description").replaceAll("\n","<br>") : "No description")
                    .append("</p></div>");
                html.append("</div>");

                response.getWriter().write(html.toString());
            } else {
                response.getWriter().write("<p style='color:red;'>Task not found</p>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        }
    }
}