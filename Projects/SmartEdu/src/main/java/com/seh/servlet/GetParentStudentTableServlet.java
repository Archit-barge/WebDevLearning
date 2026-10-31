package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/getParentStudentTable")
public class GetParentStudentTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String search = request.getParameter("search");
        String classId = request.getParameter("classId");
        String excludeParentId = request.getParameter("excludeParentId");

        if (search == null) {
            search = "";
        }
        if (classId == null) {
            classId = "";
        }
        if (excludeParentId == null) {
            excludeParentId = "";
        }

        StringBuilder sql = new StringBuilder(
                "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, c.class_name, c.section " +
                "FROM students s " +
                "LEFT JOIN classes c ON s.class_id = c.class_id ");

        boolean excludeLinked = !excludeParentId.trim().isEmpty();
        if (excludeLinked) {
            sql.append("LEFT JOIN student_parents sp ON s.student_id = sp.student_id AND sp.parent_id = ? ");
        }

        sql.append("WHERE 1=1 ");
        if (excludeLinked) {
            sql.append("AND sp.student_id IS NULL ");
        }
        if (!search.trim().isEmpty()) {
            sql.append("AND (s.first_name LIKE ? OR s.last_name LIKE ? OR s.roll_number LIKE ?) ");
        }
        if (!classId.trim().isEmpty()) {
            sql.append("AND s.class_id = ? ");
        }
        sql.append("ORDER BY s.roll_number ASC");

        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString());
             PrintWriter out = response.getWriter()) {

            int index = 1;
            if (excludeLinked) {
                stmt.setInt(index++, Integer.parseInt(excludeParentId));
            }
            if (!search.trim().isEmpty()) {
                String like = "%" + search.trim() + "%";
                stmt.setString(index++, like);
                stmt.setString(index++, like);
                stmt.setString(index++, like);
            }
            if (!classId.trim().isEmpty()) {
                stmt.setInt(index, Integer.parseInt(classId));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                boolean hasData = false;
                while (rs.next()) {
                    hasData = true;
                    int sid = rs.getInt("student_id");
                    String roll = rs.getString("roll_number") != null ? rs.getString("roll_number") : "-";
                    String firstName = rs.getString("first_name") != null ? rs.getString("first_name") : "";
                    String lastName = rs.getString("last_name") != null ? rs.getString("last_name") : "";
                    String fullName = (firstName + " " + lastName).trim();
                    String className = rs.getString("class_name");
                    String section = rs.getString("section");
                    String classDisplay = className != null ? className + (section != null ? " - " + section : "") : "Unassigned";

                    out.println("<tr>");
                    out.println("<td>" + escapeHtml(roll) + "</td>");
                    out.println("<td>" + escapeHtml(fullName) + "</td>");
                    out.println("<td>" + escapeHtml(classDisplay) + "</td>");
                    out.println("<td>");
                    out.println("<button type='button' class='action-btn view' onclick=\"selectStudentForParent(" +
                            sid + ", '" + escapeJsAttr(fullName) + "', '" + escapeJsAttr(roll) + "')\">");
                    out.println("<i class='fas fa-link'></i> Link</button>");
                    out.println("</td>");
                    out.println("</tr>");
                }

                if (!hasData) {
                    out.println("<tr><td colspan='4' style='text-align: center; color: #94a3b8;'>No students found</td></tr>");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write(
                    "<tr><td colspan='4' style='text-align: center; color: #dc2626;'>Error loading students</td></tr>");
        }
    }

    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String escapeJs(String value) {
        if (value == null) {
            return "";
        }
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
