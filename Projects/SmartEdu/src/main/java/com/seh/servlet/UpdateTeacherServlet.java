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

@WebServlet("/updateTeacher")
public class UpdateTeacherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String teacherIdStr = request.getParameter("teacherId");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String employeeId = request.getParameter("employeeId");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String classIdStr = request.getParameter("classId");
        String subjectIdStr = request.getParameter("subjectId");
        String address = request.getParameter("address");

        response.setContentType("text/html;charset=UTF-8");

        if (teacherIdStr == null ||
                firstName == null || firstName.trim().isEmpty() ||
                lastName == null || lastName.trim().isEmpty() ||
                employeeId == null || employeeId.trim().isEmpty() ||
                username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {

            response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Required fields are missing</div>");
            return;
        }

        try {
            int teacherId = Integer.parseInt(teacherIdStr);
            firstName = firstName.trim();
            lastName = lastName.trim();
            employeeId = employeeId.trim();
            username = username.trim();
            email = email.trim();
            password = password.trim();
            phone = (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null;
            address = (address != null && !address.trim().isEmpty()) ? address.trim() : null;

            Integer classId = null;
            if (classIdStr != null && !classIdStr.trim().isEmpty()) {
                try {
                    classId = Integer.parseInt(classIdStr);
                } catch (NumberFormatException e) {
                    classId = null;
                }
            }

            Integer subjectId = null;
            if (subjectIdStr != null && !subjectIdStr.trim().isEmpty()) {
                try {
                    subjectId = Integer.parseInt(subjectIdStr);
                } catch (NumberFormatException e) {
                    subjectId = null;
                }
            }

            Connection conn = null;
            PreparedStatement stmt = null;

            try {
                conn = SQLConnection.getConnection();

                String updateTeacherSql = "UPDATE teachers SET employee_id = ?, first_name = ?, last_name = ?, " +
                        "phone = ?, address = ?, subject_id = ? " +
                        "WHERE teacher_id = ?";

                stmt = conn.prepareStatement(updateTeacherSql);
                stmt.setString(1, employeeId);
                stmt.setString(2, firstName);
                stmt.setString(3, lastName);
                stmt.setString(4, phone);
                stmt.setString(5, address);

                if (subjectId != null) {
                    stmt.setInt(6, subjectId);
                } else {
                    stmt.setNull(6, java.sql.Types.INTEGER);
                }

                stmt.setInt(7, teacherId);

                int result = stmt.executeUpdate();
                stmt.close();

                if (classId != null) {
                    String clearClassSql = "UPDATE classes SET teacher_id = NULL WHERE teacher_id = ?";
                    stmt = conn.prepareStatement(clearClassSql);
                    stmt.setInt(1, teacherId);
                    stmt.executeUpdate();
                    stmt.close();

                    String assignClassSql = "UPDATE classes SET teacher_id = ? WHERE class_id = ?";
                    stmt = conn.prepareStatement(assignClassSql);
                    stmt.setInt(1, teacherId);
                    stmt.setInt(2, classId);
                    stmt.executeUpdate();
                    stmt.close();
                }

                if (result > 0) {

                    String updateUserSql = "UPDATE users SET username = ?, email = ?, password = ? " +
                            "WHERE user_id = (SELECT user_id FROM teachers WHERE teacher_id = ?)";

                    stmt = conn.prepareStatement(updateUserSql);
                    stmt.setString(1, username);
                    stmt.setString(2, email);
                    stmt.setString(3, password);
                    stmt.setInt(4, teacherId);
                    stmt.executeUpdate();
                    stmt.close();

                    response.getWriter().write(
                            "<div class='alert alert-success'><i class='fas fa-check-circle'></i> Teacher updated successfully!</div>");
                } else {
                    response.getWriter().write(
                            "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Error updating teacher.</div>");
                }

            } catch (SQLException e) {
                e.printStackTrace();
                response.getWriter().write(
                        "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: " +
                                e.getMessage() + "</div>");
            } finally {
                SQLConnection.closeResources(conn, stmt);
            }

        } catch (NumberFormatException e) {
            response.getWriter().write(
                    "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid input format</div>");
        }
    }
}
