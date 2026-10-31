package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/teacher/ResultAnalysisServlet")
public class ResultAnalysisServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String classId = request.getParameter("classId");
        String subjectId = request.getParameter("subjectId");
        String examName = request.getParameter("examName");

        // Perform analysis if all parameters are provided
        if (classId != null && subjectId != null && examName != null 
                && !classId.isEmpty() && !subjectId.isEmpty() && !examName.isEmpty()) {

            try (Connection conn = SQLConnection.getConnection()) {

                // Get basic statistics
                String sql = "SELECT " +
                    "COUNT(*) AS total_students, " +
                    "SUM(CASE WHEN marks >= 35 THEN 1 ELSE 0 END) AS pass_count, " +
                    "SUM(CASE WHEN marks < 35 THEN 1 ELSE 0 END) AS fail_count, " +
                    "MAX(marks) AS highest_marks, " +
                    "MIN(marks) AS lowest_marks, " +
                    "AVG(marks) AS average_marks, " +
                    "(SUM(CASE WHEN marks >= 35 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS pass_percentage " +
                    "FROM results " +
                    "WHERE class_id = ? AND subject_id = ? AND exam_name = ?";

                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(classId));
                ps.setInt(2, Integer.parseInt(subjectId));
                ps.setString(3, examName);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    request.setAttribute("total", rs.getInt("total_students"));
                    request.setAttribute("pass", rs.getInt("pass_count"));
                    request.setAttribute("fail", rs.getInt("fail_count"));
                    request.setAttribute("highest", rs.getInt("highest_marks"));
                    request.setAttribute("lowest", rs.getInt("lowest_marks"));
                    request.setAttribute("average", Math.round(rs.getDouble("average_marks") * 100.0) / 100.0);
                    request.setAttribute("percentage", Math.round(rs.getDouble("pass_percentage") * 100.0) / 100.0);
                }

                rs.close();
                ps.close();

                // Get grade distribution
                sql = "SELECT " +
                    "SUM(CASE WHEN marks >= 90 THEN 1 ELSE 0 END) AS grade_a, " +
                    "SUM(CASE WHEN marks >= 80 AND marks < 90 THEN 1 ELSE 0 END) AS grade_b, " +
                    "SUM(CASE WHEN marks >= 70 AND marks < 80 THEN 1 ELSE 0 END) AS grade_c, " +
                    "SUM(CASE WHEN marks >= 60 AND marks < 70 THEN 1 ELSE 0 END) AS grade_d, " +
                    "SUM(CASE WHEN marks >= 50 AND marks < 60 THEN 1 ELSE 0 END) AS grade_e, " +
                    "SUM(CASE WHEN marks < 50 THEN 1 ELSE 0 END) AS grade_f " +
                    "FROM results " +
                    "WHERE class_id = ? AND subject_id = ? AND exam_name = ?";
                
                ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(classId));
                ps.setInt(2, Integer.parseInt(subjectId));
                ps.setString(3, examName);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    request.setAttribute("gradeA", rs.getInt("grade_a"));
                    request.setAttribute("gradeB", rs.getInt("grade_b"));
                    request.setAttribute("gradeC", rs.getInt("grade_c"));
                    request.setAttribute("gradeD", rs.getInt("grade_d"));
                    request.setAttribute("gradeE", rs.getInt("grade_e"));
                    request.setAttribute("gradeF", rs.getInt("grade_f"));
                }

                rs.close();
                ps.close();

                // Get selected class and subject names
                ps = conn.prepareStatement("SELECT class_name, section FROM classes WHERE class_id = ?");
                ps.setInt(1, Integer.parseInt(classId));
                rs = ps.executeQuery();
                if (rs.next()) {
                    request.setAttribute("selectedClassName", rs.getString("class_name") + " - " + rs.getString("section"));
                }
                rs.close();
                ps.close();

                ps = conn.prepareStatement("SELECT subject_name FROM subjects WHERE subject_id = ?");
                ps.setInt(1, Integer.parseInt(subjectId));
                rs = ps.executeQuery();
                if (rs.next()) {
                    request.setAttribute("selectedSubjectName", rs.getString("subject_name"));
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.getRequestDispatcher("/WEB-INF/teacher/resultAnalysis.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
