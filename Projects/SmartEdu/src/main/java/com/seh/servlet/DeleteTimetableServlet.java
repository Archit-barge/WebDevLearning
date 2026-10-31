package com.seh.servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/teacher/DeleteTimetableServlet")
public class DeleteTimetableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String timetableIdStr = request.getParameter("timetableId");
        if (timetableIdStr == null) {
            session.setAttribute("deleteMessage", "Invalid timetable ID.");
            response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp?page=teacher_upload_timetable.jsp");
            return;
        }

        int timetableId = Integer.parseInt(timetableIdStr);

        try (Connection conn = SQLConnection.getConnection()) {
            // Get teacher_id
            int teacherId = 0;
            PreparedStatement psTeacher = conn.prepareStatement(
                "SELECT teacher_id FROM teachers WHERE user_id = ?"
            );
            psTeacher.setInt(1, user.getUserId());
            ResultSet rsTeacher = psTeacher.executeQuery();
            if (rsTeacher.next()) {
                teacherId = rsTeacher.getInt("teacher_id");
            } else {
                session.setAttribute("deleteMessage", "Teacher not found.");
                response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp?page=teacher_upload_timetable.jsp");
                return;
            }

            // Check if timetable belongs to this teacher
            PreparedStatement psCheck = conn.prepareStatement(
                "SELECT file_path FROM timetables WHERE id = ? AND teacher_id = ?"
            );
            psCheck.setInt(1, timetableId);
            psCheck.setInt(2, teacherId);
            ResultSet rsCheck = psCheck.executeQuery();

            if (rsCheck.next()) {
                String filePath = rsCheck.getString("file_path");

                // Delete file from filesystem
                String fullPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "timetables" + File.separator + filePath;
                File file = new File(fullPath);
                if (file.exists()) {
                    file.delete();
                }

                // Delete from database
                PreparedStatement psDelete = conn.prepareStatement(
                    "DELETE FROM timetables WHERE id = ?"
                );
                psDelete.setInt(1, timetableId);
                psDelete.executeUpdate();

            session.setAttribute("deleteMessage", "Timetable deleted successfully!");
            } else {
                session.setAttribute("deleteMessage", "Timetable not found or access denied.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("deleteMessage", "Error deleting timetable: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp?page=teacher_upload_timetable.jsp");
    }
}
