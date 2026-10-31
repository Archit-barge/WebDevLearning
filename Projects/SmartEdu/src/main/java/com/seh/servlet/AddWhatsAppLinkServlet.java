package com.seh.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.seh.util.SQLConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/addWhatsAppLink")
public class AddWhatsAppLinkServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String classIdStr = request.getParameter("classId");
        String whatsappLink = request.getParameter("whatsappLink");

        // Validation
        if (classIdStr == null || classIdStr.trim().isEmpty()) {
            out.println("<p style='color: #dc2626;'>❌ Please select a class.</p>");
            return;
        }

        if (whatsappLink == null || whatsappLink.trim().isEmpty()) {
            out.println("<p style='color: #dc2626;'>❌ Please enter a WhatsApp link.</p>");
            return;
        }

        // Basic WhatsApp link validation
        if (!whatsappLink.contains("whatsapp.com") && !whatsappLink.contains("wa.me")) {
            out.println("<p style='color: #dc2626;'>❌ Please enter a valid WhatsApp link.</p>");
            return;
        }

        try {
            int classId = Integer.parseInt(classIdStr);

            try (Connection conn = SQLConnection.getConnection()) {

                // Check if link already exists for this class
                String checkSql = "SELECT class_id FROM class_whatsapp_group WHERE class_id = ?";
                try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                    checkStmt.setInt(1, classId);
                    ResultSet rs = checkStmt.executeQuery();

                    if (rs.next()) {
                        out.println(
                                "<p style='color: #dc2626;'>❌ A WhatsApp link already exists for this class. Please use Edit to update it.</p>");
                        return;
                    }
                }

                // Insert new link
                String insertSql = "INSERT INTO class_whatsapp_group (class_id, whatsapp_link) VALUES (?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                    stmt.setInt(1, classId);
                    stmt.setString(2, whatsappLink);

                    int rows = stmt.executeUpdate();
                    if (rows > 0) {
                        out.println("<p style='color: #16a34a;'>✅ WhatsApp link added successfully!</p>");
                    } else {
                        out.println("<p style='color: #dc2626;'>❌ Failed to add WhatsApp link.</p>");
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
