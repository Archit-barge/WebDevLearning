package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import com.seh.util.SQLConnection;

@WebServlet("/addAdmin")
public class addAdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleAddAdmin(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleAddAdmin(request, response);
    }

    private void handleAddAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String username  = request.getParameter("username");
        String password  = request.getParameter("password");
        String email     = request.getParameter("email");
        String firstName = request.getParameter("firstName");
        String lastName  = request.getParameter("lastName");
        String phone     = request.getParameter("phone");
        String address   = request.getParameter("address");

       //Debug sathi aahe
        System.out.println("DEBUG addAdmin => username=" + username +
                ", password=" + password +
                ", email=" + email +
                ", firstName=" + firstName +
                ", lastName=" + lastName);

        if (isEmpty(username) || isEmpty(password) || isEmpty(email)
                || isEmpty(firstName) || isEmpty(lastName)) {
            out.print("<div class=\"alert alert-error\">" +
                      "<i class='fas fa-exclamation-triangle'></i> " +
                      "All required fields must be filled." +
                      "</div>");
            out.close();
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = SQLConnection.getConnection();
            if (conn == null) {
                out.print("<div class=\"alert alert-error\">" +
                          "<i class='fas fa-exclamation-triangle'></i> " +
                          "Database connection failed. Please try again." +
                          "</div>");
                return;
            }

            conn.setAutoCommit(false);

            String checkSql = "SELECT user_id FROM users WHERE username = ? OR email = ?";
            ps = conn.prepareStatement(checkSql);
            ps.setString(1, username.trim());
            ps.setString(2, email.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                out.print("<div class=\"alert alert-error\">" +
                          "<i class='fas fa-exclamation-triangle'></i> " +
                          "Username or email already exists." +
                          "</div>");
                conn.rollback();
                return;
            }
            SQLConnection.closeResources(null, rs, ps);
            rs = null; ps = null;

            String insertUserSql =
                    "INSERT INTO users (username, password, email, role, status) " +
                    "VALUES (?, ?, ?, 'admin', 'active')";
            ps = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, username.trim());
            ps.setString(2, password); 
            ps.setString(3, email.trim());
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            int userId = -1;
            if (rs.next()) {
                userId = rs.getInt(1);
            }
            SQLConnection.closeResources(null, rs, ps);
            rs = null; ps = null;

            if (userId == -1) {
                conn.rollback();
                out.print("<div class=\"alert alert-error\">" +
                          "<i class='fas fa-exclamation-triangle'></i> " +
                          "Failed to create user account." +
                          "</div>");
                return;
            }

            String insertAdminSql =
                    "INSERT INTO admins (user_id, first_name, last_name, phone, address) " +
                    "VALUES (?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(insertAdminSql);
            ps.setInt(1, userId);
            ps.setString(2, firstName.trim());
            ps.setString(3, lastName.trim());
            ps.setString(4, phone != null ? phone.trim() : null);
            ps.setString(5, address != null ? address.trim() : null);
            int rows = ps.executeUpdate();

            if (rows > 0) {
                conn.commit();
                out.print("<div class=\"alert alert-success\">" +
                          "<i class='fas fa-check-circle'></i> " +
                          "Admin <strong>" + escape(firstName) + " " + escape(lastName) +
                          "</strong> added successfully!" +
                          "</div>");
            } else {
                conn.rollback();
                out.print("<div class=\"alert alert-error\">" +
                          "<i class='fas fa-exclamation-triangle'></i> " +
                          "User created but admin profile failed. Please contact support." +
                          "</div>");
            }

        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ignore) {}
            e.printStackTrace();
            out.print("<div class=\"alert alert-error\">" +
                      "<i class='fas fa-exclamation-triangle'></i> " +
                      "Database error: " + escape(e.getMessage()) +
                      "</div>");
        } finally {
            SQLConnection.closeResources(conn, rs, ps);
            out.close();
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String escape(String s) {
        return s == null ? "" : s.replace("<", "&lt;").replace(">", "&gt;");
    }
}
