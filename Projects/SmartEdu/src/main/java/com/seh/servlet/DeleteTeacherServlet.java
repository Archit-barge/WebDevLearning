package com.seh.servlet;

import java.io.IOException; 
import java.io.PrintWriter;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.seh.util.SQLConnection;

@WebServlet("/deleteTeacher")
public class DeleteTeacherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String teacherIdStr = request.getParameter("teacherId");
        if (teacherIdStr == null || teacherIdStr.trim().isEmpty()) {
            out.print("Invalid teacher ID.");
            return;
        }

        int teacherId = Integer.parseInt(teacherIdStr);

        Connection conn = null;
        PreparedStatement psGetUser = null;
        PreparedStatement psClearClasses = null;
        PreparedStatement psDeleteTeacher = null;
        PreparedStatement psDeleteUser = null;
        ResultSet rs = null;

        try {
            conn = SQLConnection.getConnection();
            conn.setAutoCommit(false);

            
            psGetUser = conn.prepareStatement(
                    "SELECT user_id FROM teachers WHERE teacher_id = ?");
            psGetUser.setInt(1, teacherId);
            rs = psGetUser.executeQuery();

            int userId = -1;
            if (rs.next()) {
                userId = rs.getInt("user_id");
            } else {
                out.print("Teacher not found.");
                conn.rollback();
                return;
            }
            rs.close();
            psGetUser.close();

            
            psClearClasses = conn.prepareStatement(
                    "UPDATE classes SET teacher_id = NULL WHERE teacher_id = ?");
            psClearClasses.setInt(1, teacherId);
            psClearClasses.executeUpdate();

           
            psDeleteTeacher = conn.prepareStatement(
                    "DELETE FROM teachers WHERE teacher_id = ?");
            psDeleteTeacher.setInt(1, teacherId);
            psDeleteTeacher.executeUpdate();

            
            psDeleteUser = conn.prepareStatement(
                    "DELETE FROM users WHERE user_id = ?");
            psDeleteUser.setInt(1, userId);
            psDeleteUser.executeUpdate();

            conn.commit();
            out.print("OK");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            out.print("Error deleting teacher.");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (psGetUser != null) psGetUser.close(); } catch (SQLException ignored) {}
            try { if (psClearClasses != null) psClearClasses.close(); } catch (SQLException ignored) {}
            try { if (psDeleteTeacher != null) psDeleteTeacher.close(); } catch (SQLException ignored) {}
            try { if (psDeleteUser != null) psDeleteUser.close(); } catch (SQLException ignored) {}
            SQLConnection.closeResources(conn);
        }
    }
}
