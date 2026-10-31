package com.seh.servlet;

import com.seh.util.SQLConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/marks-entry")
public class MarksEntryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (Connection conn = SQLConnection.getConnection()) {
            if ("getClasses".equals(action)) {
                getClasses(conn, response, request);
            } else if ("getSubjects".equals(action)) {
                getSubjects(conn, response, request);
            } else if ("getExams".equals(action)) {
                getExams(conn, response, request);
            } else if ("getStudents".equals(action)) {
                getStudents(conn, response, request);
            } else if ("getPracticals".equals(action)) {
                getPracticals(conn, response, request);
            } else if ("getSLAComponents".equals(action)) {
                getSLAComponents(conn, response, request);
            } else if ("getExistingMarks".equals(action)) {
                getExistingMarks(conn, response, request);
            } else {
                response.getWriter().write("[]");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            if ("saveMarks".equals(action)) {
                saveMarks(conn, response, request);
            } else if ("addExam".equals(action)) {
                addExam(conn, response, request);
            } else if ("addPractical".equals(action)) {
                addPractical(conn, response, request);
            } else if ("addSLAComponent".equals(action)) {
                addSLAComponent(conn, response, request);
            } else if ("deletePractical".equals(action)) {
                deletePractical(conn, response, request);
            } else if ("deleteSLAComponent".equals(action)) {
                deleteSLAComponent(conn, response, request);
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid action\"}");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    private void getClasses(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        StringBuilder json = new StringBuilder("[");
        String sql = "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"class_id\":").append(rs.getInt("class_id")).append(",");
                json.append("\"class_name\":\"").append(rs.getString("class_name")).append("\",");
                json.append("\"section\":\"").append(rs.getString("section") != null ? rs.getString("section") : "").append("\"");
                json.append("}");
                first = false;
            }
        }
        
        json.append("]");
        response.getWriter().write(json.toString());
    }

    private void getSubjects(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String classIdStr = request.getParameter("class_id");
        if (classIdStr == null || classIdStr.isEmpty()) {
            response.getWriter().write("[]");
            return;
        }
        
        int classId = Integer.parseInt(classIdStr);
        StringBuilder json = new StringBuilder("[");
        
        // First try to get subjects for the selected class from class_subjects table
        String sql = "SELECT s.subject_id, s.subject_name, s.subject_code FROM subjects s " +
                     "INNER JOIN class_subjects cs ON s.subject_id = cs.subject_id " +
                     "WHERE cs.class_id = ? ORDER BY s.subject_name";
        
        boolean hasClassSubjects = false;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                hasClassSubjects = true;
                if (!first) json.append(",");
                json.append("{");
                json.append("\"subject_id\":").append(rs.getInt("subject_id")).append(",");
                json.append("\"subject_name\":\"").append(rs.getString("subject_name")).append("\",");
                json.append("\"subject_code\":\"").append(rs.getString("subject_code") != null ? rs.getString("subject_code") : "").append("\"");
                json.append("}");
                first = false;
            }
        }
        
        // If no class-specific subjects, fall back to all subjects
        if (!hasClassSubjects) {
            String fallbackSql = "SELECT subject_id, subject_name, subject_code FROM subjects ORDER BY subject_name";
            try (PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ResultSet rs = ps.executeQuery();
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(",");
                    json.append("{");
                    json.append("\"subject_id\":").append(rs.getInt("subject_id")).append(",");
                    json.append("\"subject_name\":\"").append(rs.getString("subject_name")).append("\",");
                    json.append("\"subject_code\":\"").append(rs.getString("subject_code") != null ? rs.getString("subject_code") : "").append("\"");
                    json.append("}");
                    first = false;
                }
            }
        }
        
        json.append("]");
        response.getWriter().write(json.toString());
    }

    private void getExams(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        StringBuilder json = new StringBuilder("[");
        String sql = "SELECT DISTINCT e.exam_id, e.exam_name FROM exams e " +
                      "LEFT JOIN practicals p ON e.exam_id = p.exam_id " +
                      "LEFT JOIN sla_components sc ON e.exam_id = sc.exam_id " +
                      "WHERE p.practical_id IS NOT NULL OR sc.component_id IS NOT NULL " +
                      "ORDER BY e.exam_id DESC";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"exam_id\":").append(rs.getInt("exam_id")).append(",");
                json.append("\"exam_name\":\"").append(rs.getString("exam_name")).append("\"");
                json.append("}");
                first = false;
            }
        }
        
        json.append("]");
        response.getWriter().write(json.toString());
    }

    private void getStudents(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String classIdStr = request.getParameter("class_id");
        if (classIdStr == null || classIdStr.isEmpty()) {
            response.getWriter().write("[]");
            return;
        }
        
        StringBuilder json = new StringBuilder("[");
        String sql = "SELECT student_id, first_name, last_name, roll_number FROM students WHERE class_id = ? ORDER BY roll_number";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(classIdStr));
            ResultSet rs = ps.executeQuery();
            
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                String fullName = rs.getString("first_name") + (rs.getString("last_name") != null ? " " + rs.getString("last_name") : "");     
                json.append("{");
                json.append("\"student_id\":").append(rs.getInt("student_id")).append(",");
                json.append("\"full_name\":\"").append(fullName).append("\",");
                json.append("\"roll_number\":\"").append(rs.getString("roll_number")).append("\"");
                json.append("}");
                first = false;
            }
        }
        
        json.append("]");
        response.getWriter().write(json.toString());
    }

    private void getPracticals(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String subjectIdStr = request.getParameter("subject_id");
        String examIdStr = request.getParameter("exam_id");

        if (subjectIdStr == null || examIdStr == null || subjectIdStr.isEmpty() || examIdStr.isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);
        int examId = Integer.parseInt(examIdStr);

        String checkSql = "SELECT practical_id, practical_no, max_marks FROM practicals WHERE subject_id = ? AND exam_id = ? ORDER BY practical_no";

        boolean needsSetup = false;
        try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            psCheck.setInt(1, subjectId);
            psCheck.setInt(2, examId);
            ResultSet rsCheck = psCheck.executeQuery();
            if (!rsCheck.next()) {
                needsSetup = true;
            }
        }

        if (needsSetup) {
            String templateSql = "SELECT practical_no, max_marks FROM practicals WHERE subject_id IS NULL AND exam_id = ? ORDER BY practical_no";
            try (PreparedStatement psTemplate = conn.prepareStatement(templateSql)) {
                psTemplate.setInt(1, examId);
                ResultSet rsTemplate = psTemplate.executeQuery();

                String insertSql = "INSERT INTO practicals (subject_id, exam_id, practical_no, max_marks) VALUES (?, ?, ?, ?)";
                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    while (rsTemplate.next()) {
                        psInsert.setInt(1, subjectId);
                        psInsert.setInt(2, examId);
                        psInsert.setInt(3, rsTemplate.getInt("practical_no"));
                        psInsert.setInt(4, rsTemplate.getInt("max_marks"));
                        psInsert.addBatch();
                    }
                    psInsert.executeBatch();
                }
            }
            conn.commit();
        }

        StringBuilder json = new StringBuilder("[");
        String sql = "SELECT practical_id, practical_no, max_marks FROM practicals WHERE subject_id = ? AND exam_id = ? ORDER BY practical_no";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, subjectId);
            ps.setInt(2, examId);
            ResultSet rs = ps.executeQuery();

            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"practical_id\":").append(rs.getInt("practical_id")).append(",");
                json.append("\"practical_no\":").append(rs.getInt("practical_no")).append(",");
                json.append("\"max_marks\":").append(rs.getInt("max_marks"));
                json.append("}");
                first = false;
            }
        }

        json.append("]");
        response.getWriter().write(json.toString());
    }

    private void getSLAComponents(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String subjectIdStr = request.getParameter("subject_id");
        String examIdStr = request.getParameter("exam_id");

        if (subjectIdStr == null || examIdStr == null || subjectIdStr.isEmpty() || examIdStr.isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);
        int examId = Integer.parseInt(examIdStr);

        String checkSql = "SELECT component_id, component_name, max_marks FROM sla_components WHERE subject_id = ? AND exam_id = ? ORDER BY component_id";

        boolean needsSetup = false;
        try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            psCheck.setInt(1, subjectId);
            psCheck.setInt(2, examId);
            ResultSet rsCheck = psCheck.executeQuery();
            if (!rsCheck.next()) {
                needsSetup = true;
            }
        }

        if (needsSetup) {
            String templateSql = "SELECT component_name, max_marks FROM sla_components WHERE subject_id IS NULL AND exam_id = ? ORDER BY component_id";
            try (PreparedStatement psTemplate = conn.prepareStatement(templateSql)) {
                psTemplate.setInt(1, examId);
                ResultSet rsTemplate = psTemplate.executeQuery();

                String insertSql = "INSERT INTO sla_components (subject_id, exam_id, component_name, max_marks) VALUES (?, ?, ?, ?)";
                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    while (rsTemplate.next()) {
                        psInsert.setInt(1, subjectId);
                        psInsert.setInt(2, examId);
                        psInsert.setString(3, rsTemplate.getString("component_name"));
                        psInsert.setInt(4, rsTemplate.getInt("max_marks"));
                        psInsert.addBatch();
                    }
                    psInsert.executeBatch();
                }
            }
            conn.commit();
        }

        StringBuilder json = new StringBuilder("[");
        String sql = "SELECT component_id, component_name, max_marks FROM sla_components WHERE subject_id = ? AND exam_id = ? ORDER BY component_id";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, subjectId);
            ps.setInt(2, examId);
            ResultSet rs = ps.executeQuery();

            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"component_id\":").append(rs.getInt("component_id")).append(",");
                json.append("\"component_name\":\"").append(rs.getString("component_name")).append("\",");
                json.append("\"max_marks\":").append(rs.getInt("max_marks"));
                json.append("}");
                first = false;
            }
        }

        json.append("]");
        response.getWriter().write(json.toString());
    }

    private void getExistingMarks(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String subjectIdStr = request.getParameter("subject_id");
        String examIdStr = request.getParameter("exam_id");

        if (subjectIdStr == null || examIdStr == null || subjectIdStr.isEmpty() || examIdStr.isEmpty()) {
            response.getWriter().write("{}");
            return;
        }

        Map<String, Integer> marksMap = new HashMap<>();
        String sql = "SELECT student_id, component_type, component_id, marks FROM student_marks WHERE subject_id = ? AND exam_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(subjectIdStr));
            ps.setInt(2, Integer.parseInt(examIdStr));
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String key = rs.getInt("student_id") + "_" + rs.getString("component_type") + "_" + rs.getInt("component_id");
                marksMap.put(key, rs.getInt("marks"));
            }
        }

        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Integer> entry : marksMap.entrySet()) {
            if (!first) json.append(",");
            json.append("\"").append(entry.getKey()).append("\":").append(entry.getValue());
            first = false;
        }
        json.append("}");
        response.getWriter().write(json.toString());
    }

    private void saveMarks(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String subjectIdStr = request.getParameter("subject_id");
        String examIdStr = request.getParameter("exam_id");
        String marksData = request.getParameter("marksData");

        if (subjectIdStr == null || examIdStr == null || marksData == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);
        int examId = Integer.parseInt(examIdStr);

        String[] entries = marksData.split(";");
        String sql = "INSERT INTO student_marks (student_id, subject_id, exam_id, component_type, component_id, marks) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE marks = VALUES(marks)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (String entry : entries) {
                if (entry.isEmpty()) continue;
                String[] parts = entry.split("=");
                if (parts.length != 2) continue;

                String[] keyParts = parts[0].split("_");
                if (keyParts.length != 3) continue;

                int studentId = Integer.parseInt(keyParts[0]);
                String componentType = keyParts[1];
                int componentId = Integer.parseInt(keyParts[2]);
                int marks = parts[1].isEmpty() ? 0 : Integer.parseInt(parts[1]);

                ps.setInt(1, studentId);
                ps.setInt(2, subjectId);
                ps.setInt(3, examId);
                ps.setString(4, componentType);
                ps.setInt(5, componentId);
                ps.setInt(6, marks);
                ps.addBatch();
            }

            ps.executeBatch();
            conn.commit();
            response.getWriter().write("{\"success\":true,\"message\":\"Marks saved successfully!\"}");
        }
    }

    private void addExam(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String examName = request.getParameter("exam_name");
        String practicalCountStr = request.getParameter("practical_count");
        String practicalMaxMarksStr = request.getParameter("practical_max_marks");
        String slaComponentsJson = request.getParameter("sla_components");

        if (examName == null || examName.isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Exam name required\"}");
            return;
        }

        int practicalCount = practicalCountStr != null && !practicalCountStr.isEmpty() ? Integer.parseInt(practicalCountStr) : 0;
        int practicalMaxMarks = practicalMaxMarksStr != null && !practicalMaxMarksStr.isEmpty() ? Integer.parseInt(practicalMaxMarksStr) : 10; 

        String sql = "INSERT INTO exams (exam_name, exam_type) VALUES (?, 'practical')";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, examName);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            int examId = 0;
            if (rs.next()) examId = rs.getInt(1);

            if (practicalCount > 0) {
                String practicalSql = "INSERT INTO practicals (subject_id, exam_id, practical_no, max_marks) VALUES (?, ?, ?, ?)";
                try (PreparedStatement psPractical = conn.prepareStatement(practicalSql)) {
                    for (int i = 1; i <= practicalCount; i++) {
                        psPractical.setNull(1, Types.INTEGER);
                        psPractical.setInt(2, examId);
                        psPractical.setInt(3, i);
                        psPractical.setInt(4, practicalMaxMarks);
                        psPractical.addBatch();
                    }
                    psPractical.executeBatch();
                }
            }

            if (slaComponentsJson != null && !slaComponentsJson.isEmpty()) {
                try {
                    slaComponentsJson = slaComponentsJson.replace("[", "").replace("]", "");
                    if (!slaComponentsJson.trim().isEmpty()) {
                        String[] components = slaComponentsJson.split("\\},\\{");
                        String slaSql = "INSERT INTO sla_components (subject_id, exam_id, component_name, max_marks) VALUES (?, ?, ?, ?)";     
                        try (PreparedStatement psSla = conn.prepareStatement(slaSql)) {
                            for (String comp : components) {
                                comp = comp.replace("{", "").replace("}", "").replace("\"", "");
                                String[] parts = comp.split(",");
                                String compName = "";
                                int compMaxMarks = 20;
                                for (String part : parts) {
                                    String[] kv = part.split(":");
                                    if (kv.length == 2) {
                                        if ("name".equals(kv[0].trim())) {
                                            compName = kv[1].trim();
                                        } else if ("max_marks".equals(kv[0].trim())) {
                                            compMaxMarks = Integer.parseInt(kv[1].trim());
                                        }
                                    }
                                }
                                if (!compName.isEmpty()) {
                                    psSla.setNull(1, Types.INTEGER);
                                    psSla.setInt(2, examId);
                                    psSla.setString(3, compName);
                                    psSla.setInt(4, compMaxMarks);
                                    psSla.addBatch();
                                }
                            }
                            psSla.executeBatch();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            conn.commit();
            response.getWriter().write("{\"success\":true,\"exam_id\":" + examId + ",\"message\":\"Exam added with practicals and components!\"}");
        }
    }

    private void addPractical(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String subjectIdStr = request.getParameter("subject_id");
        String examIdStr = request.getParameter("exam_id");
        String practicalNoStr = request.getParameter("practical_no");
        String maxMarksStr = request.getParameter("max_marks");

        if (subjectIdStr == null || examIdStr == null || practicalNoStr == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);
        int examId = Integer.parseInt(examIdStr);
        int practicalNo = Integer.parseInt(practicalNoStr);
        int maxMarks = maxMarksStr != null && !maxMarksStr.isEmpty() ? Integer.parseInt(maxMarksStr) : 10;

        String checkSql = "SELECT practical_id FROM practicals WHERE subject_id = ? AND exam_id = ? AND practical_no = ?";
        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setInt(1, subjectId);
            checkPs.setInt(2, examId);
            checkPs.setInt(3, practicalNo);
            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Practical already exists\"}");
                return;
            }
        }

        String sql = "INSERT INTO practicals (subject_id, exam_id, practical_no, max_marks) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, subjectId);
            ps.setInt(2, examId);
            ps.setInt(3, practicalNo);
            ps.setInt(4, maxMarks);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            int practicalId = 0;
            if (rs.next()) practicalId = rs.getInt(1);

            conn.commit();
            response.getWriter().write("{\"success\":true,\"practical_id\":" + practicalId + ",\"message\":\"Practical added!\"}");
        }
    }

    private void addSLAComponent(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String subjectIdStr = request.getParameter("subject_id");
        String examIdStr = request.getParameter("exam_id");
        String componentName = request.getParameter("component_name");
        String maxMarksStr = request.getParameter("max_marks");

        if (subjectIdStr == null || examIdStr == null || componentName == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);
        int examId = Integer.parseInt(examIdStr);
        int maxMarks = maxMarksStr != null && !maxMarksStr.isEmpty() ? Integer.parseInt(maxMarksStr) : 20;

        String sql = "INSERT INTO sla_components (subject_id, exam_id, component_name, max_marks) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, subjectId);
            ps.setInt(2, examId);
            ps.setString(3, componentName);
            ps.setInt(4, maxMarks);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            int componentId = 0;
            if (rs.next()) componentId = rs.getInt(1);

            conn.commit();
            response.getWriter().write("{\"success\":true,\"component_id\":" + componentId + ",\"message\":\"SLA Component added!\"}");        
        }
    }

    private void deletePractical(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String practicalIdStr = request.getParameter("practical_id");

        if (practicalIdStr == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Practical ID required\"}");
            return;
        }

        String sql = "DELETE FROM practicals WHERE practical_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(practicalIdStr));
            ps.executeUpdate();

            String deleteMarksSql = "DELETE FROM student_marks WHERE component_type = 'PRACTICAL' AND component_id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(deleteMarksSql)) {
                ps2.setInt(1, Integer.parseInt(practicalIdStr));
                ps2.executeUpdate();
            }

            conn.commit();
            response.getWriter().write("{\"success\":true,\"message\":\"Practical deleted!\"}");
        }
    }

    private void deleteSLAComponent(Connection conn, HttpServletResponse response, 
            HttpServletRequest request) throws SQLException, IOException {
        String componentIdStr = request.getParameter("component_id");

        if (componentIdStr == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Component ID required\"}");
            return;
        }

        String sql = "DELETE FROM sla_components WHERE component_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(componentIdStr));
            ps.executeUpdate();

            String deleteMarksSql = "DELETE FROM student_marks WHERE component_type = 'SLA' AND component_id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(deleteMarksSql)) {
                ps2.setInt(1, Integer.parseInt(componentIdStr));
                ps2.executeUpdate();
            }

            conn.commit();
            response.getWriter().write("{\"success\":true,\"message\":\"SLA Component deleted!\"}");
        }
    }
}
