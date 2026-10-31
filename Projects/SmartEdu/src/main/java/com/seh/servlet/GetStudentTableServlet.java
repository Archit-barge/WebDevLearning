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

@WebServlet("/getStudentTable")
public class GetStudentTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search") != null ? request.getParameter("search").trim() : "";
        String classFilter = request.getParameter("class") != null ? request.getParameter("class").trim() : "";
        String genderFilter = request.getParameter("gender") != null ? request.getParameter("gender").trim() : "";
        String source = request.getParameter("source") != null ? request.getParameter("source").trim() : "admin";

        response.setContentType("text/html;charset=UTF-8");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = SQLConnection.getConnection();

            String sql = "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, s.phone, s.gender, s.date_of_birth, s.address, s.admission_date, s.class_id, " +
            		"c.class_name, c.section, u.username, u.email, u.password, u.status "+
                        "FROM students s " +
                        "LEFT JOIN users u ON s.user_id = u.user_id " +
                        "LEFT JOIN classes c ON s.class_id = c.class_id " +
                        "WHERE 1=1 ";

            

            if (!search.isEmpty()) {
                sql += "AND (s.first_name LIKE ? OR s.last_name LIKE ? OR s.roll_number LIKE ? OR u.email LIKE ? OR u.username LIKE ?) ";
            }

            if (!classFilter.isEmpty()) {
                sql += "AND s.class_id = ? ";
            }

            if (!genderFilter.isEmpty()) {
                sql += "AND s.gender = ? ";
            }

            sql += "ORDER BY s.roll_number ASC";

            stmt = conn.prepareStatement(sql);
            int paramIndex = 1;

            if (!search.isEmpty()) {
                String searchTerm = "%" + search + "%";
                stmt.setString(paramIndex++, searchTerm);
                stmt.setString(paramIndex++, searchTerm);
                stmt.setString(paramIndex++, searchTerm);
                stmt.setString(paramIndex++, searchTerm);
                stmt.setString(paramIndex++, searchTerm);
            }

            if (!classFilter.isEmpty()) {
                try {
                    stmt.setInt(paramIndex++, Integer.parseInt(classFilter));
                } catch (NumberFormatException e) {
                    // skip if not a valid number
                }
            }

            if (!genderFilter.isEmpty()) {
                stmt.setString(paramIndex++, genderFilter);
            }

            rs = stmt.executeQuery();

            boolean hasData = false;
            StringBuilder html = new StringBuilder();

            while (rs.next()) {
                hasData = true;
                int studentId = rs.getInt("student_id");
                String rollNumber = rs.getString("roll_number");
                String firstName = rs.getString("first_name") != null ? rs.getString("first_name") : "";
                String lastName = rs.getString("last_name") != null ? rs.getString("last_name") : "";
                String fullName = (firstName + " " + lastName).trim();
                if (fullName.isEmpty()) fullName = "Unknown Student";
                String avatarLetter = !firstName.isEmpty() ? firstName.substring(0, 1).toUpperCase() : "S";
                String className = rs.getString("class_name");
                String section = rs.getString("section");
                String classDisplay = (className != null && section != null) ? className + "-" + section : "-";
                String username = rs.getString("username") != null ? rs.getString("username") : "-";
                String password = rs.getString("password") != null ? rs.getString("password") : "";
                String email = rs.getString("email") != null ? rs.getString("email") : "-";
                String phone = rs.getString("phone") != null ? rs.getString("phone") : "-";
                String gender = rs.getString("gender") != null ? rs.getString("gender") : "";
                String dateOfBirth = rs.getString("date_of_birth") != null ? rs.getString("date_of_birth") : "";
                String address = rs.getString("address") != null ? rs.getString("address") : "";
                String admissionDate = rs.getString("admission_date") != null ? rs.getString("admission_date") : "";
                String status = rs.getString("status") != null ? rs.getString("status") : "";
                int classId = rs.getInt("class_id");

                html.append("<tr>")
                    .append("<td>").append(rollNumber).append("</td>")
                    .append("<td>")
                    .append("<div class='student-info'>")
                    .append("<div class='student-avatar'>").append(avatarLetter).append("</div>")
                    .append("<div class='student-details'>")
                    .append("<h6>").append(fullName).append("</h6>")
                    .append("</div>")
                    .append("</div>")
                    .append("</td>");
                
                if ("admin".equals(source)) {
                    html.append("<td>").append(username).append("</td>");
                }
                
                html.append("<td>").append(classDisplay).append("</td>")
                    .append("<td>").append(phone).append("</td>");

                if ("admin".equals(source)) {
                    html.append("<td>")
                        .append("<button type='button' class='action-btn edit' onclick=\"openEditStudentModal(")
                        .append(studentId).append(", '").append(escapeJsAttr(fullName)).append("', '")
                        .append(escapeJsAttr(rollNumber)).append("', '").append(escapeJsAttr(username)).append("', '")
                        .append(escapeJsAttr(email)).append("', '").append(escapeJsAttr(dateOfBirth)).append("', '")
                        .append(escapeJsAttr(gender)).append("', '").append(escapeJsAttr(phone)).append("', ")
                        .append(classId).append(", '").append(escapeJsAttr(address)).append("', '")
                        .append(escapeJsAttr(admissionDate)).append("', '").append(escapeJsAttr(password)).append("')\">")
                        .append("<i class='fas fa-edit'></i> Edit")
                        .append("</button> ")
                        .append("<button type='button' class='action-btn view' onclick=\"openViewModal(")
                        .append(studentId).append(", '").append(escapeJsAttr(fullName)).append("', '")
                        .append(escapeJsAttr(username)).append("', '").append(escapeJsAttr(email)).append("', '")
                        .append(escapeJsAttr(rollNumber)).append("', '").append(escapeJsAttr(dateOfBirth)).append("', '")
                        .append(escapeJsAttr(gender)).append("', '").append(escapeJsAttr(phone)).append("', '")
                        .append(escapeJsAttr(classDisplay)).append("', '").append(escapeJsAttr(address)).append("', '")
                        .append(escapeJsAttr(admissionDate)).append("', '").append(escapeJsAttr(status)).append("', '")
                        .append(escapeJsAttr(password)).append("')\">")
                        .append("<i class='fas fa-eye'></i> View")
                        .append("</button> ")
                        .append("<button type='button' class='action-btn delete' onclick=\"deleteStudent(")
                        .append(studentId).append(", '").append(escapeJsAttr(fullName)).append("')\">")
                        .append("<i class='fas fa-trash'></i> Delete")
                        .append("</button>")
                        .append("</td>");
                } else if ("teacher".equals(source)) {
                    html.append("<td>").append(email).append("</td>");
                }
                html.append("</tr>");
            }

            if (!hasData) {
                int colspan = "teacher".equals(source) ? 5 : 6;
                html.append("<tr><td colspan='").append(colspan).append("' class='no-data'>No students found.</td></tr>");
            }

            response.getWriter().write(html.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQL Error in GetStudentTableServlet: " + e.getMessage());
            response.getWriter().write("<tr><td colspan='6' class='table-cell-error'>Error loading students.</td></tr>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private String escapeJs(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                   .replace("'", "\\'")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r");
    }

    private String escapeJsAttr(String value) {
        String jsEscaped = escapeJs(value);
        return jsEscaped.replace("&", "&amp;")
                        .replace("<", "&lt;")
                        .replace(">", "&gt;")
                        .replace("\"", "&quot;");
    }
}
