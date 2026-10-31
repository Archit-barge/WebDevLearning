package com.seh.servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import com.seh.util.S3Util;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize       = 1024 * 1024 * 10,
    maxRequestSize    = 1024 * 1024 * 50
)
@WebServlet("/teacher/UploadTimetableServlet")
public class UploadTimetableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String classIdStr = request.getParameter("classId");
        Part filePart     = request.getPart("timetableFile");

        if (classIdStr == null || filePart == null || filePart.getSize() == 0) {
            session.setAttribute("error", "Please select a class and a file.");
            response.sendRedirect(request.getContextPath() + "/PageLoaderTeacher?page=teacher_upload_timetable.jsp");
            return;
        }

        int classId = Integer.parseInt(classIdStr);
        String originalFileName = java.nio.file.Paths.get(filePart.getSubmittedFileName())
                                                      .getFileName().toString();
        String extension = originalFileName.substring(
                originalFileName.lastIndexOf('.') + 1).toLowerCase();

        if (!extension.matches("pdf|png|jpg|jpeg")) {
            session.setAttribute("error", "Only PDF and image files are allowed.");
            response.sendRedirect(request.getContextPath() + "/PageLoaderTeacher?page=teacher_upload_timetable.jsp");
            return;
        }

        // S3 key: timetables/<timestamp>_<originalname>
        String storedFileName = System.currentTimeMillis() + "_" + originalFileName;
        String s3Key          = "timetables/" + storedFileName;
        String contentType    = filePart.getContentType();
        if (contentType == null) contentType = "application/octet-stream";

        try {
            // 1. Upload to S3 — correct arg order: ctx, inputStream, s3Key, contentType, fileSize
            try (InputStream in = filePart.getInputStream()) {
                S3Util.uploadFile(getServletContext(), in, s3Key, contentType, filePart.getSize());
            }

            // 2. Insert into documents table
            try (Connection conn = SQLConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO documents (title, description, document_type, class_id, " +
                     "subject_id, uploaded_by, file_name, original_file_name, file_path, file_size, file_extension) " +
                     "VALUES (?, NULL, 'TIMETABLES', ?, NULL, ?, ?, ?, ?, ?, ?)")) {

                ps.setString(1, originalFileName);
                ps.setInt   (2, classId);
                ps.setInt   (3, user.getUserId());
                ps.setString(4, storedFileName);
                ps.setString(5, originalFileName);
                ps.setString(6, s3Key);
                ps.setLong  (7, filePart.getSize());
                ps.setString(8, extension);
                ps.executeUpdate();
            }

            session.setAttribute("success", "Timetable uploaded successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Upload failed: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/PageLoaderTeacher?page=teacher_upload_timetable.jsp");
    }
}
