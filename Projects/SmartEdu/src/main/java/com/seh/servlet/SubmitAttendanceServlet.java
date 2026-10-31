package com.seh.servlet;

import java.io.IOException;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/SubmitAttendanceServlet")
public class SubmitAttendanceServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("Attendance servlet called");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String classIdStr = request.getParameter("class_id");
        String subjectIdStr = request.getParameter("subject_id");
        String date = request.getParameter("date");
        String sessionType = request.getParameter("sessionType");
        String timeSlot = request.getParameter("timeSlot");

        System.out.println("Class ID: " + classIdStr);
        System.out.println("Subject ID: " + subjectIdStr);
        System.out.println("Date: " + date);
        System.out.println("Session Type: " + sessionType);
        System.out.println("Time Slot: " + timeSlot);

        if (classIdStr == null || subjectIdStr == null || date == null ||
                sessionType == null || timeSlot == null ||
                classIdStr.isEmpty() || subjectIdStr.isEmpty() || date.isEmpty() ||
                sessionType.isEmpty() || timeSlot.isEmpty()) {

            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/WEB-INF/teacher/mark_attendance.jsp")
                    .forward(request, response);
            return;
        }

        int classId = Integer.parseInt(classIdStr);
        int subjectId = Integer.parseInt(subjectIdStr);

        Connection conn = null;
        PreparedStatement psTeacher = null;
        PreparedStatement psStudents = null;
        PreparedStatement psInsert = null;
        ResultSet rsTeacher = null;
        ResultSet rsStudents = null;

        try {

            conn = SQLConnection.getConnection();

            // ===== GET TEACHER ID =====
            psTeacher = conn.prepareStatement(
                    "SELECT teacher_id FROM teachers WHERE user_id = ?");
            psTeacher.setInt(1, user.getUserId());

            rsTeacher = psTeacher.executeQuery();

            int teacherId = 0;

            if (rsTeacher.next()) {
                teacherId = rsTeacher.getInt("teacher_id");
            } else {
                throw new ServletException("Teacher not found");
            }

            System.out.println("Teacher ID: " + teacherId);

            // ===== GET STUDENTS =====
            psStudents = conn.prepareStatement(
                    "SELECT student_id FROM students WHERE class_id = ?");
            psStudents.setInt(1, classId);

            rsStudents = psStudents.executeQuery();

            // ===== INSERT QUERY =====
            String insertSQL =
                    "INSERT INTO full_attendance " +
                    "(student_id, class_id, subject_id, attendance_date, session_type, time_slot, status, marked_by) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            psInsert = conn.prepareStatement(insertSQL);

            int count = 0;

            while (rsStudents.next()) {

                int studentId = rsStudents.getInt("student_id");

                String status = request.getParameter("attendance_" + studentId);

                if (status == null) {
                    status = "absent";
                }

                System.out.println("Student: " + studentId + " Status: " + status);

                psInsert.setInt(1, studentId);
                psInsert.setInt(2, classId);
                psInsert.setInt(3, subjectId);
                psInsert.setDate(4, java.sql.Date.valueOf(date));
                psInsert.setString(5, sessionType);
                psInsert.setString(6, timeSlot);
                psInsert.setString(7, status);
                psInsert.setInt(8, teacherId);

                psInsert.executeUpdate();

                count++;
            }

            System.out.println("Total Attendance Saved: " + count);

            response.sendRedirect(
                    request.getContextPath()
                            + "/teacher/Index.jsp?success=Attendance Saved");

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                            + "/teacher/Index.jsp?error=" + e.getMessage());

        } finally {

            try {
                if (rsTeacher != null)
                    rsTeacher.close();
                if (rsStudents != null)
                    rsStudents.close();
                if (psTeacher != null)
                    psTeacher.close();
                if (psStudents != null)
                    psStudents.close();
                if (psInsert != null)
                    psInsert.close();
                if (conn != null)
                    conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp");
    }
}