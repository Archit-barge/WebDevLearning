package com.seh.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.seh.model.User;
import com.seh.util.SQLConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet({"/deleteAdminAnnouncement", "/DeleteAdminAnnouncementServlet"})
public class DeleteAdminAnnouncementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        boolean ajax = isAjax(request);

        if (!isAdmin(request)) {
            if (ajax) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Unauthorized.</div>");
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
            return;
        }

        Integer id = parseId(request.getParameter("id"));
        if (id == null) {
            if (ajax) {
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid announcement id.</div>");
            } else {
                setFlash(request, "error", "Invalid announcement id.");
                response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=admin_announcements.jsp");
            }
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {
            String sql = "DELETE FROM announcements WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                int deleted = ps.executeUpdate();
                if (deleted == 0) {
                    if (ajax) {
                        response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Announcement not found.</div>");
                        return;
                    }
                    setFlash(request, "error", "Announcement not found.");
                } else {
                    if (ajax) {
                        response.getWriter().write("<div class='alert alert-success'><i class='fas fa-check-circle'></i> Announcement deleted successfully.</div>");
                        return;
                    }
                    setFlash(request, "success", "Announcement deleted successfully.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (ajax) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Failed to delete announcement.</div>");
                return;
            }
            setFlash(request, "error", "Failed to delete announcement.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=admin_announcements.jsp");
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Object role = session.getAttribute("role");
        Object user = session.getAttribute("user");
        return "admin".equals(role) && user instanceof User;
    }

    private void setFlash(HttpServletRequest request, String key, String message) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute(key, message);
        }
    }

    private Integer parseId(String rawId) {
        if (rawId == null || rawId.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(rawId.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean isAjax(HttpServletRequest request) {
        return "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
    }
}
