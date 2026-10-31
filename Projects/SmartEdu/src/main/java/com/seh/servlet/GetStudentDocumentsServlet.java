package com.seh.servlet;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/getStudentDocuments")
public class GetStudentDocumentsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || !"student".equals(session.getAttribute("role"))) {
            out.print("[]");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();

        // Get the student's class_id from the students table
        int studentClassId = 0;
        try (Connection c = SQLConnection.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT class_id FROM students WHERE user_id = ?")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) studentClassId = rs.getInt("class_id");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
            return;
        }

        String search    = request.getParameter("search");
        String subjectId = request.getParameter("subjectId");
        String docType   = request.getParameter("docType");

        StringBuilder sql = new StringBuilder(
            "SELECT d.document_id, d.title, d.description, d.document_type, " +
            "d.original_file_name, d.class_id, d.subject_id, " +
            "c.class_name, c.section, s.subject_name, " +
            "CASE WHEN u.role='admin'   THEN CONCAT(a.first_name,' ',a.last_name) " +
            "     WHEN u.role='teacher' THEN CONCAT(t.first_name,' ',t.last_name) " +
            "     ELSE 'Unknown' END AS uploader " +
            "FROM documents d " +
            "JOIN  users    u ON d.uploaded_by = u.user_id " +
            "LEFT JOIN admins   a ON u.user_id = a.user_id " +
            "LEFT JOIN teachers t ON u.user_id = t.user_id " +
            "LEFT JOIN classes  c ON d.class_id   = c.class_id " +
            "LEFT JOIN subjects s ON d.subject_id = s.subject_id " +
            "WHERE d.document_type IN ('SYLLABUS','NOTES') " +
            "AND (d.class_id IS NULL OR d.class_id = " + studentClassId + ") "
        );

        if (search    != null && !search.isBlank())    sql.append("AND (d.title LIKE ? OR a.first_name LIKE ? OR t.first_name LIKE ?) ");
        if (subjectId != null && !subjectId.isBlank()) sql.append("AND d.subject_id = ? ");
        if (docType   != null && !docType.isBlank())   sql.append("AND d.document_type = ? ");

        sql.append("ORDER BY d.upload_date DESC");

        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int i = 1;
            if (search    != null && !search.isBlank())    { String like = "%" + search + "%"; ps.setString(i++, like); ps.setString(i++, like); ps.setString(i++, like); }
            if (subjectId != null && !subjectId.isBlank()) ps.setInt(i++, Integer.parseInt(subjectId));
            if (docType   != null && !docType.isBlank())   ps.setString(i++, docType);

            ResultSet rs = ps.executeQuery();
            StringBuilder json = new StringBuilder("[");
            boolean first = true;

            while (rs.next()) {
                if (!first) json.append(",");
                first = false;

                String cls = rs.getString("class_name");
                String sec = rs.getString("section");
                String classDisplay = cls != null ? cls + (sec != null ? " - " + sec : "") : "All Classes";

                String uploaderVal = rs.getString("uploader");
                if (uploaderVal == null) uploaderVal = "";

                int subjectIdVal = rs.getObject("subject_id") != null ? rs.getInt("subject_id") : 0;

                json.append("{")
                    .append("\"id\":").append(rs.getInt("document_id")).append(",")
                    .append("\"title\":").append(jsonStr(rs.getString("title"))).append(",")
                    .append("\"description\":").append(jsonStr(rs.getString("description"))).append(",")
                    .append("\"type\":").append(jsonStr(rs.getString("document_type"))).append(",")
                    .append("\"originalFile\":").append(jsonStr(rs.getString("original_file_name"))).append(",")
                    .append("\"uploader\":").append(jsonStr(uploaderVal.trim())).append(",")
                    .append("\"classDisplay\":").append(jsonStr(classDisplay)).append(",")
                    .append("\"subjectId\":").append(subjectIdVal).append(",")
                    .append("\"subjectName\":").append(jsonStr(rs.getString("subject_name")))
                    .append("}");
            }

            json.append("]");
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        }
    }

    private String jsonStr(String s) {
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"")
                        .replace("\n", "\\n").replace("\r", "") + "\"";
    }
}
