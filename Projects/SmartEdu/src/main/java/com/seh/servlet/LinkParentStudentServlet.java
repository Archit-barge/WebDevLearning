package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/linkParentStudent")
public class LinkParentStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action"); 
        String parentIdStr = request.getParameter("parentId");
        String studentIdStr = request.getParameter("studentId");
        int studentId = 0;
        
        
        if (parentIdStr == null || action == null) {
            out.println("<p style='color:#dc2626;'>Missing required parameters</p>");
            return;
        }

        if ((action.equals("link") || action.equals("unlink")) && studentIdStr == null) {
             out.println("<p style='color:#dc2626;'>Missing student ID</p>");
             return;
        }

        try (Connection conn = SQLConnection.getConnection()) {

            int parentId = Integer.parseInt(parentIdStr);

            if (action.equals("list")) {
                String allowUnlinkStr = request.getParameter("allowUnlink");
                boolean allowUnlink = "true".equals(allowUnlinkStr);

                String sql = "SELECT s.student_id, s.first_name, s.last_name, s.roll_number, c.class_name, c.section " +
                        "FROM student_parents sp " +
                        "JOIN students s ON sp.student_id = s.student_id " +
                        "LEFT JOIN classes c ON s.class_id = c.class_id " +
                        "WHERE sp.parent_id = ? ORDER BY s.first_name";

                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, parentId);
                ResultSet rs = stmt.executeQuery();

                out.println("<div style='display: flex; flex-direction: column; gap: 0.5rem;'>");
                boolean hasData = false;

                while (rs.next()) {
                    hasData = true;
                    int sid = rs.getInt("student_id");
                    String name = rs.getString("first_name") + " " + rs.getString("last_name");
                    String roll = rs.getString("roll_number");
                    String cls = rs.getString("class_name");
                    String sec = rs.getString("section");
                    String classDisplay = cls != null ? cls + (sec != null ? " - " + sec : "") : "";

                    out.println(
                            "<div style='display: flex; justify-content: space-between; align-items: center; padding: 0.5rem; background: #f8fafc; border-radius: 0.375rem; border: 1px solid #e2e8f0;'>");
                    out.println("  <div>");
                    out.println("    <div style='font-weight: 500; color: #1e293b;'>" + escapeHtml(name) + "</div>");
                    out.println("    <div style='font-size: 0.875rem; color: #64748b;'>Roll: " + escapeHtml(roll)
                            + (classDisplay.isEmpty() ? "" : " • " + escapeHtml(classDisplay)) + "</div>");
                    out.println("  </div>");

                    if (allowUnlink) {
                        out.println("  <button type='button' onclick=\"unlinkStudent(" + parentId + ", " + sid + ")\" "
                                +
                                "style='color: #ef4444; background: none; border: none; cursor: pointer; font-size: 0.875rem; font-weight: 500;'>Unlink</button>");
                    }
                    out.println("</div>");
                }

                if (!hasData) {
                    out.println("<p style='color: #94a3b8; font-style: italic;'>No students linked yet.</p>");
                }
                out.println("</div>");

                rs.close();
                stmt.close();

            } else if (action.equals("link")) {
                studentId = Integer.parseInt(studentIdStr);
                String sql = "INSERT IGNORE INTO student_parents(student_id, parent_id) VALUES (?, ?)";

                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, studentId);
                stmt.setInt(2, parentId);
                stmt.executeUpdate();
                stmt.close();
                out.println("<p style='color:#166534;'>Student linked successfully!</p>");

            } else if (action.equals("unlink")) {
                studentId = Integer.parseInt(studentIdStr);
                String sql = "DELETE FROM student_parents WHERE student_id=? AND parent_id=?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, studentId);
                stmt.setInt(2, parentId);
                stmt.executeUpdate();
                stmt.close();
                out.println("<p style='color:#166534;'>Student unlinked successfully!</p>");

            } else {
                out.println("<p style='color:#dc2626;'>Invalid action</p>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:#dc2626;'>Error: " + e.getMessage() + "</p>");
        }
    }

    private String escapeHtml(String s) {
        if (s == null)
            return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
