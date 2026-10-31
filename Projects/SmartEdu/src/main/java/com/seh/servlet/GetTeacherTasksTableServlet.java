package com.seh.servlet;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/getTeacherTasksTable")
public class GetTeacherTasksTableServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAdmin(request)) {
            handleUnauthorized(request, response);
            return;
        }

        response.setContentType("text/html;charset=UTF-8");

        TeacherTasksQueryHelper.Filters filters = TeacherTasksQueryHelper.fromRequest(request);
        String selectSql = "SELECT t.task_date, t.topic, t.duration, t.description, " +
                "u.username, c.class_name, c.section, s.subject_name " +
                "FROM teacher_tasks t " +
                "JOIN users u ON t.teacher_id = u.user_id " +
                "JOIN classes c ON t.class_id = c.class_id " +
                "JOIN subjects s ON t.subject_id = s.subject_id";
        String sql = TeacherTasksQueryHelper.buildSql(selectSql, filters);

        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             PrintWriter out = response.getWriter()) {

            TeacherTasksQueryHelper.bindFilters(ps, filters);
            int count = 0;

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    count++;
                    String classDisplay = rs.getString("class_name");
                    String section = rs.getString("section");
                    if (section != null && !section.isBlank()) {
                        classDisplay += " - " + section;
                    }

                    out.println("<tr>");
                    out.println("<td class='teacher-task-date'>" + escHtml(rs.getString("task_date")) + "</td>");
                    out.println("<td><strong>" + escHtml(rs.getString("username")) + "</strong></td>");
                    out.println("<td><span class='teacher-task-badge'>" + escHtml(classDisplay) + "</span></td>");
                    out.println("<td>" + escHtml(rs.getString("subject_name")) + "</td>");
                    out.println("<td>" + escHtml(rs.getString("topic")) + "</td>");
                    out.println("<td><i class='far fa-clock'></i> " + rs.getInt("duration") + " min</td>");
                    out.println("<td class='teacher-task-desc'>" + escHtml(nvl(rs.getString("description"))) + "</td>");
                    out.println("</tr>");
                }
            }

            response.setHeader("X-Total-Count", String.valueOf(count));

            if (count == 0) {
                out.println("<tr><td colspan='7' class='no-data'>No records found for the selected criteria.</td></tr>");
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("<tr><td colspan='7' class='table-cell-error'>Error loading teacher tasks.</td></tr>");
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Object role = session.getAttribute("role");
        Object user = session.getAttribute("user");
        return "admin".equals(role) && user instanceof User;
    }

    private boolean isAjax(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith);
    }

    private void handleUnauthorized(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (isAjax(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    private String nvl(String value) {
        return value == null ? "" : value;
    }

    private String escHtml(String value) {
        return nvl(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
