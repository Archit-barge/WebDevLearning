package com.seh.util;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/PageLoaderStudent")
public class PageLoaderStudent extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || !"student".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String page = request.getParameter("page");

        if (page == null || page.trim().isEmpty()) {
            response.getWriter().println("<h3>No page specified</h3>");
            return;
        }

        String path = null;

        switch (page) {

            case "dashboard.jsp":
                path = "/WEB-INF/student/dashboard.jsp";
                break;

            case "student_timetable.jsp":
                path = "/student/ViewTimetableServlet";
                break;

            case "view_attendance.jsp":
                path = "/student/ViewAttendanceStudent";
                break;

            case "my_marks.jsp":
                path = "/student/MyMarksStudentServlet";
                break;

            case "my_assignments.jsp":
                path = "/WEB-INF/student/my_assignments.jsp";
                break;

            case "view_Announcement.jsp":
                path = "/WEB-INF/student/view_Announcement.jsp";
                break;

            case "student_document_library.jsp":
                path = "/WEB-INF/student/student_document_library.jsp";
                break;

            default:
                response.getWriter().println("<h1>404</h1><p>Page not found</p>");
                return;
        }

        request.getRequestDispatcher(path).forward(request, response);
    }
}
