<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.seh.util.SQLConnection"%>
<%@page import="com.seh.model.User"%>

<%


User user = (User) session.getAttribute("user");
String avatarLetter = "A";
if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
    avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
}
%>

<div class="teacher_tasks-content">
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Teacher Tasks</h1>
            <p>Track teacher planning records with class, subject, and date filters.</p>
        </div>
        <div class="user-info">
            <div class="user-avatar"><%=avatarLetter%></div>
            <div class="user-details">
                <p class="user-role-name"><%=user.getFullName()%></p>
                <p class="user-role-desc"><%=user.getRole()%></p>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </div>

    <div class="filters-container">
        <form id="teacherTasksFilterForm" onsubmit="return applyTeacherTasksFilters();">
            <div id="teacherTasksValidationAlert" class="alert alert-error teacher-tasks-alert u-hidden">
                <i class="fas fa-exclamation-triangle"></i> Please select Teacher, Class, and Subject before applying filters.
            </div>

            <div class="filters-grid">
                <div class="filter-group" id="teacherTaskTeacherGroup">
                    <label for="teacherTaskTeacherId">Teacher</label>
                    <select id="teacherTaskTeacherId" name="teacherId">
                        <option value="">Select Teacher</option>
                        <%
                        try (Connection conn = SQLConnection.getConnection();
                             PreparedStatement ps = conn.prepareStatement("SELECT user_id, username FROM users WHERE LOWER(role)='teacher' ORDER BY username ASC");
                             ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                        %>
                        <option value="<%=rs.getInt("user_id")%>"><%=rs.getString("username")%></option>
                        <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        %>
                    </select>
                </div>

                <div class="filter-group" id="teacherTaskClassGroup">
                    <label for="teacherTaskClassId">Class</label>
                    <select id="teacherTaskClassId" name="classId">
                        <option value="">Select Class</option>
                        <%
                        try (Connection conn = SQLConnection.getConnection();
                             PreparedStatement ps = conn.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name, section ASC");
                             ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                String classDisplay = rs.getString("class_name") +
                                        (rs.getString("section") != null && !rs.getString("section").isBlank() ? " - " + rs.getString("section") : "");
                        %>
                        <option value="<%=rs.getInt("class_id")%>"><%=classDisplay%></option>
                        <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        %>
                    </select>
                </div>

                <div class="filter-group" id="teacherTaskSubjectGroup">
                    <label for="teacherTaskSubjectId">Subject</label>
                    <select id="teacherTaskSubjectId" name="subjectId">
                        <option value="">Select Subject</option>
                        <%
                        try (Connection conn = SQLConnection.getConnection();
                             PreparedStatement ps = conn.prepareStatement("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name ASC");
                             ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                        %>
                        <option value="<%=rs.getInt("subject_id")%>"><%=rs.getString("subject_name")%></option>
                        <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        %>
                    </select>
                </div>

                <div class="filter-group">
                    <label for="teacherTaskStartDate">Start Date</label>
                    <input type="date" id="teacherTaskStartDate" name="startDate">
                </div>

                <div class="filter-group">
                    <label for="teacherTaskEndDate">End Date</label>
                    <input type="date" id="teacherTaskEndDate" name="endDate">
                </div>

            </div>

            <div class="teacher-tasks-actions">
                <button type="submit" class="btn btn-primary" id="teacherTaskApplyBtn">
                    <i class="fas fa-filter"></i> Apply Filters
                </button>
                <button type="button" class="btn btn-secondary" onclick="resetTeacherTasksFilters()">
                    <i class="fas fa-rotate"></i> Reset
                </button>
                <button type="button" class="btn btn-success" onclick="exportTeacherTasks()">
                    <i class="fas fa-file-excel"></i> Export Excel
                </button>
            </div>
        </form>
    </div>

    <div class="table-container">
        <div class="table-header">
            <h3>Teacher Tasks List</h3>
            <span id="teacherTasksCount">0 records found</span>
        </div>
        <div class="table-wrapper teacher-tasks-scroll">
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Teacher</th>
                        <th>Class</th>
                        <th>Subject</th>
                        <th>Topic</th>
                        <th>Duration</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody id="teacherTasksTableBody">
                    <tr>
                        <td colspan="7" class="no-data">Loading...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

