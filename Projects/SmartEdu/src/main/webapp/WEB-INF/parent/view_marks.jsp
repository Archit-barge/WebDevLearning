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
    List<Map<String, Object>> marksList = new ArrayList<>();

    // Handle Subject Filter
    String searchSubject = request.getParameter("searchSubject");

    if (activeChildId != null) {
        try (Connection con = SQLConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("SELECT subject_name, ut1, ut2, average, created_at FROM marks WHERE student_id = ? ");
            if (searchSubject != null && !searchSubject.trim().isEmpty()) {
                sql.append(" AND subject_name = ? ");
            }
            sql.append(" ORDER BY created_at DESC");
            
            PreparedStatement ps = con.prepareStatement(sql.toString());
            ps.setInt(1, activeChildId);
            if (searchSubject != null && !searchSubject.trim().isEmpty()) {
                ps.setString(2, searchSubject);
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> mark = new HashMap<>();
                mark.put("subject", rs.getString("subject_name"));
                mark.put("ut1", rs.getInt("ut1"));
                mark.put("ut2", rs.getInt("ut2"));
                mark.put("average", rs.getFloat("average"));
                mark.put("date", rs.getTimestamp("created_at"));
                marksList.add(mark);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Fetch distinct subjects for the filter dropdown
    List<String> subjectsList = new ArrayList<>();
    if (activeChildId != null) {
        try (Connection con2 = SQLConnection.getConnection()) {
            PreparedStatement psSub = con2.prepareStatement("SELECT DISTINCT subject_name FROM marks WHERE student_id = ? ORDER BY subject_name");
            psSub.setInt(1, activeChildId);
            ResultSet rsSub = psSub.executeQuery();
            while(rsSub.next()) {
                subjectsList.add(rsSub.getString("subject_name"));
            }
        } catch(Exception e) {}
    }
%>

<div class="dashboard-content">
    
    <div class="top-bar mb-4">
        <div class="welcome-section">
            <h2 class="mb-1"><i class="fas fa-clipboard-list text-warning me-2"></i> Examination Marks</h2>
            <p class="mb-0 text-muted">Track your child's academic performance</p>
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
        
        <div class="bg-white p-3 rounded-3 shadow-sm border border-light mb-4">
            <form class="row gx-3 gy-2 align-items-center m-0" onsubmit="event.preventDefault(); let u = new URLSearchParams(new FormData(this)).toString(); loadPage('view_marks.jsp?' + u);">
                <div class="col-auto">
                    <label class="form-label fw-bold text-secondary mb-0">Filter By Subject:</label>
                </div>
                <div class="col-md-5">
                    <select name="searchSubject" class="form-select border-2 shadow-sm">
                        <option value="">-- View All Subjects --</option>
                        <% for (String sub : subjectsList) { %>
                            <option value="<%= sub %>" <%= (searchSubject != null && searchSubject.equals(sub)) ? "selected" : "" %>><%= sub %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-auto d-flex gap-2">
                    <button type="submit" class="btn btn-primary fw-bold shadow-sm"><i class="fas fa-filter me-1"></i> Apply Filter</button>
                    <% if(searchSubject != null && !searchSubject.isEmpty()) { %>
                        <button type="button" class="btn btn-light border shadow-sm" onclick="loadPage('view_marks.jsp')" title="Clear Filter"><i class="fas fa-times"></i> Clear</button>
                    <% } %>
                </div>
            </form>
        </div>
        
        <div class="table-responsive bg-white rounded shadow-sm border">
            <table class="table table-hover mb-0 align-middle text-center">
                <thead class="table-light">
                    <tr>
                        <th class="text-start ps-4">Subject</th>
                        <th>Unit Test 1 (UT1)</th>
                        <th>Unit Test 2 (UT2)</th>
                        <th class="text-primary">Average Score</th>
                        <th>Last Updated</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (marksList.isEmpty()) { %>
                        <tr>
                            <td colspan="5" class="py-4 text-muted">
                                <i class="fas fa-info-circle"></i> No marks records found for this student.
                            </td>
                        </tr>
                    <% } else { 
                        for (Map<String, Object> mark : marksList) {
                            float avg = (Float) mark.get("average");
                    %>
                        <tr>
                            <td class="text-start ps-4 fw-bold"><%= mark.get("subject") %></td>
                            <td><%= mark.get("ut1") %></td>
                            <td><%= mark.get("ut2") %></td>
                            <td>
                                <% if (avg < 40) { %>
                                    <span class="badge bg-danger fs-6"><%= String.format("%.2f", avg) %></span>
                                <% } else if (avg >= 75) { %>
                                    <span class="badge bg-success fs-6"><%= String.format("%.2f", avg) %></span>
                                <% } else { %>
                                    <span class="badge bg-primary fs-6"><%= String.format("%.2f", avg) %></span>
                                <% } %>
                            </td>
                            <td class="text-muted small"><%= mark.get("date").toString().substring(0, 10) %></td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>

    <% } %>
</div>
