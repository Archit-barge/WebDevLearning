package com.seh.servlet;

import jakarta.servlet.*; 
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/student/MyTimetableServlet")
public class MyTimetableServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if(user == null){
            response.sendRedirect("../login.jsp");
            return;
        }

        List<Map<String,Object>> timetables = new ArrayList<>();

        try(Connection conn = SQLConnection.getConnection()){

            // Get student class
            int classId = 0;

            PreparedStatement psStudent = conn.prepareStatement(
                    "SELECT class_id FROM students WHERE user_id=?");

            psStudent.setInt(1, user.getUserId());
            ResultSet rsStudent = psStudent.executeQuery();

            if(rsStudent.next()){
                classId = rsStudent.getInt("class_id");
            }

            // Get timetable
            PreparedStatement ps = conn.prepareStatement(
                    "SELECT * FROM timetables WHERE class_id=? ORDER BY uploaded_at DESC");

            ps.setInt(1, classId);
            ResultSet rs = ps.executeQuery();

            while(rs.next()){
                Map<String,Object> map = new HashMap<>();
                map.put("file_path", rs.getString("file_path"));
                map.put("file_type", rs.getString("file_type"));
                timetables.add(map);
            }

        }catch(Exception e){
            e.printStackTrace();
        }

        request.setAttribute("timetables", timetables);

        request.getRequestDispatcher("/WEB-INF/student/myTimetable.jsp")
               .forward(request, response);
    }
}
