package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

import com.seh.util.SQLConnection;

@WebServlet("/addTeacher")
public class addTeacherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String employeeId = request.getParameter("employeeId");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String subjectId = request.getParameter("subjectId");

        Connection conn = null;

        try {
            conn = SQLConnection.getConnection();

            if (conn == null) {
                request.getSession().setAttribute("error", "Unable to connect with Database");
                response.sendRedirect("admin/Index.jsp?page=add_teacher.jsp");
                return;
            }
            if (userExists(username, email)) {
                request.getSession().setAttribute("error", "Username or email already exists");
                response.sendRedirect("admin/Index.jsp?page=add_teacher.jsp");
                return;
            }
            if (empIdExists(employeeId)) {
                request.getSession().setAttribute("error", "Employee Id already exists");
                response.sendRedirect("admin/Index.jsp?page=add_teacher.jsp");
                return;
            }

            boolean success = addTeacher(username, password, email, employeeId, firstName, lastName,
                    phone, address, subjectId);

            if (success) {
                request.getSession().setAttribute("success", "Teacher added successfully");
            } else {
                request.getSession().setAttribute("error", "An error occurred while adding the teacher");
            }
            response.sendRedirect("admin/Index.jsp?page=add_teacher.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect("admin/Index.jsp?page=add_teacher.jsp");
        } finally {
            SQLConnection.closeResources(conn);
        }
    }

    private boolean userExists(String username, String email) throws SQLException {
        try (Connection conn = SQLConnection.getConnection();
                PreparedStatement stmt = conn
                        .prepareStatement("SELECT COUNT(*) FROM users WHERE username=? OR email=?")) {
            stmt.setString(1, username);
            stmt.setString(2, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private boolean empIdExists(String employeeId) throws SQLException {
        try (Connection conn = SQLConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM teachers WHERE employee_id=?")) {
            stmt.setString(1, employeeId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private boolean addTeacher(String username, String password, String email, String employeeId,
            String firstName, String lastName, String phone, String address,
            String subjectId) throws SQLException {
        Connection conn = null;
        PreparedStatement userStatement = null;
        PreparedStatement teacherStatement = null;
        ResultSet generatedKeys = null;
        try {
            conn = SQLConnection.getConnection();
            conn.setAutoCommit(false);

            String userQuery = "INSERT INTO users(username, password, email, role) VALUES (?, ?, ?, 'teacher')";
            userStatement = conn.prepareStatement(userQuery, PreparedStatement.RETURN_GENERATED_KEYS);
            userStatement.setString(1, username);
            userStatement.setString(2, password);
            userStatement.setString(3, email);

            int userRowsAffected = userStatement.executeUpdate();
            if (userRowsAffected == 0) {
                conn.rollback();
                return false;
            }

            generatedKeys = userStatement.getGeneratedKeys();
            int userId = 0;
            if (generatedKeys.next()) {
                userId = generatedKeys.getInt(1);
            }

            String teacherQuery = "INSERT INTO teachers(user_id, employee_id, first_name, last_name, phone, address, subject_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
            teacherStatement = conn.prepareStatement(teacherQuery);
            teacherStatement.setInt(1, userId);
            teacherStatement.setString(2, employeeId);
            teacherStatement.setString(3, firstName);
            teacherStatement.setString(4, lastName);
            teacherStatement.setString(5, phone);
            teacherStatement.setString(6, address);

            if (subjectId != null && !subjectId.trim().isEmpty()) {
                teacherStatement.setInt(7, Integer.parseInt(subjectId));
            } else {
                teacherStatement.setNull(7, java.sql.Types.INTEGER);
            }

            int rowsAffected = teacherStatement.executeUpdate();
            if (rowsAffected > 0) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }

        } catch (Exception e) {
            if (conn != null)
                conn.rollback();
            throw e;
        } finally {
            if (generatedKeys != null)
                generatedKeys.close();
            SQLConnection.closeResources(conn, teacherStatement);
            if (userStatement != null)
                userStatement.close();
        }
    }
}
