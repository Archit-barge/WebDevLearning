<%@ page import="com.seh.util.SQLConnection" %>
<%@ page import="com.seh.model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // ===== AUTH CHECK =====
    User user = (User) session.getAttribute("user");
    String avatarLetter = "A";
    if (user != null && user.getFullName() != null && user.getFullName().length() > 0) {
        avatarLetter = String.valueOf(user.getFullName().charAt(0)).toUpperCase();
    }
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String classIdParam   = request.getParameter("classId");
    String subjectIdParam = request.getParameter("subject_id");
    String dateParam      = request.getParameter("date");
    String sessionTypeParam = request.getParameter("sessionType");
    String timeSlotParam = request.getParameter("timeSlot");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
    <title>Mark Attendance | Smart Edu Hub</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --primary-dark: #4f46e5;
            --success: #10b981;
            --danger: #ef4444;
            --bg: #f8fafc;
            --surface: #ffffff;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --border: #e2e8f0;
            --shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
            --radius: 16px;
            --touch-target: 48px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        html { -webkit-text-size-adjust: 100%; }

        body { 
            font-family: 'Plus Jakarta Sans', sans-serif; 
            background-color: var(--bg); 
            color: var(--text-main); 
            padding: 16px; 
            -webkit-font-smoothing: antialiased;
        }

        .container { max-width: 1100px; margin: 0 auto; padding-bottom: 40px; }

        /* --- TOP BAR --- */
       .top-bar {
            display: flex; justify-content: space-between; align-items: center;
            width: 100%; margin-bottom: 2rem; padding: 1.5rem 2rem;
            background: #fff; border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .welcome-section h1 { font-size: 2rem; font-weight: 700; color: #1e293b; margin-bottom: 0.5rem; line-height: 1.2; }
        .welcome-section p  { color: #64748b; font-size: 1rem;}
        
        .user-info { display: flex; align-items: center; gap: 1rem; }
        .user-avatar {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-weight: 600;
    font-size: 1.2rem;
}
        .logout-btn {
            background: #ef4444; color: #fff; border: none;
            padding: 0.75rem 1.5rem; border-radius: 8px;
            cursor: pointer; transition: all 0.3s; font-weight: 500;
        }
        .logout-btn:hover { background: #dc2626; transform: translateY(-1px); }

        /* --- STATS --- */
        .stats-grid { 
            display: grid; 
            grid-template-columns: repeat(3, 1fr); 
            gap: 12px; 
            margin-bottom: 20px; 
        }
        .stat-card { 
            background: var(--surface); 
            padding: 16px 12px; 
            border-radius: var(--radius); 
            box-shadow: var(--shadow); 
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }
        .stat-icon { 
            width: 44px; 
            height: 44px; 
            border-radius: 12px; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 18px; 
            flex-shrink: 0;
        }
        .stat-card h2 { font-size: 22px; font-weight: 700; margin: 0; }
        .stat-card p { font-size: 11px; margin: 0; color: var(--text-muted); font-weight: 600; }

        /* --- CONFIG CARD --- */
        .card { background: var(--surface); padding: 20px; border-radius: var(--radius); box-shadow: var(--shadow); margin-bottom: 20px; }
        .card-title { font-size: 16px; font-weight: 700; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; color: var(--primary); }
        
        .filter-form-top { display: flex; flex-direction: column; gap: 16px; margin-bottom: 20px; }
        
        .form-group label { display: block; font-size: 12px; font-weight: 700; color: var(--text-muted); margin-bottom: 8px; text-transform: uppercase; }
        
        .form-control { 
            width: 100%; 
            padding: 14px 16px; 
            border: 1.5px solid var(--border); 
            border-radius: 10px; 
            font-size: 15px; 
            font-family: inherit; 
            min-height: var(--touch-target);
            background: var(--surface);
            -webkit-appearance: none;
            appearance: none;
        }

        /* --- TIMING SECTION --- */
        .timing-container {
            background: #f1f5f9;
            padding: 20px;
            border-radius: 12px;
            border: 2px dashed var(--border);
            margin-bottom: 20px;
        }
        .timing-container > label {
            display: block;
            text-align: center;
            font-weight: 800;
            color: var(--text-muted);
            margin-bottom: 15px;
            font-size: 13px;
        }
        .time-picker-wrapper { 
            display: flex; 
            flex-direction: column;
            gap: 15px; 
        }
        .time-group { flex: 1; }
        .time-group label {
            display: block;
            font-size: 10px;
            color: var(--text-muted);
            margin-bottom: 6px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .time-input-big {
            width: 100%;
            padding: 14px;
            font-size: 1.1rem;
            font-weight: 700;
            border: 2px solid var(--border);
            border-radius: 10px;
            background: #ffffff;
            color: var(--primary);
            text-align: center;
            min-height: var(--touch-target);
            -webkit-appearance: none;
            appearance: none;
        }

        /* --- BUTTONS --- */
        .btn-load {
            width: 100%;
            padding: 16px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 700;
            font-size: 15px;
            cursor: pointer;
            transition: 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            min-height: var(--touch-target);
            -webkit-tap-highlight-color: transparent;
        }
        .btn-load:hover { background: var(--primary-dark); }
        .btn-load:active { transform: scale(0.98); }
        
        .btn-present {
            background: var(--success);
        }
        .btn-present:hover {
            background: #059669;
        }
        
        .btn-absent {
            background: var(--danger);
        }
        .btn-absent:hover {
            background: #dc2626;
        }
        
        .btn-submit {
            background: var(--primary);
        }
        .btn-submit:hover {
            background: var(--primary-dark);
        }

        /* --- TABLE STYLES --- */
        .table-wrapper {
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            border-radius: 12px;
            border: 1px solid var(--border);
        }
        .attendance-table { width: 100%; border-collapse: collapse; min-width: 400px; }
        .attendance-table th { 
            background: #f8fafc; 
            padding: 14px 12px; 
            text-align: left; 
            font-size: 11px; 
            color: var(--text-muted); 
            border-bottom: 1px solid var(--border); 
            font-weight: 700;
            text-transform: uppercase;
            white-space: nowrap;
        }
        .attendance-table td { 
            padding: 14px 12px; 
            border-bottom: 1px solid var(--border); 
            background: #fff;
            font-size: 14px;
        }
        .attendance-table tr:last-child td { border-bottom: none; }

        .student-info { display: flex; flex-direction: column; gap: 2px; }
        .student-info .roll { font-size: 12px; color: var(--text-muted); font-weight: 600; }
        .student-info .name { font-weight: 600; color: var(--text-main); }

        .status-toggle {
            cursor: pointer; 
            display: inline-flex; 
            align-items: center; 
            gap: 8px;
            padding: 10px 16px; 
            border-radius: 20px; 
            font-weight: 700; 
            font-size: 12px;
            background: #fee2e2; 
            color: var(--danger); 
            transition: 0.3s;
            white-space: nowrap;
            min-height: var(--touch-target);
        }
        .att-checkbox:checked + .status-toggle { 
            background: #d1fae5; 
            color: var(--success); 
        }
        .att-checkbox { display: none; }

        .action-footer { display: flex; flex-direction: column; gap: 12px; margin-top: 20px; }

        /* --- RESPONSIVE --- */
        @media (min-width: 768px) {
            body { padding: 24px; }
            
            .top-bar {
                padding: 18px;
            }
            .welcome-section h1 { font-size: 22px; }
            .welcome-section p { font-size: 14px; }
            .user-info { flex-shrink: 0; }
            .logout-btn { width: auto; }
            .stats-grid { gap: 20px; margin-bottom: 24px; }
            .stat-card { 
                padding: 20px; 
                gap: 15px;
                flex-direction: row;
                text-align: left;
                justify-content: flex-start;
            }
            .stat-card h2 { font-size: 24px; }
            .stat-card p { font-size: 12px; }
            .card { padding: 32px; margin-bottom: 24px; }
            .card-title { font-size: 18px; margin-bottom: 24px; }
            .filter-form-top { 
                display: grid; 
                grid-template-columns: repeat(3, 1fr); 
                gap: 20px; 
                margin-bottom: 24px; 
            }
            .timing-container { padding: 24px; margin-bottom: 24px; }
            .time-picker-wrapper { 
                flex-direction: row; 
                align-items: flex-end;
            }
            .time-separator {
                display: block;
                font-size: 20px;
                font-weight: 800;
                color: var(--text-muted);
                padding-bottom: 12px;
            }
            .action-footer { flex-direction: row; gap: 16px; margin-top: 24px; }
            .btn-load { width: auto; flex: 1; }
            .attendance-table th, .attendance-table td { padding: 16px; }
            .student-info { flex-direction: row; align-items: center; gap: 10px; }
        }
		@media (max-width: 768px) {
            .top-bar {
                flex-direction: column;
                gap: 12px;
                text-align: center;
                padding: 16px;
            }

            .welcome-section h1 {
                font-size: 20px;
            }

            .welcome-section p {
                font-size: 12px;
            }

            .user-info {
                flex-direction: column;
                width: 100%;
                gap: 10px;
            }

            .user-details {
                text-align: center;
            }

            .user-details .name {
                max-width: 150px;
            }

            .logout-btn {
                width: 100%;
                justify-content: center;
            }
        /* --- TOUCH DEVICE OPTIMIZATIONS --- */
        @media (hover: none) and (pointer: coarse) {
            .btn-load:hover { background: var(--primary); }
            .btn-load:active { transform: scale(0.98); background: var(--primary-dark); }
            .stat-card:active { transform: scale(0.98); }
        }

        /* --- ANIMATIONS --- */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .card, .stat-card { animation: fadeIn 0.4s ease-out; }

        /* --- iOS ZOOM PREVENTION --- */
        @supports (-webkit-touch-callout: none) {
            input, select, button { font-size: 16px !important; }
        }
        
    </style>
</head>
<body>

<div class="container">
    
    <div class="top-bar">
        <div class="welcome-section">
            <h1>Mark Attendance</h1>
            <p>Welcome, <%= user.getFullName() %></p>
        </div>
        <div class="user-info">
            <div class="user-avatar"><%= avatarLetter %></div>
            <div class="user-details">
                <div style="font-weight:600;color:#1e293b;font-size:0.9rem;"><%=user.getUsername()%></div>
                <div style="font-size:0.8rem;color:#64748b;text-transform: capitalize;"><%=user.getRole()%></div>
            </div>
            <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> <span>Logout</span></button>
        </div>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: #eff6ff; color: #3b82f6;"><i class="fas fa-users"></i></div>
            <div>
                <h2 id="totalCount">0</h2>
                <p>Total</p>
            </div>
        </div>
        <div class="stat-card" style="border-bottom: 3px solid var(--success);">
            <div class="stat-icon" style="background: #f0fdf4; color: var(--success);"><i class="fas fa-check"></i></div>
            <div>
                <h2 id="presentCount" style="color: var(--success);">0</h2>
                <p>Present</p>
            </div>
        </div>
        <div class="stat-card" style="border-bottom: 3px solid var(--danger);">
            <div class="stat-icon" style="background: #fef2f2; color: var(--danger);"><i class="fas fa-times"></i></div>
            <div>
                <h2 id="absentCount" style="color: var(--danger);">0</h2>
                <p>Absent</p>
            </div>
        </div>
    </div>

    <section class="card">
        <div class="card-title"><i class="fas fa-sliders-h"></i> Configuration</div>
        <form method="post" action="<%=request.getContextPath()%>/teacher/TeacherAttendanceServlet" onsubmit="syncTimeSlot()">
            
            <div class="filter-form-top">
                <div class="form-group">
                    <label>Class / Section</label>
                    <select name="classId" class="form-control" required>
                        <option value="">Select Class</option>
                        <% try (Connection conn = SQLConnection.getConnection()) {
                            PreparedStatement ps = conn.prepareStatement("SELECT class_id, class_name, section FROM classes");
                            ResultSet rs = ps.executeQuery();
                            while(rs.next()){ %>
                                <option value="<%= rs.getString("class_id") %>" <%= rs.getString("class_id").equals(classIdParam) ? "selected" : "" %>><%= rs.getString("class_name") %> - <%= rs.getString("section") %></option>
                        <% } } catch(Exception e){} %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Subject</label>
                    <select name="subject_id" class="form-control" required>
                        <option value="">Select Subject</option>
                        <% try (Connection conn = SQLConnection.getConnection()) {
                            PreparedStatement ps = conn.prepareStatement("SELECT subject_id, subject_name FROM subjects");
                            ResultSet rs = ps.executeQuery();
                            while(rs.next()){ %>
                                <option value="<%= rs.getString("subject_id") %>" <%= rs.getString("subject_id").equals(subjectIdParam) ? "selected" : "" %>><%= rs.getString("subject_name") %></option>
                        <% } } catch(Exception e){} %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Date</label>
                    <input type="date" name="date" class="form-control" value="<%= (dateParam!=null ? dateParam : java.time.LocalDate.now()) %>" required>
                </div>
            </div>

            <div class="timing-container">
                <label>SESSION TIMING</label>
                <div class="time-picker-wrapper">
                    <div class="time-group">
                        <label>START TIME</label>
                        <input type="time" id="startTime" class="time-input-big" required>
                    </div>
                    
                    <div class="time-separator"><i class="fas fa-arrow-right"></i></div>
                    
                    <div class="time-group">
                        <label>END TIME</label>
                        <input type="time" id="endTime" class="time-input-big" required>
                    </div>
                </div>
                <input type="hidden" name="timeSlot" id="timeSlot" value="<%= (timeSlotParam!=null ? timeSlotParam : "") %>">
            </div>
            <div class="form-group">
<label>Session Type</label>
<select name="sessionType" class="form-control" required>
<option value="">Select</option>
<option value="theory">Theory</option>
<option value="practical">Practical</option>
</select>
</div>

            <button type="submit" class="btn-load"><i class="fas fa-sync-alt"></i> LOAD STUDENT LIST</button>
        </form>
    </section>

    <% if(classIdParam != null && !classIdParam.isEmpty()){ %>
    <form method="post" action="<%=request.getContextPath()%>/SubmitAttendanceServlet" id="attendanceForm">
        <input type="hidden" name="class_id" value="<%= classIdParam %>">
        <input type="hidden" name="subject_id" value="<%= subjectIdParam %>">
        <input type="hidden" name="date" value="<%= dateParam %>">
        <input type="hidden" name="sessionType" value="<%= sessionTypeParam %>">
		<input type="hidden" name="timeSlot" value="<%= timeSlotParam %>">

        <div class="card" style="padding: 0;">
            <div class="table-wrapper">
                <table class="attendance-table">
                    <thead>
                        <tr>
                            <th>Roll No.</th>
                            <th>Student Name</th>
                            <th style="text-align: center;">Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% try (Connection conn = SQLConnection.getConnection()) {
                               PreparedStatement ps = conn.prepareStatement("SELECT student_id, first_name, last_name, roll_number FROM students WHERE class_id = ? ORDER BY roll_number");
                               ps.setInt(1, Integer.parseInt(classIdParam));
                               ResultSet rs = ps.executeQuery();
                               while(rs.next()){ %>
                            <tr>
                                <td><strong>#<%= rs.getString("roll_number") %></strong></td>
                                <td>
                                    <div class="student-info">
                                        <span class="name"><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></span>
                                    </div>
                                </td>
                                <td style="text-align: center;">
                                    <input type="checkbox" class="att-checkbox" id="s_<%= rs.getInt("student_id") %>" name="attendance_<%= rs.getInt("student_id") %>" value="present">
                                    <label for="s_<%= rs.getInt("student_id") %>" class="status-toggle">
                                        <i class="fas fa-user-slash"></i> <span>Absent</span>
                                    </label>
                                </td>
                            </tr>
                        <% } } catch(Exception e){} %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="action-footer">
            <button type="button" class="btn-load btn-present" onclick="setBulk(true)">
                <i class="fas fa-check"></i> ALL PRESENT
            </button>
            <button type="button" class="btn-load btn-absent" onclick="setBulk(false)">
                <i class="fas fa-times"></i> ALL ABSENT
            </button>
            <button type="submit" class="btn-load btn-submit">
                <i class="fas fa-save"></i> SUBMIT
            </button>
        </div>
    </form>
    <% } %>
</div>

<script>
    function syncTimeSlot() {
        const start = document.getElementById('startTime').value;
        const end = document.getElementById('endTime').value;
        if(start && end) document.getElementById('timeSlot').value = start + '-' + end;
    }

    window.addEventListener('load', () => {
        const existing = document.getElementById('timeSlot').value;
        if(existing && existing.includes('-')) {
            const parts = existing.split('-');
            document.getElementById('startTime').value = parts[0];
            document.getElementById('endTime').value = parts[1];
        }
        updateStats();
    });

    function updateStats() {
        const total = document.querySelectorAll('.att-checkbox').length;
        const present = document.querySelectorAll('.att-checkbox:checked').length;
        document.getElementById('totalCount').innerText = total;
        document.getElementById('presentCount').innerText = present;
        document.getElementById('absentCount').innerText = total - present;
    }

    document.querySelectorAll('.att-checkbox').forEach(cb => {
        cb.addEventListener('change', function() {
            const label = this.nextElementSibling;
            label.querySelector('span').innerText = this.checked ? "Present" : "Absent";
            label.querySelector('i').className = this.checked ? "fas fa-user-check" : "fas fa-user-slash";
            updateStats();
        });
    });

    function setBulk(status) {
        document.querySelectorAll('.att-checkbox').forEach(cb => {
            cb.checked = status;
            cb.dispatchEvent(new Event('change'));
        });
    }
</script>

</body>
</html>

