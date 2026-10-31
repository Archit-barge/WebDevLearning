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
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/previewAdminAnnouncementWhatsApp")
public class PreviewAdminAnnouncementWhatsAppServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
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

        String title = trimToNull(request.getParameter("title"));
        String description = trimToNull(request.getParameter("description"));
        String classIdStr = trimToNull(request.getParameter("classId"));

        if (title == null || description == null) {
            writeAlert(response, "error", "Title and description are required.");
            return;
        }

        Integer classId = parseClassId(classIdStr);
        if (classId == null) {
            writeAlert(response, "error", "Please select a valid class for WhatsApp preview.");
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {
            String groupLink = getClassWhatsAppLink(conn, classId);
            if (groupLink == null || groupLink.isBlank()) {
                writeAlert(response, "error", "No WhatsApp group link configured for this class.");
                return;
            }

            String classLabel = getClassLabel(conn, classId);
            User user = (User) request.getSession(false).getAttribute("user");
            String senderName = resolveSenderName(user);
            String message = buildWhatsAppMessage(title, description, senderName);

            Map<String, String> data = new LinkedHashMap<>();
            data.put("preview", "true");
            data.put("group-link", groupLink);
            data.put("message", message);
            data.put("class-label", classLabel == null ? "Selected Class" : classLabel);
            data.put("title", title);
            data.put("description", description);
            writeAlert(response, "success", "WhatsApp preview ready.", data);
        } catch (Exception e) {
            e.printStackTrace();
            if (ajax) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
            writeAlert(response, "error", "Failed to load WhatsApp preview.");
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
        return "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
    }

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
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

    private String getClassLabel(Connection conn, int classId) throws Exception {
        String sql = "SELECT class_name, section FROM classes WHERE class_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                String className = rs.getString("class_name");
                String section = rs.getString("section");
                if (section != null && !section.isBlank()) {
                    return className + " - " + section;
                }
                return className;
            }
        }
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
