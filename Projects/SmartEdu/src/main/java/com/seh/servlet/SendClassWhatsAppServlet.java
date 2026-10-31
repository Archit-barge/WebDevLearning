package com.seh.servlet;

import java.io.IOException; 
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/teacher/SendClassWhatsAppServlet")
public class SendClassWhatsAppServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        String desc = request.getParameter("desc");
        String classId = request.getParameter("classId");

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User teacher = (User) session.getAttribute("user");
        if (teacher == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String teacherName = teacher.getFullName();

        if (title == null || title.trim().isEmpty()) title = "No Title";
        if (desc == null || desc.trim().isEmpty()) desc = "No Message";

        // 🔹 Fetch WhatsApp group link (CLASS-WISE)
        String groupLink = null;

        try (Connection con = SQLConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT whatsapp_link FROM class_whatsapp_group WHERE class_id=?");
            ps.setInt(1, Integer.parseInt(classId));
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                groupLink = rs.getString("whatsapp_link");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (groupLink == null) {
            response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp");
            return;
        }

        // 🔹 Message to COPY (not prefilled)
        String message =
                "📢 New Announcement\n\n" +
                "Title: " + title + "\n" +
                "Message: " + desc + "\n\n" +
                "Sent by: " + teacherName;

        request.setAttribute("groupLink", groupLink);
        request.setAttribute("message", message);

        request.getRequestDispatcher("/WEB-INF/teacher/SendWhatsAppGroup.jsp")
               .forward(request, response);
    }
}
