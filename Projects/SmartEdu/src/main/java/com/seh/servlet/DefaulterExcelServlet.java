package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/teacher/DefaulterExcelServlet")
public class DefaulterExcelServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String classIdParam = request.getParameter("class_id");
        String filterType = request.getParameter("filter_type");
        String startDateParam = request.getParameter("start_date");
        String endDateParam = request.getParameter("end_date");

        // Set default values
        if (filterType == null || filterType.isEmpty()) {
            filterType = "overall";
        }
        if (startDateParam == null || startDateParam.isEmpty()) {
            startDateParam = java.time.LocalDate.now().withDayOfMonth(1).toString();
        }
        if (endDateParam == null || endDateParam.isEmpty()) {
            endDateParam = java.time.LocalDate.now().toString();
        }

        if (classIdParam == null || classIdParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Class ID is required");
            return;
        }

        // Excel compatible CSV
        response.setContentType("text/csv; charset=UTF-8");
        String fileName;
        String periodHeader;
        
        if ("overall".equals(filterType)) {
            fileName = "Defaulters_Overall.csv";
            periodHeader = "Overall";
        } else {
            fileName = "Defaulters_" + startDateParam + "_to_" + endDateParam + ".csv";
            periodHeader = startDateParam + " to " + endDateParam;
        }
        
        response.setHeader("Content-Disposition", "attachment; filename=" + fileName);

        try (
            PrintWriter out = response.getWriter();
            Connection con = SQLConnection.getConnection();
        ) {
            PreparedStatement ps;
            ResultSet rs;
            
            if ("overall".equals(filterType)) {
                // Overall (all-time) defaulter query - use LEFT JOIN to include students with no attendance
                String sql = "SELECT s.roll_number, CONCAT(s.first_name,' ',s.last_name) AS full_name, " +
                        "COALESCE(SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END), 0) AS present_classes, " +
                        "COUNT(a.attendance_id) AS total_classes, " +
                        "COALESCE((SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END)*100.0 / NULLIF(COUNT(a.attendance_id), 0)), 0) AS attendance_percent " +
                        "FROM students s " +
                        "LEFT JOIN full_attendance a ON s.student_id = a.student_id " +
                        "WHERE s.class_id = ? " +
                        "GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name " +
                        "HAVING attendance_percent < 75 OR attendance_percent = 0";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(classIdParam));
            } else {
                // Custom date range defaulter query - use LEFT JOIN to include students with no attendance
                String sql = "SELECT s.roll_number, CONCAT(s.first_name,' ',s.last_name) AS full_name, " +
                        "COALESCE(SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END), 0) AS present_classes, " +
                        "COUNT(a.attendance_id) AS total_classes, " +
                        "COALESCE((SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END)*100.0 / NULLIF(COUNT(a.attendance_id), 0)), 0) AS attendance_percent " +
                        "FROM students s " +
                        "LEFT JOIN full_attendance a ON s.student_id = a.student_id " +
                        "AND a.attendance_date >= ? " +
                        "AND a.attendance_date <= ? " +
                        "WHERE s.class_id = ? " +
                        "GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name " +
                        "HAVING attendance_percent < 75 OR attendance_percent = 0";
                ps = con.prepareStatement(sql);
                ps.setString(1, startDateParam);
                ps.setString(2, endDateParam);
                ps.setInt(3, Integer.parseInt(classIdParam));
            }

            rs = ps.executeQuery();

            // Excel UTF Fix (important for Excel)
            out.write('\ufeff');

            // Header
            out.println("Roll Number,Student Name,Present Classes,Total Classes,Attendance %,Period");

            boolean hasData = false;

            while (rs.next()) {
                hasData = true;
                double percent = rs.getDouble("attendance_percent");
                if (rs.wasNull()) percent = 0;

                out.println(
                        rs.getString("roll_number") + "," +
                        rs.getString("full_name") + "," +
                        rs.getInt("present_classes") + "," +
                        rs.getInt("total_classes") + "," +
                        String.format("%.2f", percent) + "," +
                        periodHeader
                );
            }

            if (!hasData) {
                out.println("No defaulters found for this criteria");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating CSV");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        doGet(request, response);
    }
}
