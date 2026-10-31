package com.seh.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;
import com.seh.util.SQLConnection;

@WebServlet("/updateStudent")
public class UpdateStudentServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String studentIdStr = request.getParameter("studentId");
		String firstName = request.getParameter("firstName");
		String lastName = request.getParameter("lastName");
		String rollNumber = request.getParameter("rollNumber");
		String username = request.getParameter("username");
		String email = request.getParameter("email");
		String dateOfBirth = request.getParameter("dateOfBirth");
		String gender = request.getParameter("gender");
		String phone = request.getParameter("phone");
		String classIdStr = request.getParameter("classId");
		String address = request.getParameter("address");
		String admissionDate = request.getParameter("admissionDate");
		String password = request.getParameter("password");

		response.setContentType("text/html;charset=UTF-8");

		if (studentIdStr == null || firstName == null || firstName.trim().isEmpty() || username == null
				|| username.trim().isEmpty() || email == null || email.trim().isEmpty() || rollNumber == null
				|| rollNumber.trim().isEmpty() || password == null || password.trim().isEmpty()) {

			response.getWriter().write(
					"<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Required fields are missing</div>");
			return;
		}

		try {
			int studentId = Integer.parseInt(studentIdStr);
			firstName = firstName.trim();
			lastName = (lastName != null) ? lastName.trim() : "";
			rollNumber = (rollNumber != null) ? rollNumber.trim() : "";
			username = (username != null) ? username.trim() : "";
			email = (email != null) ? email.trim() : "";
			password = password.trim();
			dateOfBirth = (dateOfBirth != null && !dateOfBirth.isEmpty()) ? dateOfBirth : null;
			gender = (gender != null && !gender.isEmpty()) ? gender : null;
			phone = (phone != null && !phone.isEmpty()) ? phone : null;
			address = (address != null && !address.isEmpty()) ? address : null;
			admissionDate = (admissionDate != null && !admissionDate.isEmpty()) ? admissionDate : null;

			Integer classId = null;
			if (classIdStr != null && !classIdStr.isEmpty()) {
				try {
					classId = Integer.parseInt(classIdStr);
				} catch (NumberFormatException e) {
					classId = null;
				}
			}

			Connection conn = null;
			PreparedStatement stmt = null;

			try {
				conn = SQLConnection.getConnection();

				String updateStudentSql = "UPDATE students SET roll_number = ?, first_name = ?, last_name = ?, "
						+ "date_of_birth = ?, gender = ?, phone = ?, class_id = ?, address = ?, admission_date = ? "
						+ "WHERE student_id = ?";

				stmt = conn.prepareStatement(updateStudentSql);
				stmt.setString(1, rollNumber);
				stmt.setString(2, firstName);
				stmt.setString(3, lastName);
				stmt.setString(4, dateOfBirth);
				stmt.setString(5, gender);
				stmt.setString(6, phone);

				if (classId != null) {
					stmt.setInt(7, classId);
				} else {
					stmt.setNull(7, java.sql.Types.INTEGER);
				}

				stmt.setString(8, address);
				stmt.setString(9, admissionDate);
				stmt.setInt(10, studentId);

				int result = stmt.executeUpdate();
				stmt.close();

				if (result > 0) {
					String updateUserSql =
						    "UPDATE users SET username = ?, email = ?, password = ? WHERE user_id = " +
						    "(SELECT user_id FROM students WHERE student_id = ?)";

						stmt = conn.prepareStatement(updateUserSql);
						stmt.setString(1, username);
						stmt.setString(2, email);
						stmt.setString(3, password);    	
						stmt.setInt(4, studentId);
						stmt.executeUpdate();
						stmt.close();

					response.getWriter().write(
							"<div class='alert alert-success'><i class='fas fa-check-circle'></i> Student updated successfully!</div>");
				} else {
					response.getWriter().write(
							"<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Error updating student.</div>");
				}

			} catch (SQLException e) {
				e.printStackTrace();
				response.getWriter().write(
						"<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Database error: "
								+ e.getMessage() + "</div>");
			} finally {
				SQLConnection.closeResources(conn, stmt);
			}

		} catch (NumberFormatException e) {
			response.getWriter().write(
					"<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Invalid input format</div>");
		}
	}
}
