package com.seh.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.seh.util.SQLConnection;
import com.seh.util.S3Util;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/downloadDocument")
public class DownloadDocumentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String id = request.getParameter("id");
        if (id == null || id.isBlank()) {
            response.getWriter().print(
                "<div class=\"alert alert-error\">" +
                "<i class='fas fa-exclamation-triangle'></i> Invalid document request" +
                "</div>"
            );
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {

            PreparedStatement ps = conn.prepareStatement(
                "SELECT file_path, original_file_name FROM documents WHERE document_id = ?"
            );
            ps.setInt(1, Integer.parseInt(id));

            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                response.getWriter().print(
                    "<div class=\"alert alert-error\">" +
                    "<i class='fas fa-exclamation-triangle'></i> Document not found" +
                    "</div>"
                );
                return;
            }

            // file_path is now an S3 key (e.g. "timetables/1740000_file.pdf")
            String s3Key       = rs.getString("file_path");
            String originalName = rs.getString("original_file_name");

            String inlineStr = request.getParameter("inline");
            boolean isInline = "true".equalsIgnoreCase(inlineStr);

            // Generate a 15-minute pre-signed URL
            String presignedUrl = S3Util.getPresignedUrl(
                getServletContext(),
                s3Key,
                15,
                isInline
            );

            // Redirect the browser directly to the S3 pre-signed URL
            response.sendRedirect(presignedUrl);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print(
                "<div class=\"alert alert-error\">" +
                "<i class='fas fa-exclamation-triangle'></i> Download failed. Please try again." +
                "</div>"
            );
        }
    }
}
