package com.seh.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.seh.util.SQLConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/deleteWhatsAppLink")
public class DeleteWhatsAppLinkServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String classIdStr = request.getParameter("classId");

        // Validation
        if (classIdStr == null || classIdStr.trim().isEmpty()) {
            out.println("<p style='color: #dc2626;'>❌ Class ID is required.</p>");
            return;
        }

        try {
            int classId = Integer.parseInt(classIdStr);

            try (Connection conn = SQLConnection.getConnection()) {

                String deleteSql = "DELETE FROM class_whatsapp_group WHERE class_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(deleteSql)) {
                    stmt.setInt(1, classId);

                    int rows = stmt.executeUpdate();
                    if (rows > 0) {
                        out.println("<p style='color: #16a34a;'>✅ WhatsApp link deleted successfully!</p>");
                    } else {
                        out.println(
                                "<p style='color: #dc2626;'>❌ Failed to delete WhatsApp link. Link may not exist.</p>");
                    }
                }
            }

        } catch (NumberFormatException e) {
            out.println("<p style='color: #dc2626;'>❌ Invalid class ID.</p>");
            e.printStackTrace();
        } catch (Exception e) {
            out.println("<p style='color: #dc2626;'>❌ Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
}
