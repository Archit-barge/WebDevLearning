package com.seh.servlet;

import com.seh.util.SQLConnection;
import com.seh.util.S3Util;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/deleteAdminTimetable")
public class DeleteAdminTimetableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.getWriter().write("<div class='alert alert-danger'>Unauthorized access.</div>");
            return;
        }

        String documentId = request.getParameter("documentId");
        if (documentId == null || documentId.trim().isEmpty()) {
            response.getWriter().write("<div class='alert alert-danger'>Invalid document ID.</div>");
            return;
        }

        try (Connection con = SQLConnection.getConnection()) {

            // Fetch S3 key (file_path) and type before deleting
            String selectSql = "SELECT file_path, document_type FROM documents WHERE document_id = ? " +
                               "AND document_type IN ('TIMETABLES', 'EXAM_TIMETABLE')";
            String s3Key  = null;

            try (PreparedStatement psSel = con.prepareStatement(selectSql)) {
                psSel.setInt(1, Integer.parseInt(documentId));
                try (ResultSet rs = psSel.executeQuery()) {
                    if (rs.next()) {
                        s3Key = rs.getString("file_path");
                    }
                }
            }

            if (s3Key == null) {
                response.getWriter().write("<div class='alert alert-danger'>Timetable not found.</div>");
                return;
            }

            // Delete DB record
            String deleteSql = "DELETE FROM documents WHERE document_id = ?";
            try (PreparedStatement psDel = con.prepareStatement(deleteSql)) {
                psDel.setInt(1, Integer.parseInt(documentId));
                int rows = psDel.executeUpdate();

                if (rows > 0) {
                    // Delete from S3
                    try {
                        S3Util.deleteFile(getServletContext(), s3Key);
                    } catch (Exception e) {
                        e.printStackTrace(); // non-fatal
                    }
                    response.getWriter().write("<div class='alert alert-success'>Timetable deleted successfully!</div>");
                } else {
                    response.getWriter().write("<div class='alert alert-danger'>Failed to delete timetable.</div>");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }
}
