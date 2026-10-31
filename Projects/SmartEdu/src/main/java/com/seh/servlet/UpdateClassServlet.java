package com.seh.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;
import com.seh.util.SQLConnection;

@WebServlet("/updateClass")
public class UpdateClassServlet extends HttpServlet {
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
        String className = request.getParameter("className");
        String section = request.getParameter("section");
        String capacityStr = request.getParameter("capacity");
        String classTeacherId = request.getParameter("classTeacherId");

        if (classIdStr == null || className == null || className.trim().isEmpty()) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid input.</div>");
            return;
        }

        try {
            int classId = Integer.parseInt(classIdStr);
            int capacity = Integer.parseInt(capacityStr != null ? capacityStr : "40");
            
            if (capacity <= 0) {
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Capacity must be positive.</div>");
                return;
            }

            className = className.trim();
            section = section != null && !section.trim().isEmpty() ? section.trim() : null;

            Integer teacherId = null;
            if (classTeacherId != null && !classTeacherId.trim().isEmpty() && !classTeacherId.equals("null")) {
                try {
                    teacherId = Integer.parseInt(classTeacherId.trim());
                } catch (NumberFormatException e) {
                    response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid teacher selected.</div>");
                    return;
                }
            }

            try (Connection conn = SQLConnection.getConnection()) {
                String updateSql = "UPDATE classes SET class_name = ?, section = ?, max_students = ?, teacher_id = ? WHERE class_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, className);
                    if (section != null) {
                        ps.setString(2, section);
                    } else {
                        ps.setNull(2, java.sql.Types.VARCHAR);
                    }
                    ps.setInt(3, capacity);
                    if (teacherId != null) {
                        ps.setInt(4, teacherId);
                    } else {
                        ps.setNull(4, java.sql.Types.INTEGER);
                    }
                    ps.setInt(5, classId);

                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        response.getWriter().write("<div class='alert alert-success'><i class='fas fa-check-circle'></i> Class updated successfully!</div>");
                    } else {
                        response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Class not found.</div>");
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: " + e.getMessage() + "</div>");
            }
        } catch (NumberFormatException e) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid number format.</div>");
        }
    }
}
