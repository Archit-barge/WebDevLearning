package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.sql.*;

import com.seh.util.SQLConnection;

@WebServlet("/teacher/DownloadMarksServlet")
public class DownloadMarksServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String classIdStr = request.getParameter("classId");
        String subjectIdStr = request.getParameter("subjectId");
        String examType = request.getParameter("examType");

        if (examType == null) {
            examType = "ut";
        }

        if (classIdStr == null || subjectIdStr == null ||
            classIdStr.isEmpty() || subjectIdStr.isEmpty()) {

            response.getWriter().println("Class and Subject must be selected!");
            return;
        }

        int classId = Integer.parseInt(classIdStr);
        int subjectId = Integer.parseInt(subjectIdStr);

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader(
                "Content-Disposition",
                "attachment; filename=Marks_Class" + classId +
                "_Subject" + subjectId + "_" + examType + ".csv"
        );

        try (
                OutputStream os = response.getOutputStream();
                OutputStreamWriter osw = new OutputStreamWriter(os, "UTF-8");
                PrintWriter out = new PrintWriter(osw);
                Connection conn = SQLConnection.getConnection()
        ) {

            // Excel UTF-8 support
            out.write('\uFEFF');

            String className = "";
            String subjectName = "";

            /* =========================
               GET CLASS NAME
            ========================== */

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT class_name, section FROM classes WHERE class_id=?")) {

                ps.setInt(1, classId);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    className = rs.getString("class_name") +
                            " - " + rs.getString("section");
                }
            }

            /* =========================
               GET SUBJECT NAME
            ========================== */

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT subject_name FROM subjects WHERE subject_id=?")) {

                ps.setInt(1, subjectId);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    subjectName = rs.getString("subject_name");
                }
            }

            /* =========================
               PRINT HEADER
            ========================== */

            out.println("Class : " + className);
            out.println("Subject : " + subjectName);
            out.println("Exam Type : " + examType.toUpperCase());
            out.println();

            if (examType.equals("ut")) {
                out.println("Roll,First Name,Last Name,UT1,UT2,Average");
            } else {
                out.println("Roll,First Name,Last Name,SEM1,SEM2,Average");
            }

            /* =========================
               SQL QUERY
            ========================== */

            String sql;

            if (examType.equals("ut")) {

                sql =
                        "SELECT s.roll_number, s.first_name, s.last_name, " +
                        "m.ut1, m.ut2, m.average " +
                        "FROM students s " +
                        "LEFT JOIN marks m ON s.student_id = m.student_id AND m.subject_id=? " +
                        "WHERE s.class_id=? ORDER BY s.roll_number ASC";

            } else {

                sql =
                        "SELECT s.roll_number, s.first_name, s.last_name, " +
                        "m.sem1, m.sem2, m.sem_average " +
                        "FROM students s " +
                        "LEFT JOIN marks m ON s.student_id = m.student_id AND m.subject_id=? " +
                        "WHERE s.class_id=? ORDER BY s.roll_number ASC";
            }

            /* =========================
               FETCH DATA
            ========================== */

            try (PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, subjectId);
                ps.setInt(2, classId);

                ResultSet rs = ps.executeQuery();

                while (rs.next()) {

                    String roll = rs.getString("roll_number");

                    String first = rs.getString("first_name");
                    first = first != null
                            ? "\"" + first.replace("\"", "\"\"") + "\""
                            : "\"\"";

                    String last = rs.getString("last_name");
                    last = last != null
                            ? "\"" + last.replace("\"", "\"\"") + "\""
                            : "\"\"";

                    String mark1 = "";
                    String mark2 = "";
                    String avg = "";

                    if (examType.equals("ut")) {

                        mark1 = rs.getObject("ut1") != null
                                ? String.valueOf(rs.getInt("ut1"))
                                : "";

                        mark2 = rs.getObject("ut2") != null
                                ? String.valueOf(rs.getInt("ut2"))
                                : "";

                        avg = rs.getObject("average") != null
                                ? String.valueOf(rs.getFloat("average"))
                                : "";

                    } else {

                        mark1 = rs.getObject("sem1") != null
                                ? String.valueOf(rs.getInt("sem1"))
                                : "";

                        mark2 = rs.getObject("sem2") != null
                                ? String.valueOf(rs.getInt("sem2"))
                                : "";

                        avg = rs.getObject("sem_average") != null
                                ? String.valueOf(rs.getFloat("sem_average"))
                                : "";
                    }

                    out.println(String.join(",", roll, first, last, mark1, mark2, avg));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}