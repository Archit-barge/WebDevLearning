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
import java.sql.Types;

@WebServlet({"/updateAdminAnnouncement", "/UpdateAdminAnnouncementServlet", "/admin/UpdateAdminAnnouncementServlet"})
public class UpdateAdminAnnouncementServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");

        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Unauthorized.</div>");
            return;
        }

        Integer id = parseInt(request.getParameter("id"));
        String title = trimToNull(request.getParameter("title"));
        String description = trimToNull(request.getParameter("description"));
        Integer classId = parseInt(request.getParameter("classId"));

        if (id == null || title == null || description == null) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid request. Title and description are required.</div>");
            return;
        }

        String sql = "UPDATE announcements SET title=?, description=?, class_id=? WHERE id=?";

        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, title);
            ps.setString(2, description);
            if (classId != null) {
                ps.setInt(3, classId);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, id);

            int updated = ps.executeUpdate();
            if (updated > 0) {
                response.getWriter().write("<div class='alert alert-success'><i class='fas fa-check-circle'></i> Announcement updated successfully.</div>");
            } else {
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Announcement not found.</div>");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Failed to update announcement.</div>");
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Object role = session.getAttribute("role");
        Object user = session.getAttribute("user");
        return "admin".equals(role) && user instanceof User;
    }

    private Integer parseInt(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
