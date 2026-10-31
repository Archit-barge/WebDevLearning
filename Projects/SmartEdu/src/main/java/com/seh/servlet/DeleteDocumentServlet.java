package com.seh.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import com.seh.util.S3Util;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/deleteDocument")
public class DeleteDocumentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

        response.setContentType("text/html;charset=UTF-8");

        // Auth check
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.getWriter().print("<div class=\"alert alert-error\">Unauthorized.</div>");
            return;
        }
        String sessionRole = (String) session.getAttribute("role");
        User   sessionUser = (User)   session.getAttribute("user");
        if (sessionUser == null || (!sessionRole.equals("admin") && !sessionRole.equals("teacher"))) {
            response.getWriter().print("<div class=\"alert alert-error\">Unauthorized.</div>");
            return;
        }

        String id = request.getParameter("documentId");
        if (id == null || id.isBlank()) {
            response.getWriter().print("<div class=\"alert alert-error\">"
                    + "<i class='fas fa-exclamation-triangle'></i> Invalid document." + "</div>");
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {

            // Fetch file_path and uploaded_by
            PreparedStatement ps = conn.prepareStatement(
                "SELECT file_path, uploaded_by FROM documents WHERE document_id=?"
            );
            ps.setInt(1, Integer.parseInt(id));
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                response.getWriter().print("<div class=\"alert alert-error\">"
                        + "<i class='fas fa-exclamation-triangle'></i> Document not found." + "</div>");
                return;
            }

            String s3Key     = rs.getString("file_path");
            int    uploadedBy = rs.getInt("uploaded_by");

            // Teachers can only delete their own documents
            if ("teacher".equals(sessionRole) && uploadedBy != sessionUser.getUserId()) {
                response.getWriter().print("<div class=\"alert alert-error\">"
                        + "<i class='fas fa-exclamation-triangle'></i> You can only delete your own documents." + "</div>");
                return;
            }

            // Delete from S3
            try {
                S3Util.deleteFile(getServletContext(), s3Key);
            } catch (Exception e) {
                e.printStackTrace(); // non-fatal
            }

            // Delete from DB
            PreparedStatement del = conn.prepareStatement(
                "DELETE FROM documents WHERE document_id=?"
            );
            del.setInt(1, Integer.parseInt(id));
            del.executeUpdate();

            response.getWriter().print("<div class=\"alert alert-success\">"
                    + "<i class='fas fa-check-circle'></i> Document deleted successfully." + "</div>");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print("<div class=\"alert alert-error\">"
                    + "<i class='fas fa-exclamation-triangle'></i> Failed to delete document." + "</div>");
        }
    }
}
