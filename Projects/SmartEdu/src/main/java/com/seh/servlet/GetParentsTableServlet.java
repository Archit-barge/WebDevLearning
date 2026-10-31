package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/getParentsTable")
public class GetParentsTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String search = request.getParameter("search");
        if (search == null)
            search = "";
        
        String sql = "SELECT p.parent_id, u.user_id, u.username, p.first_name, p.last_name, " +
                "u.email, p.phone, p.address, p.relationship_to_student, u.password " +
                "FROM parents p JOIN users u ON p.user_id = u.user_id " +
                "WHERE (p.first_name LIKE ? OR p.last_name LIKE ? " +
                "OR u.email LIKE ? OR p.phone LIKE ? OR u.username LIKE ?) " +
                "ORDER BY LOWER(p.first_name), LOWER(p.last_name), LOWER(u.username)";

        try (Connection conn = SQLConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            String like = "%" + search + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);
            ps.setString(5, like);

            ResultSet rs = ps.executeQuery();
            boolean hasData = false;

            while (rs.next()) {
                hasData = true;

                int parentId = rs.getInt("parent_id");
                String username = rs.getString("username");
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                String fullName = firstName + " " + lastName;
                String avatarLetter = (firstName != null && !firstName.isEmpty())
                        ? firstName.substring(0, 1).toUpperCase()
                        : "P";
                String email = rs.getString("email") != null ? rs.getString("email") : "-";
                String phone = rs.getString("phone") != null ? rs.getString("phone") : "-";
                String address = rs.getString("address") != null ? rs.getString("address") : "-";
                String relationship = rs.getString("relationship_to_student") != null
                        ? rs.getString("relationship_to_student")
                        : "-";
                String password = rs.getString("password") != null ? rs.getString("password") : "";

                String linkedStudents = getLinkedStudents(conn, parentId);

                out.println("<tr>");
                
                out.println("  <td>");
                out.println("    <div class=\"admin-info\">");
                out.println("      <div class=\"admin-avatar\">" + escapeHtml(avatarLetter) + "</div>");
                out.println("      <div class=\"admin-details\">");
                out.println("        <h6>" + escapeHtml(fullName) + "</h6>");
                out.println("      </div>");
                out.println("    </div>");
                out.println("  </td>");

                out.println("  <td>" + escapeHtml(email) + "</td>");
                out.println("  <td>" + escapeHtml(phone) + "</td>");
                out.println("  <td>" + capitalize(escapeHtml(relationship)) + "</td>");
                out.println("  <td>" + (linkedStudents.isEmpty() ? "<span class='table-cell-muted'>None</span>"
                        : escapeHtml(linkedStudents)) + "</td>");

                out.println("  <td>");
                
                out.println("    <button type=\"button\" class=\"action-btn edit\" " +
                        "onclick=\"openEditParentModal(" +
                        parentId + ", '" + escapeJsAttr(firstName) + "', '" + escapeJsAttr(lastName) + "', '" +
                        escapeJsAttr(phone) + "', '" + escapeJsAttr(email) + "', '" +
                        escapeJsAttr(address) + "', '" +
                        escapeJsAttr(relationship) + "', '" + 
                        escapeJsAttr(username) + "', '" + 
                        escapeJsAttr(password) + "')\">" +
                        "<i class=\"fas fa-edit\"></i> Edit</button>");

                
                out.println("    <button type=\"button\" class=\"action-btn view\" " +
                        "onclick=\"openViewParentModal(" +
                        parentId + ", '" + escapeJsAttr(fullName) + "', '" + escapeJsAttr(username) + "', '" +
                        escapeJsAttr(email) + "', '" + escapeJsAttr(phone) + "', '" + escapeJsAttr(address) + "', '', '" +
                        escapeJsAttr(relationship) + "', '" + escapeJsAttr(password) + "')\">" +
                        "<i class=\"fas fa-eye\"></i> View</button>");

                
                out.println("    <button type=\"button\" class=\"action-btn view\" " +
                        "onclick=\"openLinkParentModal(" + parentId + ", '" + escapeJsAttr(fullName) + "')\">" +
                        "<i class=\"fas fa-link\"></i> Link</button>");

                
                out.println("    <button type=\"button\" class=\"action-btn delete\" " +
                        "onclick=\"openDeleteParentModal(" + parentId + ", '" + escapeJsAttr(fullName) + "')\">" +
                        "<i class=\"fas fa-trash\"></i> Delete</button>");

                out.println("  </td>");
                out.println("</tr>");
            }

            if (!hasData) {
                out.println("<tr><td colspan='6' class='no-data'>No parents found.</td></tr>");
            }

            rs.close();

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<tr><td colspan='7' class='table-cell-error'>Error: " + escapeHtml(e.getMessage())
                    + "</td></tr>");
        }
    }

    private String getLinkedStudents(Connection conn, int parentId) throws SQLException {
        String sql = "SELECT s.first_name, s.last_name, s.roll_number " +
                "FROM student_parents sp JOIN students s ON sp.student_id = s.student_id " +
                "WHERE sp.parent_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, parentId);
        ResultSet rs = ps.executeQuery();

        String result = "";
        int count = 0;
        while (rs.next()) {
            count++;
            if (count == 1) {
                result = rs.getString("first_name") + " " + rs.getString("last_name") + " (" + rs.getString("roll_number") + ")";
            }
        }
        if (count > 1) {
            result += " ...";
        }
        rs.close();
        ps.close();
        return result;
    }

    private String escapeHtml(String s) {
        if (s == null)
            return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    private String escapeJs(String s) {
        if (s == null)
            return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"");
    }

    private String escapeJsAttr(String value) {
        String jsEscaped = escapeJs(value);
        return jsEscaped.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private String capitalize(String s) {
        if (s == null || s.isEmpty() || s.equals("-"))
            return s;
        return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }
}
