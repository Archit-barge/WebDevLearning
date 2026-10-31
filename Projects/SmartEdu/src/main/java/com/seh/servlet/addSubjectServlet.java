package com.seh.servlet;

import java.io.IOException; 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;
import com.seh.util.SQLConnection;

@WebServlet("/addSubject")
public class addSubjectServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String subjectName = request.getParameter("subjectName");
        String subjectCode = request.getParameter("subjectCode");
        String description = request.getParameter("description");
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        
        if (subjectName == null || subjectName.trim().isEmpty()) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Subject name is required</div>");
            return;
        }
        
        if (subjectCode == null || subjectCode.trim().isEmpty()) {
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Subject code is required</div>");
            return;
        }
        
        subjectName = subjectName.trim();
        subjectCode = subjectCode.trim();
        description = description != null ? description.trim() : "";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = SQLConnection.getConnection();
            
         
            String checkSql = "SELECT COUNT(*) FROM subjects WHERE subject_code = ?";
            stmt = conn.prepareStatement(checkSql);
            stmt.setString(1, subjectCode);
            rs = stmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Subject code already exists</div>");
                SQLConnection.closeResources(conn, rs, stmt);
                return;
            }
            
            SQLConnection.closeResources(conn, rs, stmt);
            
           
            conn = SQLConnection.getConnection();
            String insertSql = "INSERT INTO subjects (subject_name, subject_code, description) VALUES (?, ?, ?)";
            stmt = conn.prepareStatement(insertSql);
            stmt.setString(1, subjectName);
            stmt.setString(2, subjectCode);
            stmt.setString(3, description);
            
            int result = stmt.executeUpdate();
            
            if (result > 0) {
            	response.getWriter().write("<div class='alert alert-success'><i class='fas fa-check-circle'></i> Subject added successfully!</div>");

                response.getWriter().write("<script>setTimeout(function() { location.reload(); }, 1500);</script>");
            } else {
            	response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Subject code already exists</div>");

            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: " + e.getMessage() + "</div>");
        } finally {
            SQLConnection.closeResources(conn, rs, stmt);
        }
    }
}
