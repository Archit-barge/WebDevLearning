package com.seh.servlet;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/getAdminTable")
public class GetAdminTableServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String search = request.getParameter("search");
        if (search == null) search = "";

        Integer currentUserId = null;
        Object userObj = request.getSession().getAttribute("user");
        if (userObj instanceof User) {
            currentUserId = ((User) userObj).getUserId();
        }

        String sql =
            "SELECT a.admin_id, u.user_id, u.username, a.first_name, a.last_name, " +
            "u.email, a.phone, a.address, u.password " +
            "FROM admins a JOIN users u ON a.user_id = u.user_id " +
            "WHERE (a.first_name LIKE ? OR a.last_name LIKE ? " +
            "       OR u.username LIKE ? OR u.email LIKE ?) " +
            "ORDER BY LOWER(a.first_name), LOWER(a.last_name), LOWER(u.username)";

        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             PrintWriter out = response.getWriter()) {

            String like = "%" + search + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);

            try (ResultSet rs = ps.executeQuery()) {

                boolean hasData = false;

                while (rs.next()) {
                    hasData = true;

                    int adminId    = rs.getInt("admin_id");
                    int userId     = rs.getInt("user_id");
                    String username   = rs.getString("username");
                    String firstName  = rs.getString("first_name");
                    String lastName   = rs.getString("last_name");
                    String fullName   = firstName + " " + lastName;
                    String avatarLetter = (firstName != null && !firstName.isEmpty())
                            ? firstName.substring(0, 1).toUpperCase()
                            : "A";
                    String email      = rs.getString("email");
                    String phone      = rs.getString("phone")    != null ? rs.getString("phone")    : "-";
                    String address    = rs.getString("address")  != null ? rs.getString("address")  : "-";
                    String password   = rs.getString("password") != null ? rs.getString("password") : "";

                    boolean isCurrent = (currentUserId != null && currentUserId == userId);

                    out.println("<tr>");
                    out.println("  <td>" + escapeHtml(username) + "</td>");

                    out.println("  <td>");
                    out.println("    <div class='admin-info'>");
                    out.println("      <div class='admin-avatar'>" + escapeHtml(avatarLetter) + "</div>");
                    out.println("      <div class='admin-details'>");
                    out.print ("        <h6>" + escapeHtml(fullName));
                    if (isCurrent) {
                        out.print(" <span class='self-badge-inline'>You</span>");
                    }
                    out.println("</h6>");
                    out.print ("        <p class='self-text'>");
                    if (isCurrent) {
                        out.print("Currently logged in");
                    }
                    out.println("</p>");
                    out.println("      </div>");
                    out.println("    </div>");
                    out.println("  </td>");

                    out.println("  <td>" + escapeHtml(email == null ? "" : email) + "</td>");
                    out.println("  <td>" + escapeHtml(phone) + "</td>");

                    out.println("  <td>");
                    out.println("    <div class='admin-actions-row'>");
                    out.println("    <button type='button' class='action-btn edit' " +
                                "onclick=\"openEditAdminModal(" +
                                adminId + ",'" + escapeJsAttr(fullName) + "','" + escapeJsAttr(username) + "','" +
                                escapeJsAttr(email == null ? "" : email) + "','" +
                                escapeJsAttr(phone == null ? "" : phone) + "','" +
                                escapeJsAttr(password) + "','" + escapeJsAttr(address) + "')\">");
                    out.println("      <i class='fas fa-edit'></i> Edit");
                    out.println("    </button>");

                    out.println("    <button type='button' class='action-btn view' " +
                                "onclick=\"openViewAdminModal('" +
                                escapeJsAttr(fullName) + "','" + escapeJsAttr(username) + "','" +
                                escapeJsAttr(email == null ? "" : email) + "','" +
                                escapeJsAttr(phone == null ? "" : phone) + "','" +
                                escapeJsAttr(password) + "','" + escapeJsAttr(address) + "')\">");
                    out.println("      <i class='fas fa-eye'></i> View");
                    out.println("    </button>");

                    if (!isCurrent) {
                        out.println("    <button type='button' class='action-btn delete' " +
                                    "onclick=\"openDeleteAdminModal(" +
                                    adminId + ",'" + escapeJsAttr(fullName) + "')\">");
                        out.println("      <i class='fas fa-trash'></i> Delete");
                        out.println("    </button>");
                    }
                    out.println("    </div>");
                    out.println("  </td>");

                    out.println("</tr>");
                }

                if (!hasData) {
                    out.println("<tr>");
                    out.println("<td colspan='5' class='no-data'>No admins found.</td>");
                    out.println("</tr>");
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Error loading admin table", e);
        }
    }

    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private String escapeJs(String value) {
        if (value == null) {
            return "";
        }
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
