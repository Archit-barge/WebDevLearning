package com.seh.servlet;

import com.seh.model.User;
import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/exportTeacherTasks")
public class TeacherTasksExcelServlet extends HttpServlet {

protected void doGet(HttpServletRequest request,HttpServletResponse response)
throws ServletException,IOException{

if(!isAdmin(request)){
handleUnauthorized(request,response);
return;
}

TeacherTasksQueryHelper.Filters filters = TeacherTasksQueryHelper.fromRequest(request);

response.setContentType("application/vnd.ms-excel");
response.setHeader("Content-Disposition","attachment; filename=teacher_tasks.xls");

PrintWriter out=response.getWriter();

out.println("<table border='1'>");
out.println("<tr>");
out.println("<th>Date</th>");
out.println("<th>Teacher</th>");
out.println("<th>Class</th>");
out.println("<th>Subject</th>");
out.println("<th>Topic</th>");
out.println("<th>Duration</th>");
out.println("<th>Description</th>");
out.println("</tr>");

String sql="SELECT t.*,u.username,c.class_name,c.section,s.subject_name "
+"FROM teacher_tasks t "
+"JOIN users u ON t.teacher_id=u.user_id "
+"JOIN classes c ON t.class_id=c.class_id "
+"JOIN subjects s ON t.subject_id=s.subject_id";

sql = TeacherTasksQueryHelper.buildSql(sql, filters);

try(Connection conn=SQLConnection.getConnection();
PreparedStatement ps=conn.prepareStatement(sql)){

TeacherTasksQueryHelper.bindFilters(ps, filters);

ResultSet rs=ps.executeQuery();

while(rs.next()){

out.println("<tr>");

out.println("<td>"+rs.getString("task_date")+"</td>");
out.println("<td>"+rs.getString("username")+"</td>");
out.println("<td>"+rs.getString("class_name")+"-"+rs.getString("section")+"</td>");
out.println("<td>"+rs.getString("subject_name")+"</td>");
out.println("<td>"+rs.getString("topic")+"</td>");
out.println("<td>"+rs.getInt("duration")+" min</td>");
out.println("<td>"+rs.getString("description")+"</td>");

out.println("</tr>");

}

}catch(Exception e){
e.printStackTrace();
}

out.println("</table>");

}

private boolean isAdmin(HttpServletRequest request) {
	HttpSession session = request.getSession(false);
	if (session == null) return false;
	Object role = session.getAttribute("role");
	Object user = session.getAttribute("user");
	return "admin".equals(role) && user instanceof User;
}

private boolean isAjax(HttpServletRequest request) {
	String requestedWith = request.getHeader("X-Requested-With");
	return "XMLHttpRequest".equalsIgnoreCase(requestedWith);
}

private void handleUnauthorized(HttpServletRequest request, HttpServletResponse response) throws IOException {
	if (isAjax(request)) {
		response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
		response.setContentType("application/json;charset=UTF-8");
		response.getWriter().write("{\"error\":\"Unauthorized\"}");
		return;
	}
	response.sendRedirect(request.getContextPath() + "/login.jsp");
}
}
