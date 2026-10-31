package com.seh.servlet;

import java.io.IOException; 
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.util.SQLConnection;

@WebServlet("/updateSubject")
public class UpdateSubjectServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String idStr        = request.getParameter("subjectId");
        String subjectName  = request.getParameter("subjectName");
        String subjectCode  = request.getParameter("subjectCode");
        String description  = request.getParameter("description");

        if (idStr == null || idStr.trim().isEmpty()) {
            out.print("<span style='color:red;'>Invalid subject ID.</span>");
            return;
        }

        int subjectId = Integer.parseInt(idStr);

        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE subjects SET subject_name = ?, subject_code = ?, description = ? " +
                     "WHERE subject_id = ?")) {

            ps.setString(1, subjectName);
            ps.setString(2, subjectCode);
            ps.setString(3, description);
            ps.setInt(4, subjectId);

            int updated = ps.executeUpdate();
            if (updated > 0) {
                out.print("<span style='color:green;'>Subject updated successfully.</span>");
            } else {
                out.print("<span style='color:red;'>Subject not found.</span>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            out.print("<span style='color:red;'>Error updating subject.</span>");
        }
    }
}
