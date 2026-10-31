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

@WebServlet("/deleteClass")
public class DeleteClassServlet extends HttpServlet {
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

        if (classIdStr == null || classIdStr.trim().isEmpty()) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Class ID is required.</div>");
            return;
        }

        try {
            int classId = Integer.parseInt(classIdStr.trim());

            try (Connection conn = SQLConnection.getConnection()) {
                String deleteSql = "DELETE FROM classes WHERE class_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setInt(1, classId);

                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        response.getWriter().write("<div class='alert alert-success'><i class='fas fa-check-circle'></i> Class deleted successfully!</div>");
                    } else {
                        response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Class not found.</div>");
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: " + e.getMessage() + "</div>");
            }
        } catch (NumberFormatException e) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid class ID format.</div>");
        }
    }
}
