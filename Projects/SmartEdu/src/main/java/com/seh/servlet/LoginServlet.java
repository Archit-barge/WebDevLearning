package com.seh.servlet;

import jakarta.servlet.ServletException; 
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.RequestDispatcher;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = SQLConnection.getConnection()) {

            if (conn == null) {
                System.out.println("Error: DB Connection Failed");
                request.setAttribute("loginError", "Database connection failed. Please try again.");
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
                return;
            }

            String sql = "SELECT user_id, username, email, role FROM users WHERE BINARY username=? AND BINARY password=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int userId = rs.getInt("user_id");
                        String uname = rs.getString("username");
                        String email = rs.getString("email");
                        String role = rs.getString("role");

                        String fullName = null;
                        String phone = null;

                        switch (role) {
                            case "admin":
                                sql = "SELECT first_name, last_name, phone FROM admins WHERE user_id=?";
                                break;
                            case "teacher":
                                sql = "SELECT first_name, last_name, phone FROM teachers WHERE user_id=?";
                                break;
                            case "student":
                                sql = "SELECT first_name, last_name, phone FROM students WHERE user_id=?";
                                break;
                            case "parent":
                                sql = "SELECT first_name, last_name, phone FROM parents WHERE user_id=?";
                                break;
                            default:
                                request.setAttribute("loginError", "Invalid role for this user.");
                                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                                rd.forward(request, response);
                                return;
                        }

                        try (PreparedStatement ps2 = conn.prepareStatement(sql)) {
                            ps2.setInt(1, userId);
                            try (ResultSet rs2 = ps2.executeQuery()) {
                                if (rs2.next()) {
                                    fullName = rs2.getString("first_name") + " " + rs2.getString("last_name");
                                    phone = rs2.getString("phone");
                                }
                            }
                        }

                        User user = new User(userId, uname, fullName, role, email);
                        user.setPhone(phone);

                        HttpSession session = request.getSession();
                        session.setAttribute("user", user);
                        session.setAttribute("role", role);

                        System.out.println("User: " + uname + " | Role: " + role + " has logged in successfully");

                        switch (role) {
                            case "admin":
                                response.sendRedirect("admin/Index.jsp");
                                break;
                            case "teacher":
                                response.sendRedirect("teacher/Index.jsp");
                                break;
                            case "student":
                                response.sendRedirect("student/Index.jsp");
                                break;
                            case "parent":
                                response.sendRedirect("parent/Index.jsp");
                                break;
                        }

                    } else {
                        System.out.println("Login failed for username=" + username + " and password=" + password);
                        request.setAttribute("loginError", "Invalid username or password.");
                        RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                        rd.forward(request, response);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("loginError", "An internal error occurred. Please try again.");
            RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
            rd.forward(request, response);
        }
    }
}
