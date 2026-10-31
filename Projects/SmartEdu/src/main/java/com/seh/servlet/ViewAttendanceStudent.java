package com.seh.servlet;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.util.SQLConnection;
import com.seh.model.User;

@WebServlet("/student/ViewAttendanceStudent")
public class ViewAttendanceStudent extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get user from session
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get student_id from users table using user_id
        int studentId = 0;
        int classId = 0;
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = SQLConnection.getConnection();
            
            // Get student_id and class_id from students table using user_id
            String studentQuery = "SELECT student_id, class_id FROM students WHERE user_id = ?";
            pst = conn.prepareStatement(studentQuery);
            pst.setInt(1, user.getUserId());
            rs = pst.executeQuery();
            
            if (rs.next()) {
                studentId = rs.getInt("student_id");
                classId = rs.getInt("class_id");
            } else {
                // No student record found for this user
                request.setAttribute("error", "Student record not found");
                request.getRequestDispatcher("/WEB-INF/student/view_attendance.jsp").forward(request, response);
                return;
            }
            
            rs.close();
            pst.close();
            
            // ===== 1. Overall Attendance =====
            // Query the full_attendance table (not just "attendance")
            String overallQuery = "SELECT " +
                    "COUNT(*) AS total_classes, " +
                    "SUM(CASE WHEN status='present' THEN 1 ELSE 0 END) AS total_present, " +
                    "SUM(CASE WHEN status='absent' THEN 1 ELSE 0 END) AS total_absent " +
                    "FROM full_attendance WHERE student_id = ?";
            pst = conn.prepareStatement(overallQuery);
            pst.setInt(1, studentId);
            rs = pst.executeQuery();
            
            if (rs.next()) {
                request.setAttribute("total_classes", rs.getInt("total_classes"));
                request.setAttribute("total_present", rs.getInt("total_present"));
                request.setAttribute("total_absent", rs.getInt("total_absent"));
            }
            rs.close();
            pst.close();

            // ===== 2. Subject-wise Attendance =====
            // Query the full_attendance table (not just "attendance")
            String subjectQuery =
                    "SELECT s.subject_name AS subject_name, " +
                    "COUNT(fa.attendance_id) AS total_classes, " +
                    "SUM(CASE WHEN fa.status='present' THEN 1 ELSE 0 END) AS total_present, " +
                    "SUM(CASE WHEN fa.status='absent' THEN 1 ELSE 0 END) AS total_absent " +
                    "FROM full_attendance fa " +
                    "INNER JOIN subjects s ON s.subject_id = fa.subject_id " +
                    "WHERE fa.student_id = ? " +
                    "GROUP BY s.subject_id, s.subject_name";

            pst = conn.prepareStatement(subjectQuery);
            pst.setInt(1, studentId);
            rs = pst.executeQuery();

            List<Map<String, Object>> subjectAttendance = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("subject_name", rs.getString("subject_name"));
                row.put("total_classes", rs.getInt("total_classes"));
                row.put("total_present", rs.getInt("total_present"));
                row.put("total_absent", rs.getInt("total_absent"));
                subjectAttendance.add(row);
            }
            request.setAttribute("subjectAttendance", subjectAttendance);

            // Forward to JSP
            request.getRequestDispatcher("/WEB-INF/student/view_attendance.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pst != null) pst.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
