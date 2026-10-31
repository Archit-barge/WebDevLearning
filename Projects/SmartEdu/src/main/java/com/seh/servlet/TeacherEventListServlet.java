package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.*;

@WebServlet("/teacher/event-list")
public class TeacherEventListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, Object>> events = new ArrayList<>();

        try (Connection conn = SQLConnection.getConnection()) {

            ResultSet rs = conn.createStatement()
                    .executeQuery("SELECT * FROM events ORDER BY created_at DESC");

            while (rs.next()) {
                Map<String, Object> e = new HashMap<>();
                e.put("title", rs.getString("title"));
                e.put("date", rs.getDate("event_date"));
                e.put("template", rs.getInt("template_type"));
                events.add(e);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            throw new ServletException(ex);
        }

        request.setAttribute("events", events);
        request.getRequestDispatcher("/WEB-INF/teacher/eventList.jsp")
               .forward(request, response);
    }
}
