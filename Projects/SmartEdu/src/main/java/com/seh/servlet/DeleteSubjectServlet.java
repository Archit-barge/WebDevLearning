package com.seh.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.util.SQLConnection;

@WebServlet("/deleteSubject")
public class DeleteSubjectServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String idStr = request.getParameter("subjectId");
        if (idStr == null || idStr.trim().isEmpty()) {
            out.print("Invalid subject ID.");
            return;
        }

        int subjectId = Integer.parseInt(idStr);

        Connection conn = null;
        PreparedStatement psClearTeachers = null;
        PreparedStatement psDeleteSubject = null;

        try {
            conn = SQLConnection.getConnection();
            conn.setAutoCommit(false);

            // Example: clear subject_id in teachers so delete is safe
            psClearTeachers = conn.prepareStatement(
                    "UPDATE teachers SET subject_id = NULL WHERE subject_id = ?");
            psClearTeachers.setInt(1, subjectId);
            psClearTeachers.executeUpdate();

            // If you have subject allocation table(s), clear them here similarly.

            psDeleteSubject = conn.prepareStatement(
                    "DELETE FROM subjects WHERE subject_id = ?");
            psDeleteSubject.setInt(1, subjectId);
            int deleted = psDeleteSubject.executeUpdate();

            if (deleted > 0) {
                conn.commit();
                out.print("OK");
            } else {
                conn.rollback();
                out.print("Subject not found.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
            out.print("Error deleting subject.");
        } finally {
            try { if (psClearTeachers != null) psClearTeachers.close(); } catch (SQLException ignored) {}
            try { if (psDeleteSubject != null) psDeleteSubject.close(); } catch (SQLException ignored) {}
            SQLConnection.closeResources(conn);
        }
    }
}
