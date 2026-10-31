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

@WebServlet("/deleteClassSubject")
public class DeleteClassSubjectServlet extends HttpServlet {
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

        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid request.</div>"
            );
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid ID format.</div>"
            );
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = SQLConnection.getConnection();

            String deleteSql = "DELETE FROM class_subjects WHERE id = ?";
            stmt = conn.prepareStatement(deleteSql);
            stmt.setInt(1, id);

            int result = stmt.executeUpdate();

            if (result > 0) {
                response.getWriter().write(
                    "<div class='alert alert-success'><i class='fas fa-check-circle'></i> Class subject deleted successfully!</div>"
                );
                response.getWriter().write("<script>setTimeout(function() { location.reload(); }, 1500);</script>");
            } else {
                response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Class subject not found.</div>"
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: " + e.getMessage() + "</div>"
            );
        } finally {
            SQLConnection.closeResources(conn, null, stmt);
        }
    }
}
