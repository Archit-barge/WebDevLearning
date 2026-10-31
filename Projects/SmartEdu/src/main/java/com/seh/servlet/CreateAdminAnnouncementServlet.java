package com.seh.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.LinkedHashMap;
import java.util.Map;

import com.seh.model.User;
import com.seh.util.SQLConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet({"/createAdminAnnouncement", "/CreateAdminAnnouncement", "/CreateAdminAnnouncementServlet", "/admin/CreateAdminAnnouncementServlet"})
public class CreateAdminAnnouncementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/admin/admin_announcements.jsp")
               .forward(request, response);
    }

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

        handleCreateAnnouncement(request, response, ajax);
    }

    private void handleCreateAnnouncement(HttpServletRequest request, HttpServletResponse response, boolean ajax)
            throws IOException {
        String title = trimToNull(request.getParameter("title"));
        String description = trimToNull(request.getParameter("description"));
        String classIdStr = trimToNull(request.getParameter("classId"));
        boolean sendToWhatsapp = "true".equalsIgnoreCase(trimToNull(request.getParameter("sendToWhatsapp")));

        if (title == null || description == null) {
            if (ajax) {
                writeAlert(response, "error", "Title and description are required.");
            } else {
                setFlash(request, "error", "Title and description are required.");
                response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=admin_announcements.jsp");
            }
            return;
        }

        Integer classId = parseClassId(classIdStr);
        if (classIdStr != null && classId == null) {
            if (ajax) {
                writeAlert(response, "error", "Invalid class selected.");
            } else {
                setFlash(request, "error", "Invalid class selected.");
                response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=admin_announcements.jsp");
            }
            return;
        }

        if (sendToWhatsapp && classId == null) {
            if (ajax) {
                writeAlert(response, "error", "Class-specific announcement is required for WhatsApp send.");
            } else {
                setFlash(request, "error", "Class-specific announcement is required for WhatsApp send.");
                response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=admin_announcements.jsp");
            }
            return;
        }

        String whatsappLink = null;
        String whatsappMessage = null;

        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false);

            if (sendToWhatsapp && classId != null) {
                whatsappLink = getClassWhatsAppLink(conn, classId);
                if (whatsappLink == null || whatsappLink.isBlank()) {
                    conn.rollback();
                    if (ajax) {
                        writeAlert(response, "error", "No WhatsApp group link configured for this class.");
                    } else {
                        setFlash(request, "error", "No WhatsApp group link configured for this class.");
                        response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=admin_announcements.jsp");
                    }
                    return;
                }

                User user = (User) request.getSession(false).getAttribute("user");
                String senderName = resolveSenderName(user);
                whatsappMessage = buildWhatsAppMessage(title, description, senderName);
            }

            String sql =
                "INSERT INTO announcements (title, description, class_id, created_at) " +
                "VALUES (?, ?, ?, NOW())";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, title);
                ps.setString(2, description);

                if (classId != null) {
                    ps.setInt(3, classId);
                } else {
                    ps.setNull(3, Types.INTEGER);
                }

                ps.executeUpdate();
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (ajax) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                writeAlert(response, "error", "Failed to create announcement.");
            } else {
                setFlash(request, "error", "Failed to create announcement.");
                response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=admin_announcements.jsp");
            }
            return;
        }

        if (ajax) {
            if (sendToWhatsapp && whatsappLink != null && whatsappMessage != null) {
                Map<String, String> data = new LinkedHashMap<>();
                data.put("group-link", whatsappLink);
                data.put("message", whatsappMessage);
                writeAlert(response, "success", "Announcement posted successfully.", data);
            } else {
                writeAlert(response, "success", "Announcement posted successfully.");
            }
        } else {
            setFlash(request, "success", "Announcement posted successfully.");
            response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=admin_announcements.jsp");
        }
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

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private boolean isAjax(HttpServletRequest request) {
        return "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
    }

    private String escAttr(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\r\n", "&#10;")
                .replace("\n", "&#10;")
                .replace("\r", "&#10;");
    }

    private String escHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    private Integer parseClassId(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String resolveSenderName(User user) {
        if (user == null) return "Admin";
        if (user.getFullName() != null && !user.getFullName().trim().isEmpty()) {
            return user.getFullName().trim();
        }
        if (user.getUsername() != null && !user.getUsername().trim().isEmpty()) {
            return user.getUsername().trim();
        }
        return "Admin";
    }

    private String buildWhatsAppMessage(String title, String description, String senderName) {
        return "\uD83D\uDCE2 New Announcement\n\n"
                + "Title: " + title + "\n"
                + "Message: " + description + "\n\n"
                + "Sent by: " + senderName;
    }

    private String getClassWhatsAppLink(Connection conn, int classId) throws Exception {
        String sql = "SELECT whatsapp_link FROM class_whatsapp_group WHERE class_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("whatsapp_link");
            }
        }
        return null;
    }

    private void writeAlert(HttpServletResponse response, String type, String message) throws IOException {
        writeAlert(response, type, message, null);
    }

    private void writeAlert(HttpServletResponse response, String type, String message, Map<String, String> dataAttributes)
            throws IOException {
        String cssType = "success".equalsIgnoreCase(type) ? "success" : "error";
        String icon = "success".equalsIgnoreCase(type) ? "fa-check-circle" : "fa-exclamation-triangle";
        StringBuilder out = new StringBuilder();
        out.append("<div class='alert alert-").append(cssType).append("'");
        if (dataAttributes != null) {
            for (Map.Entry<String, String> entry : dataAttributes.entrySet()) {
                out.append(" data-").append(entry.getKey()).append("=\"")
                   .append(escAttr(entry.getValue())).append("\"");
            }
        }
        out.append("><i class='fas ").append(icon).append("'></i> ")
           .append(escHtml(message))
           .append("</div>");
        response.getWriter().write(out.toString());
    }
}
