package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.net.URLEncoder;

@WebServlet("/getAdminTimetables")
public class GetAdminTimetablesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String search = request.getParameter("search");
        String classId = request.getParameter("classId");
        String uploaderRole = request.getParameter("uploaderRole");

        StringBuilder sql = new StringBuilder("SELECT d.*, c.class_name, c.section, s.subject_name, "
                + "COALESCE(u.role, 'unknown') AS role, "
                + "CASE WHEN u.role='admin' THEN CONCAT(a.first_name,' ',a.last_name) "
                + "WHEN u.role='teacher' THEN CONCAT(t.first_name,' ',t.last_name) "
                + "ELSE 'Unknown' END uploader FROM documents d "
                + "LEFT JOIN classes c ON d.class_id=c.class_id LEFT JOIN subjects s ON d.subject_id=s.subject_id "
                + "LEFT JOIN users u ON d.uploaded_by=u.user_id LEFT JOIN admins a ON u.user_id=a.user_id "
                + "LEFT JOIN teachers t ON u.user_id=t.user_id WHERE d.document_type = 'TIMETABLES' ");

        if (search != null && !search.isBlank())
            sql.append("AND (d.title LIKE ? OR a.first_name LIKE ? OR t.first_name LIKE ?) ");

        if (classId != null && !classId.isBlank())
            sql.append("AND (d.class_id=? OR d.class_id IS NULL OR d.class_id=0) ");

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
            if (uploaderRole != null && !uploaderRole.isBlank())
                ps.setString(i++, uploaderRole);

            ResultSet rs = ps.executeQuery();
            boolean hasData = false;

            while (rs.next()) {
                hasData = true;
                int docId = rs.getInt("document_id");
                String title = escapeHtml(rs.getString("title"));
                String description = escapeHtml(rs.getString("description"));
                String className = escapeHtml(rs.getString("class_name"));
                String section = escapeHtml(rs.getString("section"));
                Object classIdObj = rs.getObject("class_id");
                String uploader = escapeHtml(rs.getString("uploader"));
                String role = rs.getString("role");
                String fileName = rs.getString("file_name");
                String originalFileName = escapeHtml(rs.getString("original_file_name"));
                long uploadDate = rs.getTimestamp("upload_date").getTime();
                if (uploader == null || uploader.isBlank()) {
                    uploader = "Unknown";
                }
                String roleLabel = (role == null || role.isBlank())
                        ? "Unknown"
                        : role.substring(0, 1).toUpperCase() + role.substring(1);

                String displayClass = className != null && !className.isEmpty() ? className : "All Classes";
                if (section != null && !section.isEmpty() && !displayClass.equals("All Classes")) {
                    displayClass += " - " + section;
                }

                String fileType = getFileType(fileName);
                String fileUrl = request.getContextPath() + "/downloadDocument?id=" + docId + "&inline=true";
                String downloadUrl = request.getContextPath() + "/downloadDocument?id=" + docId;

                out.println("<div class=\"timetable-card\" data-doc-id=\"" + docId + "\" "
                        + "data-title=\"" + title + "\" "
                        + "data-desc=\"" + description + "\" "
                        + "data-class-id=\"" + (classIdObj != null ? classIdObj : "") + "\" "
                        + "data-original-file=\"" + originalFileName + "\" "
                        + "data-preview-url=\"" + fileUrl + "\">");

                out.println("  <div class=\"timetable-header\">");
                out.println("    <h3 class=\"timetable-title\" title=\"" + title + "\">" + title + "</h3>");
                out.println("    <div class=\"timetable-meta\">");
                out.println("      <span class=\"timetable-meta-primary\"><i class=\"fas fa-users\"></i> " + displayClass + "</span>");
                out.println("      <span class=\"timetable-meta-secondary\" title=\"Uploaded by " + uploader + "\">Uploaded by: " + uploader + " (" + roleLabel + ")</span>");
                out.println("    </div>");
                out.println("  </div>");

                out.println("  <div class=\"timetable-preview\">");
                if ("pdf".equals(fileType)) {
                    out.println("    <iframe src=\"" + fileUrl + "#toolbar=0&navpanes=0&scrollbar=0\"></iframe>");
                } else if ("doc".equals(fileType)) {
                    out.println("    <div class=\"timetable-preview-fallback\"><i class=\"fas fa-file-word\"></i><span>Word Document</span><small>Preview unavailable</small></div>");
                } else if ("image".equals(fileType)) {
                    out.println("    <img src=\"" + fileUrl + "\" alt=\"Timetable Preview\">");
                } else {
                    out.println("    <div class=\"timetable-preview-fallback\"><i class=\"fas fa-file-alt timetable-icon\"></i><span>File Preview</span></div>");
                }
                out.println("  </div>");

                out.println("  <div class=\"timetable-actions\">");
                out.println("    <a href=\"" + fileUrl + "\" target=\"_blank\" class=\"action-btn btn-open\"><i class=\"fas fa-external-link-alt\"></i> Open</a>");
                out.println("    <a href=\"" + downloadUrl + "\" class=\"action-btn btn-download\"><i class=\"fas fa-download\"></i> Download</a>");
                out.println("    <button type=\"button\" onclick=\"openEditTimetableModal(" + docId + ")\" class=\"action-btn btn-edit\" title=\"Edit\" aria-label=\"Edit\"><i class=\"fas fa-pen\"></i></button>");
                out.println("    <button type=\"button\" onclick=\"deleteTimetable(" + docId + ")\" class=\"action-btn btn-delete\" title=\"Delete\" aria-label=\"Delete\"><i class=\"fas fa-trash-alt\"></i></button>");
                out.println("  </div>");

                out.println("</div>");
            }

            if (!hasData) {
                out.println("<div class=\"no-timetables empty-state timetable-empty-state\">");
                out.println(" <i class=\"fas fa-calendar-times\"></i>");
                out.println(" <h3>No Timetables Found</h3>");
                out.println(" <p>Try adjusting your search or filters.</p>");
                out.println("</div>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<div class=\"error-message\">Error loading timetables: " + e.getMessage() + "</div>");
        }
    }

    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    private String getFileType(String fileName) {
        if (fileName == null) return "unknown";
        String lowerName = fileName.toLowerCase();
        if (lowerName.endsWith(".pdf")) return "pdf";
        if (lowerName.endsWith(".doc") || lowerName.endsWith(".docx")) return "doc";
        if (lowerName.endsWith(".png") || lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg")) return "image";
        return "other";
    }
}
