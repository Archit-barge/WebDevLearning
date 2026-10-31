package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.*;
import java.sql.*;
import java.util.*;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/bulkInsertUsers")
public class BulkInsertServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;
        String sessionRole = (sessionUser != null && sessionUser.getRole() != null)
                ? sessionUser.getRole().trim().toLowerCase(Locale.ROOT)
                : "";
        // Accept labels like "Admin", "Arc Admin", "Super Admin".
        if (sessionUser == null || !sessionRole.contains("admin")) {
            response.setStatus(403);
            out.print("[{\"error\":\"Unauthorized\"}]");
            return;
        }

        // Read JSON body
        StringBuilder sb = new StringBuilder();
        BufferedReader reader = request.getReader();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        String body = sb.toString();

        String role;
        List<Map<String, String>> users;
        try {
            Map<String, Object> payload = JsonMiniParser.parseObject(body);
            role = asString(payload.get("role"));
            users = asUserRows(payload.get("users"));
        } catch (IllegalArgumentException ex) {
            response.setStatus(400);
            out.print("[{\"error\":\"Invalid JSON payload\"}]");
            return;
        }

        if (!Arrays.asList("student", "teacher", "parent", "admin").contains(role)) {
            response.setStatus(400);
            out.print("[{\"error\":\"Invalid role\"}]");
            return;
        }

        if (role == null || role.isEmpty() || users == null || users.isEmpty()) {
            out.print("[]");
            return;
        }

        List<Map<String, String>> results = new ArrayList<>();
        Connection conn = null;

        try {
            conn = SQLConnection.getConnection();
            if (conn == null) {
                for (Map<String, String> u : users) {
                    Map<String, String> r = new LinkedHashMap<>();
                    r.put("name", getVal(u, "first_name") + " " + getVal(u, "last_name"));
                    r.put("username", getVal(u, "username"));
                    r.put("success", "false");
                    r.put("error", "Database connection failed");
                    results.add(r);
                }
                out.print(toJsonArray(results));
                return;
            }

            for (Map<String, String> u : users) {
                Map<String, String> result = new LinkedHashMap<>();
                String name = getVal(u, "first_name") + " " + getVal(u, "last_name");
                String username = getVal(u, "username");
                result.put("name", name);
                result.put("username", username);

                try {
                    conn.setAutoCommit(false);

                    // Check for existing username or email in DB
                    if (usernameOrEmailExists(conn, getVal(u, "username"), getVal(u, "email"))) {
                        conn.rollback();
                        result.put("success", "false");
                        result.put("error", "Username or email already exists in database");
                        results.add(result);
                        continue;
                    }

                    // Role-specific checks
                    if ("student".equals(role)) {
                        if (rollNumberExists(conn, getVal(u, "roll_number"))) {
                            conn.rollback();
                            result.put("success", "false");
                            result.put("error", "Roll number already exists");
                            results.add(result);
                            continue;
                        }
                    } else if ("teacher".equals(role)) {
                        if (employeeIdExists(conn, getVal(u, "employee_id"))) {
                            conn.rollback();
                            result.put("success", "false");
                            result.put("error", "Employee ID already exists");
                            results.add(result);
                            continue;
                        }
                    }

                    // Insert into users table
                    int userId = insertUser(conn, getVal(u, "username"), getVal(u, "password"),
                                            getVal(u, "email"), role);
                    if (userId == -1) {
                        conn.rollback();
                        result.put("success", "false");
                        result.put("error", "Failed to create user account");
                        results.add(result);
                        continue;
                    }

                    // Insert into role-specific table
                    boolean inserted = false;
                    switch (role) {
                        case "student":
                            inserted = insertStudent(conn, userId, u);
                            break;
                        case "teacher":
                            inserted = insertTeacher(conn, userId, u);
                            break;
                        case "parent":
                            inserted = insertParent(conn, userId, u);
                            break;
                        case "admin":
                            inserted = insertAdmin(conn, userId, u);
                            break;
                    }

                    if (inserted) {
                        conn.commit();
                        result.put("success", "true");
                        result.put("error", "");
                    } else {
                        conn.rollback();
                        result.put("success", "false");
                        result.put("error", "Failed to create " + role + " profile");
                    }

                } catch (Exception e) {
                    try { conn.rollback(); } catch (SQLException ex) {}
                    result.put("success", "false");
                    result.put("error", e.getMessage() != null ? e.getMessage() : "Unknown error");
                }
                results.add(result);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            SQLConnection.closeResources(conn);
        }

        out.print(toJsonArray(results));
        out.flush();
    }

    // ========== DB CHECKS ==========

    private boolean usernameOrEmailExists(Connection conn, String username, String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ? OR email = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private boolean rollNumberExists(Connection conn, String rollNumber) throws SQLException {
        String sql = "SELECT COUNT(*) FROM students WHERE roll_number = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rollNumber);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private boolean employeeIdExists(Connection conn, String employeeId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM teachers WHERE employee_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    // ========== INSERT USER ==========

    private int insertUser(Connection conn, String username, String password, String email, String role)
            throws SQLException {
        String sql = "INSERT INTO users(username, password, email, role) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, email);
            ps.setString(4, role);
            int rows = ps.executeUpdate();
            if (rows == 0) return -1;
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    // ========== INSERT STUDENT ==========

    private boolean insertStudent(Connection conn, int userId, Map<String, String> u) throws SQLException {
        String sql = "INSERT INTO students(user_id, roll_number, first_name, last_name, date_of_birth, gender, phone, address, class_id, section, admission_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, getVal(u, "roll_number"));
            ps.setString(3, getVal(u, "first_name"));
            ps.setString(4, getVal(u, "last_name"));

            String dob = getVal(u, "dob");
            if (!dob.isEmpty()) {
                ps.setDate(5, java.sql.Date.valueOf(dob));
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setString(6, getVal(u, "gender"));
            ps.setString(7, emptyToNull(getVal(u, "phone")));
            ps.setString(8, emptyToNull(getVal(u, "address")));

            String className = getVal(u, "class_name");
            String sectionVal = getVal(u, "section");
            if (!className.isEmpty()) {
                int classId = resolveClassId(conn, className, sectionVal);
                if (classId > 0) ps.setInt(9, classId);
                else ps.setNull(9, Types.INTEGER);
            } else {
                ps.setNull(9, Types.INTEGER);
            }

            ps.setString(10, emptyToNull(sectionVal));
            
            String admDate = getVal(u, "admission_date");
            if (!admDate.isEmpty()) {
                ps.setDate(11, java.sql.Date.valueOf(admDate));
            } else {
                ps.setNull(11, Types.DATE);
            }

            return ps.executeUpdate() > 0;
        }
    }

    // ========== INSERT TEACHER ==========

    private boolean insertTeacher(Connection conn, int userId, Map<String, String> u) throws SQLException {
        String sql = "INSERT INTO teachers(user_id, employee_id, first_name, last_name, phone, address, subject_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, getVal(u, "employee_id"));
            ps.setString(3, getVal(u, "first_name"));
            ps.setString(4, getVal(u, "last_name"));
            ps.setString(5, emptyToNull(getVal(u, "phone")));
            ps.setString(6, emptyToNull(getVal(u, "address")));

            String subjectVal = getVal(u, "subject");
            if (!subjectVal.isEmpty()) {
                try {
                    ps.setInt(7, Integer.parseInt(subjectVal));
                } catch (NumberFormatException e) {
                    int subjectId = resolveSubjectId(conn, subjectVal);
                    if (subjectId > 0) ps.setInt(7, subjectId);
                    else ps.setNull(7, Types.INTEGER);
                }
            } else {
                ps.setNull(7, Types.INTEGER);
            }

            return ps.executeUpdate() > 0;
        }
    }

    // ========== INSERT PARENT ==========

    private boolean insertParent(Connection conn, int userId, Map<String, String> u) throws SQLException {
        String sql = "INSERT INTO parents(user_id, first_name, last_name, phone, email, address, relationship_to_student) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, getVal(u, "first_name"));
            ps.setString(3, getVal(u, "last_name"));
            ps.setString(4, emptyToNull(getVal(u, "phone")));
            ps.setString(5, getVal(u, "email"));
            ps.setString(6, emptyToNull(getVal(u, "address")));
            ps.setString(7, getVal(u, "relationship"));
            int rows = ps.executeUpdate();

            if (rows > 0) {
                // Fetch parent_id
                int parentId = getParentIdByUserId(conn, userId);
                if (parentId > 0) {
                    linkStudents(conn, parentId, getVal(u, "student_roll_numbers"));
                }
                return true;
            }
            return false;
        }
    }

    private int getParentIdByUserId(Connection conn, int userId) throws SQLException {
        String sql = "SELECT parent_id FROM parents WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    private void linkStudents(Connection conn, int parentId, String rollNumbers) throws SQLException {
        if (rollNumbers == null || rollNumbers.trim().isEmpty()) return;

        String[] rolls = rollNumbers.split("[,;\\s]+");
        String linkSql = "INSERT INTO student_parents(student_id, parent_id) VALUES (?, ?)";
        String findStudentSql = "SELECT student_id FROM students WHERE roll_number = ?";

        try (PreparedStatement findPs = conn.prepareStatement(findStudentSql);
             PreparedStatement linkPs = conn.prepareStatement(linkSql)) {
            for (String roll : rolls) {
                roll = roll.trim();
                if (roll.isEmpty()) continue;
                findPs.setString(1, roll);
                try (ResultSet rs = findPs.executeQuery()) {
                    if (rs.next()) {
                        int studentId = rs.getInt(1);
                        linkPs.setInt(1, studentId);
                        linkPs.setInt(2, parentId);
                        linkPs.addBatch();
                    }
                }
            }
            linkPs.executeBatch();
        }
    }

    // ========== INSERT ADMIN ==========

    private boolean insertAdmin(Connection conn, int userId, Map<String, String> u) throws SQLException {
        String sql = "INSERT INTO admins(user_id, first_name, last_name, phone, address) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, getVal(u, "first_name"));
            ps.setString(3, getVal(u, "last_name"));
            ps.setString(4, emptyToNull(getVal(u, "phone")));
            ps.setString(5, emptyToNull(getVal(u, "address")));
            return ps.executeUpdate() > 0;
        }
    }

    // ========== RESOLVERS ==========

    private int resolveClassId(Connection conn, String className, String section) throws SQLException {
        String sql;
        if (section != null && !section.trim().isEmpty()) {
            sql = "SELECT class_id FROM classes WHERE class_name = ? AND section = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, className.trim());
                ps.setString(2, section.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } else {
            sql = "SELECT class_id FROM classes WHERE class_name = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, className.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private int resolveSubjectId(Connection conn, String subjectName) throws SQLException {
        String sql = "SELECT subject_id FROM subjects WHERE subject_name LIKE ? OR subject_code LIKE ? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + subjectName + "%");
            ps.setString(2, "%" + subjectName + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    // ========== UTILITIES ==========

    private String getVal(Map<String, String> row, String key) {
        String v = row.get(key);
        return (v == null) ? "" : v.trim();
    }

    private String emptyToNull(String val) {
        return (val == null || val.trim().isEmpty()) ? null : val.trim();
    }

    // ========== JSON PARSING ==========

    private String asString(Object val) {
        return (val == null) ? "" : String.valueOf(val).trim();
    }

    private List<Map<String, String>> asUserRows(Object usersObj) {
        List<Map<String, String>> rows = new ArrayList<>();
        if (!(usersObj instanceof List<?>)) return rows;

        List<?> list = (List<?>) usersObj;
        for (Object item : list) {
            if (!(item instanceof Map<?, ?>)) continue;
            Map<?, ?> obj = (Map<?, ?>) item;
            Map<String, String> row = new LinkedHashMap<>();
            for (Map.Entry<?, ?> entry : obj.entrySet()) {
                String key = (entry.getKey() == null) ? "" : String.valueOf(entry.getKey());
                String value = (entry.getValue() == null) ? "" : String.valueOf(entry.getValue());
                row.put(key, value);
            }
            rows.add(row);
        }
        return rows;
    }

    private static final class JsonMiniParser {
        private final String s;
        private int i = 0;

        private JsonMiniParser(String s) {
            this.s = (s == null) ? "" : s;
        }

        static Map<String, Object> parseObject(String json) {
            JsonMiniParser p = new JsonMiniParser(json);
            Object val = p.parseValue();
            p.skipWs();
            if (p.i != p.s.length() || !(val instanceof Map<?, ?>)) {
                throw new IllegalArgumentException("Invalid JSON object");
            }
            @SuppressWarnings("unchecked")
            Map<String, Object> map = (Map<String, Object>) val;
            return map;
        }

        private Object parseValue() {
            skipWs();
            if (i >= s.length()) throw new IllegalArgumentException("Unexpected end of JSON");
            char c = s.charAt(i);
            if (c == '{') return parseObjectInternal();
            if (c == '[') return parseArray();
            if (c == '"') return parseString();
            if (c == 't' || c == 'f') return parseBoolean();
            if (c == 'n') return parseNull();
            if (c == '-' || Character.isDigit(c)) return parseNumber();
            throw new IllegalArgumentException("Unexpected token");
        }

        private Map<String, Object> parseObjectInternal() {
            expect('{');
            Map<String, Object> map = new LinkedHashMap<>();
            skipWs();
            if (peek('}')) {
                i++;
                return map;
            }
            while (true) {
                String key = parseString();
                skipWs();
                expect(':');
                Object value = parseValue();
                map.put(key, value);
                skipWs();
                if (peek(',')) {
                    i++;
                    continue;
                }
                expect('}');
                return map;
            }
        }

        private List<Object> parseArray() {
            expect('[');
            List<Object> list = new ArrayList<>();
            skipWs();
            if (peek(']')) {
                i++;
                return list;
            }
            while (true) {
                list.add(parseValue());
                skipWs();
                if (peek(',')) {
                    i++;
                    continue;
                }
                expect(']');
                return list;
            }
        }

        private String parseString() {
            expect('"');
            StringBuilder out = new StringBuilder();
            while (i < s.length()) {
                char c = s.charAt(i++);
                if (c == '"') return out.toString();
                if (c == '\\') {
                    if (i >= s.length()) throw new IllegalArgumentException("Invalid escape");
                    char e = s.charAt(i++);
                    switch (e) {
                        case '"': out.append('"'); break;
                        case '\\': out.append('\\'); break;
                        case '/': out.append('/'); break;
                        case 'b': out.append('\b'); break;
                        case 'f': out.append('\f'); break;
                        case 'n': out.append('\n'); break;
                        case 'r': out.append('\r'); break;
                        case 't': out.append('\t'); break;
                        case 'u':
                            if (i + 4 > s.length()) throw new IllegalArgumentException("Invalid unicode escape");
                            String hex = s.substring(i, i + 4);
                            out.append((char) Integer.parseInt(hex, 16));
                            i += 4;
                            break;
                        default:
                            throw new IllegalArgumentException("Invalid escape");
                    }
                } else {
                    out.append(c);
                }
            }
            throw new IllegalArgumentException("Unterminated string");
        }

        private Object parseBoolean() {
            if (s.startsWith("true", i)) {
                i += 4;
                return Boolean.TRUE;
            }
            if (s.startsWith("false", i)) {
                i += 5;
                return Boolean.FALSE;
            }
            throw new IllegalArgumentException("Invalid boolean");
        }

        private Object parseNull() {
            if (s.startsWith("null", i)) {
                i += 4;
                return null;
            }
            throw new IllegalArgumentException("Invalid null");
        }

        private Object parseNumber() {
            int start = i;
            if (peek('-')) i++;
            while (i < s.length() && Character.isDigit(s.charAt(i))) i++;
            if (peek('.')) {
                i++;
                while (i < s.length() && Character.isDigit(s.charAt(i))) i++;
            }
            if (peek('e') || peek('E')) {
                i++;
                if (peek('+') || peek('-')) i++;
                while (i < s.length() && Character.isDigit(s.charAt(i))) i++;
            }
            String num = s.substring(start, i);
            try {
                if (num.contains(".") || num.contains("e") || num.contains("E")) {
                    return Double.parseDouble(num);
                }
                return Long.parseLong(num);
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Invalid number");
            }
        }

        private void skipWs() {
            while (i < s.length()) {
                char c = s.charAt(i);
                if (c == ' ' || c == '\n' || c == '\r' || c == '\t') i++;
                else break;
            }
        }

        private void expect(char expected) {
            skipWs();
            if (i >= s.length() || s.charAt(i) != expected) {
                throw new IllegalArgumentException("Expected " + expected);
            }
            i++;
        }

        private boolean peek(char c) {
            return i < s.length() && s.charAt(i) == c;
        }
    }

    // ========== JSON OUTPUT ==========

    private String toJsonArray(List<Map<String, String>> rows) {
        StringBuilder jb = new StringBuilder("[");
        for (int i = 0; i < rows.size(); i++) {
            if (i > 0) jb.append(",");
            jb.append("{");
            Map<String, String> row = rows.get(i);
            int j = 0;
            for (Map.Entry<String, String> entry : row.entrySet()) {
                if (j > 0) jb.append(",");
                jb.append("\"").append(escapeJson(entry.getKey())).append("\":\"")
                  .append(escapeJson(entry.getValue())).append("\"");
                j++;
            }
            jb.append("}");
        }
        jb.append("]");
        return jb.toString();
    }

    private String escapeJson(String val) {
        if (val == null) return "";
        return val.replace("\\", "\\\\").replace("\"", "\\\"")
                  .replace("\n", "\\n").replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
