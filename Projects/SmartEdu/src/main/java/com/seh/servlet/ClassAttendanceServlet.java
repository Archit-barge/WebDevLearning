package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/teacher/ClassAttendanceServlet")
public class ClassAttendanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Get parameters
        String classIdParam = request.getParameter("class_id");
        String subjectIdParam = request.getParameter("subject_id");
        String sessionTypeParam = request.getParameter("session_type");

        // Get teacher ID
        int teacherId = 0;
        try (Connection conn = SQLConnection.getConnection()) {
            PreparedStatement psT = conn.prepareStatement(
                "SELECT teacher_id FROM teachers WHERE user_id = ?"
            );
            psT.setInt(1, user.getUserId());
            ResultSet rsT = psT.executeQuery();
            if (rsT.next()) {
                teacherId = rsT.getInt("teacher_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        List<Map<String, Object>> attendanceList = new ArrayList<>();

        if (classIdParam != null && subjectIdParam != null && sessionTypeParam != null &&
            !classIdParam.isEmpty() && !subjectIdParam.isEmpty() && !sessionTypeParam.isEmpty()) {

            try (Connection con = SQLConnection.getConnection()) {

                // Build SQL based on session type
                String sql;
                if ("all".equals(sessionTypeParam)) {
                    // Show both theory and practical combined
                    sql = """
                        SELECT 
                            s.student_id,
                            s.roll_number,
                            s.first_name,
                            s.last_name,
                            c.class_name,
                            c.section,
                            sub.subject_name,

                            COUNT(DISTINCT CONCAT(fa.attendance_date, fa.time_slot, fa.session_type)) AS total_lectures,

                            SUM(CASE WHEN fa.status = 'present' THEN 1 ELSE 0 END) AS present_lectures,

                            SUM(CASE WHEN fa.status = 'absent' THEN 1 ELSE 0 END) AS absent_lectures

                        FROM students s
                        JOIN classes c ON s.class_id = c.class_id
                        JOIN class_subjects cs ON cs.class_id = s.class_id
                        JOIN subjects sub ON sub.subject_id = cs.subject_id
                        LEFT JOIN full_attendance fa 
                            ON fa.student_id = s.student_id 
                            AND fa.subject_id = sub.subject_id
                            AND fa.class_id = s.class_id

                        WHERE s.class_id = ?
                            AND sub.subject_id = ?
                            AND cs.teacher_id = ?

                        GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name, 
                                 c.class_name, c.section, sub.subject_name
                        ORDER BY s.roll_number
                        """;
                } else {
                    // Filter by specific session type (theory or practical)
                    sql = """
                        SELECT 
                            s.student_id,
                            s.roll_number,
                            s.first_name,
                            s.last_name,
                            c.class_name,
                            c.section,
                            sub.subject_name,

                            COUNT(DISTINCT CONCAT(fa.attendance_date, fa.time_slot, fa.session_type)) AS total_lectures,

                            SUM(CASE WHEN fa.status = 'present' THEN 1 ELSE 0 END) AS present_lectures,

                            SUM(CASE WHEN fa.status = 'absent' THEN 1 ELSE 0 END) AS absent_lectures

                        FROM students s
                        JOIN classes c ON s.class_id = c.class_id
                        JOIN class_subjects cs ON cs.class_id = s.class_id
                        JOIN subjects sub ON sub.subject_id = cs.subject_id
                        LEFT JOIN full_attendance fa 
                            ON fa.student_id = s.student_id 
                            AND fa.subject_id = sub.subject_id
                            AND fa.class_id = s.class_id
                            AND fa.session_type = ?

                        WHERE s.class_id = ?
                            AND sub.subject_id = ?
                            AND cs.teacher_id = ?

                        GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name, 
                                 c.class_name, c.section, sub.subject_name
                        ORDER BY s.roll_number
                        """;
                }

                PreparedStatement ps = con.prepareStatement(sql);

                int paramIndex = 1;
                if ("all".equals(sessionTypeParam)) {
                    ps.setInt(paramIndex++, Integer.parseInt(classIdParam));
                    ps.setInt(paramIndex++, Integer.parseInt(subjectIdParam));
                    ps.setInt(paramIndex++, teacherId);
                } else {
                    ps.setString(paramIndex++, sessionTypeParam);
                    ps.setInt(paramIndex++, Integer.parseInt(classIdParam));
                    ps.setInt(paramIndex++, Integer.parseInt(subjectIdParam));
                    ps.setInt(paramIndex++, teacherId);
                }

                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("student_id", rs.getInt("student_id"));
                    row.put("roll_number", rs.getString("roll_number"));
                    row.put("first_name", rs.getString("first_name"));
                    row.put("last_name", rs.getString("last_name"));
                    row.put("full_name", rs.getString("first_name") + " " + rs.getString("last_name"));
                    row.put("class_name", rs.getString("class_name"));
                    row.put("section", rs.getString("section"));
                    row.put("subject_name", rs.getString("subject_name"));

                    int totalLectures = rs.getInt("total_lectures");
                    int presentLectures = rs.getInt("present_lectures");
                    int absentLectures = rs.getInt("absent_lectures");

                    row.put("total_lectures", totalLectures);
                    row.put("present_lectures", presentLectures);
                    row.put("absent_lectures", absentLectures);

                    double percentage = 0;
                    if (totalLectures > 0) {
                        percentage = (presentLectures * 100.0) / totalLectures;
                    }
                    row.put("percentage", Math.round(percentage * 100.0) / 100.0);

                    attendanceList.add(row);
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("attendanceList", attendanceList);
        request.setAttribute("classId", classIdParam);
        request.setAttribute("subjectId", subjectIdParam);
        request.setAttribute("sessionType", sessionTypeParam);

        request.getRequestDispatcher("/WEB-INF/teacher/class_attendance_report.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
