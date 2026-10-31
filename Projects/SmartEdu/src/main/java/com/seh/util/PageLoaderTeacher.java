package com.seh.util;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@SuppressWarnings("serial")
@WebServlet("/PageLoaderTeacher")
public class PageLoaderTeacher extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String page = request.getParameter("page");

        if (page == null || page.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Page parameter missing");
            return;
        }

        // Transfer messages from session → request
        HttpSession session = request.getSession(false);
        if (session != null) {
            String error = (String) session.getAttribute("error");
            String success = (String) session.getAttribute("success");

            if (error != null) {
                request.setAttribute("error", error);
                session.removeAttribute("error");
            }
            if (success != null) {
                request.setAttribute("success", success);
                session.removeAttribute("success");
            }
        }

        String path = "/WEB-INF/teacher/" + page;
        RequestDispatcher rd = request.getRequestDispatcher(path);
        rd.forward(request, response);
    }
}
