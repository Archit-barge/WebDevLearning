package com.seh.servlet;

import com.seh.util.SQLConnection;
import com.seh.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import jakarta.servlet.annotation.MultipartConfig;

@WebServlet("/updateTask")
@MultipartConfig
public class UpdateTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            if (session == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\":\"Session expired\"}");
                return;
            }

            User user = (User) session.getAttribute("user");
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\":\"User not logged in\"}");
                return;
            }

            int teacherId = user.getUserId();
            if (teacherId <= 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid user ID\"}");
                return;
            }

            // Get and validate parameters
            String taskIdStr = request.getParameter("taskId");
            String dateStr = request.getParameter("taskDate");
            String classIdStr = request.getParameter("classId");
            String subjectIdStr = request.getParameter("subjectId");
            String topic = request.getParameter("topic");
            String description = request.getParameter("description");
            String durationStr = request.getParameter("duration");

            if (taskIdStr == null || taskIdStr.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Missing taskId\"}");
                return;
            }

            if (dateStr == null || dateStr.trim().isEmpty() || !dateStr.matches("\\d{4}-\\d{2}-\\d{2}")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid taskDate format (YYYY-MM-DD)\"}");
                return;
            }

            if (classIdStr == null || classIdStr.trim().isEmpty() ||
                subjectIdStr == null || subjectIdStr.trim().isEmpty() ||
                topic == null || topic.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Missing required fields (classId, subjectId, topic)\"}");
                return;
            }

            // Parse integers safely
            int taskId, classId, subjectId, duration = 0;
            try {
                taskId = Integer.parseInt(taskIdStr.trim());
                classId = Integer.parseInt(classIdStr.trim());
                subjectId = Integer.parseInt(subjectIdStr.trim());
                if (durationStr != null && !durationStr.trim().isEmpty()) {
                    duration = Integer.parseInt(durationStr.trim());
                    if (duration <= 0 || duration > 480) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.print("{\"error\":\"Duration must be 1-480 minutes\"}");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid number format in IDs or duration\"}");
                return;
            }

            try (Connection conn = SQLConnection.getConnection()) {
                if (conn == null) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\":\"Database connection failed\"}");
                    return;
                }

                // Verify task belongs to teacher
                String checkSql = "SELECT teacher_id FROM teacher_tasks WHERE task_id = ?";
                try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                    checkPs.setInt(1, taskId);
                    try (ResultSet rs = checkPs.executeQuery()) {
                        if (!rs.next()) {
                            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                            out.print("{\"error\":\"Task not found\"}");
                            return;
                        }
                        if (rs.getInt("teacher_id") != teacherId) {
                            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                            out.print("{\"error\":\"Not authorized to edit this task\"}");
                            return;
                        }
                    }
                }

                // Update task
                String updateSql = "UPDATE teacher_tasks SET task_date = ?, class_id = ?, subject_id = ?, topic = ?, description = ?, duration = ? WHERE task_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setDate(1, Date.valueOf(dateStr));
                    ps.setInt(2, classId);
                    ps.setInt(3, subjectId);
                    ps.setString(4, topic.trim());
                    ps.setString(5, description != null ? description.trim() : null);
                    if (duration > 0) {
                        ps.setInt(6, duration);
                    } else {
                        ps.setNull(6, Types.INTEGER);
                    }
                    ps.setInt(7, taskId);

                    int rowsUpdated = ps.executeUpdate();
                    if (rowsUpdated > 0) {
                        response.setStatus(HttpServletResponse.SC_OK);
                        out.print("{\"success\":\"Task updated successfully\"}");
                    } else {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.print("{\"error\":\"No rows updated - task may not exist\"}");
                    }
                }

            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Database error: " + e.getMessage() + "\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Server error: " + e.getMessage() + "\"}");
        } finally {
            out.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp");
    }
}

