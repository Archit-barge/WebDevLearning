package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/teacher/PracticalMarksServlet")
public class PracticalMarksServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();

        try {

            String studentId = request.getParameter("studentId");
            String classId = request.getParameter("classId");
            String subjectId = request.getParameter("subjectId");
            String activity = request.getParameter("activity");
            String practicalNo = request.getParameter("practicalNo");
            String marks = request.getParameter("marks");

            if(studentId==null || classId==null || subjectId==null ||
               activity==null || practicalNo==null){
                out.println("Missing Parameters");
                return;
            }

            int sId = Integer.parseInt(studentId);
            int cId = Integer.parseInt(classId);
            int subId = Integer.parseInt(subjectId);
            int pNo = Integer.parseInt(practicalNo);

            Integer markValue = null;

            if(marks!=null && !marks.trim().equals("")){
                markValue = Integer.parseInt(marks);
            }

            Connection conn = SQLConnection.getConnection();

            String sql =
            "INSERT INTO practical_marks " +
            "(student_id,class_id,subject_id,activity_name,practical_no,marks) " +
            "VALUES (?,?,?,?,?,?) " +
            "ON DUPLICATE KEY UPDATE marks=VALUES(marks)";

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, sId);
            ps.setInt(2, cId);
            ps.setInt(3, subId);
            ps.setString(4, activity);
            ps.setInt(5, pNo);

            if(markValue==null){
                ps.setNull(6, java.sql.Types.INTEGER);
            }else{
                ps.setInt(6, markValue);
            }

            ps.executeUpdate();

            ps.close();
            conn.close();

            out.println("Saved");

        } catch(Exception e){
            e.printStackTrace();
            out.println("Error");
        }
    }
}