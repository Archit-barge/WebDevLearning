package com.seh.servlet;

import jakarta.servlet.ServletException; 
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.seh.model.User;
@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
		HttpSession session = request.getSession(false); // don’t create new
        if (session != null) {
            User user = (User) session.getAttribute("user");

            if (user != null) {
                System.out.println("🔴 User logged out: " + user.getUsername() + " (" + user.getRole() + ")");
            } else {
                System.out.println("🔴 Unknown user logged out (no user in session).");
            }
            session.invalidate();
        }


		response.sendRedirect("login.jsp");
	}

}
