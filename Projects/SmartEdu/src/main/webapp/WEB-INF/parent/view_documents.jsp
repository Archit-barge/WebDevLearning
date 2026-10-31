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

    // Handle filter parameters
    String searchTitle = request.getParameter("searchTitle");
    String paramSubject = request.getParameter("subjectId");
    String paramType = request.getParameter("docType");

    if (activeClassId != null) {
        try (Connection con = SQLConnection.getConnection()) {
            StringBuilder sql = new StringBuilder(
                "SELECT d.document_id, d.title, d.description, d.document_type, d.upload_date, d.file_path, s.subject_name " +
                "FROM documents d LEFT JOIN subjects s ON d.subject_id = s.subject_id " +
                "WHERE d.class_id = ? AND upper(d.document_type) IN ('NOTES', 'SYLLABUS') ");

            if (searchTitle != null && !searchTitle.trim().isEmpty()) {
                sql.append(" AND d.title LIKE ? ");
            }
            if (paramSubject != null && !paramSubject.trim().isEmpty()) {
                sql.append(" AND d.subject_id = ? ");
            }
            if (paramType != null && !paramType.trim().isEmpty()) {
                sql.append(" AND upper(d.document_type) = ? ");
            }
            sql.append(" ORDER BY d.upload_date DESC");

            PreparedStatement ps = con.prepareStatement(sql.toString());
            int paramIndex = 1;
            ps.setInt(paramIndex++, activeClassId);
            
            if (searchTitle != null && !searchTitle.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + searchTitle + "%");
            }
            if (paramSubject != null && !paramSubject.trim().isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(paramSubject));
            }
            if (paramType != null && !paramType.trim().isEmpty()) {
                ps.setString(paramIndex++, paramType.toUpperCase());
            }

            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> doc = new HashMap<>();
                doc.put("id", rs.getInt("document_id"));
                doc.put("title", rs.getString("title"));
                doc.put("description", rs.getString("description"));
                doc.put("type", rs.getString("document_type"));
                doc.put("subject", rs.getString("subject_name") != null ? rs.getString("subject_name") : "General");
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
    
    // Fetch subjects for the filter dropdown
    List<Map<String, Object>> subjectsList = new ArrayList<>();
    try (Connection con2 = SQLConnection.getConnection()) {
        ResultSet rs2 = con2.createStatement().executeQuery("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name");
        while(rs2.next()) {
            Map<String, Object> sub = new HashMap<>();
            sub.put("id", rs2.getInt("subject_id"));
            sub.put("name", rs2.getString("subject_name"));
            subjectsList.add(sub);
        }
    } catch(Exception e) {}
%>

<div class="dashboard-content">
    
    <div class="top-bar mb-4">
        <div class="welcome-section">
            <h2 class="mb-1"><i class="fas fa-book-open text-info me-2"></i> Syllabus & Notes</h2>
            <p class="mb-0 text-muted">View study materials for your child's class</p>
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
            <form id="filterForm" class="row g-2 align-items-center m-0" onsubmit="event.preventDefault(); let u = new URLSearchParams(new FormData(this)).toString(); loadPage('view_documents.jsp?' + u);">
                <div class="col-md-3">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-2 text-muted"><i class="fas fa-search"></i></span>
                        <input type="text" name="searchTitle" class="form-control border-2" placeholder="Search File Name..." value="<%= searchTitle != null ? searchTitle : "" %>">
                    </div>
                </div>
                <div class="col-md-3">
                    <select name="subjectId" class="form-select border-2">
                        <option value="">-- All Subjects --</option>
                        <% for(Map<String, Object> sub : subjectsList) { %>
                            <option value="<%= sub.get("id") %>" <%= (paramSubject != null && paramSubject.equals(sub.get("id").toString())) ? "selected" : "" %>><%= sub.get("name") %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-3">
                    <select name="docType" class="form-select border-2">
                        <option value="">-- All Types --</option>
                        <option value="NOTES" <%= "NOTES".equalsIgnoreCase(paramType) ? "selected" : "" %>>Notes</option>
                        <option value="SYLLABUS" <%= "SYLLABUS".equalsIgnoreCase(paramType) ? "selected" : "" %>>Syllabus</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-primary fw-bold flex-fill"><i class="fas fa-filter me-1"></i> Apply Filter</button>
                    <% if(searchTitle != null || paramSubject != null || paramType != null) { %>
                        <button type="button" class="btn btn-light border" onclick="loadPage('view_documents.jsp')" title="Clear Filters"><i class="fas fa-times"></i></button>
                    <% } %>
                </div>
            </form>
        </div>

        <div class="row g-4 pb-5">
            <% if (docsList.isEmpty()) { %>
                <div class="col-12 py-4 text-center text-muted border rounded bg-light">
                    <i class="fas fa-box-open fa-3x mb-3 text-secondary opacity-50"></i>
                    <p>No study materials or syllabus found for this class.</p>
                </div>
            <% } else { 
                for (Map<String, Object> doc : docsList) {
                    int docId = (Integer) doc.get("id");
                    String title = (String) doc.get("title");
                    String desc = (String) doc.get("description");
                    String type = (String) doc.get("type");
                    String subject = (String) doc.get("subject");
                    String date = doc.get("date").toString().substring(0, 10);
                    boolean isImg = (Boolean) doc.get("isImage");
                    boolean isPdf = (Boolean) doc.get("isPdf");
                    
                    String previewUrl = "../downloadDocument?id=" + docId + "&inline=true";
                    String downloadUrl = "../downloadDocument?id=" + docId;
            %>
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 doc-card">
                        <div class="card-header bg-transparent border-bottom-0 pt-4 pb-0 d-flex justify-content-between align-items-center">
                            <span class="badge <%= "NOTES".equalsIgnoreCase(type) ? "bg-info text-dark" : "bg-primary" %> px-3 py-2 rounded-pill"><i class="fas <%= "NOTES".equalsIgnoreCase(type) ? "fa-sticky-note" : "fa-book" %> me-1"></i> <%= type %></span>
                            <small class="text-muted fw-medium"><i class="fas fa-calendar-alt text-secondary"></i> <%= date %></small>
                        </div>
                        <div class="card-body">
                            <h5 class="card-title fw-bold text-dark mb-1 fs-5 lh-sm letter-spacing-tight"><%= title %></h5>
                            <span class="badge bg-light text-secondary border mb-3"><i class="fas fa-book-reader"></i> <%= subject %></span>
                            <p class="card-text text-secondary small lh-base"><%= desc != null ? desc : "No description provided." %></p>
                            
                            <div class="text-center mt-3 mb-3 rounded-3 img-preview-container img-preview-dashed-primary">
                                <% if (isImg) { %>
                                    <img src="<%= previewUrl %>" alt="Preview" class="img-preview-thumb">
                                <% } else if (isPdf) { %>
                                    <div class="text-danger flex-column d-flex align-items-center justify-content-center">
                                        <i class="fas fa-file-pdf fa-4x mb-2 opacity-75 drop-shadow"></i>
                                        <span class="small fw-bold">PDF Document</span>
                                    </div>
                                <% } else { %>
                                    <div class="text-muted flex-column d-flex align-items-center justify-content-center">
                                        <i class="fas fa-file-word fa-4x mb-2 text-primary opacity-50"></i>
                                        <span class="small fw-bold text-dark mt-2">Word/Other Document</span>
                                        <p class="mb-0 mt-1 fs-75">Requires Download</p>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        <div class="card-footer bg-transparent border-top-0 pb-4 pt-0 px-4 d-flex gap-2">
                            <a href="<%= previewUrl %>" target="_blank" class="btn btn-open-doc flex-fill py-2 rounded-3">
                                <i class="fas fa-external-link-alt"></i> Open
                            </a>
                            <a href="<%= downloadUrl %>" class="btn btn-download-doc flex-fill py-2 rounded-3">
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
