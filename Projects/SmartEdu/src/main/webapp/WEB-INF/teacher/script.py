import os
import re

path = r"d:\Ashita\Desktop\SmartEdu Hub\SmartEdu Hub\src\main\webapp\WEB-INF\teacher\enter_marks.jsp"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

new_style = """    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            --primary: #6366f1;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --bg: #f3f4f6;
            --surface: #ffffff;
            --text-main: #111827;
            --text-muted: #6b7280;
            --border: #e5e7eb;
            --shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            --radius-lg: 1rem;
            --radius-md: 0.75rem;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', -apple-system, sans-serif;
            background: var(--bg);
            color: var(--text-main);
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
        }

        /* ----- TOP BAR ----- */
        .top-bar {
            display: flex; justify-content: space-between; align-items: center;
            width: 100%; margin-bottom: 2rem; padding: 1.5rem 2rem;
            background: #fff; border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .welcome-section h1 { font-size: 2rem; font-weight: 700; color: #1e293b; margin-bottom: 0.5rem; line-height: 1.2; }
        .welcome-section p  { color: #64748b; font-size: 1rem;}
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .user-details {
            display: flex;
            flex-direction: column;
            text-align: right;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: var(--primary-gradient);
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
            display: flex; align-items: center; gap: 8px;
        }
        .logout-btn:hover { background: #dc2626; transform: translateY(-1px); }

        /* ----- LAYOUT & CARDS ----- */
        .main-container {
            max-width: 1100px;
            margin: 1.5rem auto;
            padding: 0 1rem;
            padding-bottom: 40px;
        }

        .filter-card, .table-card {
            background: var(--surface);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-md);
            margin-bottom: 1.5rem;
            overflow: hidden;
        }

        .filter-card { padding: 1.25rem; }

        .filter-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 15px;
        }
        .filter-header h2 { font-size: 1.125rem; font-weight: 700; display: flex; align-items: center; gap: 8px; color: var(--text-main); margin: 0; }
        .filter-header h2 i { color: var(--primary); }

        .table-title {
            padding: 1rem 1.25rem;
            border-bottom: 1px solid var(--border);
            background: #f9fafb;
            font-weight: 700;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--text-main);
        }

        /* ----- FORMS ----- */
        .filter-form {
            display: flex; flex-wrap: wrap; gap: 1rem; align-items: flex-end; width: 100%;
        }

        .form-group {
            flex: 1; min-width: 200px;
        }
        .form-group label {
            display: block; margin-bottom: 0.4rem; font-weight: 600; font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.025em;
        }
        .form-group select {
            width: 100%; padding: 0.6rem 0.8rem; border: 1px solid var(--border); border-radius: var(--radius-md); font-size: 0.9rem; background: #f9fafb; transition: all 0.2s; font-family: inherit;
        }
        .form-group select:focus {
            outline: none; border-color: var(--primary); background: white; box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }

        /* ----- TOGGLE BUTTONS ----- */
        .exam-type-toggle { display: flex; gap: 8px; margin-bottom: 1rem; background: #f3f4f6; padding: 4px; border-radius: 10px; width: fit-content; }
        .exam-type-btn { padding: 8px 16px; border: none; background: transparent; border-radius: 8px; cursor: pointer; font-weight: 600; font-size: 0.875rem; color: var(--text-muted); transition: all 0.2s; white-space: nowrap; }
        .exam-type-btn.active { background: white; color: var(--primary); box-shadow: var(--shadow-sm); }

        /* ----- BUTTONS ----- */
        .btn-primary { 
            background: var(--primary-gradient); color: white; border: none; border-radius: var(--radius-md); padding: 0.6rem 1.25rem; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem; height: 42px;
        }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); }

        .btn-back-top { background: transparent; color: var(--text-muted); border: 1px solid var(--border); border-radius: var(--radius-md); padding: 0.4rem 0.8rem; font-weight: 600; font-size: 0.8rem; cursor: pointer; display: flex; align-items: center; gap: 6px; transition: all 0.2s; }
        .btn-back-top:hover { background: #f3f4f6; color: var(--text-main); }
        
        .footer-actions { display: flex; justify-content: flex-end; gap: 12px; padding: 1.25rem; border-top: 1px solid var(--border); background: #f9fafb; margin-top: 0; }
        .btn-save { background: var(--success); color: white; border: none; padding: 0.6rem 1.25rem; border-radius: var(--radius-md); font-weight: 600; font-size: 0.9rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: all 0.2s; }
        .btn-save:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }
        .btn-excel { background: #10b981; color: white; border: none; padding: 0.6rem 1.25rem; border-radius: var(--radius-md); font-weight: 600; font-size: 0.9rem; text-decoration: none; display: flex; align-items: center; gap: 8px; transition: all 0.2s; }
        .btn-excel:hover { transform: translateY(-1px); background: #059669; }

        /* ----- TABLES ----- */
        .table-wrapper { overflow-x: auto; -webkit-overflow-scrolling: touch; margin: 0; padding: 0; border: none; }
        table { width: 100%; border-collapse: collapse; min-width: 800px; }
        th { background: #f9fafb; padding: 0.75rem 1rem; text-align: left; font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase; border-bottom: 2px solid var(--border); white-space: nowrap; }
        td { padding: 0.85rem 1rem; border-bottom: 1px solid var(--border); font-size: 0.9rem; vertical-align: middle; }
        tr:hover td { background-color: #f9fafb; }
        
        .student-profile { display: flex; align-items: center; gap: 12px; }
        .student-init { width: 32px; height: 32px; min-width: 32px; border-radius: 8px; background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.8rem; }
        .student-profile span { font-weight: 500; color: var(--text-main); white-space: nowrap; }

        input.form-control { width: 70px; padding: 8px; border-radius: 6px; border: 1px solid var(--border); text-align: center; font-weight: 600; transition: all 0.2s; background: #f9fafb; font-size: 0.9rem; color: var(--text-main); }
        input.form-control:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1); background: white; }
        input.form-control[readonly] { background: transparent; color: var(--primary); border-color: transparent; font-weight: 700; }
        
        .ut-avg-cell { color: var(--primary) !important; font-weight: 800; }
        .sem-avg-cell { color: var(--warning) !important; font-weight: 800; }

        /* ----- MOBILE RESPONSIVENESS ----- */
        @media (max-width: 768px) {
            .top-bar { flex-direction: column; gap: 0.75rem; align-items: stretch; text-align: center; }
            .user-info { justify-content: space-between; background: #f3f4f6; padding: 0.5rem; border-radius: 12px; }
            .container, .main-container { margin: 1rem auto; padding: 0 0.5rem; }
            .logout-btn span { display: none; }
            
            .filter-header { flex-direction: column; align-items: stretch; text-align: center; }
            .filter-header h2 { justify-content: center; }
            .btn-back-top { justify-content: center; width: 100%; }
            
            .exam-type-toggle { width: 100%; display: flex; }
            .exam-type-btn { flex: 1; text-align: center; }
            
            .filter-form { flex-direction: column; align-items: stretch; }
            .form-group { width: 100%; }
            .btn-primary { width: 100%; }
            
            .footer-actions { flex-direction: column; gap: 0.8rem; }
            .btn-save, .btn-excel { width: 100%; justify-content: center; }
        }
    </style>"""

content = re.sub(r'<style>.*?</style>', new_style, content, flags=re.DOTALL)
with open(path, "w", encoding="utf-8") as f:
    f.write(content)
