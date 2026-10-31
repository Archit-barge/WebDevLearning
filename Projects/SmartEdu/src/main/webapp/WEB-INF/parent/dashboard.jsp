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

    Integer parentId = null;
    List<Map<String, Object>> children = new ArrayList<>();
    Integer activeChildId = (Integer) session.getAttribute("activeChildId");
    Integer activeClassId = (Integer) session.getAttribute("activeClassId");

    String selectChildParam = request.getParameter("selectChild");
    if (selectChildParam != null && !selectChildParam.isEmpty()) {
        try {
            activeChildId = Integer.parseInt(selectChildParam);
            session.setAttribute("activeChildId", activeChildId);
        } catch (NumberFormatException e) {
        }
    }

    try (Connection con = SQLConnection.getConnection()) {
        PreparedStatement psParent = con.prepareStatement("SELECT parent_id FROM parents WHERE user_id = ?");
        psParent.setInt(1, parentUserId);
        ResultSet rsParent = psParent.executeQuery();
        if (rsParent.next()) {
            parentId = rsParent.getInt("parent_id");
        }

        if (parentId != null) {
            String childSql = "SELECT s.student_id, s.first_name, s.last_name, s.class_id, " +
                              "c.class_name, c.section " +
                              "FROM student_parents sp " +
                              "JOIN students s ON sp.student_id = s.student_id " +
                              "LEFT JOIN classes c ON s.class_id = c.class_id " +
                              "WHERE sp.parent_id = ?";
            PreparedStatement psChild = con.prepareStatement(childSql);
            psChild.setInt(1, parentId);
            ResultSet rsChild = psChild.executeQuery();

            while (rsChild.next()) {
                Map<String, Object> child = new HashMap<>();
                int cId = rsChild.getInt("student_id");
                child.put("id", cId);
                child.put("name", rsChild.getString("first_name") + " " + rsChild.getString("last_name"));
                child.put("class_id", rsChild.getInt("class_id"));
                
                String className = rsChild.getString("class_name");
                String section = rsChild.getString("section");
                child.put("class_name", (className != null ? className : "N/A") + 
                                       (section != null ? (" - " + section) : ""));
                children.add(child);

                if (activeChildId == null) {
                    activeChildId = cId;
                    session.setAttribute("activeChildId", activeChildId);
                }
                
                if (activeChildId != null && activeChildId == cId) {
                    activeClassId = rsChild.getInt("class_id");
                    session.setAttribute("activeClassId", activeClassId);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    List<Map<String, Object>> recentAttendance = new ArrayList<>();
    List<Map<String, Object>> recentDocs = new ArrayList<>();
    List<Map<String, Object>> recentAnnouncements = new ArrayList<>();

    if (activeChildId != null) {
        try (Connection con = SQLConnection.getConnection()) {
            String attSql = "SELECT s.subject_name, fa.attendance_date, fa.status " +
                            "FROM full_attendance fa " +
                            "JOIN subjects s ON fa.subject_id = s.subject_id " +
                            "WHERE fa.student_id = ? " +
                            "ORDER BY fa.attendance_date DESC, fa.created_at DESC LIMIT 5";
            PreparedStatement psAtt = con.prepareStatement(attSql);
            psAtt.setInt(1, activeChildId);
            ResultSet rsAtt = psAtt.executeQuery();
            while (rsAtt.next()) {
                Map<String, Object> att = new HashMap<>();
                att.put("subject", rsAtt.getString("subject_name"));
                att.put("date", rsAtt.getDate("attendance_date"));
                att.put("status", rsAtt.getString("status"));
                recentAttendance.add(att);
            }

            if (activeClassId != null) {
                String docSql = "SELECT title, document_type, upload_date FROM documents " +
                                "WHERE class_id = ? AND upper(document_type) IN ('NOTES', 'SYLLABUS', 'TIMETABLES', 'EXAM_TIMETABLE') " +
                                "ORDER BY upload_date DESC LIMIT 5";
                PreparedStatement psDoc = con.prepareStatement(docSql);
                psDoc.setInt(1, activeClassId);
                ResultSet rsDoc = psDoc.executeQuery();
                while (rsDoc.next()) {
                    Map<String, Object> doc = new HashMap<>();
                    doc.put("title", rsDoc.getString("title"));
                    doc.put("type", rsDoc.getString("document_type"));
                    doc.put("date", rsDoc.getTimestamp("upload_date"));
                    recentDocs.add(doc);
                }
            }

            if (activeClassId != null) {
                String annSql = "SELECT title, created_at, class_id FROM announcements " +
                                "WHERE class_id = ? OR class_id IS NULL " +
                                "ORDER BY created_at DESC LIMIT 3";
                PreparedStatement psAnn = con.prepareStatement(annSql);
                psAnn.setInt(1, activeClassId);
                ResultSet rsAnn = psAnn.executeQuery();
                while (rsAnn.next()) {
                    Map<String, Object> ann = new HashMap<>();
                    ann.put("title", rsAnn.getString("title"));
                    ann.put("date", rsAnn.getTimestamp("created_at"));
                    ann.put("isGlobal", rsAnn.getObject("class_id") == null);
                    recentAnnouncements.add(ann);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<div class="dashboard-content">

    <div class="top-bar">
        <div class="welcome-section">
            <h2>Welcome, <%=user.getFullName()%></h2>
            <p>Here's your child's latest updates</p>
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
    
    <% if (children.isEmpty()) { %>
        <div class="alert alert-warning m-4 shadow-sm border-0">
            <h4 class="alert-heading"><i class="fas fa-exclamation-circle"></i> No Children Linked</h4>
            <p>Your account is not currently linked to any students. Please contact the school administrator to have your child's profile linked to your account.</p>
        </div>
    <% } else { %>
        
        <form id="childSelectorForm" class="d-flex align-items-center justify-content-end gap-2 px-4 mb-4">
            <label for="childSelect" class="fw-bold text-secondary mb-0"><i class="fas fa-child"></i> Viewing:</label>
            <select id="childSelect" name="selectChild" class="form-select w-auto shadow-sm fw-bold text-teal border-teal border-2 child-select-dropdown" onchange="loadPage('dashboard.jsp?selectChild=' + this.value)">
                <% for (Map<String, Object> child : children) { 
                    int cId = (Integer) child.get("id");
                    boolean isSelected = (activeChildId != null && activeChildId == cId);
                %>
                    <option value="<%= cId %>" <%= isSelected ? "selected" : "" %>>
                        <%= child.get("name") %> (<%= child.get("class_name") %>)
                    </option>
                <% } %>
            </select>
        </form>

        <div class="row g-4 px-1">
            
            <div class="col-lg-7">
                
                <div class="card shadow-sm border-0 mb-4 rounded-4 overflow-hidden">
                    <div class="card-header bg-white border-0 pt-4 pb-2 px-4 d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold text-dark mb-0"><i class="fas fa-clipboard-check text-success me-2"></i> Recent Attendance</h5>
                        <button onclick="loadPage('view_attendance.jsp')" class="btn btn-sm btn-outline-success rounded-pill px-3">View Full</button>
                    </div>
                    <div class="card-body px-4 pb-4">
                        <% if (recentAttendance.isEmpty()) { %>
                            <div class="text-center py-4 bg-light rounded text-muted">
                                <i class="fas fa-info-circle fa-2x mb-2 opacity-50"></i>
                                <p class="mb-0 small">No recent attendance records found.</p>
                            </div>
                        <% } else { %>
                            <div class="list-group list-group-flush border rounded">
                                <% for (Map<String, Object> att : recentAttendance) { 
                                    boolean isPresent = "present".equalsIgnoreCase((String)att.get("status"));
                                %>
                                    <div class="list-group-item d-flex justify-content-between align-items-center py-3">
                                        <div>
                                            <h6 class="mb-0 fw-bold"><%= att.get("subject") %></h6>
                                            <small class="text-muted"><i class="far fa-calendar-alt"></i> <%= att.get("date") %></small>
                                        </div>
                                        <div>
                                            <% if (isPresent) { %>
                                                <span class="badge bg-success-subtle text-success border border-success px-3 py-2 rounded-pill"><i class="fas fa-check-circle"></i> Present</span>
                                            <% } else { %>
                                                <span class="badge bg-danger-subtle text-danger border border-danger px-3 py-2 rounded-pill"><i class="fas fa-times-circle"></i> Absent</span>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>
                
                <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
                    <div class="card-header bg-white border-0 pt-4 pb-2 px-4 d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold text-dark mb-0"><i class="fas fa-bullhorn text-danger me-2"></i> Notice Board</h5>
                        <button onclick="loadPage('view_announcements.jsp')" class="btn btn-sm btn-outline-danger rounded-pill px-3">View All</button>
                    </div>
                    <div class="card-body px-4 pb-4">
                         <% if (recentAnnouncements.isEmpty()) { %>
                            <div class="text-center py-4 bg-light rounded text-muted">
                                <i class="fas fa-bell-slash fa-2x mb-2 opacity-50"></i>
                                <p class="mb-0 small">No recent announcements.</p>
                            </div>
                        <% } else { %>
                            <div class="d-flex flex-column gap-3">
                                <% for (Map<String, Object> ann : recentAnnouncements) { 
                                    boolean isGlobal = (Boolean) ann.get("isGlobal");
                                    Timestamp ts = (Timestamp) ann.get("date");
                                    
                                    LocalDateTime pt = ts.toLocalDateTime();
                                    LocalDateTime n = LocalDateTime.now();
                                    long days = ChronoUnit.DAYS.between(pt, n);
                                    String tAgo = (days == 0) ? "Today" : (days == 1) ? "Yesterday" : days + " days ago";
                                %>
                                    <div class="p-3 border rounded-3 position-relative <%= isGlobal ? "border-primary-subtle bg-primary-subtle bg-opacity-10" : "border-info-subtle bg-light" %>">
                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                            <h6 class="mb-0 fw-bold"><%= ann.get("title") %></h6>
                                            <small class="text-muted"><%= tAgo %></small>
                                        </div>
                                        <span class="badge <%= isGlobal ? "bg-primary" : "bg-info text-dark" %> fs-75">
                                            <%= isGlobal ? "School Notice" : "Class Notice" %>
                                        </span>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>

            </div>
            
            <div class="col-lg-5">
                
                <div class="card shadow-sm border-0 mb-4 rounded-4 overflow-hidden">
                    <div class="card-header bg-white border-0 pt-4 pb-2 px-4 d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold text-dark mb-0"><i class="fas fa-folder-open text-warning me-2"></i> Recent Files</h5>
                        <button onclick="loadPage('view_documents.jsp')" class="btn btn-sm btn-outline-warning text-dark rounded-pill px-3">Files</button>
                    </div>
                    <div class="card-body px-4 pb-4">
                        <% if (recentDocs.isEmpty()) { %>
                            <div class="text-center py-4 bg-light rounded text-muted">
                                <i class="fas fa-box-open fa-2x mb-2 opacity-50"></i>
                                <p class="mb-0 small">No recently uploaded files.</p>
                            </div>
                        <% } else { %>
                            <div class="list-group list-group-flush border rounded">
                                <% for (Map<String, Object> doc : recentDocs) { 
                                    String type = (String) doc.get("type");
                                    String bgClass = "bg-secondary";
                                    String icon = "fa-file-alt";
                                    
                                    if(type.equalsIgnoreCase("NOTES") || type.equalsIgnoreCase("SYLLABUS")) {
                                        bgClass = "bg-info text-dark";
                                        icon = "fa-book";
                                    } else if (type.contains("TIMETABLE")) {
                                        bgClass = "bg-warning text-dark";
                                        icon = "fa-calendar-alt";
                                    }
                                %>
                                    <div class="list-group-item d-flex align-items-center py-3 gap-3">
                                        <div class="d-flex justify-content-center align-items-center rounded bg-light icon-circle-sm">
                                            <i class="fas <%= icon %> text-secondary"></i>
                                        </div>
                                        <div class="flex-grow-1 min-w-0">
                                            <h6 class="mb-1 fw-bold text-truncate"><%= doc.get("title") %></h6>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="badge <%= bgClass %> fs-65"><%= type %></span>
                                                <small class="text-muted fs-75"><%= doc.get("date").toString().substring(0, 10) %></small>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>

                <div class="card shadow-sm border-0 rounded-4 overflow-hidden gradient-teal">
                    <div class="card-body p-4 text-center">
                        <h5 class="fw-bold mb-4 opacity-75">Quick Navigation</h5>
                        <div class="d-grid gap-3">
                            <button onclick="loadPage('view_marks.jsp')" class="btn btn-light btn-lg text-teal fw-bold shadow-sm d-flex align-items-center justify-content-center gap-2">
                                <i class="fas fa-award"></i> View Marks & Grades
                            </button>
                            <button onclick="loadPage('view_timetables.jsp')" class="btn btn-outline-light btn-lg fw-bold d-flex align-items-center justify-content-center gap-2">
                                <i class="fas fa-clock"></i> View Timetables
                            </button>
                        </div>
                    </div>
                </div>

            </div>
            
        </div>
    <% } %>
</div>


