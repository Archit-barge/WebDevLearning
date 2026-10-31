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

@WebServlet("/getSubjectTable")
public class GetSubjectsTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (Connection conn = SQLConnection.getConnection()) {
            String sql = "SELECT subject_id, subject_name, subject_code, description FROM subjects ORDER BY subject_name ASC";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            if (!rs.isBeforeFirst()) {
                response.getWriter().write(
                    "<tr><td colspan='4' style='text-align: center;'>No subjects found. Add one using the form above.</td></tr>"
                );
            } else {
                while (rs.next()) {
                    int subjectId = rs.getInt("subject_id");
                    
                    String subjectName = rs.getString("subject_name");
                    String subjectCode = rs.getString("subject_code");
                    String description = rs.getString("description");
                    
                    response.getWriter().write(
                        "<tr>" +
                            "<td>" + escapeHtml(subjectName) + "</td>" +
                            "<td>" + escapeHtml(subjectCode) + "</td>" +
                            "<td>" + escapeHtml(description != null ? description : "-") + "</td>" +
                            "<td>" +
                            "<button type='button' class='action-btn edit' " +
                                "onclick=\"openEditSubjectModal(" + subjectId + ", '" + escapeJsAttr(subjectName) + "', '" + escapeJsAttr(subjectCode) + "', '" + escapeJsAttr(description) + "')\">" +
                                "<i class='fas fa-edit'></i> Edit</button> " +
                            "<button type='button' class='action-btn delete' " +
                                "onclick=\"deleteSubject(" + subjectId + ", '" + escapeJsAttr(subjectName) + "')\">" +
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
                "<tr><td colspan='4' style='text-align: center;'>Error loading subjects.</td></tr>"
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
