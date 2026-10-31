package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/teacher/ViewAnnouncementServlet")
public class ViewAnnouncementServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");

        if (id == null || id.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp?page=announcements.jsp");
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {
            String sql = "SELECT title, description, created_at FROM announcements WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, Integer.parseInt(id));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("title", rs.getString("title"));
                        request.setAttribute("description", rs.getString("description"));
                        request.setAttribute("created_at", rs.getTimestamp("created_at"));
                        
                        // Success: Forward to the view page
                        request.getRequestDispatcher("/WEB-INF/teacher/view_announcement.jsp").forward(request, response);
                    } else {
                        // ID doesn't exist: Redirect back to list
                        response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp?page=announcements.jsp&error=notfound");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp?page=announcements.jsp&error=db");
        }
    }
}