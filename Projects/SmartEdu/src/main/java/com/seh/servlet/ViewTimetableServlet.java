package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/student/ViewTimetableServlet")
public class ViewTimetableServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String,Object>> timetables = new ArrayList<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        try (Connection con = SQLConnection.getConnection()) {

            // Get student's class_id
            int classId = 0;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT class_id FROM students WHERE user_id = ?")) {
                ps.setInt(1, user.getUserId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) classId = rs.getInt("class_id");
            }

            // Fallback: try users table
            if (classId == 0) {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT class_id FROM users WHERE user_id = ?")) {
                    ps.setInt(1, user.getUserId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) classId = rs.getInt("class_id");
                }
            }

            if (classId == 0) {
                request.setAttribute("timetables", timetables);
                request.getRequestDispatcher("/WEB-INF/student/student_timetable.jsp")
                       .forward(request, response);
                return;
            }

            // Fetch timetables from documents table for this student's class OR all classes
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT document_id, original_file_name, upload_date " +
                    "FROM documents " +
                    "WHERE document_type = 'TIMETABLES' " +
                    "  AND (class_id = ? OR class_id IS NULL OR class_id = 0) " +
                    "ORDER BY upload_date DESC")) {

                ps.setInt(1, classId);
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    String origFile = rs.getString("original_file_name");
                    int docId = rs.getInt("document_id");

                    // Pre-compute file type from original filename
                    String fileType = "other";
                    if (origFile != null) {
                        String lower = origFile.toLowerCase();
                        if (lower.endsWith(".pdf"))                  fileType = "pdf";
                        else if (lower.endsWith(".doc") || lower.endsWith(".docx")) fileType = "doc";
                        else if (lower.matches(".*\\.(png|jpg|jpeg|gif|webp)")) fileType = "image";
                    }

                    Map<String,Object> row = new HashMap<>();
                    // 'file' = full inline URL (replaces old /uploads/timetables/<filename>)
                    row.put("file", request.getContextPath() + "/downloadDocument?id=" + docId + "&inline=true");
                    // 'fileName' = original name for display
                    row.put("fileName", origFile != null ? origFile : "timetable");
                    // 'type' = pre-computed type string
                    row.put("type", fileType);
                    // 'date' = same key as before
                    row.put("date", rs.getTimestamp("upload_date"));
                    timetables.add(row);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading timetables: " + e.getMessage());
        }

        request.setAttribute("timetables", timetables);
        request.getRequestDispatcher("/WEB-INF/student/student_timetable.jsp")
               .forward(request, response);
    }
}
