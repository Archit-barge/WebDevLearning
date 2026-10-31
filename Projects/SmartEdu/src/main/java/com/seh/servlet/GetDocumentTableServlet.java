package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/getDocumentTable")
public class GetDocumentTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String search = request.getParameter("search");
        String classId = request.getParameter("classId");
        String subjectId = request.getParameter("subjectId");
        String docType = request.getParameter("docType");
        String uploaderRole = request.getParameter("uploaderRole");

        StringBuilder sql = new StringBuilder("SELECT d.*, c.class_name, c.section, s.subject_name, u.role, "
                + "CASE WHEN u.role='admin' THEN CONCAT(a.first_name,' ',a.last_name) "
                + "WHEN u.role='teacher' THEN CONCAT(t.first_name,' ',t.last_name) END uploader FROM documents d "
                + "LEFT JOIN classes c ON d.class_id=c.class_id LEFT JOIN subjects s ON d.subject_id=s.subject_id "
                + "JOIN users u ON d.uploaded_by=u.user_id LEFT JOIN admins a ON u.user_id=a.user_id "
                + "LEFT JOIN teachers t ON u.user_id=t.user_id WHERE d.document_type != 'TIMETABLES' ");

        if (search != null && !search.isBlank())
            sql.append("AND (d.title LIKE ? OR a.first_name LIKE ? OR t.first_name LIKE ?) ");

        if (classId != null && !classId.isBlank())
            sql.append("AND (d.class_id=? OR d.class_id IS NULL OR d.class_id=0) ");

        if (subjectId != null && !subjectId.isBlank())
            sql.append("AND d.subject_id=? ");

        if (docType != null && !docType.isBlank())
            sql.append("AND d.document_type=? ");

        if (uploaderRole != null && !uploaderRole.isBlank())
            sql.append("AND u.role=? ");

        sql.append("ORDER BY d.upload_date DESC");

        try (Connection c = SQLConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {

            int i = 1;

            if (search != null && !search.isBlank()) {
                String like = "%" + search + "%";
                ps.setString(i++, like);
                ps.setString(i++, like);
                ps.setString(i++, like);
            }
            if (classId != null && !classId.isBlank())
                ps.setInt(i++, Integer.parseInt(classId));
            if (subjectId != null && !subjectId.isBlank())
                ps.setInt(i++, Integer.parseInt(subjectId));
            if (docType != null && !docType.isBlank())
                ps.setString(i++, docType);
            if (uploaderRole != null && !uploaderRole.isBlank())
                ps.setString(i++, uploaderRole);

            ResultSet rs = ps.executeQuery();
            boolean hasData = false;

            while (rs.next()) {
                hasData = true;
                int docId = rs.getInt("document_id");
                String title = escapeHtml(rs.getString("title"));
                String description = escapeHtml(rs.getString("description"));
                Object classIdObj = rs.getObject("class_id");
                String className = escapeHtml(rs.getString("class_name"));
                String section = escapeHtml(rs.getString("section"));
                Object subjectIdObj = rs.getObject("subject_id");
                String subjectName = escapeHtml(rs.getString("subject_name"));
                String type = rs.getString("document_type");
                String safeType = (type != null && !type.isBlank()) ? type : "FILE";
                String uploader = escapeHtml(rs.getString("uploader"));
                String role = rs.getString("role");
                String originalFileName = escapeHtml(rs.getString("original_file_name"));
                String fileName = escapeHtml(rs.getString("file_name"));

                String displaySubject = subjectName != null && !subjectName.isEmpty() ? subjectName : "General";
                String displayClass = className != null && !className.isEmpty() ? className : "All Classes";
                if (section != null && !section.isEmpty() && !displayClass.equals("All Classes")) {
                    displayClass += " - " + section;
                }

                out.println("<div class=\"doc-card doc-library-card\" onclick=\"openDocModal(this)\"");
                out.println(" data-doc-id=\"" + docId + "\"");
                out.println(" data-title=\"" + title + "\"");
                out.println(" data-desc=\"" + description + "\"");
                out.println(" data-class-id=\"" + (classIdObj != null ? classIdObj : "") + "\"");
                out.println(" data-class-name=\"" + (className != null ? className : "") + "\"");
                out.println(" data-class-section=\"" + (section != null ? section : "") + "\"");
                out.println(" data-subject-id=\"" + (subjectIdObj != null ? subjectIdObj : "") + "\"");
                out.println(" data-subject-name=\"" + (subjectName != null ? subjectName : "") + "\"");
                out.println(" data-type=\"" + safeType + "\"");
                out.println(" data-uploader=\"" + uploader + " (" + role + ")\"");
                out.println(" data-original-file=\"" + originalFileName + "\"");
                out.println(" data-stored-file=\"" + fileName + "\">");

                out.println(" <div class=\"doc-card-top\">");
                out.println("  <div class=\"doc-type-icon type-" + safeType.toLowerCase() + "\">");
                out.println("   <i class=\"fas fa-file-alt\"></i>");
                out.println("  </div>");
                out.println("  <span class=\"doc-type-badge\">" + escapeHtml(safeType) + "</span>");
                out.println(" </div>");

                out.println(" <h3 class=\"doc-title\">" + title + "</h3>");

                out.println(" <p class=\"doc-sub\">");
                out.println("  " + displaySubject + " - " + displayClass);
                out.println(" </p>");

                out.println(" <div class=\"doc-uploader-row\">");
                out.println("  <span class=\"doc-uploader-dot\"></span>");
                out.println("  <p class=\"doc-uploader\">Uploaded by: <strong>" + uploader + "</strong></p>");
                out.println(" </div>");

                out.println(" <div class=\"doc-actions doc-actions-row\">");
                out.println("  <a href=\"../downloadDocument?id=" + docId + "\" class=\"btn btn-primary\" onclick=\"event.stopPropagation(); return true;\"> Download </a>");
                out.println(" </div>");

                out.println("</div>");
            }

            if (!hasData) {
                out.println("<div class=\"no-data-message empty-state doc-empty-state\">");
                out.println(" <i class=\"fas fa-folder-open\"></i>");
                out.println(" <p>No documents found matching the criteria.</p>");
                out.println("</div>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<div class=\"error-message\">Error loading documents: " + e.getMessage() + "</div>");
        }
    }

    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
