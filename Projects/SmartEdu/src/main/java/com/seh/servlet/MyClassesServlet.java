package com.seh.servlet;

import jakarta.servlet.*; 
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/student/MyClassesServlet")
public class MyClassesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String, Object>> timetables = new ArrayList<>();

        try (Connection conn = SQLConnection.getConnection()) {

            // ================= GET STUDENT CLASS =================
            int classId = 0;

            PreparedStatement psStudent = conn.prepareStatement(
                    "SELECT class_id FROM students WHERE user_id=?"
            );
            psStudent.setInt(1, user.getUserId());

            ResultSet rsStudent = psStudent.executeQuery();

            if (rsStudent.next()) {
                classId = rsStudent.getInt("class_id");
            }

            // ================= GET TIMETABLE =================
            PreparedStatement psTimetable = conn.prepareStatement(
                    "SELECT id, file_path, file_type, uploaded_at FROM timetables WHERE class_id=? ORDER BY uploaded_at DESC"
            );

            psTimetable.setInt(1, classId);

            ResultSet rs = psTimetable.executeQuery();

            while (rs.next()) {

                Map<String, Object> t = new HashMap<>();

                t.put("id", rs.getInt("id"));
                t.put("file_path", rs.getString("file_path"));
                t.put("file_type", rs.getString("file_type"));
                t.put("uploaded_at", rs.getTimestamp("uploaded_at"));

                timetables.add(t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("timetables", timetables);

        request.getRequestDispatcher("/WEB-INF/student/myclasses.jsp")
                .forward(request, response);
    }
}
