package com.seh.servlet;

import java.io.IOException; 
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.seh.util.SQLConnection;

@WebServlet("/teacher/SearchStudentServlet")
public class SearchStudentServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("query");

        try (Connection conn = SQLConnection.getConnection()) {

            String sql = "SELECT * FROM students WHERE name LIKE ? OR roll_no LIKE ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "%" + query + "%");
            ps.setString(2, "%" + query + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                response.getWriter().println(
                    "<tr>" +
                    "<td>" + rs.getString("roll_no") + "</td>" +
                    "<td>" + rs.getString("name") + "</td>" +
                    "<td>" + rs.getString("department") + "</td>" +
                    "<td>" + rs.getString("semester") + "</td>" +
                    "<td>" + rs.getString("email") + "</td>" +
                    "<td>" +
                       "<form action='ViewStudentServlet' method='get' style='display:inline;'>" +
                       "<input type='hidden' name='roll_no' value='" + rs.getString("roll_no") + "'>" +
                       "<button class='btn-small'>View</button></form>" +

                       "<form action='DeleteStudentServlet' method='post' style='display:inline;'>" +
                       "<input type='hidden' name='roll_no' value='" + rs.getString("roll_no") + "'>" +
                       "<button class='btn-small btn-danger'>Remove</button></form>" +
                    "</td>" +
                    "</tr>"
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
