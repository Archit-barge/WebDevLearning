package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/teacher/TeacherAnnouncementServlet")
public class TeacherAnnouncementServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get parameters
        String id = request.getParameter("id");
        String title = request.getParameter("title");
        String description = request.getParameter("description");

        if(title == null || title.trim().isEmpty() || description == null || description.trim().isEmpty()){
            request.getSession().setAttribute("error", "Title and Description cannot be empty!");
            response.sendRedirect(request.getContextPath() + "/PageLoaderTeacher?page=announcements.jsp");
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {

            if (id == null || id.trim().isEmpty()) {
                // ADD
                PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO announcements(title, description) VALUES(?, ?)");
                ps.setString(1, title);
                ps.setString(2, description);
                ps.executeUpdate();
                request.getSession().setAttribute("success", "Announcement added successfully!");
            } else {
                // EDIT
                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE announcements SET title=?, description=? WHERE id=?");
                ps.setString(1, title);
                ps.setString(2, description);
                ps.setInt(3, Integer.parseInt(id));
                int updated = ps.executeUpdate();
                if(updated > 0){
                    request.getSession().setAttribute("success", "Announcement updated successfully!");
                } else {
                    request.getSession().setAttribute("error", "Announcement not found!");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
        }

        // Redirect back to announcements page
        response.sendRedirect(request.getContextPath() + "/PageLoaderTeacher?page=announcements.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String id = request.getParameter("id");

        if("delete".equals(action) && id != null && !id.isEmpty()){
            try(Connection conn = SQLConnection.getConnection()){
                PreparedStatement ps = conn.prepareStatement("DELETE FROM announcements WHERE id=?");
                ps.setInt(1, Integer.parseInt(id));
                int deleted = ps.executeUpdate();
                if(deleted > 0){
                    request.getSession().setAttribute("success", "Announcement deleted successfully!");
                } else {
                    request.getSession().setAttribute("error", "Announcement not found!");
                }
            } catch(Exception e){
                e.printStackTrace();
                request.getSession().setAttribute("error", "Database error: " + e.getMessage());
            }
        } else {
            request.getSession().setAttribute("error", "Invalid request!");
        }

        // Redirect back to announcements page
        response.sendRedirect(request.getContextPath() + "/PageLoaderTeacher?page=announcements.jsp");
    }
}
