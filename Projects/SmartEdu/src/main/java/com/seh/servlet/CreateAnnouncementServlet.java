package com.seh.servlet;

import java.io.IOException;
import java.sql.*;
import java.net.URLEncoder; // ✅ ADDED
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.seh.util.SQLConnection;

@WebServlet("/teacher/CreateAnnouncementServlet")
public class CreateAnnouncementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/teacher/announcements.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String classIdStr = request.getParameter("classId"); // optional

        try (Connection conn = SQLConnection.getConnection()) {

            // Insert announcement
            String sql = "INSERT INTO announcements(title, description, class_id, created_at) VALUES (?, ?, ?, NOW())";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, title);
                ps.setString(2, description);
                if (classIdStr != null && !classIdStr.trim().isEmpty()) {
                    ps.setInt(3, Integer.parseInt(classIdStr));
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.executeUpdate();

                // Get generated announcement ID
                int announcementId = -1;
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        announcementId = rs.getInt(1);
                    }
                }

                // Insert notifications for students
                if (announcementId != -1) {
                    String notifySql =
                        "INSERT INTO notifications (user_id, announcement_id, is_read) " +
                        "SELECT user_id, ?, FALSE FROM users WHERE role='student'" +
                        (classIdStr != null && !classIdStr.trim().isEmpty() ? " AND class_id=?" : "");

                    try (PreparedStatement nps = conn.prepareStatement(notifySql)) {
                        nps.setInt(1, announcementId);
                        if (classIdStr != null && !classIdStr.trim().isEmpty()) {
                            nps.setInt(2, Integer.parseInt(classIdStr));
                        }
                        nps.executeUpdate();
                    }
                }
            }

        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }

        /* =======================
           ✅ ADDED: WhatsApp Redirect
           ======================= */
        if (classIdStr != null && !classIdStr.trim().isEmpty()) {
            response.sendRedirect(
                request.getContextPath()
                + "/teacher/SendClassWhatsAppServlet"
                + "?classId=" + classIdStr
                + "&title=" + URLEncoder.encode(title, "UTF-8")
                + "&desc=" + URLEncoder.encode(description, "UTF-8")
            );
        } else {
            response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp");
        }
    }
}
