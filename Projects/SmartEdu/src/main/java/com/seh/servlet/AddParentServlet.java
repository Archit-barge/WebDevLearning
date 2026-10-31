package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;

import com.seh.util.SQLConnection;

@WebServlet("/addParent")
public class AddParentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String relationship = request.getParameter("relationship");
        String[] studentIds = request.getParameterValues("studentIds");

        Connection conn = null;

        try {
            conn = SQLConnection.getConnection();

            if (conn == null) {
                request.getSession().setAttribute("error", "Unable to connect with Database");
                response.sendRedirect("admin/Index.jsp?page=add_parent.jsp");
                return;
            }

            // Check if username or email already exists
            PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM users WHERE username=? OR email=?");
            checkStmt.setString(1, username);
            checkStmt.setString(2, email);
            ResultSet checkRs = checkStmt.executeQuery();
            if (checkRs.next() && checkRs.getInt(1) > 0) {
                checkRs.close();
                checkStmt.close();
                request.getSession().setAttribute("error", "Username or email already exists");
                response.sendRedirect("admin/Index.jsp?page=add_parent.jsp");
                return;
            }
            checkRs.close();
            checkStmt.close();
			String userSql = "INSERT INTO users(username, password, email, role) VALUES (?, ?, ?, 'parent')";
			PreparedStatement userStmt = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS);
			userStmt.setString(1, username);
			userStmt.setString(2, password);
			userStmt.setString(3, email);

			int affectedRows = userStmt.executeUpdate();
			if (affectedRows == 0) {
				conn.rollback();
				request.getSession().setAttribute("error", "Failed to create user account");
				response.sendRedirect("admin/Index.jsp?page=add_parent.jsp");
				return;
			}

			int userId = 0;
			try (ResultSet generatedKeys = userStmt.getGeneratedKeys()) {
				if (generatedKeys.next()) {
					userId = generatedKeys.getInt(1);
				} else {
					conn.rollback();
					request.getSession().setAttribute("error", "Failed to obtain user ID");
					response.sendRedirect("admin/Index.jsp?page=add_parent.jsp");
					return;
				}
			}
			userStmt.close();

			String parentSql = "INSERT INTO parents(user_id, first_name, last_name, phone, email, address, relationship_to_student) VALUES (?, ?, ?, ?, ?, ?, ?)";
			PreparedStatement parentStmt = conn.prepareStatement(parentSql, Statement.RETURN_GENERATED_KEYS);
			parentStmt.setInt(1, userId);
			parentStmt.setString(2, firstName);
			parentStmt.setString(3, lastName);
			parentStmt.setString(4, phone);
			parentStmt.setString(5, email);
			parentStmt.setString(6, address);
			parentStmt.setString(7, relationship);

			int parentRows = parentStmt.executeUpdate();
			if (parentRows == 0) {
				conn.rollback();
				request.getSession().setAttribute("error", "Failed to create parent record");
				response.sendRedirect("admin/Index.jsp?page=add_parent.jsp");
				return;
			}

			int parentId = 0;
			try (ResultSet pKeys = parentStmt.getGeneratedKeys()) {
				if (pKeys.next()) {
					parentId = pKeys.getInt(1);
				}
			}
			parentStmt.close();

			if (studentIds != null && studentIds.length > 0) {
				String linkSql = "INSERT INTO student_parents(student_id, parent_id) VALUES (?, ?)";
				PreparedStatement linkStmt = conn.prepareStatement(linkSql);
				for (String sId : studentIds) {
					if (sId != null && !sId.trim().isEmpty()) {
						linkStmt.setInt(1, Integer.parseInt(sId));
						linkStmt.setInt(2, parentId);
						linkStmt.addBatch();
					}
				}
				linkStmt.executeBatch();
				linkStmt.close();
			}

			conn.commit();
			request.getSession().setAttribute("success", "Parent added successfully");
			response.sendRedirect("admin/Index.jsp?page=add_parent.jsp");

		} catch (Exception e) {
			e.printStackTrace();
			try {
				if (conn != null)
					conn.rollback();
			} catch (SQLException ex) {
				ex.printStackTrace();
			}
			request.getSession().setAttribute("error", "Database error: " + e.getMessage());
			response.sendRedirect("admin/Index.jsp?page=add_parent.jsp");
        } finally {
            SQLConnection.closeResources(conn);
        }
    }
}
