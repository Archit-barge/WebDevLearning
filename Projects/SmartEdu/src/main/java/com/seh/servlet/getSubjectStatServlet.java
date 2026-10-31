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

@WebServlet("/getSubjectStat")
public class getSubjectStatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (Connection conn = SQLConnection.getConnection()) {
            ResultSet rs = conn.prepareStatement("SELECT COUNT(*) AS total FROM subjects").executeQuery();
            if (rs.next()) {
                int totalSubjects = rs.getInt("total");
                response.getWriter().write(String.valueOf(totalSubjects));
            }
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("0");
        }
    }
}
