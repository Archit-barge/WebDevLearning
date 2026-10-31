package com.seh.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.seh.util.SQLConnection;

@WebServlet("/getTeacherTable")
public class GetTeacherTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String classFilter = request.getParameter("class");
        String subjectFilter = request.getParameter("subject");

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = SQLConnection.getConnection();

            String sql = "SELECT t.teacher_id, t.employee_id, t.first_name, t.last_name, t.phone, t.address, " +
                    "u.username, u.email, u.password, " +
                    "s.subject_id, s.subject_name, " +
                    "c.class_id, c.class_name, c.section " +
                    "FROM teachers t " +
                    "JOIN users u ON t.user_id = u.user_id " +
                    "LEFT JOIN subjects s ON t.subject_id = s.subject_id " +
                    "LEFT JOIN classes c ON c.teacher_id = t.teacher_id " +
                    "WHERE u.role = 'teacher' ";

            if (search != null && !search.trim().isEmpty()) {
                String esc = search.replace("'", "''");
                sql += "AND (t.first_name LIKE '%" + esc + "%' " +
                        "OR t.last_name LIKE '%" + esc + "%' " +
                        "OR t.employee_id LIKE '%" + esc + "%' " +
                        "OR u.username LIKE '%" + esc + "%' " +
                        "OR u.email LIKE '%" + esc + "%') ";
            }

            if (classFilter != null && !classFilter.trim().isEmpty()) {
                String esc = classFilter.replace("'", "''");
                sql += "AND c.class_id = " + esc + " ";
            }

            if (subjectFilter != null && !subjectFilter.trim().isEmpty()) {
                String esc = subjectFilter.replace("'", "''");
                sql += "AND s.subject_id = " + esc + " ";
            }

            sql += "ORDER BY t.employee_id ASC";

            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            boolean hasData = false;

            while (rs.next()) {
                hasData = true;

                int teacherId = rs.getInt("teacher_id");
                String employeeId = rs.getString("employee_id");
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                String fullName = firstName + " " + lastName;
                String avatarLetter = (firstName != null && !firstName.isEmpty()) ? firstName.substring(0, 1).toUpperCase() : "T";
                String username = rs.getString("username");
                String emailVal = rs.getString("email") != null ? rs.getString("email") : "";
                String password = rs.getString("password") != null ? rs.getString("password") : "";
                String phoneVal = rs.getString("phone") != null ? rs.getString("phone") : "-";
                String addressVal = rs.getString("address") != null ? rs.getString("address") : "";

                int classId = rs.getInt("class_id");
                String className = rs.getString("class_name");
                String section = rs.getString("section");
                String classDisplay = (className != null ? className : "-") +
                        (section != null ? "-" + section : "");

                int subjectId = rs.getInt("subject_id");
                String subjectName = rs.getString("subject_name") != null ? rs.getString("subject_name") : "-";

                out.println("<tr>");
                out.println("<td>" + escapeHtml(employeeId) + "</td>");

                out.println("<td>");
                out.println("<div class='student-info'>");
                out.println("<div class='student-avatar'>" + escapeHtml(avatarLetter) + "</div>");
                out.println("<div class='student-details'><h6>" + escapeHtml(fullName) + "</h6></div>");
                out.println("</div>");
                out.println("</td>");

                out.println("<td>" + escapeHtml(username) + "</td>");
                out.println("<td>" + escapeHtml(classDisplay) + "</td>");
                out.println("<td>" + escapeHtml(subjectName) + "</td>");
                out.println("<td>" + escapeHtml(phoneVal) + "</td>");

                out.println("<td>");
                out.println("<button type='button' class='action-btn edit' " +
                        "onclick=\"openEditTeacherModal(" +
                        teacherId + ", '" +
                        escapeJsAttr(fullName) + "', '" +
                        escapeJsAttr(username) + "', '" +
                        escapeJsAttr(emailVal) + "', '" +
                        escapeJsAttr(employeeId) + "', '" +
                        escapeJsAttr(phoneVal) + "', " +
                        classId + ", " +
                        subjectId + ", '" +
                        escapeJsAttr(addressVal) + "', '" +
                        escapeJsAttr(password) + "'" +
                        ")\">" +
                        "<i class='fas fa-edit'></i> Edit</button> ");

                out.println("<button type='button' class='action-btn view' " +
                        "onclick=\"openViewTeacherModal('" +
                        escapeJsAttr(fullName) + "', '" +
                        escapeJsAttr(username) + "', '" +
                        escapeJsAttr(emailVal) + "', '" +
                        escapeJsAttr(employeeId) + "', '" +
                        escapeJsAttr(phoneVal) + "', '" +
                        escapeJsAttr(classDisplay) + "', '" +
                        escapeJsAttr(subjectName) + "', '" +
                        escapeJsAttr(addressVal) + "', '" +
                        escapeJsAttr(password) + "'" +
                        ")\">" +
                        "<i class='fas fa-eye'></i> View</button> ");

                out.println("<button type='button' class='action-btn delete' " +
                        "onclick=\"deleteTeacher(" + teacherId + ", '" + escapeJsAttr(fullName) + "')\">" +
                        "<i class='fas fa-trash'></i> Delete</button>");
                out.println("</td>");

                out.println("</tr>");
            }

            if (!hasData) {
                out.println("<tr><td colspan='7' class='no-data'>No teachers found.</td></tr>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<tr><td colspan='7' class='table-cell-error'>Error loading teachers.</td></tr>");
        } finally {
            try {
                if (rs != null)
                    rs.close();
            } catch (SQLException ignored) {
            }
            try {
                if (stmt != null)
                    stmt.close();
            } catch (SQLException ignored) {
            }
            SQLConnection.closeResources(conn);
        }
    }

    private String escapeHtml(String s) {
        if (s == null)
            return "";
        return s.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;");
    }

    private String escapeJs(String s) {
        if (s == null)
            return "";
        return s.replace("\\", "\\\\")
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
