package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/updateParent")
public class UpdateParentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String parentIdStr = request.getParameter("parentId");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String occupation = request.getParameter("occupation");
        String relationship = request.getParameter("relationship");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (parentIdStr == null || firstName == null || lastName == null || username == null || password == null) {
            out.println("<p style='color:#dc2626;'>Missing required fields</p>");
            return;
        }

        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction

            try {
                // 1. Update parents table
                String sqlParent = "UPDATE parents SET first_name=?, last_name=?, phone=?, email=?, address=?, relationship_to_student=? WHERE parent_id=?";
                PreparedStatement stmtParent = conn.prepareStatement(sqlParent);
                stmtParent.setString(1, firstName);
                stmtParent.setString(2, lastName);
                stmtParent.setString(3, phone);
                stmtParent.setString(4, email);
                stmtParent.setString(5, address);
                if (relationship != null && !relationship.trim().isEmpty()) {
                    stmtParent.setString(6, relationship);
                } else {
                    stmtParent.setNull(6, Types.VARCHAR);
                }
                stmtParent.setInt(7, Integer.parseInt(parentIdStr));

                int rowsParent = stmtParent.executeUpdate();
                stmtParent.close();

                // 2. Update users table (username, password)
                String sqlUser = "UPDATE users SET username=?, password=? WHERE user_id = (SELECT user_id FROM parents WHERE parent_id=?)";
                PreparedStatement stmtUser = conn.prepareStatement(sqlUser);
                stmtUser.setString(1, username);
                stmtUser.setString(2, password);
                stmtUser.setInt(3, Integer.parseInt(parentIdStr));
                
                int rowsUser = stmtUser.executeUpdate();
                stmtUser.close();

                if (rowsParent > 0 && rowsUser > 0) {
                    conn.commit();
                    out.println("<p style='color:#166534;'>Parent updated successfully!</p>");
                } else {
                    conn.rollback();
                    out.println("<p style='color:#dc2626;'>Parent not found or update failed</p>");
                }
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:#dc2626;'>Error: " + e.getMessage() + "</p>");
        }
    }
}
