<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>

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
    
    List<Map<String, Object>> announcements = new ArrayList<>();
    String whatsappLink = null;

    if (activeClassId != null) {
        try (Connection con = SQLConnection.getConnection()) {
            
            PreparedStatement psWa = con.prepareStatement("SELECT whatsapp_link FROM class_whatsapp_group WHERE class_id = ?");
            psWa.setInt(1, activeClassId);
            ResultSet rsWa = psWa.executeQuery();
            if (rsWa.next()) {
                whatsappLink = rsWa.getString("whatsapp_link");
            }
            
            String annSql = "SELECT title, description, created_at, class_id FROM announcements WHERE class_id = ? OR class_id IS NULL ORDER BY created_at DESC";
            PreparedStatement psAnn = con.prepareStatement(annSql);
            psAnn.setInt(1, activeClassId);
            ResultSet rsAnn = psAnn.executeQuery();
            
            while (rsAnn.next()) {
                Map<String, Object> ann = new HashMap<>();
                ann.put("title", rsAnn.getString("title"));
                ann.put("description", rsAnn.getString("description"));
                ann.put("date", rsAnn.getTimestamp("created_at"));
                
                Integer cId = (Integer) rsAnn.getObject("class_id");
                ann.put("isGlobal", cId == null);
                
                announcements.add(ann);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<div class="dashboard-content">
    
    <div class="top-bar mb-4">
        <div class="welcome-section">
            <h2 class="mb-1"><i class="fas fa-bullhorn text-danger me-2"></i> Announcements & Communications</h2>
            <p class="mb-0 text-muted">Stay updated with messages from the school</p>
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
    
        <div class="card shadow-sm border-0 mb-4 gradient-green">
            <div class="card-body d-flex justify-content-between align-items-center p-4">
                <div>
                    <h4 class="fw-bold mb-1"><i class="fab fa-whatsapp fa-lg me-2"></i> Class WhatsApp Group</h4>
                    <p class="mb-0 opacity-75">Join to stay updated with your child's teachers and other parents.</p>
                </div>
                <div>
                    <% if (whatsappLink != null && !whatsappLink.isEmpty()) { %>
                        <a href="<%= whatsappLink %>" target="_blank" class="btn btn-light btn-lg text-success fw-bold px-4 rounded-pill shadow-sm">
                            <i class="fas fa-link"></i> Join Group
                        </a>
                    <% } else { %>
                        <button class="btn btn-light btn-lg text-secondary fw-bold px-4 rounded-pill opacity-50 pe-none">
                            Not Configured
                        </button>
                    <% } %>
                </div>
            </div>
        </div>

        <hr class="my-4 hr-dashed">

        <div class="d-flex align-items-center mb-4">
            <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3 icon-circle-lg gradient-blue">
                <i class="fas fa-bell fa-lg"></i>
            </div>
            <h4 class="mb-0 fw-bold text-dark">Notice Board</h4>
        </div>



        <div class="row g-4 pb-5">
            <% if (announcements.isEmpty()) { %>
                <div class="col-12 py-5 text-center text-muted border rounded-4 bg-light shadow-sm">
                    <i class="fas fa-envelope-open-text fa-4x mb-3 text-secondary opacity-25"></i>
                    <h5 class="fw-bold">No Announcements Yet</h5>
                    <p class="mb-0">There are no notices or updates posted for this class currently.</p>
                </div>
            <% } else { 
                for (Map<String, Object> ann : announcements) {
                    Timestamp ts = (Timestamp) ann.get("date");
                    LocalDateTime postTime = ts.toLocalDateTime();
                    LocalDateTime now = LocalDateTime.now();
                    
                    long minutes = ChronoUnit.MINUTES.between(postTime, now);
                    long hours = ChronoUnit.HOURS.between(postTime, now);
                    long days = ChronoUnit.DAYS.between(postTime, now);
                    
                    String timeAgo;
                    if(minutes < 60) timeAgo = minutes + " mins ago";
                    else if(hours < 24) timeAgo = hours + " hrs ago";
                    else if(days == 1) timeAgo = "Yesterday";
                    else timeAgo = days + " days ago";
                    
                    boolean isGlobal = (Boolean) ann.get("isGlobal");
                    String borderClass = isGlobal ? "ann-global" : "ann-class";
                    String iconBgClass = isGlobal ? "ann-icon-global" : "ann-icon-class";
                    String badgeClass = isGlobal ? "bg-primary" : "bg-info";
                    String badgeIcon = isGlobal ? "fa-globe" : "fa-users";
                    String badgeText = isGlobal ? "School" : "Class";
            %>
                <div class="col-md-6 col-lg-6">
                    <div class="card h-100 border-0 announcement-card <%= borderClass %> p-1">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="<%= iconBgClass %> rounded-circle d-flex align-items-center justify-content-center icon-circle-md">
                                        <i class="fas <%= badgeIcon %> fa-lg"></i>
                                    </div>
                                    <h5 class="fw-bold text-dark mb-0 fs-5 letter-spacing-tight"><%= ann.get("title") %></h5>
                                </div>
                                <span class="badge <%= badgeClass %> px-3 py-2 rounded-pill shadow-sm"><i class="fas <%= badgeIcon %>"></i> <%= badgeText %></span>
                            </div>
                            
                            <p class="text-secondary mt-3 mb-4 lh-lg fs-7"><%= ann.get("description") %></p>
                            
                            <div class="d-flex align-items-center text-muted small mt-auto border-top pt-3">
                                <i class="far fa-clock me-2"></i>
                                <span class="fw-medium">Posted <%= timeAgo %></span>
                            </div>
                        </div>
                    </div>
                </div>
            <%  }
               } %>
        </div>

    <% } %>
</div>
