package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.*;
import java.sql.*;

@WebServlet("/teacher/GetSubjectsServlet")
public class GetSubjectsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int classId = Integer.parseInt(req.getParameter("classId"));
        resp.setContentType("application/json");

        StringBuilder json = new StringBuilder("[");
        boolean first = true;

        try (Connection con = SQLConnection.getConnection()) {
            String sql =
              "SELECT s.subject_id, s.subject_name " +
              "FROM subjects s " +
              "JOIN class_subjects cs ON s.subject_id = cs.subject_id " +
              "WHERE cs.class_id=?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{\"id\":")
                    .append(rs.getInt("subject_id"))
                    .append(",\"name\":\"")
                    .append(rs.getString("subject_name"))
                    .append("\"}");
                first = false;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        json.append("]");
        resp.getWriter().print(json.toString());
    }
}
