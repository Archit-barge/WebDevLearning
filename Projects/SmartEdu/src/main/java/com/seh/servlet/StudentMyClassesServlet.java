package com.seh.servlet;

import java.io.IOException; 
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/student/StudentMyClassesServlet")
public class StudentMyClassesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // SESSION CHECK
        HttpSession session = request.getSession(false);
        if(session == null || !"student".equals(session.getAttribute("role"))) {
            response.sendRedirect("../login.jsp");
            return;
        }

        // Forward to JSP under WEB-INF
        request.getRequestDispatcher("/WEB-INF/student/my_classes.jsp")
               .forward(request, response);
    }
}
