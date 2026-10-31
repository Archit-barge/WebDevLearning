package com.seh.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;
import com.seh.util.SQLConnection;

@WebServlet("/addClassSubject")
public class AddClassSubjectServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");

        String classIdStr = request.getParameter("classId");
        String subjectIdStr = request.getParameter("subjectId");
        String teacherIdStr = request.getParameter("teacherId");

        // Validate required fields
        if (classIdStr == null || classIdStr.trim().isEmpty()) {
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Class is required.</div>"
            );
            return;
        }

        if (subjectIdStr == null || subjectIdStr.trim().isEmpty()) {
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Subject is required.</div>"
            );
            return;
        }

        if (teacherIdStr == null || teacherIdStr.trim().isEmpty()) {
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Teacher is required.</div>"
            );
            return;
        }

        // Parse IDs
        int classId;
        int subjectId;
        int teacherId;

        try {
            classId = Integer.parseInt(classIdStr.trim());
            subjectId = Integer.parseInt(subjectIdStr.trim());
            teacherId = Integer.parseInt(teacherIdStr.trim());
        } catch (NumberFormatException e) {
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid ID format.</div>"
            );
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = SQLConnection.getConnection();

            // Check if class exists
            String checkClassSql = "SELECT COUNT(*) FROM classes WHERE class_id = ?";
            stmt = conn.prepareStatement(checkClassSql);
            stmt.setInt(1, classId);
            rs = stmt.executeQuery();

            if (rs.next() && rs.getInt(1) == 0) {
                response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Selected class does not exist.</div>"
                );
                SQLConnection.closeResources(conn, rs, stmt);
                return;
            }

            SQLConnection.closeResources(conn, rs, stmt);
            conn = SQLConnection.getConnection();

            // Check if subject exists
            String checkSubjectSql = "SELECT COUNT(*) FROM subjects WHERE subject_id = ?";
            stmt = conn.prepareStatement(checkSubjectSql);
            stmt.setInt(1, subjectId);
            rs = stmt.executeQuery();

            if (rs.next() && rs.getInt(1) == 0) {
                response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Selected subject does not exist.</div>"
                );
                SQLConnection.closeResources(conn, rs, stmt);
                return;
            }

            SQLConnection.closeResources(conn, rs, stmt);
            conn = SQLConnection.getConnection();

            // Check if teacher exists
            String checkTeacherSql = "SELECT COUNT(*) FROM teachers WHERE teacher_id = ?";
            stmt = conn.prepareStatement(checkTeacherSql);
            stmt.setInt(1, teacherId);
            rs = stmt.executeQuery();

            if (rs.next() && rs.getInt(1) == 0) {
                response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Selected teacher does not exist.</div>"
                );
                SQLConnection.closeResources(conn, rs, stmt);
                return;
            }

            SQLConnection.closeResources(conn, rs, stmt);
            conn = SQLConnection.getConnection();

            // Check for duplicate class_subject assignment
            String checkDuplicateSql = "SELECT COUNT(*) FROM class_subjects WHERE class_id = ? AND subject_id = ?";
            stmt = conn.prepareStatement(checkDuplicateSql);
            stmt.setInt(1, classId);
            stmt.setInt(2, subjectId);
            rs = stmt.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> This subject is already assigned to this class.</div>"
                );
                SQLConnection.closeResources(conn, rs, stmt);
                return;
            }

            SQLConnection.closeResources(conn, rs, stmt);
            conn = SQLConnection.getConnection();

            // Insert the class_subject
            String insertSql = "INSERT INTO class_subjects (class_id, subject_id, teacher_id) VALUES (?, ?, ?)";
            stmt = conn.prepareStatement(insertSql);
            stmt.setInt(1, classId);
            stmt.setInt(2, subjectId);
            stmt.setInt(3, teacherId);

            int result = stmt.executeUpdate();

            if (result > 0) {
                response.getWriter().write(
                    "<div class='alert alert-success'><i class='fas fa-check-circle'></i> Class subject assigned successfully!</div>"
                );
                response.getWriter().write("<script>setTimeout(function() { location.reload(); }, 1500);</script>");
            } else {
                response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Failed to assign subject to class.</div>"
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: " + e.getMessage() + "</div>"
            );
        } finally {
            SQLConnection.closeResources(conn, rs, stmt);
        }
    }
}
