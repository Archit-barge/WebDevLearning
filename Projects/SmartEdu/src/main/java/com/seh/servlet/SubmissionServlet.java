package com.seh.servlet;

import com.seh.util.SQLConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/teacher/SubmissionServlet")
public class SubmissionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/teacher/SubmissionTracker.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String classIdStr = request.getParameter("classId");
        String subjectIdStr = request.getParameter("subjectId");
        String activity = request.getParameter("activity");
        String rowsStr = request.getParameter("rows");

        if (classIdStr == null || subjectIdStr == null || activity == null || rowsStr == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/SubmissionServlet");
            return;
        }

        int classId = Integer.parseInt(classIdStr);
        int subjectId = Integer.parseInt(subjectIdStr);
        int rows = Integer.parseInt(rowsStr);

        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false);

            // Delete previous submissions
            try (PreparedStatement psDel = conn.prepareStatement(
                    "DELETE FROM submissions WHERE class_id=? AND subject_id=? AND activity_name=?")) {
                psDel.setInt(1, classId);
                psDel.setInt(2, subjectId);
                psDel.setString(3, activity);
                psDel.executeUpdate();
            }

            // Insert new submissions
            try (PreparedStatement psIns = conn.prepareStatement(
                    "INSERT INTO submissions (student_id, class_id, subject_id, activity_name, submitted) VALUES (?, ?, ?, ?, 1)")) {
                for (int i = 1; i <= rows; i++) {
                    String studentIdStr = request.getParameter("student_" + i);
                    if (studentIdStr != null) {
                        psIns.setInt(1, Integer.parseInt(studentIdStr));
                        psIns.setInt(2, classId);
                        psIns.setInt(3, subjectId);
                        psIns.setString(4, activity);
                        psIns.addBatch();
                    }
                }
                psIns.executeBatch();
            }

            conn.commit();
            response.setContentType("text/plain");
            response.getWriter().write("success");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("ERROR: " + e.getMessage());
        }
    }
}