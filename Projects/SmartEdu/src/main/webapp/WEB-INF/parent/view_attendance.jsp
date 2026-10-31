<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.seh.util.SQLConnection" %>

<%@ page import="com.seh.model.User" %>
<%
    if (session == null || !"parent".equals(session.getAttribute("role"))) {
        out.println("<script>window.location.href='../login.jsp';</script>");
        return;
    }

    User user = (User) session.getAttribute("user");
    if (user == null) {
        out.println("<script>window.location.href='../login.jsp';</script>");
        return;
    }
    
    int parentUserId = user.getUserId();
    
    String avatarLetter = "P";
    if (user.getFullName() != null && user.getFullName().length() > 0) {
    	avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }

    Integer activeChildId = (Integer) session.getAttribute("activeChildId");
    
    int total = 0, present = 0, absent = 0;
    List<Map<String, Object>> subjectAttendance = new ArrayList<>();

    if (activeChildId != null) {
        try (Connection con = SQLConnection.getConnection()) {
            
            PreparedStatement psOverall = con.prepareStatement(
                "SELECT status FROM full_attendance WHERE student_id = ?"
            );
            psOverall.setInt(1, activeChildId);
            ResultSet rsOverall = psOverall.executeQuery();
            while (rsOverall.next()) {
                total++;
                if ("present".equalsIgnoreCase(rsOverall.getString("status"))) {
                    present++;
                } else {
                    absent++;
                }
            }
            
            PreparedStatement psSubj = con.prepareStatement(
                "SELECT s.subject_name, " +
                "COUNT(*) as total_classes, " +
                "SUM(CASE WHEN fa.status='present' THEN 1 ELSE 0 END) as total_present, " +
                "SUM(CASE WHEN fa.status='absent' THEN 1 ELSE 0 END) as total_absent " +
                "FROM full_attendance fa " +
                "JOIN subjects s ON fa.subject_id = s.subject_id " +
                "WHERE fa.student_id = ? " +
                "GROUP BY fa.subject_id, s.subject_name " +
                "ORDER BY s.subject_name ASC"
            );
            psSubj.setInt(1, activeChildId);
            ResultSet rsSubj = psSubj.executeQuery();
            while (rsSubj.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("subject_name", rsSubj.getString("subject_name"));
                row.put("total_classes", rsSubj.getInt("total_classes"));
                row.put("total_present", rsSubj.getInt("total_present"));
                row.put("total_absent", rsSubj.getInt("total_absent"));
                subjectAttendance.add(row);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    double perc = (total > 0) ? (present * 100.0 / total) : 0;
%>

<div class="dashboard-content">
    
    <div class="top-bar mb-4">
        <div class="welcome-section">
            <h2 class="mb-1"><i class="fas fa-calendar-check text-primary me-2"></i> Attendance Report</h2>
            <p class="mb-0 text-muted">View your child's attendance records</p>
        </div>
        <div class="user-info">
            <div class="user-avatar bg-teal"><%=avatarLetter%></div>
            <div>
                <div class="user-name"><%=user.getFullName()%></div>
                <div class="user-role-label"><%=user.getRole()%></div>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </div>

    <% if (activeChildId == null) { %>
        <div class="alert alert-warning">
            <i class="fas fa-exclamation-triangle"></i> No child selected. Please select a child from the Dashboard.
        </div>
    <% } else { %>
    
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="dashboard-card text-center border-top-primary">
                    <i class="fas fa-chalkboard-teacher fa-2x text-primary mb-2"></i>
                    <h3><%= total %></h3>
                    <p class="mb-0 text-muted">Total Classes</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="dashboard-card text-center border-top-success">
                    <i class="fas fa-user-check fa-2x text-success mb-2"></i>
                    <h3><%= present %></h3>
                    <p class="mb-0 text-muted">Present</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="dashboard-card text-center border-top-danger">
                    <i class="fas fa-user-times fa-2x text-danger mb-2"></i>
                    <h3><%= absent %></h3>
                    <p class="mb-0 text-muted">Absent</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="dashboard-card text-center border-top-purple">
                    <i class="fas fa-percentage fa-2x text-info mb-2"></i>
                    <h3><%= String.format("%.1f%%", perc) %></h3>
                    <p class="mb-0 text-muted">Overall %</p>
                </div>
            </div>
        </div>

        <hr class="my-4">

        <h5 class="mb-3 text-secondary"><i class="fas fa-book"></i> Subject-wise Breakdown</h5>
        
        <div class="table-responsive bg-white rounded shadow-sm border">
            <table class="table table-hover mb-0 align-middle text-center">
                <thead class="table-light">
                    <tr>
                        <th class="text-start ps-4">Subject</th>
                        <th>Total Classes</th>
                        <th class="text-success">Present</th>
                        <th class="text-danger">Absent</th>
                        <th class="text-primary">Percentage</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (subjectAttendance.isEmpty()) { %>
                        <tr>
                            <td colspan="5" class="py-4 text-muted">
                                <i class="fas fa-info-circle"></i> No attendance records found for this student.
                            </td>
                        </tr>
                    <% } else { 
                        for (Map<String, Object> row : subjectAttendance) {
                            int tCls = (Integer) row.get("total_classes");
                            int pCls = (Integer) row.get("total_present");
                            int aCls = (Integer) row.get("total_absent");
                            double pPerc = (tCls > 0) ? (pCls * 100.0 / tCls) : 0;
                    %>
                        <tr>
                            <td class="text-start ps-4 fw-bold"><%= row.get("subject_name") %></td>
                            <td><%= tCls %></td>
                            <td class="text-success fw-bold"><%= pCls %></td>
                            <td class="text-danger fw-bold"><%= aCls %></td>
                            <td>
                                <% if (pPerc < 75) { %>
                                    <span class="badge bg-danger"><%= String.format("%.1f%%", pPerc) %></span>
                                <% } else { %>
                                    <span class="badge bg-success"><%= String.format("%.1f%%", pPerc) %></span>
                                <% } %>
                            </td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>

    <% } %>
</div>
