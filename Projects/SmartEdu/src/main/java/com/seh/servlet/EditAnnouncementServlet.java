package com.seh.servlet;

import java.io.IOException; 
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.util.SQLConnection;

@WebServlet("/EditAnnouncementServlet")
public class EditAnnouncementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));

        try (Connection conn = SQLConnection.getConnection()) {
            String sql = "SELECT * FROM announcements WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    request.setAttribute("id", rs.getInt("id"));
                    request.setAttribute("title", rs.getString("title"));
                    request.setAttribute("description", rs.getString("description"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("edit_announcement.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");

        try (Connection conn = SQLConnection.getConnection()) {
            String sql = "UPDATE announcements SET title=?, description=? WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, title);
                ps.setString(2, description);
                ps.setInt(3, id);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/Index.jsp?page=announcements.jsp");
    }
}
