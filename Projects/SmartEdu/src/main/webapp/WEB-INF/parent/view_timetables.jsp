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
    Integer activeClassId = (Integer) session.getAttribute("activeClassId");
    List<Map<String, Object>> docsList = new ArrayList<>();

    if (activeClassId != null) {
        try (Connection con = SQLConnection.getConnection()) {
            String sql = "SELECT document_id, title, description, document_type, upload_date, file_path " +
                         "FROM documents " +
                         "WHERE class_id = ? AND upper(document_type) IN ('TIMETABLES', 'EXAM_TIMETABLE') " +
                         "ORDER BY upload_date DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, activeClassId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> doc = new HashMap<>();
                doc.put("id", rs.getInt("document_id"));
                doc.put("title", rs.getString("title"));
                doc.put("description", rs.getString("description"));
                doc.put("type", rs.getString("document_type"));
                doc.put("date", rs.getTimestamp("upload_date"));
                
                String path = rs.getString("file_path");
                boolean isImage = path.toLowerCase().endsWith(".png") || 
                                  path.toLowerCase().endsWith(".jpg") || 
                                  path.toLowerCase().endsWith(".jpeg") || 
                                  path.toLowerCase().endsWith(".gif");
                boolean isPdf = path.toLowerCase().endsWith(".pdf");
                doc.put("isImage", isImage);
                doc.put("isPdf", isPdf);
                
                docsList.add(doc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<div class="dashboard-content">
    
    <div class="top-bar mb-4">
        <div class="welcome-section">
            <h2 class="mb-1"><i class="fas fa-calendar-alt text-warning me-2"></i> Class Timetables</h2>
            <p class="mb-0 text-muted">View upcoming schedules and exam timetables</p>
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
        
        <div class="row g-4">
            <% if (docsList.isEmpty()) { %>
                <div class="col-12 py-4 text-center text-muted border rounded bg-light">
                    <i class="fas fa-calendar-times fa-3x mb-3 text-secondary opacity-50"></i>
                    <p>No timetables found for this class.</p>
                </div>
            <% } else { 
                for (Map<String, Object> doc : docsList) {
                    int docId = (Integer) doc.get("id");
                    String title = (String) doc.get("title");
                    String desc = (String) doc.get("description");
                    String date = doc.get("date").toString().substring(0, 10);
                    boolean isImg = (Boolean) doc.get("isImage");
                    boolean isPdf = (Boolean) doc.get("isPdf");
                    
                    String previewUrl = "../downloadDocument?id=" + docId + "&inline=true";
                    String downloadUrl = "../downloadDocument?id=" + docId;
            %>
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 tt-card">
                        <div class="card-header bg-transparent border-bottom-0 pt-4 pb-0 d-flex justify-content-between align-items-center">
                            <span class="badge bg-warning text-dark px-3 py-2 rounded-pill"><i class="fas fa-clock me-1"></i> Timetable</span>
                            <small class="text-muted fw-medium"><i class="fas fa-calendar-alt text-secondary"></i> <%= date %></small>
                        </div>
                        <div class="card-body">
                            <h5 class="card-title fw-bold text-dark mb-1 fs-5 lh-sm letter-spacing-tight"><%= title %></h5>
                            <p class="card-text text-secondary small lh-base mt-2"><%= desc != null ? desc : "No description provided." %></p>
                            
                            <div class="text-center mt-3 mb-3 rounded-3 img-preview-container img-preview-dashed-warning">
                                <% if (isImg || isPdf) { %>
                                    <img src="<%= previewUrl %>" alt="Preview" class="img-preview-thumb">
                                <% } else { %>
                                    <div class="text-muted flex-column d-flex align-items-center justify-content-center">
                                        <i class="fas fa-file-word fa-4x mb-2 text-warning opacity-75"></i>
                                        <span class="small fw-bold text-dark mt-2">Word/Other Document</span>
                                        <p class="mb-0 mt-1 fs-75">Requires Download</p>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        <div class="card-footer bg-transparent border-top-0 pb-4 pt-0 px-4 d-flex gap-2">
                            <a href="<%= previewUrl %>" target="_blank" class="btn btn-open-tt flex-fill py-2 rounded-3">
                                <i class="fas fa-external-link-alt"></i> Open
                            </a>
                            <a href="<%= downloadUrl %>" class="btn btn-download-tt flex-fill py-2 rounded-3">
                                <i class="fas fa-download"></i> Download
                            </a>
                        </div>
                    </div>
                </div>
            <%  }
               } %>
        </div>

    <% } %>
</div>
