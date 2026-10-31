package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.seh.util.SQLConnection;

@WebServlet("/teacher/DownloadAttendanceServlet")
public class DownloadAttendanceServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String classId = request.getParameter("class_id");
        String subjectId = request.getParameter("subject_id");
        String date = request.getParameter("date");

        // Set CSV response
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=Attendance.csv");

        try (PrintWriter out = response.getWriter();
             Connection conn = SQLConnection.getConnection()) {

            // Write CSV header
            out.println("Student ID,Name,Roll Number,Attendance");

            String sql = "SELECT st.student_id, st.first_name, st.last_name, st.roll_number, " +
                         "IFNULL(a.status,'absent') AS status " +
                         "FROM students st " +
                         "LEFT JOIN attendance a ON a.student_id = st.student_id AND a.subject_id=? AND a.date=? " +
                         "WHERE st.class_id=? " +
                         "ORDER BY st.roll_number";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(subjectId));
            ps.setString(2, date);
            ps.setInt(3, Integer.parseInt(classId));

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int studentId = rs.getInt("student_id");
                String name = rs.getString("first_name") + " " + rs.getString("last_name");
                String roll = rs.getString("roll_number");
                String status = rs.getString("status");

                // Escape commas in names
                name = "\"" + name.replace("\"", "\"\"") + "\"";

                out.println(studentId + "," + name + "," + roll + "," + status);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
