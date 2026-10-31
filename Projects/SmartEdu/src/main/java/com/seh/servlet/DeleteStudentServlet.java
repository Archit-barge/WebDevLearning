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

@WebServlet("/deleteStudent")
public class DeleteStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentIdStr = request.getParameter("studentId");
        response.setContentType("text/html;charset=UTF-8");

        if (studentIdStr == null) {
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid student ID</div>"
            );
            return;
        }

        try {
            int studentId = Integer.parseInt(studentIdStr);
            Connection conn = null;
            PreparedStatement stmt = null;

            try {
                conn = SQLConnection.getConnection();

                // Get user_id for this student
                String getUserIdSql = "SELECT user_id FROM students WHERE student_id = ?";
                stmt = conn.prepareStatement(getUserIdSql);
                stmt.setInt(1, studentId);
                ResultSet rs = stmt.executeQuery();

                int userId = -1;
                if (rs.next()) {
                    userId = rs.getInt("user_id");
                }
                rs.close();
                stmt.close();

                if (userId == -1) {
                    response.getWriter().write(
                        "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Student not found.</div>"
                    );
                    return;
                }

                // Delete from students
                String deleteStudentSql = "DELETE FROM students WHERE student_id = ?";
                stmt = conn.prepareStatement(deleteStudentSql);
                stmt.setInt(1, studentId);
                int result = stmt.executeUpdate();
                stmt.close();

                if (result > 0) {
                    // Delete from users
                    String deleteUserSql = "DELETE FROM users WHERE user_id = ?";
                    stmt = conn.prepareStatement(deleteUserSql);
                    stmt.setInt(1, userId);
                    stmt.executeUpdate();
                    stmt.close();

                    response.getWriter().write(
                        "<div class='alert alert-success'><i class='fas fa-check-circle'></i> Student deleted successfully!</div>"
                    );
                } else {
                    response.getWriter().write(
                        "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Error deleting student.</div>"
                    );
                }

            } catch (SQLException e) {
                e.printStackTrace();
                response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: " +
                    e.getMessage() + "</div>"
                );
            } finally {
                SQLConnection.closeResources(conn, stmt);
            }

        } catch (NumberFormatException e) {
            response.getWriter().write(
                "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid student ID format</div>"
            );
        }
    }
}
