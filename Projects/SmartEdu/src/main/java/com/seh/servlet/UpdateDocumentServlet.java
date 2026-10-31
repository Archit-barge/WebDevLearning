package com.seh.servlet;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import com.seh.util.S3Util;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/updateDocument")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
public class UpdateDocumentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("text/html;charset=UTF-8");

        String documentId   = request.getParameter("documentId");
        String title        = request.getParameter("title");
        String description  = request.getParameter("description");
        String documentType = request.getParameter("documentType");
        String classId      = request.getParameter("classId");
        String subjectId    = request.getParameter("subjectId");
        String newOriginalFileName = request.getParameter("originalFileName");

        // Auth check
        HttpSession session  = request.getSession(false);
        User        sesUser  = session != null ? (User) session.getAttribute("user") : null;
        String      sesRole  = session != null ? (String) session.getAttribute("role") : null;
        if (sesUser == null || (!"admin".equals(sesRole) && !"teacher".equals(sesRole))) {
            response.getWriter().print(
                "<div class='alert alert-error'>" +
                "<i class='fas fa-exclamation-triangle'></i> Unauthorized." +
                "</div>"
            );
            return;
        }

        if (documentId == null || documentId.isBlank() || documentType == null || title == null) {
            response.getWriter().print(
                "<div class='alert alert-error'>" +
                "<i class='fas fa-exclamation-triangle'></i> Invalid request." +
                "</div>"
            );
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {

            conn.setAutoCommit(false);

            // Fetch existing record (including owner)
            PreparedStatement fetch = conn.prepareStatement(
                "SELECT file_path, file_name, original_file_name, file_extension, uploaded_by FROM documents WHERE document_id=?"
            );
            fetch.setInt(1, Integer.parseInt(documentId));
            ResultSet rs = fetch.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                response.getWriter().print(
                    "<div class='alert alert-error'>" +
                    "<i class='fas fa-exclamation-triangle'></i> Document not found." +
                    "</div>"
                );
                return;
            }

            String oldS3Key      = rs.getString("file_path");
            String oldStoredName = rs.getString("file_name");
            String oldOrigName   = rs.getString("original_file_name");
            String oldExtension  = rs.getString("file_extension");
            int    uploadedBy    = rs.getInt("uploaded_by");

            // Teachers can only update their own documents
            if ("teacher".equals(sesRole) && uploadedBy != sesUser.getUserId()) {
                conn.rollback();
                response.getWriter().print(
                    "<div class='alert alert-error'>" +
                    "<i class='fas fa-exclamation-triangle'></i> You can only edit your own documents." +
                    "</div>"
                );
                return;
            }

            // Check if a new file was supplied
            Part filePart = null;
            try {
                filePart = request.getPart("documentFile");
            } catch (Exception ignored) {}

            String newS3Key      = oldS3Key;
            String newStoredName = oldStoredName;
            String safeOrigName  = (newOriginalFileName != null && !newOriginalFileName.isBlank())
                                    ? newOriginalFileName.trim()
                                    : oldOrigName;

            if (filePart != null && filePart.getSize() > 0) {
                // A replacement file was uploaded
                String uploadedOrigName = filePart.getSubmittedFileName();
                String ext = uploadedOrigName.substring(uploadedOrigName.lastIndexOf('.') + 1).toLowerCase();
                newStoredName = System.currentTimeMillis() + "_" + uploadedOrigName;
                newS3Key = mapFolder(documentType) + "/" + newStoredName;

                String contentType = filePart.getContentType();
                if (contentType == null) contentType = "application/octet-stream";

                // Upload new file to S3
                S3Util.uploadFile(
                    getServletContext(),
                    filePart.getInputStream(),
                    newS3Key,
                    contentType,
                    filePart.getSize()
                );

                // Delete old S3 object
                try {
                    S3Util.deleteFile(getServletContext(), oldS3Key);
                } catch (Exception e) {
                    e.printStackTrace(); // non-fatal — old file may already be gone
                }

                safeOrigName = uploadedOrigName;

            } else if (!mapFolder(documentType).equals(folderFromKey(oldS3Key))) {
                // No new file but the document type changed (folder changed) — move the key
                newStoredName = System.currentTimeMillis() + "_" + safeOrigName;
                newS3Key = mapFolder(documentType) + "/" + newStoredName;

                // We can't copy in S3 with just SDK v1 easily, so just update the key in DB.
                // The actual S3 object stays where it is (old key). This is acceptable for a
                // metadata-only type change; the presigned URL will still resolve correctly if
                // oldS3Key is kept. Keep oldS3Key in this edge case.
                newS3Key = oldS3Key;
                newStoredName = oldStoredName;
            }

            // Update DB
            PreparedStatement update = conn.prepareStatement(
                "UPDATE documents SET " +
                "title=?, description=?, document_type=?, class_id=?, subject_id=?, " +
                "file_name=?, original_file_name=?, file_path=? " +
                "WHERE document_id=?"
            );

            update.setString(1, title);
            update.setString(2, description);
            update.setString(3, documentType);

            if (classId != null && !classId.isBlank())
                update.setInt(4, Integer.parseInt(classId));
            else
                update.setNull(4, java.sql.Types.INTEGER);

            if (subjectId != null && !subjectId.isBlank())
                update.setInt(5, Integer.parseInt(subjectId));
            else
                update.setNull(5, java.sql.Types.INTEGER);

            update.setString(6, newStoredName);
            update.setString(7, safeOrigName);
            update.setString(8, newS3Key);
            update.setInt(9, Integer.parseInt(documentId));

            update.executeUpdate();
            conn.commit();

            response.getWriter().print(
                "<div class='alert alert-success'>" +
                "<i class='fas fa-check-circle'></i> Document updated successfully." +
                "</div>"
            );

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print(
                "<div class='alert alert-error'>" +
                "<i class='fas fa-exclamation-triangle'></i> Server error. Please try again." +
                "</div>"
            );
        }
    }

    private String mapFolder(String type) {
        return switch (type) {
            case "SYLLABUS"       -> "syllabus";
            case "NOTES"          -> "notes";
            case "TIMETABLES",
                 "EXAM_TIMETABLE" -> "timetables";
            default               -> "others";
        };
    }

    private String folderFromKey(String s3Key) {
        if (s3Key == null || !s3Key.contains("/")) return "";
        return s3Key.substring(0, s3Key.indexOf('/'));
    }
}
