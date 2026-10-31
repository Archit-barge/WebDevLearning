package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.util.SQLConnection;
import com.seh.util.S3Util;
import com.seh.model.User;

import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/uploadDocument")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
public class UploadDocumentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.getWriter().write("<div class='error'>Unauthorized</div>");
            return;
        }

        User user = (User) session.getAttribute("user");

        String title        = request.getParameter("title");
        String description  = request.getParameter("description");
        String documentType = request.getParameter("documentType");
        String classId      = request.getParameter("classId");
        String subjectId    = request.getParameter("subjectId");

        Part filePart = request.getPart("documentFile");
        if (filePart == null || filePart.getSize() == 0) {
            response.getWriter().write("<div class='error'>No file selected</div>");
            return;
        }

        String originalFileName = Paths.get(filePart.getSubmittedFileName())
                .getFileName().toString();

        String extension = originalFileName.substring(
                originalFileName.lastIndexOf('.') + 1
        ).toLowerCase();

        if (!extension.matches("pdf|doc|docx|ppt|pptx|jpg|jpeg|png")) {
            response.getWriter().write("<div class='error'>Invalid file type</div>");
            return;
        }

        // Map document type to S3 folder prefix
        String folderName;
        switch (documentType) {
            case "SYLLABUS":      folderName = "syllabus";  break;
            case "NOTES":         folderName = "notes";     break;
            case "TIMETABLES":    folderName = "timetables"; break;
            case "EXAM_TIMETABLE": folderName = "timetables"; break;
            default:
                response.getWriter().write("<div class='error'>Invalid document type</div>");
                return;
        }

        // Unique S3 key: folder/timestamp_originalname  (e.g. timetables/1740000000_schedule.pdf)
        String storedFileName = System.currentTimeMillis() + "_" + originalFileName;
        String s3Key = folderName + "/" + storedFileName;
        String contentType = filePart.getContentType();
        if (contentType == null) contentType = "application/octet-stream";

        try {
            // Upload to S3
            S3Util.uploadFile(
                getServletContext(),
                filePart.getInputStream(),
                s3Key,
                contentType,
                filePart.getSize()
            );
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("<div class='error'>S3 upload failed: " + e.getMessage() + "</div>");
            return;
        }

        // Persist to DB — file_path stores the S3 key
        try (Connection conn = SQLConnection.getConnection()) {

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO documents (" +
                "title, description, document_type, " +
                "file_name, original_file_name, file_path, " +
                "file_size, file_extension, " +
                "class_id, subject_id, uploaded_by" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            );

            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, documentType);

            ps.setString(4, storedFileName);          // stored file name
            ps.setString(5, originalFileName);         // original file name
            ps.setString(6, s3Key);                    // S3 key (e.g. timetables/xyz.pdf)

            ps.setLong(7, filePart.getSize());
            ps.setString(8, extension);

            if (classId != null && !classId.isEmpty())
                ps.setInt(9, Integer.parseInt(classId));
            else
                ps.setNull(9, java.sql.Types.INTEGER);

            if (subjectId != null && !subjectId.isEmpty())
                ps.setInt(10, Integer.parseInt(subjectId));
            else
                ps.setNull(10, java.sql.Types.INTEGER);

            ps.setInt(11, user.getUserId());

            ps.executeUpdate();

            response.getWriter().write("<div class='success'>Document uploaded successfully</div>");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("<div class='error'>Database error after upload</div>");
        }
    }
}
