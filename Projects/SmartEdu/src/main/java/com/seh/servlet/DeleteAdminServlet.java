package com.seh.servlet;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/DeleteAdminServlet")
public class DeleteAdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        String adminIdStr = request.getParameter("adminId");

        try (Connection conn = SQLConnection.getConnection();
             PrintWriter out = response.getWriter()) {

            if (adminIdStr == null || adminIdStr.isEmpty()) {
                out.print("Invalid request.");
                return;
            }

            int adminId = Integer.parseInt(adminIdStr);

            Integer currentUserId = null;
            Object userObj = request.getSession().getAttribute("user");
            if (userObj instanceof User) {
                currentUserId = ((User) userObj).getUserId();
            }

            Integer userId = null;
            String sqlUserId = "SELECT user_id FROM admins WHERE admin_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUserId)) {
                ps.setInt(1, adminId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                    }
                }
            }

            if (userId == null) {
                out.print("Admin not found.");
                return;
            }

            if (currentUserId != null && currentUserId == userId) {
                out.print("You cannot delete your own admin account.");
                return;
            }

            String sqlDelAdmin = "DELETE FROM admins WHERE admin_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDelAdmin)) {
                ps.setInt(1, adminId);
                ps.executeUpdate();
            }

            String sqlDelUser = "DELETE FROM users WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDelUser)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }

            out.print("Admin deleted successfully.");

        } catch (Exception e) {
            e.printStackTrace();
            try (PrintWriter out = response.getWriter()) {
                out.print("Error deleting admin.");
            }
        }
    }
}
