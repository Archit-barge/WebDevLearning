package com.seh.servlet;

import java.io.IOException; 
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.util.SQLConnection;
import com.seh.model.User;

@WebServlet("/student/MyMarksStudentServlet")
public class MyMarksStudentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"student".equals(session.getAttribute("role"))) {
            response.sendRedirect("../login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();

        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            conn = SQLConnection.getConnection();

            // 🔹 Step 1: Get student_id
            int studentId;
            pst = conn.prepareStatement(
                    "SELECT student_id FROM students WHERE user_id = ?");
            pst.setInt(1, userId);
            rs = pst.executeQuery();

            if (!rs.next()) {
                response.getWriter().println("Student record not found.");
                return;
            }

            studentId = rs.getInt("student_id");
            rs.close();
            pst.close();

            // 🔹 Step 2: Fetch marks (JOIN with subjects)
            String query =
                    "SELECT s.subject_name, m.ut1, m.ut2, m.average, m.created_at " +
                    "FROM marks m " +
                    "JOIN subjects s ON m.subject_id = s.subject_id " +
                    "WHERE m.student_id = ? " +
                    "ORDER BY m.created_at DESC";

            pst = conn.prepareStatement(query);
            pst.setInt(1, studentId);
            rs = pst.executeQuery();

            List<Map<String, Object>> marksList = new ArrayList<>();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("subject_name", rs.getString("subject_name"));
                row.put("ut1", rs.getInt("ut1"));
                row.put("ut2", rs.getInt("ut2"));
                row.put("average", rs.getFloat("average"));
                row.put("created_at", rs.getDate("created_at"));
                marksList.add(row);
            }

            request.setAttribute("marksList", marksList);
            request.getRequestDispatcher("/WEB-INF/student/my_marks.jsp")
                   .forward(request, response);

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
