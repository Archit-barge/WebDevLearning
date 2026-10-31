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

@WebServlet("/getClassSubjectsTable")
public class GetClassSubjectsTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        try (Connection conn = SQLConnection.getConnection()) {
            String sql = "SELECT cs.id, c.class_id, c.class_name, c.section, s.subject_id, s.subject_name, " +
                        "t.teacher_id, t.first_name, t.last_name " +
                        "FROM class_subjects cs " +
                        "JOIN classes c ON cs.class_id = c.class_id " +
                        "JOIN subjects s ON cs.subject_id = s.subject_id " +
                        "JOIN teachers t ON cs.teacher_id = t.teacher_id " +
                        "ORDER BY c.class_name, s.subject_name ASC";

            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            if (!rs.isBeforeFirst()) {
                response.getWriter().write(
                    "<tr><td colspan='5' style='text-align: center;'>No class subjects found. Add one using the form above.</td></tr>"
                );
            } else {
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String className = rs.getString("class_name");
                    String section = rs.getString("section");
                    String subjectName = rs.getString("subject_name");
                    String teacherName = rs.getString("first_name") + " " + rs.getString("last_name");

                    String classDisplay = section != null && !section.isEmpty() ? 
                        className + " - " + section : className;

                    response.getWriter().write(
                        "<tr>" +
                            "<td>" + escapeHtml(classDisplay) + "</td>" +
                            "<td>" + escapeHtml(subjectName) + "</td>" +
                            "<td>" + escapeHtml(teacherName) + "</td>" +
                            "<td>" +
                            "<button type='button' class='action-btn edit' " +
                                "onclick=\"openEditClassSubjectModal(" + id + ", " + 
                                rs.getInt("class_id") + ", " + rs.getInt("subject_id") + ", " + 
                                rs.getInt("teacher_id") + ", '" + escapeJsAttr(classDisplay) + "', '" + 
                                escapeJsAttr(subjectName) + "', '" + escapeJsAttr(teacherName) + "')\">" +
                                "<i class='fas fa-edit'></i> Edit</button> " +
                            "<button type='button' class='action-btn delete' " +
                                "onclick=\"deleteClassSubject(" + id + ", '" + escapeJsAttr(classDisplay) + 
                                "', '" + escapeJsAttr(subjectName) + "')\">" +
                                "<i class='fas fa-trash'></i> Delete</button>" +
                            "</td>" +
                        "</tr>"
                    );
                }
            }
            rs.close();
            stmt.close();

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write(
                "<tr><td colspan='5' style='text-align: center;'>Error loading class subjects.</td></tr>"
            );
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
