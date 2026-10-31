<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="com.seh.model.User" %>

<%
String role = (String) session.getAttribute("role");
User user = (User) session.getAttribute("user");
if (user == null || role == null || !"admin".equals(role)) {
    response.sendRedirect("../login.jsp");
    return;
}

String avatarLetter = (user.getFullName() != null && !user.getFullName().isEmpty())
    ? String.valueOf(user.getFullName().charAt(0)).toUpperCase() : "A";

String successMsg = (String) session.getAttribute("success");
String errorMsg = (String) session.getAttribute("error");
if (successMsg != null) session.removeAttribute("success");
if (errorMsg != null) session.removeAttribute("error");

List<Map<String, String>> classes = new ArrayList<>();
try (Connection conn = SQLConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement("SELECT class_id, class_name, section FROM classes ORDER BY class_name, section");
     ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
        Map<String, String> c = new HashMap<>();
        c.put("id", String.valueOf(rs.getInt("class_id")));
        String name = rs.getString("class_name");
        String section = rs.getString("section");
        c.put("label", name + ((section != null && !section.trim().isEmpty()) ? " - " + section : ""));
        classes.add(c);
    }
}
%>

<div class="admin-announcements-content">
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Announcements</h1>
            <p>Create and manage announcements for classes and all students.</p>
        </div>

        <div class="user-info">
            <div class="user-avatar"><%=avatarLetter%></div>
            <div class="user-details">
                <p class="user-role-name"><%=user.getFullName() %></p>
                <p class="user-role-desc"><%=user.getRole()%></p>
            </div>
            <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> Logout</button>
        </div>
    </div>

    <div id="adminAnnouncementResult">
        <% if (successMsg != null) { %>
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=successMsg%></div>
        <% } %>
        <% if (errorMsg != null) { %>
            <div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> <%=errorMsg%></div>
        <% } %>
    </div>

    <div class="form-container">
        <div class="form-header">
            <h2>Create Announcement</h2>
            <p>Post an announcement for all classes or a selected class.</p>
        </div>

        <form id="createAnnouncementForm" onsubmit="return createAdminAnnouncement(event)">
            <div class="form-grid">
                <div class="form-group">
                    <label>Title <span class="required">*</span></label>
                    <input type="text" id="annTitle" name="title" required>
                </div>

                <div class="form-group">
                    <label>Target Class</label>
                    <select id="annClassId" name="classId">
                        <option value="">General (All Classes)</option>
                        <% for (Map<String, String> c : classes) { %>
                            <option value="<%=c.get("id")%>"><%=c.get("label")%></option>
                        <% } %>
                    </select>
                </div>

          <div class="form-group ux-grid-span-full">
                    <label>Description <span class="required">*</span></label>
                    <textarea id="annDescription" name="description" rows="4" required></textarea>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Post Announcement</button>
            </div>
        </form>
    </div>

      <div class="table-container ux-mt-1-5">
        <div class="table-header">
            <h3>Announcements</h3>
            <span id="announcementsCountText">Loading...</span>
        </div>
        <div class="announcement-grid" id="announcementsGrid"></div>
    </div>
</div>

<div id="viewAnnouncementModal" class="modal-overlay ux-hidden">
    <div class="modal-container">
        <div class="modal-header">
            <h2>View Announcement</h2>
            <button class="modal-close" type="button" onclick="closeViewAnnouncementModal()">&times;</button>
        </div>
        <div class="details-content">
        <div class="detail-grid ux-grid-columns-1">
                <div class="detail-item">
                    <label>Title</label>
                    <p id="viewAnnTitle">-</p>
                </div>
                <div class="detail-item">
                    <label>Description</label>
                    <p id="viewAnnDescription">-</p>
                </div>
                <div class="detail-item">
                    <label>Target Class</label>
                    <p id="viewAnnTarget">-</p>
                </div>
                <div class="detail-item">
                    <label>Created At</label>
                    <p id="viewAnnCreated">-</p>
                </div>
            </div>
        </div>
        <div class="form-actions">
            <button type="button" class="btn btn-secondary" onclick="closeViewAnnouncementModal()">Close</button>
        </div>
    </div>
</div>

<div id="editAnnouncementModal" class="modal-overlay ux-hidden">
    <div class="modal-container">
        <div class="modal-header">
            <h2>Edit Announcement</h2>
            <button class="modal-close" type="button" onclick="closeEditAnnouncementModal()">&times;</button>
        </div>

        <div id="editAnnouncementResult"></div>

        <form id="editAnnouncementForm" onsubmit="return updateAdminAnnouncement(event)">
            <input type="hidden" id="editAnnId" name="id">

            <div class="form-grid">
                <div class="form-group">
                    <label>Title <span class="required">*</span></label>
                    <input type="text" id="editAnnTitle" name="title" required>
                </div>

                <div class="form-group">
                    <label>Target Class</label>
                    <select id="editAnnClassId" name="classId">
                        <option value="">General (All Classes)</option>
                        <% for (Map<String, String> c : classes) { %>
                            <option value="<%=c.get("id")%>"><%=c.get("label")%></option>
                        <% } %>
                    </select>
                </div>

      <div class="form-group ux-grid-span-full">
                    <label>Description <span class="required">*</span></label>
                    <textarea id="editAnnDescription" name="description" rows="4" required></textarea>
                </div>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-secondary" onclick="closeEditAnnouncementModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Update</button>
            </div>
        </form>
    </div>
</div>

<div id="whatsappAnnouncementModal" class="modal-overlay ux-hidden">
    <div class="modal-container">
        <div class="modal-header">
            <h2>Send to WhatsApp Group</h2>
            <button class="modal-close" type="button" onclick="cancelAdminAnnouncementPreview()">&times;</button>
        </div>

        <div class="details-content">
        <div class="detail-grid ux-grid-columns-1">
                <div class="detail-item">
                    <label>Target Class</label>
                    <p id="waPreviewClassLabel">-</p>
                </div>
                <div class="detail-item">
                    <label>Message to Send</label>
          <textarea id="waPreviewMessage" class="ux-textarea-preview" rows="7" readonly></textarea>
                </div>
            </div>
        </div>

        <div class="form-actions">
            <button type="button" class="btn btn-secondary" onclick="cancelAdminAnnouncementPreview()">Cancel</button>
            <button type="button" class="btn btn-primary" onclick="confirmAdminAnnouncementAndSend()">Copy & Open WhatsApp</button>
        </div>
    </div>
</div>

<script>
(function () {
    function fallbackLoadAnnouncements() {
        var grid = document.getElementById("announcementsGrid");
        if (!grid) return;

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "../getAdminAnnouncementsTable?_=" + new Date().getTime(), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    grid.innerHTML = xhr.responseText;
                    var cards = grid.querySelectorAll(".announcement-card").length;
                    var countEl = document.getElementById("announcementsCountText");
                    if (countEl) countEl.textContent = cards + " announcements";
                } else {
                    grid.innerHTML = "<div class='table-cell-error'>Failed to load announcements.</div>";
                    var countEl2 = document.getElementById("announcementsCountText");
                    if (countEl2) countEl2.textContent = "0 announcements";
                }
            }
        };
        xhr.send();
    }

    if (typeof loadAdminAnnouncementsTable === "function") {
        loadAdminAnnouncementsTable();
    } else {
        fallbackLoadAnnouncements();
    }
})();
</script>
