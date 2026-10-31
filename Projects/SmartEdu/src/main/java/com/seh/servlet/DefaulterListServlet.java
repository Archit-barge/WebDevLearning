package com.seh.servlet;

import com.seh.util.SQLConnection;
import com.seh.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/teacher/DefaulterListServlet")
public class DefaulterListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth check
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String classIdParam = request.getParameter("class_id");
        String startDateParam = request.getParameter("start_date");
        String endDateParam = request.getParameter("end_date");
        String filterType = request.getParameter("filter_type");
        
        // Set default values
        if (filterType == null || filterType.isEmpty()) {
            filterType = "overall";
        }
        
        // Set default dates to current month if not provided
        if (startDateParam == null || startDateParam.isEmpty()) {
            java.time.LocalDate now = java.time.LocalDate.now();
            startDateParam = now.withDayOfMonth(1).toString(); // First day of current month
        }
        if (endDateParam == null || endDateParam.isEmpty()) {
            endDateParam = java.time.LocalDate.now().toString(); // Today
        }

        List<Map<String,Object>> defaulters = new ArrayList<>();

        if(classIdParam != null && !classIdParam.isEmpty()){
            String sql;
            PreparedStatement ps;
            
            try(Connection con = SQLConnection.getConnection()){
                if ("overall".equals(filterType)) {
                    // Overall (all-time) defaulter query - use LEFT JOIN to include students with no attendance
                    sql = "SELECT s.student_id, s.roll_number, CONCAT(s.first_name,' ',s.last_name) AS full_name, " +
                            "COALESCE(SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END), 0) AS present_classes, " +
                            "COUNT(a.attendance_id) AS total_classes, " +
                            "COALESCE((SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END)*100.0 / NULLIF(COUNT(a.attendance_id), 0)), 0) AS percentage " +
                            "FROM students s " +
                            "LEFT JOIN full_attendance a ON s.student_id = a.student_id " +
                            "WHERE s.class_id = ? " +
                            "GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name " +
                            "HAVING percentage < 75 OR percentage = 0";
                    ps = con.prepareStatement(sql);
                    ps.setInt(1, Integer.parseInt(classIdParam));
                } else if ("custom".equals(filterType)) {
                    // Custom date range defaulter query - use LEFT JOIN to include students with no attendance
                    sql = "SELECT s.student_id, s.roll_number, CONCAT(s.first_name,' ',s.last_name) AS full_name, " +
                            "COALESCE(SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END), 0) AS present_classes, " +
                            "COUNT(a.attendance_id) AS total_classes, " +
                            "COALESCE((SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END)*100.0 / NULLIF(COUNT(a.attendance_id), 0)), 0) AS percentage " +
                            "FROM students s " +
                            "LEFT JOIN full_attendance a ON s.student_id = a.student_id " +
                            "AND a.attendance_date >= ? " +
                            "AND a.attendance_date <= ? " +
                            "WHERE s.class_id = ? " +
                            "GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name " +
                            "HAVING percentage < 75 OR percentage = 0";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, startDateParam);
                    ps.setString(2, endDateParam);
                    ps.setInt(3, Integer.parseInt(classIdParam));
                } else {
                    // Month-wise defaulter query (for backward compatibility)
                    int month = Integer.parseInt(filterType);
                    int year = Integer.parseInt(request.getParameter("year") != null ? request.getParameter("year") : String.valueOf(java.time.Year.now().getValue()));
                    
                    sql = "SELECT s.student_id, s.roll_number, CONCAT(s.first_name,' ',s.last_name) AS full_name, " +
                            "SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END) AS present_classes, " +
                            "COUNT(a.attendance_id) AS total_classes, " +
                            "(SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END)*100.0/COUNT(a.attendance_id)) AS percentage " +
                            "FROM students s " +
                            "JOIN full_attendance a ON s.student_id=a.student_id " +
                            "WHERE s.class_id=? " +
                            "AND YEAR(a.attendance_date)=? " +
                            "AND MONTH(a.attendance_date)=? " +
                            "GROUP BY s.student_id " +
                            "HAVING percentage<75";
                    ps = con.prepareStatement(sql);
                    ps.setInt(1, Integer.parseInt(classIdParam));
                    ps.setInt(2, year);
                    ps.setInt(3, month);
                }

                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    Map<String,Object> d = new HashMap<>();
                    d.put("roll_number", rs.getString("roll_number"));
                    d.put("full_name", rs.getString("full_name"));
                    d.put("present_classes", rs.getInt("present_classes"));
                    d.put("total_classes", rs.getInt("total_classes"));
                    d.put("percentage", rs.getDouble("percentage"));
                    defaulters.add(d);
                }
            } catch(SQLException e){ e.printStackTrace(); }
        }

        request.setAttribute("class_id", classIdParam);
        request.setAttribute("filter_type", filterType);
        request.setAttribute("start_date", startDateParam);
        request.setAttribute("end_date", endDateParam);
        request.setAttribute("defaulters", defaulters);
        
        // Forward to the dedicated DefaulterList.jsp
        request.getRequestDispatcher("/WEB-INF/teacher/defaulter_list.jsp").forward(request,response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request,response);
    }
}
