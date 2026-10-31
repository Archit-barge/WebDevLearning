package com.seh.servlet;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

/**
 * Servlet to export session-wise student attendance to Excel (CSV format).
 */
@WebServlet("/teacher/AttendanceExcelServlet")
public class AttendanceExcelServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final DateTimeFormatter DB_DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DISPLAY_DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String classId = request.getParameter("classId");
        String subjectId = request.getParameter("subject_id");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        if (classId == null || subjectId == null || startDate == null || endDate == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/ViewAttendanceServlet");
            return;
        }

        try {
            generateSessionWiseCSV(response, classId, subjectId, startDate, endDate);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/teacher/ViewAttendanceServlet");
        }
    }

    private void generateSessionWiseCSV(HttpServletResponse response, String classId, String subjectId,
                                        String startDate, String endDate) throws SQLException, IOException {

        Map<String, Map<String, String>> attendanceData = new LinkedHashMap<>();
        Map<String, Map<String, Object>> studentInfo = new LinkedHashMap<>();
        List<String> sessionHeaders = new ArrayList<>();
        String className = "";
        String subjectName = "";

        try (Connection conn = SQLConnection.getConnection()) {
            // 1. Get class name
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT class_name, section FROM classes WHERE class_id=?")) {
                ps.setInt(1, Integer.parseInt(classId));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) className = rs.getString("class_name") + " " + rs.getString("section");
                }
            }

            // 2. Get subject name
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT subject_name FROM subjects WHERE subject_id=?")) {
                ps.setInt(1, Integer.parseInt(subjectId));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) subjectName = rs.getString("subject_name");
                }
            }

            // 3. Get students
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT student_id, roll_number, first_name, last_name " +
                            "FROM students WHERE class_id=? ORDER BY LPAD(roll_number, 10,'0')")) {
                ps.setInt(1, Integer.parseInt(classId));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String studentId = String.valueOf(rs.getInt("student_id"));
                        Map<String, Object> info = new HashMap<>();
                        info.put("roll_number", rs.getString("roll_number"));
                        info.put("first_name", rs.getString("first_name"));
                        info.put("last_name", rs.getString("last_name"));
                        studentInfo.put(studentId, info);
                        attendanceData.put(studentId, new LinkedHashMap<>());
                    }
                }
            }

            // 4. Get all sessions for the date range dynamically
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DISTINCT attendance_date, session_type FROM full_attendance " +
                            "WHERE class_id=? AND subject_id=? AND attendance_date BETWEEN ? AND ? " +
                            "ORDER BY attendance_date, session_type")) {
                ps.setInt(1, Integer.parseInt(classId));
                ps.setInt(2, Integer.parseInt(subjectId));
                ps.setString(3, startDate);
                ps.setString(4, endDate);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String key = rs.getString("attendance_date") + "|" + rs.getString("session_type");
                        if (!sessionHeaders.contains(key)) sessionHeaders.add(key);
                    }
                }
            }

            // 5. Get attendance records
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT student_id, attendance_date, session_type, status FROM full_attendance " +
                            "WHERE class_id=? AND subject_id=? AND attendance_date BETWEEN ? AND ?")) {
                ps.setInt(1, Integer.parseInt(classId));
                ps.setInt(2, Integer.parseInt(subjectId));
                ps.setString(3, startDate);
                ps.setString(4, endDate);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String studentId = String.valueOf(rs.getInt("student_id"));
                        String key = rs.getString("attendance_date") + "|" + rs.getString("session_type");
                        String status = rs.getString("status");
                        Map<String, String> map = attendanceData.get(studentId);
                        if (map != null) map.put(key, status);
                    }
                }
            }
        }

        // Build CSV
        StringBuilder csv = new StringBuilder();
        csv.append("\uFEFF"); // BOM for Excel

        csv.append("ATTENDANCE REPORT\n");
        csv.append("Class:,").append(escapeCSV(className)).append("\n");
        csv.append("Subject:,").append(escapeCSV(subjectName)).append("\n");
        csv.append("Period:,").append(startDate).append(" to ").append(endDate).append("\n");
        csv.append("Total Students:,").append(studentInfo.size()).append("\n\n");

        // Header row
        csv.append("S.No,Roll No.,Student Name,");
        for (String s : sessionHeaders) {
            String[] parts = s.split("\\|");
            csv.append(parts[0]).append(" (").append(parts[1]).append("),");
        }
        csv.append("Present,Absent,Percentage (%)\n");

        // Student rows
        int serial = 1;
        for (String studentId : studentInfo.keySet()) {
            Map<String, Object> info = studentInfo.get(studentId);
            Map<String, String> att = attendanceData.get(studentId);

            csv.append(serial).append(",");
            csv.append(escapeCSV((String) info.get("roll_number"))).append(",");
            csv.append(escapeCSV(info.get("first_name") + " " + info.get("last_name"))).append(",");

            int present = 0, absent = 0;

            for (String s : sessionHeaders) {
                String status = att.get(s);
                if (status == null || status.isEmpty() || "nm".equalsIgnoreCase(status)) status = "-";
                else if ("present".equalsIgnoreCase(status)) { status = "P"; present++; }
                else if ("absent".equalsIgnoreCase(status)) { status = "A"; absent++; }
                csv.append(status).append(",");
            }

            csv.append(present).append(",").append(absent).append(",");
            double perc = (sessionHeaders.isEmpty()) ? 0 : (present * 100.0 / sessionHeaders.size());
            csv.append(String.format("%.2f", perc)).append("\n");

            serial++;
        }

        // Response
        String fileName = "Attendance_" + className.replaceAll("[^a-zA-Z0-9]", "_") + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        response.getWriter().write(csv.toString());
    }

    private String escapeCSV(String value) {
        if (value == null) return "";
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}