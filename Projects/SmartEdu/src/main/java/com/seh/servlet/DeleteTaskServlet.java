package com.seh.servlet;

import com.seh.util.SQLConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/deleteTask")
public class DeleteTaskServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");

        try (Connection conn = SQLConnection.getConnection()) {

            String taskIdStr = request.getParameter("id");

            if(taskIdStr == null || taskIdStr.isEmpty()){
                response.sendError(400,"Task ID missing");
                return;
            }

            int taskId = Integer.parseInt(taskIdStr);

            String sql = "DELETE FROM teacher_tasks WHERE task_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, taskId);

            int rows = ps.executeUpdate();

            if(rows > 0){
                response.getWriter().print("Task deleted successfully");
            }else{
                response.sendError(404,"Task not found");
            }

        } catch (Exception e) {

            e.printStackTrace();
            response.sendError(500,"Server error");

        }
    }
}