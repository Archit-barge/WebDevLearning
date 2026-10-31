package com.seh.servlet;

import jakarta.servlet.ServletException; 
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;

import com.seh.util.SQLConnection;

@WebServlet("/addStudent")
public class addStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String rollNumber = request.getParameter("rollNumber");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String phone = request.getParameter("phone");
        String classId = request.getParameter("classId");
        String address = request.getParameter("address");
        String section = request.getParameter("section");
        String admissionDate = request.getParameter("admissionDate");
        Connection conn = null;

        try {
            conn = SQLConnection.getConnection();

            if (conn == null) {
                request.getSession().setAttribute("error", "Unable to connect with Database");
                response.sendRedirect("admin/Index.jsp?page=add_student.jsp");
                return;
            }
            if (userExists(username, email)) {
                request.getSession().setAttribute("error", "Username or email already exists");
                response.sendRedirect("admin/Index.jsp?page=add_student.jsp");
                return;
            }
            if (rollNumberExists(rollNumber)) {
                request.getSession().setAttribute("error", "Roll number already exists");
                response.sendRedirect("admin/Index.jsp?page=add_student.jsp");
                return;
            }

            boolean success = addStudent(username, password, email, rollNumber, firstName, lastName,
                    dateOfBirth, gender, phone, classId, address, section, admissionDate);

            if (success) {
                request.getSession().setAttribute("success", "Student added successfully");
            } else {
                request.getSession().setAttribute("error", "An error occurred while adding the student");
            }
            response.sendRedirect("admin/Index.jsp?page=add_student.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect("admin/Index.jsp?page=add_student.jsp");
        } finally {
            SQLConnection.closeResources(conn);
        }
    }

    private boolean userExists(String username, String email) throws SQLException {
        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE username=? OR email=?")) {
            stmt.setString(1, username);
            stmt.setString(2, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private boolean rollNumberExists(String rollNumber) throws SQLException {
        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM students WHERE roll_number=?")) {
            stmt.setString(1, rollNumber);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private boolean addStudent(String username, String password, String email, String rollNumber, String firstName,
                               String lastName, String dateOfBirth, String gender, String phone, String classId,
                               String address, String section, String admissionDate) throws SQLException {
        Connection conn = null;
        PreparedStatement userStatement = null;
        PreparedStatement studentStatement = null;
        ResultSet generatedKeys = null;
        try {
            conn = SQLConnection.getConnection();
            conn.setAutoCommit(false);

            String userQuery = "INSERT INTO users(username, password, email, role) VALUES (?, ?, ?, 'student')";
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

            String studentQuery = "INSERT INTO students(user_id, roll_number, first_name, last_name, date_of_birth, gender, phone, address, class_id, section, admission_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            studentStatement = conn.prepareStatement(studentQuery);
            studentStatement.setInt(1, userId);
            studentStatement.setString(2, rollNumber);
            studentStatement.setString(3, firstName);
            studentStatement.setString(4, lastName);

            if (dateOfBirth != null && !dateOfBirth.trim().isEmpty()) {
                studentStatement.setDate(5, Date.valueOf(dateOfBirth));
            } else {
                studentStatement.setNull(5, java.sql.Types.DATE);
            }
            studentStatement.setString(6, gender);
            studentStatement.setString(7, phone);
            studentStatement.setString(8, address);
            if (classId != null && !classId.trim().isEmpty()) {
                studentStatement.setInt(9, Integer.parseInt(classId));
            } else {
                studentStatement.setNull(9, java.sql.Types.INTEGER);
            }
            studentStatement.setString(10, section);
            if (admissionDate != null && !admissionDate.trim().isEmpty()) {
                studentStatement.setDate(11, Date.valueOf(admissionDate));
            } else {
                studentStatement.setNull(11, java.sql.Types.DATE);
            }

            int studentRowsAffected = studentStatement.executeUpdate();
            if (studentRowsAffected > 0) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }

        } catch (Exception e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (generatedKeys != null) generatedKeys.close();
            SQLConnection.closeResources(conn, studentStatement);
            if (userStatement != null) userStatement.close();
        }
    }
}
