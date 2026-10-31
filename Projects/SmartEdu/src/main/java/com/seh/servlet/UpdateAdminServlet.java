package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/UpdateAdminServlet")
public class UpdateAdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");

        String adminIdStr = request.getParameter("adminId");
        String username   = request.getParameter("username");
        String password   = request.getParameter("password");
        String email      = request.getParameter("email");
        String firstName  = request.getParameter("firstName");
        String lastName   = request.getParameter("lastName");
        String phone      = request.getParameter("phone");
        String address    = request.getParameter("address");

        try (PrintWriter out = response.getWriter();
             Connection conn = SQLConnection.getConnection()) {

            if (adminIdStr == null || adminIdStr.isEmpty()) {
                out.print("Invalid admin id.");
                return;
            }

            int adminId = Integer.parseInt(adminIdStr);
            if (username == null)  username = "";
            if (password == null)  password = "";
            if (email == null)     email = "";
            if (firstName == null) firstName = "";
            if (lastName == null)  lastName = "";
            if (phone == null)     phone = "";
            if (address == null)   address = "";

            conn.setAutoCommit(false);

            Integer userId = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT user_id FROM admins WHERE admin_id = ?")) {
                ps.setInt(1, adminId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                    }
                }
            }

            if (userId == null) {
                conn.rollback();
                out.print("Admin not found.");
                return;
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE users SET username = ?, email = ?, password = ? WHERE user_id = ?")) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.setInt(4, userId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE admins SET first_name = ?, last_name = ?, phone = ?, address = ? WHERE admin_id = ?")) {
                ps.setString(1, firstName);
                ps.setString(2, lastName);
                ps.setString(3, phone);
                ps.setString(4, address);
                ps.setInt(5, adminId);
                ps.executeUpdate();
            }

            conn.commit();
            out.print("Update success");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print("Error updating admin.");
        }
    }
}
