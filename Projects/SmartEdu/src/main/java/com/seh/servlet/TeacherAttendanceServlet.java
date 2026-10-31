package com.seh.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/teacher/TeacherAttendanceServlet")
public class TeacherAttendanceServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String classId = request.getParameter("classId");
        String subjectId = request.getParameter("subject_id");
        String date = request.getParameter("date");
        String sessionType = request.getParameter("sessionType");
        String timeSlot = request.getParameter("timeSlot");

        // ✅ SET ATTRIBUTES
        request.setAttribute("classId", classId);
        request.setAttribute("subject_id", subjectId);
        request.setAttribute("date", date);
        request.setAttribute("sessionType", sessionType);
        request.setAttribute("timeSlot", timeSlot);

        // ✅ FORWARD (NOT REDIRECT)
        request.getRequestDispatcher("/WEB-INF/teacher/mark_attendance.jsp")
                .forward(request, response);
    }

    // ✅ ADDED DOGET
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Option 1 (Best) → Reuse doPost logic
        doPost(request, response);

        // Option 2 → If you want direct forward instead, use below and remove above line
        /*
        request.getRequestDispatcher("/WEB-INF/teacher/mark_attendance.jsp")
                .forward(request, response);
        */
    }
}
