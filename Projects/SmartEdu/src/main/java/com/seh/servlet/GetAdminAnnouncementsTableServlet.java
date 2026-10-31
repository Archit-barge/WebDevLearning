package com.seh.servlet;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;

@WebServlet("/getAdminAnnouncementsTable")
public class GetAdminAnnouncementsTableServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");

        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Unauthorized.</div>");
            return;
        }

        String sql = "SELECT a.id, a.title, a.description, a.class_id, a.created_at, c.class_name, c.section " +
                "FROM announcements a " +
                "LEFT JOIN classes c ON a.class_id = c.class_id " +
                "ORDER BY a.created_at DESC";

        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            boolean hasRows = false;
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

            while (rs.next()) {
                hasRows = true;
                int id = rs.getInt("id");
                String title = nvl(rs.getString("title"));
                String description = nvl(rs.getString("description"));
                Integer classId = (Integer) rs.getObject("class_id");
                String className = rs.getString("class_name");
                String section = rs.getString("section");
                String targetClass = className == null
                        ? "General"
                        : className + ((section != null && !section.isBlank()) ? " - " + section : "");

                Timestamp createdAt = rs.getTimestamp("created_at");
                String created = createdAt == null ? "-" : createdAt.toLocalDateTime().format(fmt);

                response.getWriter().println("<div class='announcement-card'>");
                response.getWriter().println("  <div class='announcement-badge'><i class='fas fa-users'></i> " + escHtml(targetClass) + "</div>");
                response.getWriter().println("  <h3 class='announcement-title'>" + escHtml(title) + "</h3>");
                response.getWriter().println("  <p class='announcement-desc'>" + escHtml(description) + "</p>");
                response.getWriter().println("  <p class='announcement-meta'><i class='far fa-clock'></i> " + escHtml(created) + "</p>");
                response.getWriter().println("  <div class='actions'>");
                response.getWriter().println("    <button type='button' class='action-btn view' " +
                        "data-id='" + id + "' " +
                        "data-title=\"" + escAttr(title) + "\" " +
                        "data-description=\"" + escAttr(description) + "\" " +
                        "data-target=\"" + escAttr(targetClass) + "\" " +
                        "data-created=\"" + escAttr(created) + "\" " +
                        "data-class-id='" + (classId == null ? "" : classId) + "' " +
                        "onclick='openViewAnnouncementModal(this)'>View</button>");
                response.getWriter().println("    <button type='button' class='action-btn edit' " +
                        "data-id='" + id + "' " +
                        "data-title=\"" + escAttr(title) + "\" " +
                        "data-description=\"" + escAttr(description) + "\" " +
                        "data-class-id='" + (classId == null ? "" : classId) + "' " +
                        "onclick='openEditAnnouncementModal(this)'>Edit</button>");
                response.getWriter().println("    <button type='button' class='action-btn delete' onclick='deleteAdminAnnouncement(" + id + ")'>Delete</button>");
                response.getWriter().println("  </div>");
                response.getWriter().println("</div>");
            }

            if (!hasRows) {
                response.getWriter().write("<div class='no-data'>No announcements yet.</div>");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Failed to load announcements.</div>");
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Object role = session.getAttribute("role");
        Object user = session.getAttribute("user");
        return "admin".equals(role) && user instanceof User;
    }

    private String nvl(String value) {
        return value == null ? "" : value;
    }

    private String escHtml(String value) {
        return nvl(value).replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    private String escAttr(String value) {
        return escHtml(value).replace("\"", "&quot;").replace("'", "&#39;");
    }
}
