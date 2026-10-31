// File: src/main/java/com/seh/servlet/getClassTableServlet.java

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

@WebServlet("/getClassTable")
public class getClassTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        try (Connection conn = SQLConnection.getConnection()) {
            String sql = "SELECT c.class_id, c.class_name, c.section, c.max_students, t.teacher_id, t.first_name, t.last_name FROM classes c LEFT JOIN teachers t ON c.teacher_id = t.teacher_id ORDER BY c.class_name, c.section";

            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            if (!rs.isBeforeFirst()) {
                response.getWriter().write("<tr><td colspan='5' class='text-center'>No classes found.</td></tr>");
            } else {
                while (rs.next()) {
                    int classId = rs.getInt("class_id");
                    String className = rs.getString("class_name");
                    String rawSection = rs.getString("section");
                    String section = rawSection != null ? rawSection : "-";
                    String classDisplayName = className + ((rawSection != null && !rawSection.trim().isEmpty()) ? (" - " + rawSection) : "");
                    int capacity = rs.getInt("max_students");
                    int teacherId = rs.getInt("teacher_id");
                    String firstName = rs.getString("first_name");
                    String lastName = rs.getString("last_name");
                    String teacherName = (firstName == null || firstName.trim().isEmpty()) ? "Not Assigned" : firstName + " " + (lastName != null ? lastName : "");

                    response.getWriter().write("<tr>");
                    response.getWriter().write("<td>" + escapeHtml(className) + "</td>");
                    response.getWriter().write("<td>" + escapeHtml(section) + "</td>");
                    response.getWriter().write("<td>" + capacity + "</td>");
                    response.getWriter().write("<td>" + escapeHtml(teacherName.trim()) + "</td>");
                    response.getWriter().write("<td>");
                    response.getWriter().write("<button type='button' class='action-btn edit' onclick=\"openEditClassModal(" + classId + ", '" + escapeJsAttr(className) + "', '" + escapeJsAttr(section) + "', " + capacity + ", " + (teacherId != 0 ? teacherId : "''") + ")\">");
                    response.getWriter().write("<i class='fas fa-edit'></i> Edit");
                    response.getWriter().write("</button>");
                    response.getWriter().write("<button type='button' class='action-btn delete' onclick=\"deleteClass(" + classId + ", '" + escapeJsAttr(classDisplayName) + "')\">");
                    response.getWriter().write("<i class='fas fa-trash'></i> Delete");
                    response.getWriter().write("</button>");
                    response.getWriter().write("</td>");
                    response.getWriter().write("</tr>");
                }
            }
            rs.close();
            stmt.close();

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("<tr><td colspan='5'><div class='alert alert-error'>Database error</div></td></tr>");
        }
    }

    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
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
