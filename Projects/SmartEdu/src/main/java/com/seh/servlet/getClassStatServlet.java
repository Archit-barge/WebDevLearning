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

@WebServlet("/getClassStat")
public class getClassStatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (Connection conn = SQLConnection.getConnection()) {
            int totalClasses = 0;
            int totalTeachers = 0;
            
            ResultSet rs1 = conn.prepareStatement("SELECT COUNT(*) AS total FROM classes").executeQuery();
            if (rs1.next()) {
                totalClasses = rs1.getInt("total");
            }
            rs1.close();

            ResultSet rs2 = conn.prepareStatement("SELECT COUNT(*) AS total FROM teachers").executeQuery();
            if (rs2.next()) {
                totalTeachers = rs2.getInt("total");
            }
            rs2.close();

            response.getWriter().write(
                "<div class='stat-card'>" +
                "<div class='stat-number'>" + totalClasses + "</div>" +
                "<div class='stat-label'>Total Classes</div>" +
                "</div>" +
                "<div class='stat-card'>" +
                "<div class='stat-number'>" + totalTeachers + "</div>" +
                "<div class='stat-label'>Total Teachers</div>" +
                "</div>"
            );
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("<div class='stat-card'><div class='stat-number'>0</div></div>");
        }
    }
}
