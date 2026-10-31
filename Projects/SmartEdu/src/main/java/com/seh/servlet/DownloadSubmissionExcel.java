package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;

@WebServlet("/teacher/DownloadSubmissionExcel")
public class DownloadSubmissionExcel extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String classIdStr = request.getParameter("classId");
        String subjectIdStr = request.getParameter("subjectId");
        String activity = request.getParameter("activity");

        if (classIdStr == null || subjectIdStr == null || activity == null) {
            response.getWriter().println("Missing parameters");
            return;
        }

        int classId = Integer.parseInt(classIdStr);
        int subjectId = Integer.parseInt(subjectIdStr);

        response.setContentType("application/vnd.ms-excel");
        response.setHeader("Content-Disposition", "attachment; filename=Submission_Report.xls");

        PrintWriter out = response.getWriter();

        try (Connection conn = SQLConnection.getConnection()) {

            /* -----------------------------
               Step 1: Get max practical no
            ----------------------------- */

            int maxPractical = 0;

            String practicalSql =
                    "SELECT MAX(practical_no) FROM practical_marks " +
                    "WHERE class_id=? AND subject_id=? AND activity_name=?";

            PreparedStatement psMax = conn.prepareStatement(practicalSql);
            psMax.setInt(1, classId);
            psMax.setInt(2, subjectId);
            psMax.setString(3, activity);

            ResultSet rsMax = psMax.executeQuery();

            if (rsMax.next()) {
                maxPractical = rsMax.getInt(1);
            }

            if (maxPractical == 0) {
                maxPractical = 5; // default if no marks entered yet
            }

            /* -----------------------------
               Step 2: Print Excel Header
            ----------------------------- */

            out.print("Roll No\tStudent Name\tSubmitted\t");

            for (int i = 1; i <= maxPractical; i++) {
                out.print("P" + i + "\t");
            }

            out.println("Total");

            /* -----------------------------
               Step 3: Get Students
            ----------------------------- */

            String studentSql =
                    "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, " +
                    "IFNULL(MAX(sub.submitted),0) as submitted " +
                    "FROM students s " +
                    "LEFT JOIN submissions sub ON s.student_id=sub.student_id " +
                    "AND sub.class_id=? AND sub.subject_id=? AND sub.activity_name=? " +
                    "WHERE s.class_id=? " +
                    "GROUP BY s.student_id " +
                    "ORDER BY s.roll_number";

            PreparedStatement psStudents = conn.prepareStatement(studentSql);

            psStudents.setInt(1, classId);
            psStudents.setInt(2, subjectId);
            psStudents.setString(3, activity);
            psStudents.setInt(4, classId);

            ResultSet students = psStudents.executeQuery();

            while (students.next()) {

                int studentId = students.getInt("student_id");

                out.print(students.getString("roll_number") + "\t");
                out.print(students.getString("first_name") + " " +
                          students.getString("last_name") + "\t");

                out.print((students.getInt("submitted") == 1 ? "Yes" : "No") + "\t");

                /* -----------------------------
                   Step 4: Get Practical Marks
                ----------------------------- */

                Map<Integer,Integer> marksMap = new HashMap<>();

                String markSql =
                        "SELECT practical_no, marks FROM practical_marks " +
                        "WHERE student_id=? AND class_id=? AND subject_id=? AND activity_name=?";

                PreparedStatement psMarks = conn.prepareStatement(markSql);

                psMarks.setInt(1, studentId);
                psMarks.setInt(2, classId);
                psMarks.setInt(3, subjectId);
                psMarks.setString(4, activity);

                ResultSet marks = psMarks.executeQuery();

                while (marks.next()) {
                    marksMap.put(
                            marks.getInt("practical_no"),
                            marks.getInt("marks")
                    );
                }

                int total = 0;

                for (int i = 1; i <= maxPractical; i++) {

                    Integer mark = marksMap.get(i);

                    if (mark == null) {
                        out.print("\t");
                    } else {
                        out.print(mark + "\t");
                        total += mark;
                    }
                }

                if (total == 0) {
                    out.println("");
                } else {
                    out.println(total);
                }
            }

            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}