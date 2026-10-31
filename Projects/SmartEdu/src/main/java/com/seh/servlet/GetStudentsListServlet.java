package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.sql.*;

import com.seh.util.SQLConnection;

@WebServlet("/getStudentsList")
public class GetStudentsListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String search = request.getParameter("search");
        String classId = request.getParameter("classId");

        StringBuilder sql = new StringBuilder(
            "SELECT s.student_id, s.roll_number, s.first_name, s.last_name, " +
            "c.class_name, c.section " +
            "FROM students s LEFT JOIN classes c ON s.class_id = c.class_id WHERE 1=1 "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (s.first_name LIKE ? OR s.last_name LIKE ? OR s.roll_number LIKE ?) ");
        }
        if (classId != null && !classId.trim().isEmpty()) {
            sql.append("AND s.class_id = ? ");
        }
        sql.append("ORDER BY s.roll_number ASC LIMIT 100");

        Connection conn = null;
        try {
            conn = SQLConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql.toString());

            int idx = 1;
            if (search != null && !search.trim().isEmpty()) {
                String like = "%" + search.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (classId != null && !classId.trim().isEmpty()) {
                ps.setInt(idx++, Integer.parseInt(classId));
            }

            ResultSet rs = ps.executeQuery();
            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                String roll = rs.getString("roll_number");
                String fname = rs.getString("first_name");
                String lname = rs.getString("last_name");
                String cName = rs.getString("class_name");
                String sec = rs.getString("section");
                String classDisplay = cName != null ? cName + (sec != null ? " - " + sec : "") : "Unassigned";

                json.append("{")
                    .append("\"student_id\":").append(rs.getInt("student_id")).append(",")
                    .append("\"roll_number\":\"").append(esc(roll)).append("\",")
                    .append("\"name\":\"").append(esc(fname)).append(" ").append(esc(lname)).append("\",")
                    .append("\"class_display\":\"").append(esc(classDisplay)).append("\"")
                    .append("}");
            }
            json.append("]");
            rs.close();
            ps.close();

            // Also get classes list for the filter dropdown
            StringBuilder classesJson = new StringBuilder("[");
            PreparedStatement clsPs = conn.prepareStatement(
                "SELECT class_id, class_name, section FROM classes ORDER BY class_name, section ASC"
            );
            ResultSet clsRs = clsPs.executeQuery();
            boolean firstCls = true;
            while (clsRs.next()) {
                if (!firstCls) classesJson.append(",");
                firstCls = false;
                String cn = clsRs.getString("class_name");
                String s = clsRs.getString("section");
                String display = cn + (s != null ? " - " + s : "");
                classesJson.append("{\"id\":").append(clsRs.getInt("class_id"))
                    .append(",\"name\":\"").append(esc(display)).append("\"}");
            }
            classesJson.append("]");
            clsRs.close();
            clsPs.close();

            // Also get subjects list
            StringBuilder subjectsJson = new StringBuilder("[");
            PreparedStatement subPs = conn.prepareStatement(
                "SELECT subject_id, subject_name FROM subjects ORDER BY subject_name ASC"
            );
            ResultSet subRs = subPs.executeQuery();
            boolean firstSub = true;
            while (subRs.next()) {
                if (!firstSub) subjectsJson.append(",");
                firstSub = false;
                subjectsJson.append("{\"id\":").append(subRs.getInt("subject_id"))
                    .append(",\"name\":\"").append(esc(subRs.getString("subject_name"))).append("\"}");
            }
            subjectsJson.append("]");
            subRs.close();
            subPs.close();

            out.print("{\"students\":" + json + ",\"classes\":" + classesJson + ",\"subjects\":" + subjectsJson + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"students\":[],\"classes\":[],\"subjects\":[]}");
        } finally {
            SQLConnection.closeResources(conn);
        }
        out.flush();
    }

    private String esc(String val) {
        if (val == null) return "";
        return val.replace("\\", "\\\\").replace("\"", "\\\"")
                  .replace("\n", "\\n").replace("\r", "\\r");
    }
}
