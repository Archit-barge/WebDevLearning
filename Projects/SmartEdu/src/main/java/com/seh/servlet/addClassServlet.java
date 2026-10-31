package com.seh.servlet;

import java.io.IOException; 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.seh.util.SQLConnection;

@WebServlet("/addClass")
public class addClassServlet extends HttpServlet {
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

        String className = request.getParameter("className");
        String section = request.getParameter("section");
        String capacityStr = request.getParameter("capacity");
        String classTeacherId = request.getParameter("classTeacherId");

        if (className == null || className.trim().isEmpty()) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Class name is required.</div>");
            return;
        }

        if (capacityStr == null || capacityStr.trim().isEmpty()) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Capacity is required.</div>");
            return;
        }

        int capacity;
        try {
            capacity = Integer.parseInt(capacityStr.trim());
            if (capacity <= 0) {
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Capacity must be a positive number.</div>");
                return;
            }
        } catch (NumberFormatException e) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid capacity number.</div>");
            return;
        }

        className = className.trim();
        section = section != null && !section.trim().isEmpty() ? section.trim() : null;

        Integer teacherId = null;
        if (classTeacherId != null && !classTeacherId.trim().isEmpty()) {
            try {
                teacherId = Integer.parseInt(classTeacherId.trim());
            } catch (NumberFormatException e) {
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid teacher selected.</div>");
                return;
            }
        }

        try (Connection conn = SQLConnection.getConnection()) {
        	
            String checkSql = "SELECT COUNT(*) FROM classes WHERE class_name = ? AND "
                            + "(section = ? OR (section IS NULL AND ? IS NULL))";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setString(1, className);
                psCheck.setString(2, section);
                psCheck.setString(3, section);

                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Class with same name and section already exists.</div>");
                        return;
                    }
                }
            }

            String insertSql = "INSERT INTO classes (class_name, section, max_students, teacher_id) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                psInsert.setString(1, className);
                if (section != null) {
                    psInsert.setString(2, section);
                } else {
                    psInsert.setNull(2, java.sql.Types.VARCHAR);
                }
                psInsert.setInt(3, capacity);
                if (teacherId != null) {
                    psInsert.setInt(4, teacherId);
                } else {
                    psInsert.setNull(4, java.sql.Types.INTEGER);
                }

                int rows = psInsert.executeUpdate();
                if (rows > 0) {
                    response.getWriter().write("<div class='alert alert-success'><i class='fas fa-check-circle'></i> Class added successfully!</div>");
                } else {
                    response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Failed to add class.</div>");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: " + e.getMessage() + "</div>");
        }
    }
}
