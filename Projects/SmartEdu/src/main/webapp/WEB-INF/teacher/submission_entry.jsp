<%@page import="com.seh.util.SQLConnection"%>
<%@ page import="com.seh.model.User"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
    avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String classIdParam = request.getParameter("classId");
String subjectIdParam = request.getParameter("subjectId");
String examIdParam = request.getParameter("examId");

String action = request.getParameter("action");
if(action != null) {
    try(Connection conn = SQLConnection.getConnection()) {
        conn.setAutoCommit(false);
        
        if("saveMarks".equals(action)) {
            String marksData = request.getParameter("marksData");
            if(marksData != null && !marksData.isEmpty() && subjectIdParam != null && examIdParam != null) {
                String[] entries = marksData.split(";");
                String sql = "INSERT INTO submission_marks (student_id, subject_id, exam_id, component_id, marks) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE marks = VALUES(marks)";
                try(PreparedStatement ps = conn.prepareStatement(sql)) {
                    for(String entry : entries) {
                        if(entry.isEmpty()) continue;
                        String[] parts = entry.split("=");
                        if(parts.length != 2) continue;
                        String[] keyParts = parts[0].split("_");
                        if(keyParts.length != 2) continue;
                        
                        ps.setInt(1, Integer.parseInt(keyParts[0]));
                        ps.setInt(2, Integer.parseInt(subjectIdParam));
                        ps.setInt(3, Integer.parseInt(examIdParam));
                        ps.setInt(4, Integer.parseInt(keyParts[1]));
                        ps.setInt(5, parts[1].isEmpty() ? 0 : Integer.parseInt(parts[1]));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                    conn.commit();
                }
            }
        } else if("addSubmissionType".equals(action)) {
            String typeName = request.getParameter("type_name");
            if(typeName != null && subjectIdParam != null && examIdParam != null) {
                String sql = "INSERT INTO submission_types (subject_id, exam_id, type_name) VALUES (?, ?, ?)";
                try(PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(subjectIdParam));
                    ps.setInt(2, Integer.parseInt(examIdParam));
                    ps.setString(3, typeName);
                    ps.executeUpdate();
                    conn.commit();
                }
            }
        } else if("addComponent".equals(action)) {
            String componentName = request.getParameter("component_name");
            String maxMarksStr = request.getParameter("max_marks");
            String submissionType = request.getParameter("submission_type");
            if(componentName != null && subjectIdParam != null && examIdParam != null && submissionType != null) {
                String typeSql = "SELECT type_id FROM submission_types WHERE subject_id = ? AND exam_id = ? AND type_name = ?";
                int typeId = 0;
                try(PreparedStatement ps = conn.prepareStatement(typeSql)) {
                    ps.setInt(1, Integer.parseInt(subjectIdParam));
                    ps.setInt(2, Integer.parseInt(examIdParam));
                    ps.setString(3, submissionType);
                    ResultSet rs = ps.executeQuery();
                    if(rs.next()) typeId = rs.getInt("type_id");
                }
                
                if(typeId > 0) {
                    String sql = "INSERT INTO submission_components (subject_id, exam_id, type_id, component_name, max_marks) VALUES (?, ?, ?, ?, ?)";
                    try(PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(subjectIdParam));
                        ps.setInt(2, Integer.parseInt(examIdParam));
                        ps.setInt(3, typeId);
                        ps.setString(4, componentName);
                        ps.setInt(5, maxMarksStr != null ? Integer.parseInt(maxMarksStr) : 10);
                        ps.executeUpdate();
                        conn.commit();
                    }
                }
            }
        } else if("deleteComponent".equals(action)) {
            String componentIdStr = request.getParameter("component_id");
            if(componentIdStr != null) {
                String deleteMarksSql = "DELETE FROM submission_marks WHERE component_id = ?";
                try(PreparedStatement ps = conn.prepareStatement(deleteMarksSql)) {
                    ps.setInt(1, Integer.parseInt(componentIdStr));
                    ps.executeUpdate();
                }
                String sql = "DELETE FROM submission_components WHERE component_id = ?";
                try(PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(componentIdStr));
                    ps.executeUpdate();
                }
                conn.commit();
            }
        }
    } catch(Exception e) {
        e.printStackTrace();
    }
    
    String redirectUrl = "submission_entry.jsp";
    if(classIdParam != null) redirectUrl += "?classId=" + classIdParam;
    if(subjectIdParam != null) redirectUrl += "&subjectId=" + subjectIdParam;
    if(examIdParam != null) redirectUrl += "&examId=" + examIdParam;
    response.sendRedirect(redirectUrl);
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dynamic Submission Entry - SmartEdu</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f8fafc; min-height: 100vh; padding: 20px; }
        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; padding: 20px; background: white; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .welcome-section h1 { font-size: 1.5rem; font-weight: 700; color: #1e293b; margin-bottom: 4px; }
        .welcome-section p { color: #64748b; font-size: 0.9rem; }
        .user-avatar { width: 45px; height: 45px; border-radius: 50%; background: linear-gradient(135deg, #667eea, #764ba2); color: white; display: flex; align-items: center; justify-content: center; font-weight: 600; }
        .logout-btn { background: #ef4444; color: white; border: none; padding: 10px 16px; border-radius: 8px; cursor: pointer; font-weight: 500; }
        .card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .card h3 { font-size: 1.1rem; color: #1e293b; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
        .card h3 i { color: #667eea; }
        .form-label { font-weight: 600; color: #475569; font-size: 0.85rem; margin-bottom: 6px; }
        .form-select, .form-control { padding: 10px 12px; border: 2px solid #e2e8f0; border-radius: 8px; font-size: 0.95rem; }
        .form-select:focus, .form-control:focus { border-color: #667eea; box-shadow: 0 0 0 3px rgba(102,126,234,0.1); }
        .btn-primary { background: linear-gradient(135deg, #667eea, #764ba2); border: none; padding: 12px 20px; border-radius: 8px; font-weight: 600; }
        .btn-success { background: linear-gradient(135deg, #10b981, #059669); border: none; padding: 12px 20px; border-radius: 8px; font-weight: 600; }
        .btn-danger { background: linear-gradient(135deg, #ef4444, #dc2626); border: none; padding: 8px 12px; border-radius: 6px; font-size: 0.8rem; }
        .submission-type-card { background: white; border: 2px solid #e2e8f0; border-radius: 10px; padding: 14px 18px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; margin-right: 10px; margin-bottom: 10px; transition: all 0.3s; }
        .submission-type-card:hover { border-color: #667eea; transform: translateY(-2px); }
        .submission-type-card.active { border-color: #667eea; background: #eff6ff; }
        .submission-type-card i { color: #667eea; }
        .submission-type-card span { font-weight: 600; color: #1e293b; }
        .component-item { display: inline-flex; align-items: center; gap: 8px; padding: 8px 14px; background: #f1f5f9; border-radius: 8px; margin-right: 8px; margin-bottom: 8px; font-size: 0.9rem; }
        .component-item .max-marks { color: #64748b; font-size: 0.8rem; }
        .table { width: 100%; border-collapse: collapse; }
        .table th { background: #f8fafc; padding: 12px; text-align: center; font-weight: 600; color: #475569; font-size: 0.75rem; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        .table th:first-child { text-align: left; }
        .table td { padding: 12px; border-bottom: 1px solid #f1f5f9; text-align: center; }
        .table td:first-child { text-align: left; font-weight: 500; }
        .marks-input { width: 70px; padding: 8px; border: 2px solid #e2e8f0; border-radius: 6px; text-align: center; }
        .marks-input:focus { border-color: #667eea; outline: none; }
        .total-cell { font-weight: 700; color: #667eea; }
        .student-info { display: flex; align-items: center; gap: 10px; }
        .student-avatar { width: 32px; height: 32px; border-radius: 8px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 0.8rem; }
        .message-box { background: white; padding: 40px; border-radius: 12px; text-align: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .message-box i { font-size: 3rem; color: #667eea; margin-bottom: 15px; }
        .message-box p { font-size: 1rem; color: #475569; }
    </style>
</head>
<body>

<div class="container" style="max-width: 1400px; margin: 0 auto;">

    <div class="top-bar">
        <div class="welcome-section">
            <h1><i class="fas fa-file-import"></i> Dynamic Submission Entry</h1>
            <p>Welcome back, <%=user.getFullName()%>!</p>
        </div>
        <div style="display: flex; align-items: center; gap: 15px;">
            <div class="user-avatar"><%=avatarLetter%></div>
            <button class="logout-btn" onclick="if(confirm('Logout?')) window.location.href='../LogoutServlet'">Logout</button>
        </div>
    </div>

    <div style="display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap;">
        <a href="<%=request.getContextPath()%>/teacher/Index.jsp" class="btn btn-primary" style="text-decoration: none;">
            <i class="fas fa-users"></i> Students
        </a>
        
    </div>

    <div class="card">
        <h3><i class="fas fa-filter"></i> Select Details</h3>
        <form method="get" action="submission_entry.jsp">
            <div style="display: flex; gap: 12px; flex-wrap: wrap; align-items: flex-end;">
                <div style="flex: 1; min-width: 200px;">
                    <label class="form-label">Class</label>
                    <select name="classId" class="form-select" onchange="this.form.submit()">
                        <option value="">-- Select Class --</option>
                        <%
                            try(Connection conn = SQLConnection.getConnection()) {
                                ResultSet rs = conn.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name, section").executeQuery();
                                while(rs.next()) {
                                    String id = String.valueOf(rs.getInt("class_id"));
                                    String selected = (classIdParam != null && classIdParam.equals(id)) ? "selected" : "";
                        %>
                        <option value="<%=id%>" <%=selected%>><%=rs.getString("class_name")%>-<%=rs.getString("section")%></option>
                        <% } } catch(Exception e) { e.printStackTrace(); } %>
                    </select>
                </div>
                <div style="flex: 1; min-width: 200px;">
                    <label class="form-label">Subject</label>
                    <select name="subjectId" class="form-select" onchange="this.form.submit()" <%=classIdParam == null || classIdParam.isEmpty()%>>
                        <option value="">-- Select Subject --</option>
                        <%
                            if(classIdParam != null && !classIdParam.isEmpty()) {
                                try(Connection conn = SQLConnection.getConnection()) {
                                    String sql = "SELECT s.subject_id, s.subject_name FROM subjects s INNER JOIN class_subjects cs ON s.subject_id = cs.subject_id WHERE cs.class_id = ? ORDER BY s.subject_name";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setInt(1, Integer.parseInt(classIdParam));
                                    ResultSet rs = ps.executeQuery();
                                    while(rs.next()) {
                                        String id = String.valueOf(rs.getInt("subject_id"));
                                        String selected = (subjectIdParam != null && subjectIdParam.equals(id)) ? "selected" : "";
                        %>
                        <option value="<%=id%>" <%=selected%>><%=rs.getString("subject_name")%></option>
                        <% } } catch(Exception e) { e.printStackTrace(); } } %>
                    </select>
                </div>
                <div style="flex: 1; min-width: 200px;">
                    <label class="form-label">Exam</label>
                    <select name="examId" class="form-select" onchange="this.form.submit()" <%=subjectIdParam == null || subjectIdParam.isEmpty() %>>
                        <option value="">-- Select Exam --</option>
                        <%
                            try(Connection conn = SQLConnection.getConnection()) {
                                ResultSet rs = conn.prepareStatement("SELECT exam_id, exam_name FROM exams ORDER BY exam_id DESC").executeQuery();
                                while(rs.next()) {
                                    String id = String.valueOf(rs.getInt("exam_id"));
                                    String selected = (examIdParam != null && examIdParam.equals(id)) ? "selected" : "";
                        %>
                        <option value="<%=id%>" <%=selected%>><%=rs.getString("exam_name")%></option>
                        <% } } catch(Exception e) { e.printStackTrace(); } %>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary" <%=(classIdParam == null || subjectIdParam == null || examIdParam == null) %>>
                    <i class="fas fa-search"></i> Load
                </button>
            </div>
        </form>
    </div>

<% if(classIdParam == null || subjectIdParam == null || examIdParam == null) { %>
    <div class="message-box">
        <i class="fas fa-info-circle"></i>
        <p>Please select a class, subject, and exam to manage submissions.</p>
    </div>
<% } else { %>

<%
    int classId = Integer.parseInt(classIdParam);
    int subjectId = Integer.parseInt(subjectIdParam);
    int examId = Integer.parseInt(examIdParam);
    
    List<Map<String, Object>> submissionTypes = new ArrayList<>();
    List<Map<String, Object>> components = new ArrayList<>();
    List<Map<String, Object>> students = new ArrayList<>();
    Map<String, Integer> existingMarks = new HashMap<>();
    
    try(Connection conn = SQLConnection.getConnection()) {
        String typesSql = "SELECT DISTINCT st.type_id, st.type_name FROM submission_types st " +
                         "JOIN submission_components sc ON st.type_id = sc.type_id " +
                         "WHERE sc.subject_id = ? AND sc.exam_id = ? ORDER BY st.type_id";
        PreparedStatement psTypes = conn.prepareStatement(typesSql);
        psTypes.setInt(1, subjectId);
        psTypes.setInt(2, examId);
        ResultSet rsTypes = psTypes.executeQuery();
        while(rsTypes.next()) {
            Map<String, Object> type = new HashMap<>();
            type.put("type_id", rsTypes.getInt("type_id"));
            type.put("type_name", rsTypes.getString("type_name"));
            submissionTypes.add(type);
        }
        
        String compSql = "SELECT sc.component_id, sc.component_name, sc.max_marks, st.type_name " +
                        "FROM submission_components sc " +
                        "JOIN submission_types st ON sc.type_id = st.type_id " +
                        "WHERE sc.subject_id = ? AND sc.exam_id = ? " +
                        "ORDER BY st.type_id, sc.component_id";
        PreparedStatement psComp = conn.prepareStatement(compSql);
        psComp.setInt(1, subjectId);
        psComp.setInt(2, examId);
        ResultSet rsComp = psComp.executeQuery();
        while(rsComp.next()) {
            Map<String, Object> comp = new HashMap<>();
            comp.put("component_id", rsComp.getInt("component_id"));
            comp.put("component_name", rsComp.getString("component_name"));
            comp.put("max_marks", rsComp.getInt("max_marks"));
            comp.put("type_name", rsComp.getString("type_name"));
            components.add(comp);
        }
        
        String studSql = "SELECT student_id, first_name, last_name, roll_number FROM students WHERE class_id = ? ORDER BY roll_number";
        PreparedStatement psStud = conn.prepareStatement(studSql);
        psStud.setInt(1, classId);
        ResultSet rsStud = psStud.executeQuery();
        while(rsStud.next()) {
            Map<String, Object> stud = new HashMap<>();
            stud.put("student_id", rsStud.getInt("student_id"));
            stud.put("full_name", rsStud.getString("first_name") + (rsStud.getString("last_name") != null ? " " + rsStud.getString("last_name") : ""));
            stud.put("roll_number", rsStud.getString("roll_number"));
            students.add(stud);
        }
        
        String marksSql = "SELECT student_id, component_id, marks FROM submission_marks WHERE subject_id = ? AND exam_id = ?";
        PreparedStatement psMarks = conn.prepareStatement(marksSql);
        psMarks.setInt(1, subjectId);
        psMarks.setInt(2, examId);
        ResultSet rsMarks = psMarks.executeQuery();
        while(rsMarks.next()) {
            String key = rsMarks.getInt("student_id") + "_" + rsMarks.getInt("component_id");
            existingMarks.put(key, rsMarks.getInt("marks"));
        }
    } catch(Exception e) { e.printStackTrace(); }
    
    if(submissionTypes.isEmpty()) {
        try(Connection conn = SQLConnection.getConnection()) {
            String[] defaultTypes = {"Manual", "Assignment"};
            for(String typeName : defaultTypes) {
                String insertTypeSql = "INSERT INTO submission_types (subject_id, exam_id, type_name) VALUES (?, ?, ?)";
                PreparedStatement psInsert = conn.prepareStatement(insertTypeSql, Statement.RETURN_GENERATED_KEYS);
                psInsert.setInt(1, subjectId);
                psInsert.setInt(2, examId);
                psInsert.setString(3, typeName);
                psInsert.executeUpdate();
                
                ResultSet rs = psInsert.getGeneratedKeys();
                int typeId = 0;
                if(rs.next()) typeId = rs.getInt(1);
                
                int count = typeName.equals("Manual") ? 3 : 2;
                int maxMarks = typeName.equals("Manual") ? 10 : 5;
                for(int i = 1; i <= count; i++) {
                    String compSql = "INSERT INTO submission_components (subject_id, exam_id, type_id, component_name, max_marks) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement psComp = conn.prepareStatement(compSql);
                    psComp.setInt(1, subjectId);
                    psComp.setInt(2, examId);
                    psComp.setInt(3, typeId);
                    psComp.setString(4, String.valueOf(i));
                    psComp.setInt(5, maxMarks);
                    psComp.executeUpdate();
                }
            }
            conn.commit();
            response.sendRedirect("submission_entry.jsp?classId=" + classIdParam + "&subjectId=" + subjectIdParam + "&examId=" + examIdParam);
            return;
        } catch(Exception e) { e.printStackTrace(); }
    }
    
    String selectedType = submissionTypes.isEmpty() ? "" : (String)submissionTypes.get(0).get("type_name");
    
    List<Map<String, Object>> filteredComponents = new ArrayList<>();
    for(Map<String, Object> c : components) {
        if(c.get("type_name").equals(selectedType)) {
            filteredComponents.add(c);
        }
    }
%>

    <div class="card">
        <h3><i class="fas fa-folder-open"></i> Submission Type</h3>
        <div>
        <% String[] icons = {"fa-file-alt", "fa-book", "fa-project-diagram", "fa-clipboard-list"};
           for(int i = 0; i < submissionTypes.size(); i++) {
               Map<String, Object> type = submissionTypes.get(i);
        %>
            <div class="submission-type-card <%= i == 0 ? "active" : "" %>" onclick="filterByType('<%= type.get("type_name") %>')">
                <i class="fas <%= icons[i % icons.length] %>"></i>
                <span><%= type.get("type_name") %></span>
            </div>
        <% } %>
        </div>
        <form method="post" style="margin-top: 15px; display: flex; gap: 10px; flex-wrap: wrap;">
            <input type="hidden" name="action" value="addSubmissionType">
            <input type="hidden" name="classId" value="<%=classIdParam%>">
            <input type="hidden" name="subjectId" value="<%=subjectIdParam%>">
            <input type="hidden" name="examId" value="<%=examIdParam%>">
            <input type="text" name="type_name" class="form-control" placeholder="New Type Name" style="width: 200px;" required>
            <button type="submit" class="btn btn-success"><i class="fas fa-plus"></i> Add Type</button>
        </form>
    </div>

    <div class="card">
        <h3><i class="fas fa-list-ol"></i> Submission Components</h3>
        <div id="componentList">
        <%
            for(Map<String, Object> comp : filteredComponents) {
        %>
            <div class="component-item">
                <span><%= comp.get("component_name") %></span>
                <span class="max-marks">(Max: <%= comp.get("max_marks") %>)</span>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="action" value="deleteComponent">
                    <input type="hidden" name="classId" value="<%=classIdParam%>">
                    <input type="hidden" name="subjectId" value="<%=subjectIdParam%>">
                    <input type="hidden" name="examId" value="<%=examIdParam%>">
                    <input type="hidden" name="component_id" value="<%= comp.get("component_id") %>">
                    <button type="submit" class="btn-danger" onclick="return confirm('Delete this component?')"><i class="fas fa-trash"></i></button>
                </form>
            </div>
        <% } %>
        <% if(filteredComponents.isEmpty()) { %>
            <span style="color: #64748b;">No components. Add below.</span>
        <% } %>
        </div>
        
        <form method="post" style="margin-top: 15px; display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-end;">
            <input type="hidden" name="action" value="addComponent">
            <input type="hidden" name="classId" value="<%=classIdParam%>">
            <input type="hidden" name="subjectId" value="<%=subjectIdParam%>">
            <input type="hidden" name="examId" value="<%=examIdParam%>">
            <input type="hidden" name="submission_type" value="<%=selectedType%>">
            <div>
                <label class="form-label">Component Name</label>
                <input type="text" name="component_name" class="form-control" placeholder="e.g., 1, 2, First" style="width: 150px;" required>
            </div>
            <div>
                <label class="form-label">Max Marks</label>
                <input type="number" name="max_marks" class="form-control" value="10" min="1" style="width: 100px;">
            </div>
            <button type="submit" class="btn btn-primary"><i class="fas fa-plus"></i> Add Component</button>
        </form>
    </div>

    <div class="card">
        <h3><i class="fas fa-edit"></i> Submission Marks Entry</h3>
        <form method="post" id="marksForm">
            <input type="hidden" name="action" value="saveMarks">
            <input type="hidden" name="classId" value="<%=classIdParam%>">
            <input type="hidden" name="subjectId" value="<%=subjectIdParam%>">
            <input type="hidden" name="examId" value="<%=examIdParam%>">
            <input type="hidden" name="marksData" id="marksData" value="">
            
            <div style="overflow-x: auto;">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Student</th>
                            <% for(Map<String, Object> comp : filteredComponents) { %>
                            <th><%= comp.get("component_name") %><br><small>(<%= comp.get("max_marks") %>)</small></th>
                            <% } %>
                            <% if(!filteredComponents.isEmpty()) { %>
                            <th>Total</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <% for(Map<String, Object> student : students) { 
                            int sid = (Integer)student.get("student_id");
                            String firstLetter = ((String)student.get("full_name")).substring(0,1).toUpperCase();
                        %>
                        <tr>
                            <td>
                                <div class="student-info">
                                    <div class="student-avatar"><%= firstLetter %></div>
                                    <div><%= student.get("full_name") %><br><small style="color: #64748b;"><%= student.get("roll_number") %></small></div>
                                </div>
                            </td>
                            <% for(Map<String, Object> comp : filteredComponents) {
                                int cid = (Integer)comp.get("component_id");
                                String key = sid + "_" + cid;
                                Integer savedMark = existingMarks.get(key);
                            %>
                            <td>
                                <input type="number" class="marks-input" data-sid="<%=sid%>" data-cid="<%=cid%>" data-max="<%=comp.get("max_marks")%>" 
                                       value="<%= savedMark != null ? savedMark : "" %>" min="0" max="<%=comp.get("max_marks")%>" 
                                       onchange="calculateTotal(this)" oninput="calculateTotal(this)">
                            </td>
                            <% } %>
                            <% if(!filteredComponents.isEmpty()) { %>
                            <td class="total-cell" id="total_<%=sid%>">0</td>
                            <% } %>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            
            <div style="margin-top: 20px; display: flex; gap: 10px; justify-content: flex-end;">
                <button type="button" class="btn btn-success" onclick="saveMarks()">
                    <i class="fas fa-save"></i> Save Marks
                </button>
            </div>
        </form>
    </div>

<% } %>

</div>

<script>
function filterByType(typeName) {
    document.querySelectorAll('.submission-type-card').forEach(card => {
        if(card.querySelector('span').textContent === typeName) {
            card.classList.add('active');
        } else {
            card.classList.remove('active');
        }
    });
    
    const url = new URL(window.location.href);
    window.location.href = url.pathname + '?classId=' + url.searchParams.get('classId') + 
                         '&subjectId=' + url.searchParams.get('subjectId') + 
                         '&examId=' + url.searchParams.get('examId');
}

function calculateTotal(input) {
    const row = input.closest('tr');
    const sid = input.dataset.sid;
    const max = parseInt(input.dataset.max);
    let value = parseInt(input.value);
    
    if(isNaN(value) || value < 0) {
        input.style.borderColor = '#ef4444';
    } else if(value > max) {
        input.value = max;
        input.style.borderColor = '#10b981';
    } else {
        input.style.borderColor = '#10b981';
    }
    
    let total = 0;
    row.querySelectorAll('.marks-input').forEach(inp => {
        let v = parseInt(inp.value);
        if(!isNaN(v) && v >= 0) total += v;
    });
    
    const totalCell = row.querySelector('.total-cell');
    if(totalCell) totalCell.textContent = total;
}

function saveMarks() {
    let marksData = [];
    document.querySelectorAll('.marks-input').forEach(input => {
        const sid = input.dataset.sid;
        const cid = input.dataset.cid;
        const marks = input.value !== '' ? parseInt(input.value) : 0;
        marksData.push(sid + '_' + cid + '=' + marks);
    });
    
    document.getElementById('marksData').value = marksData.join(';');
    
    fetch('<%=request.getContextPath()%>/teacher/submission_entry.jsp', {
        method: 'POST',
        body: new FormData(document.getElementById('marksForm'))
    }).then(response => {
        if(response.ok) {
            alert('Marks saved successfully!');
            location.reload();
        } else {
            alert('Error saving marks');
        }
    }).catch(err => {
        alert('Error: ' + err);
    });
}

document.querySelectorAll('.marks-input').forEach(input => {
    calculateTotal(input);
});
</script>

</body>
</html>

