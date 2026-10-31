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

@WebServlet("/getWhatsAppLinks")
public class GetWhatsAppLinksServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String classFilter = request.getParameter("class");

        try (Connection conn = SQLConnection.getConnection()) {

            StringBuilder sql = new StringBuilder();
            sql.append("SELECT c.class_id, c.class_name, c.section, w.whatsapp_link ")
                    .append("FROM class_whatsapp_group w ")
                    .append("JOIN classes c ON w.class_id = c.class_id ");

            // Add filter if specified
            if (classFilter != null && !classFilter.trim().isEmpty() && !classFilter.equals("all")) {
                sql.append("WHERE c.class_name = ? ");
            }

            sql.append("ORDER BY c.class_name, c.section");

            try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

                // Set parameter if filter is active
                if (classFilter != null && !classFilter.trim().isEmpty() && !classFilter.equals("all")) {
                    stmt.setString(1, classFilter);
                }

                ResultSet rs = stmt.executeQuery();

                if (!rs.next()) {
                    out.println("<tr>");
                    out.println("<td colspan='4' style='text-align: center;'>No WhatsApp links found.</td>");
                    out.println("</tr>");
                } else {
                    do {
                        int classId = rs.getInt("class_id");
                        String className = rs.getString("class_name");
                        String section = rs.getString("section");
                        String link = rs.getString("whatsapp_link");

                        String sectionDisplay = section != null ? section : "-";
                        String classDisplayName = className + ((section != null && !section.trim().isEmpty()) ? (" - " + section) : "");
                        String truncatedLink = link.length() > 50 ? link.substring(0, 50) + "..." : link;

                        out.println("<tr>");
                        out.println("  <td>" + escapeHtml(className) + "</td>");
                        out.println("  <td>" + escapeHtml(sectionDisplay) + "</td>");
                        out.println("  <td><a href='" + escapeHtml(link) + "' target='_blank' style='color: #0ea5e9;'>"
                                + escapeHtml(truncatedLink) + "</a></td>");
                        out.println("  <td>");
                        out.println("    <button type='button' class='action-btn edit' "
                                + "onclick=\"openEditLinkModal(" + classId + ", '"
                                + escapeJsAttr(className) + "', '"
                                + escapeJsAttr(section != null ? section : "") + "', '"
                                + escapeJsAttr(link) + "')\">");
                        out.println("      <i class='fas fa-edit'></i> Edit");
                        out.println("    </button>");
                        out.println("    <button type='button' class='action-btn delete' "
                                + "onclick=\"deleteWhatsAppLink(" + classId + ", '"
                                + escapeJsAttr(classDisplayName) + "')\">");
                        out.println("      <i class='fas fa-trash'></i> Delete");
                        out.println("    </button>");
                        out.println("  </td>");
                        out.println("</tr>");

                    } while (rs.next());
                }

                rs.close();
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<tr>");
            out.println("<td colspan='4' style='text-align: center; color: #dc2626;'>Error loading links: "
                    + escapeHtml(e.getMessage()) + "</td>");
            out.println("</tr>");
        }
    }

    private String escapeHtml(String value) {
        if (value == null)
            return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String escapeJs(String value) {
        if (value == null)
            return "";
        return value.replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private String escapeJsAttr(String value) {
        String jsEscaped = escapeJs(value);
        return jsEscaped.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
