package com.seh.servlet;

import com.seh.util.SQLConnection;
import com.seh.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/addTask")
public class AddTaskServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {

            String sql = "INSERT INTO teacher_tasks "
                    + "(teacher_id, class_id, subject_id, task_date, topic, description, duration) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, user.getUserId());
            ps.setInt(2, Integer.parseInt(request.getParameter("classId")));
            ps.setInt(3, Integer.parseInt(request.getParameter("subjectId")));
            ps.setString(4, request.getParameter("taskDate"));
            ps.setString(5, request.getParameter("topic"));
            ps.setString(6, request.getParameter("description"));
            ps.setString(7, request.getParameter("duration"));

            ps.executeUpdate();

            session.setAttribute("successMessage", "Task saved successfully!");

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/teacher/Index.jsp");
    }
}