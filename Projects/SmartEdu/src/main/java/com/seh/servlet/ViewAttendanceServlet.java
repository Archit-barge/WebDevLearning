package com.seh.servlet;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/teacher/ViewAttendanceServlet")
public class ViewAttendanceServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get session user
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get parameters from form
        String classId = request.getParameter("classId");
        String subjectId = request.getParameter("subject_id");
        String viewType = request.getParameter("viewType");
        String date = request.getParameter("date");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String sessionType = request.getParameter("sessionType");
        String timeSlot = request.getParameter("timeSlot");

        // Get teacher ID
        int teacherId = 0;
        try (Connection conn = SQLConnection.getConnection()) {
            PreparedStatement psT = conn.prepareStatement("SELECT teacher_id FROM teachers WHERE user_id = ?");
            psT.setInt(1, user.getUserId());
            ResultSet rsT = psT.executeQuery();
            if (rsT.next()) {
                teacherId = rsT.getInt("teacher_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Set basic attributes
        request.setAttribute("classId", classId);
        request.setAttribute("subject_id", subjectId);
        request.setAttribute("viewType", viewType);
        request.setAttribute("sessionType", sessionType);
        request.setAttribute("timeSlot", timeSlot);

        // Handle different view types
        if ("daywise".equals(viewType)) {
            // Day-wise: show all sessions for a specific date
            request.setAttribute("date", date);
            handleDayWiseView(request, classId, subjectId, date, sessionType, teacherId);
        } else if ("monthly".equals(viewType)) {
            // Monthly: show attendance for date range
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            handleMonthlyView(request, classId, subjectId, startDate, endDate, teacherId);
        } else {
            // Single date view (default)
            request.setAttribute("date", date);
            handleSingleDayView(request, classId, subjectId, date, sessionType, timeSlot, teacherId);
        }

        // Forward to JSP
        request.getRequestDispatcher("/WEB-INF/teacher/view_attendance.jsp")
                .forward(request, response);
    }

    private void handleSingleDayView(HttpServletRequest request, String classId, String subjectId, 
            String date, String sessionType, String timeSlot, int teacherId) {
        
        List<Map<String, String>> studentList = new ArrayList<>();
        int total = 0, presentCount = 0, absentCount = 0, notMarkedCount = 0;

        if (classId != null && subjectId != null && date != null && sessionType != null && timeSlot != null) {
            try (Connection conn = SQLConnection.getConnection()) {
                String sql = "SELECT st.student_id, st.roll_number, st.first_name, st.last_name, " +
                        "c.class_name, c.section, s.subject_name, fa.status " +
                        "FROM students st " +
                        "JOIN classes c ON st.class_id = c.class_id " +
                        "JOIN class_subjects cs ON cs.class_id = st.class_id AND cs.subject_id = ? " +
                        "JOIN subjects s ON s.subject_id = cs.subject_id " +
                        "LEFT JOIN full_attendance fa " +
                        "ON fa.student_id = st.student_id " +
                        "AND fa.class_id = st.class_id " +
                        "AND fa.subject_id = cs.subject_id " +
                        "AND fa.attendance_date = ? " +
                        "AND fa.session_type = ? " +
                        "AND fa.time_slot = ? " +
                        "WHERE st.class_id = ? " +
                        "ORDER BY st.roll_number";

                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(subjectId));
                ps.setString(2, date);
                ps.setString(3, sessionType);
                ps.setString(4, timeSlot);
                ps.setInt(5, Integer.parseInt(classId));

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, String> student = new HashMap<>();
                    student.put("student_id", String.valueOf(rs.getInt("student_id")));
                    student.put("roll_number", rs.getString("roll_number"));
                    student.put("first_name", rs.getString("first_name"));
                    student.put("last_name", rs.getString("last_name"));
                    student.put("class_name", rs.getString("class_name"));
                    student.put("section", rs.getString("section"));
                    student.put("subject_name", rs.getString("subject_name"));
                    student.put("attendance_date", date);
                    student.put("session_type", sessionType);
                    student.put("time_slot", timeSlot);

                    String status = rs.getString("status");
                    if (status == null) {
                        status = "Not Marked";
                        notMarkedCount++;
                    } else if (status.equalsIgnoreCase("present")) {
                        presentCount++;
                    } else {
                        absentCount++;
                    }
                    student.put("status", status);
                    studentList.add(student);
                    total++;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("students", studentList);
        request.setAttribute("totalCount", total);
        request.setAttribute("presentCount", presentCount);
        request.setAttribute("absentCount", absentCount);
        request.setAttribute("notMarkedCount", notMarkedCount);
    }

    private void handleDayWiseView(HttpServletRequest request, String classId, String subjectId, 
            String date, String sessionType, int teacherId) {
        
        // Get all sessions for the day
        List<Map<String, String>> sessionsList = new ArrayList<>();
        Map<String, List<Map<String, String>>> attendanceBySession = new LinkedHashMap<>();
        Set<String> allStudents = new LinkedHashSet<>();
        
        int totalRecords = 0, totalPresent = 0, totalAbsent = 0, totalNotMarked = 0;

        if (classId != null && subjectId != null && date != null) {
            try (Connection conn = SQLConnection.getConnection()) {
                // Get all distinct sessions for the day
                String sessionSql = "SELECT DISTINCT session_type, time_slot " +
                        "FROM full_attendance " +
                        "WHERE class_id = ? AND subject_id = ? AND attendance_date = ? " +
                        "ORDER BY time_slot";
                
                PreparedStatement psSession = conn.prepareStatement(sessionSql);
                psSession.setInt(1, Integer.parseInt(classId));
                psSession.setInt(2, Integer.parseInt(subjectId));
                psSession.setString(3, date);
                ResultSet rsSession = psSession.executeQuery();
                
                while (rsSession.next()) {
                    Map<String, String> session = new HashMap<>();
                    session.put("session_type", rsSession.getString("session_type"));
                    session.put("time_slot", rsSession.getString("time_slot"));
                    sessionsList.add(session);
                }

                // If no sessions found, get default slots
                if (sessionsList.isEmpty()) {
                    String[] defaultSlots = {"09:00-10:00", "10:00-11:00", "11:00-12:00", 
                            "12:00-01:00", "01:00-02:00", "02:00-03:00", "03:00-04:00", "04:00-05:00"};
                    for (String slot : defaultSlots) {
                        Map<String, String> session = new HashMap<>();
                        session.put("session_type", sessionType != null ? sessionType : "theory");
                        session.put("time_slot", slot);
                        sessionsList.add(session);
                    }
                }

                // Get students
                String studentSql = "SELECT st.student_id, st.roll_number, st.first_name, st.last_name " +
                        "FROM students st " +
                        "WHERE st.class_id = ? " +
                        "ORDER BY st.roll_number";
                
                PreparedStatement psStudents = conn.prepareStatement(studentSql);
                psStudents.setInt(1, Integer.parseInt(classId));
                ResultSet rsStudents = psStudents.executeQuery();
                
                while (rsStudents.next()) {
                    String studentId = rsStudents.getInt("student_id") + "-" + rsStudents.getString("roll_number");
                    allStudents.add(studentId);
                }

                // Get attendance for each session
                for (Map<String, String> session : sessionsList) {
                    String sessType = session.get("session_type");
                    String slot = session.get("time_slot");
                    String sessionKey = sessType + "|" + slot;
                    
                    String attSql = "SELECT st.student_id, st.roll_number, st.first_name, st.last_name, fa.status " +
                            "FROM students st " +
                            "LEFT JOIN full_attendance fa ON fa.student_id = st.student_id " +
                            "AND fa.class_id = st.class_id " +
                            "AND fa.subject_id = ? " +
                            "AND fa.attendance_date = ? " +
                            "AND fa.session_type = ? " +
                            "AND fa.time_slot = ? " +
                            "WHERE st.class_id = ? " +
                            "ORDER BY st.roll_number";
                    
                    PreparedStatement psAtt = conn.prepareStatement(attSql);
                    psAtt.setInt(1, Integer.parseInt(subjectId));
                    psAtt.setString(2, date);
                    psAtt.setString(3, sessType);
                    psAtt.setString(4, slot);
                    psAtt.setInt(5, Integer.parseInt(classId));
                    
                    ResultSet rsAtt = psAtt.executeQuery();
                    List<Map<String, String>> sessionAttendance = new ArrayList<>();
                    
                    while (rsAtt.next()) {
                        Map<String, String> record = new HashMap<>();
                        record.put("student_id", String.valueOf(rsAtt.getInt("student_id")));
                        record.put("roll_number", rsAtt.getString("roll_number"));
                        record.put("first_name", rsAtt.getString("first_name"));
                        record.put("last_name", rsAtt.getString("last_name"));
                        record.put("session_type", sessType);
                        record.put("time_slot", slot);
                        
                        String status = rsAtt.getString("status");
                        if (status == null) {
                            status = "Not Marked";
                            totalNotMarked++;
                        } else if (status.equalsIgnoreCase("present")) {
                            totalPresent++;
                        } else {
                            totalAbsent++;
                        }
                        record.put("status", status);
                        sessionAttendance.add(record);
                        totalRecords++;
                    }
                    attendanceBySession.put(sessionKey, sessionAttendance);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("sessionsList", sessionsList);
        request.setAttribute("attendanceBySession", attendanceBySession);
        request.setAttribute("allStudents", new ArrayList<>(allStudents));
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("presentCount", totalPresent);
        request.setAttribute("absentCount", totalAbsent);
        request.setAttribute("notMarkedCount", totalNotMarked);
    }

    private void handleMonthlyView(HttpServletRequest request, String classId, String subjectId, 
            String startDate, String endDate, int teacherId) {
        
        List<Map<String, Object>> monthlyReport = new ArrayList<>();
        Map<String, Map<String, Object>> studentSummary = new LinkedHashMap<>();
        
        int totalDays = 0;
        int totalPresent = 0;
        int totalAbsent = 0;
        int totalNotMarked = 0;

        if (classId != null && subjectId != null && startDate != null && endDate != null) {
            try (Connection conn = SQLConnection.getConnection()) {
                // Get students
                String studentSql = "SELECT st.student_id, st.roll_number, st.first_name, st.last_name " +
                        "FROM students st " +
                        "WHERE st.class_id = ? " +
                        "ORDER BY st.roll_number";
                
                PreparedStatement psStudents = conn.prepareStatement(studentSql);
                psStudents.setInt(1, Integer.parseInt(classId));
                ResultSet rsStudents = psStudents.executeQuery();
                
                while (rsStudents.next()) {
                    String studentId = String.valueOf(rsStudents.getInt("student_id"));
                    Map<String, Object> summary = new HashMap<>();
                    summary.put("student_id", studentId);
                    summary.put("roll_number", rsStudents.getString("roll_number"));
                    summary.put("first_name", rsStudents.getString("first_name"));
                    summary.put("last_name", rsStudents.getString("last_name"));
                    summary.put("present", 0);
                    summary.put("absent", 0);
                    summary.put("notMarked", 0);
                    summary.put("total", 0);
                    studentSummary.put(studentId, summary);
                }

                // Calculate date range
                LocalDate start = LocalDate.parse(startDate);
                LocalDate end = LocalDate.parse(endDate);
                totalDays = (int) ChronoUnit.DAYS.between(start, end) + 1;

                // Get attendance for the date range
                String attSql = "SELECT st.student_id, st.roll_number, st.first_name, st.last_name, " +
                        "fa.attendance_date, fa.session_type, fa.time_slot, fa.status " +
                        "FROM students st " +
                        "LEFT JOIN full_attendance fa ON fa.student_id = st.student_id " +
                        "AND fa.class_id = st.class_id " +
                        "AND fa.subject_id = ? " +
                        "AND fa.attendance_date BETWEEN ? AND ? " +
                        "WHERE st.class_id = ? " +
                        "ORDER BY st.roll_number, fa.attendance_date, fa.time_slot";
                
                PreparedStatement psAtt = conn.prepareStatement(attSql);
                psAtt.setInt(1, Integer.parseInt(subjectId));
                psAtt.setString(2, startDate);
                psAtt.setString(3, endDate);
                psAtt.setInt(4, Integer.parseInt(classId));
                
                ResultSet rsAtt = psAtt.executeQuery();
                
                String currentStudentId = "";
                List<Map<String, String>> studentRecords = new ArrayList<>();
                
                while (rsAtt.next()) {
                    String studentId = String.valueOf(rsAtt.getInt("student_id"));
                    
                    if (!studentId.equals(currentStudentId) && !currentStudentId.isEmpty()) {
                        monthlyReport.add(createReportEntry(currentStudentId, studentRecords));
                        studentRecords = new ArrayList<>();
                    }
                    currentStudentId = studentId;
                    
                    Map<String, String> record = new HashMap<>();
                    record.put("student_id", studentId);
                    record.put("roll_number", rsAtt.getString("roll_number"));
                    record.put("first_name", rsAtt.getString("first_name"));
                    record.put("last_name", rsAtt.getString("last_name"));
                    
                    String attendanceDate = rsAtt.getString("attendance_date");
                    String status = rsAtt.getString("status");
                    
                    if (attendanceDate != null) {
                        record.put("attendance_date", attendanceDate);
                        record.put("session_type", rsAtt.getString("session_type"));
                        record.put("time_slot", rsAtt.getString("time_slot"));
                        
                        if (status == null) {
                            status = "Not Marked";
                            record.put("status", status);
                            Map<String, Object> summary = studentSummary.get(studentId);
                            if (summary != null) {
                                summary.put("notMarked", (int) summary.get("notMarked") + 1);
                            }
                            totalNotMarked++;
                        } else if (status.equalsIgnoreCase("present")) {
                            record.put("status", status);
                            Map<String, Object> summary = studentSummary.get(studentId);
                            if (summary != null) {
                                summary.put("present", (int) summary.get("present") + 1);
                            }
                            totalPresent++;
                        } else {
                            record.put("status", status);
                            Map<String, Object> summary = studentSummary.get(studentId);
                            if (summary != null) {
                                summary.put("absent", (int) summary.get("absent") + 1);
                            }
                            totalAbsent++;
                        }
                        studentRecords.add(record);
                    }
                }
                
                // Add last student
                if (!currentStudentId.isEmpty()) {
                    monthlyReport.add(createReportEntry(currentStudentId, studentRecords));
                }
                
                // Update totals in summaries
                for (Map<String, Object> summary : studentSummary.values()) {
                    int present = (int) summary.get("present");
                    int absent = (int) summary.get("absent");
                    int notMarked = (int) summary.get("notMarked");
                    summary.put("total", present + absent + notMarked);
                }
                
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("monthlyReport", monthlyReport);
        request.setAttribute("studentSummary", new ArrayList<>(studentSummary.values()));
        request.setAttribute("totalDays", totalDays);
        request.setAttribute("presentCount", totalPresent);
        request.setAttribute("absentCount", totalAbsent);
        request.setAttribute("notMarkedCount", totalNotMarked);
    }

    private Map<String, Object> createReportEntry(String studentId, List<Map<String, String>> records) {
        Map<String, Object> entry = new HashMap<>();
        if (!records.isEmpty()) {
            entry.put("student_id", records.get(0).get("student_id"));
            entry.put("roll_number", records.get(0).get("roll_number"));
            entry.put("first_name", records.get(0).get("first_name"));
            entry.put("last_name", records.get(0).get("last_name"));
        }
        entry.put("records", records);
        return entry;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set default date to today
        request.setAttribute("date", LocalDate.now().toString());
        request.setAttribute("startDate", LocalDate.now().withDayOfMonth(1).toString());
        request.setAttribute("endDate", LocalDate.now().toString());
        request.getRequestDispatcher("/WEB-INF/teacher/view_attendance.jsp")
                .forward(request, response);
    }
}

