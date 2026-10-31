package com.seh.servlet;

import com.seh.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/teacherTasks")
public class TeacherTasksServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            handleUnauthorized(request, response);
            return;
        }

        if (isAjax(request)) {
            request.getRequestDispatcher("/WEB-INF/admin/teacherTasks.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/Index.jsp?page=teacherTasks.jsp");
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Object role = session.getAttribute("role");
        Object user = session.getAttribute("user");
        return "admin".equals(role) && user instanceof User;
    }

    private boolean isAjax(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith);
    }

    private void handleUnauthorized(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (isAjax(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}
