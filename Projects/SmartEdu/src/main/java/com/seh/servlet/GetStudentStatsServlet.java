package com.seh.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;
import com.seh.util.SQLConnection;

@WebServlet("/getStudentStats")
public class GetStudentStatsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (Connection conn = SQLConnection.getConnection()) {

            int totalStudents = 0;
            int activeStudents = 0;
            int totalClasses = 0;

            ResultSet rs1 = conn.prepareStatement("SELECT COUNT(*) AS total FROM students").executeQuery();
            if (rs1.next())
                totalStudents = rs1.getInt("total");
            rs1.close();

            ResultSet rs2 = conn.prepareStatement(
                "SELECT COUNT(*) AS active FROM students s JOIN users u ON s.user_id = u.user_id WHERE u.status='active'")
                .executeQuery();
            if (rs2.next())
                activeStudents = rs2.getInt("active");
            rs2.close();

            ResultSet rs3 = conn.prepareStatement("SELECT COUNT(*) AS total_classes FROM classes").executeQuery();
            if (rs3.next())
                totalClasses = rs3.getInt("total_classes");
            rs3.close();

            response.getWriter().write(
                "<div class='stat-card'>" +
                "<div class='stat-number'>" + totalStudents + "</div>" +
                "<div class='stat-label'>Total Students</div>" +
                "</div>" +
                "<div class='stat-card'>" +
                "<div class='stat-number'>" + activeStudents + "</div>" +
                "<div class='stat-label'>Active Students</div>" +
                "</div>" +
                "<div class='stat-card'>" +
                "<div class='stat-number'>" + totalClasses + "</div>" +
                "<div class='stat-label'>Total Classes</div>" +
                "</div>"
            );

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
