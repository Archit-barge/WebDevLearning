package com.seh.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import java.util.regex.Pattern;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import com.seh.model.User;
import com.seh.util.SQLConnection;

@WebServlet("/parseUploadFile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 5,
    maxFileSize = 1024 * 1024 * 50,
    maxRequestSize = 1024 * 1024 * 500
)
public class ParseUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
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

            String role = request.getParameter("role");
            if (role == null || role.trim().isEmpty()) {
                response.setStatus(400);
                out.print("[{\"error\":\"Role parameter is required\"}]");
                return;
            }
            role = role.trim().toLowerCase(Locale.ROOT);
            if (!Arrays.asList("student", "teacher", "parent", "admin").contains(role)) {
                response.setStatus(400);
                out.print("[{\"error\":\"Invalid role\"}]");
                return;
            }

            Part filePart;
            try {
                filePart = request.getPart("file");
            } catch (IllegalStateException e) {
                response.setStatus(400);
                out.print("[{\"error\":\"Uploaded file is too large or request multipart data is invalid\"}]");
                return;
            }
            if (filePart == null || filePart.getSize() == 0) {
                response.setStatus(400);
                out.print("[{\"error\":\"No file uploaded\"}]");
                return;
            }

            String fileName = filePart.getSubmittedFileName();
            if (fileName == null || fileName.trim().isEmpty()) {
                fileName = getFileName(filePart);
            }
            int dot = (fileName != null) ? fileName.lastIndexOf('.') : -1;
            if (dot < 0 || dot == fileName.length() - 1) {
                response.setStatus(400);
                out.print("[{\"error\":\"Unsupported file type. Use .csv, .xls, or .xlsx\"}]");
                return;
            }
            String ext = fileName.substring(dot + 1).toLowerCase(Locale.ROOT);

            List<Map<String, String>> rows;
            try {
                if ("csv".equals(ext)) {
                    rows = parseCsv(filePart.getInputStream());
                } else if ("xls".equals(ext)) {
                    rows = parseExcel(filePart.getInputStream(), false);
                } else if ("xlsx".equals(ext)) {
                    rows = parseExcel(filePart.getInputStream(), true);
                } else {
                    response.setStatus(400);
                    out.print("[{\"error\":\"Unsupported file type. Use .csv, .xls, or .xlsx\"}]");
                    return;
                }
            } catch (Throwable e) {
                e.printStackTrace();
                response.setStatus(500);
                out.print("[{\"error\":\"Failed to parse file: " + escapeJson(e.getMessage()) + "\"}]");
                return;
            }

            // Validate each row
            Set<String> seenUsernames = new HashSet<>();
            Set<String> seenEmails = new HashSet<>();
            Set<String> seenRollNumbers = new HashSet<>();
            Set<String> seenEmployeeIds = new HashSet<>();
            Set<String> existingUsernames = new HashSet<>();
            Set<String> existingEmails = new HashSet<>();
            Set<String> existingRollNumbers = new HashSet<>();
            Set<String> existingEmployeeIds = new HashSet<>();
            List<Map<String, String>> result = new ArrayList<>();

            loadExistingKeys(role, existingUsernames, existingEmails, existingRollNumbers, existingEmployeeIds);

            for (Map<String, String> row : rows) {
                validateRow(
                    row,
                    role,
                    seenUsernames,
                    seenEmails,
                    seenRollNumbers,
                    seenEmployeeIds,
                    existingUsernames,
                    existingEmails,
                    existingRollNumbers,
                    existingEmployeeIds
                );
                result.add(row);
            }

            // Output JSON
            out.print(toJson(result));
            out.flush();
        } catch (Throwable e) {
            e.printStackTrace();
            response.setStatus(500);
            out.print("[{\"error\":\"Internal server error while scanning file\"}]");
            out.flush();
        }
    }

    // ========== VALIDATION ==========

    private void validateRow(Map<String, String> row, String role,
                             Set<String> seenUsernames, Set<String> seenEmails,
                             Set<String> seenRollNumbers, Set<String> seenEmployeeIds,
                             Set<String> existingUsernames, Set<String> existingEmails,
                             Set<String> existingRollNumbers, Set<String> existingEmployeeIds) {
        List<String> errors = new ArrayList<>();

        // Common required fields
        String username = getVal(row, "username");
        String password = getVal(row, "password");
        String email = getVal(row, "email");
        String firstName = getVal(row, "first_name");
        String lastName = getVal(row, "last_name");

        if (username.isEmpty()) errors.add("Username is required");
        if (password.isEmpty()) errors.add("Password is required");
        if (email.isEmpty()) errors.add("Email is required");
        else if (!EMAIL_PATTERN.matcher(email).matches()) errors.add("Invalid email format");
        if (firstName.isEmpty()) errors.add("First Name is required");
        if (lastName.isEmpty()) errors.add("Last Name is required");

        // Phone validation (optional but must be 10 digits if provided)
        String phone = getVal(row, "phone");
        if (!phone.isEmpty() && !phone.matches("\\d{10}")) {
            errors.add("Phone must be exactly 10 digits");
        }

        // Duplicate check within file
        if (!username.isEmpty()) {
            if (seenUsernames.contains(username.toLowerCase())) {
                errors.add("Duplicate username in file");
            } else {
                seenUsernames.add(username.toLowerCase());
            }
        }
        if (!email.isEmpty()) {
            if (seenEmails.contains(email.toLowerCase())) {
                errors.add("Duplicate email in file");
            } else {
                seenEmails.add(email.toLowerCase());
            }
        }
        if (!username.isEmpty() && existingUsernames.contains(username.toLowerCase())) {
            errors.add("Username already exists in database");
        }
        if (!email.isEmpty() && existingEmails.contains(email.toLowerCase())) {
            errors.add("Email already exists in database");
        }

        // Role-specific required fields
        switch (role) {
            case "student":
                String rollNumber = getVal(row, "roll_number");
                if (rollNumber.isEmpty()) errors.add("Roll Number is required");
                if (getVal(row, "dob").isEmpty()) errors.add("Date of Birth is required");
                if (getVal(row, "gender").isEmpty()) errors.add("Gender is required");
                if (!rollNumber.isEmpty()) {
                    String normalizedRoll = rollNumber.toLowerCase();
                    if (seenRollNumbers.contains(normalizedRoll)) {
                        errors.add("Duplicate roll number in file");
                    } else {
                        seenRollNumbers.add(normalizedRoll);
                    }
                    if (existingRollNumbers.contains(normalizedRoll)) {
                        errors.add("Roll number already exists in database");
                    }
                }
                break;
            case "teacher":
                String employeeId = getVal(row, "employee_id");
                if (employeeId.isEmpty()) errors.add("Employee ID is required");
                if (!employeeId.isEmpty()) {
                    String normalizedEmployeeId = employeeId.toLowerCase();
                    if (seenEmployeeIds.contains(normalizedEmployeeId)) {
                        errors.add("Duplicate employee ID in file");
                    } else {
                        seenEmployeeIds.add(normalizedEmployeeId);
                    }
                    if (existingEmployeeIds.contains(normalizedEmployeeId)) {
                        errors.add("Employee ID already exists in database");
                    }
                }
                break;
            case "parent":
                if (getVal(row, "relationship").isEmpty()) errors.add("Relationship is required");
                break;
            case "admin":
                // No extra required fields beyond common ones
                break;
        }

        if (errors.isEmpty()) {
            row.put("valid", "true");
            row.put("error", "");
        } else {
            row.put("valid", "false");
            row.put("error", String.join("; ", errors));
        }
    }

    private void loadExistingKeys(String role,
                                  Set<String> existingUsernames, Set<String> existingEmails,
                                  Set<String> existingRollNumbers, Set<String> existingEmployeeIds) {
        Connection conn = null;
        try {
            conn = SQLConnection.getConnection();
            if (conn == null) return;

            try (PreparedStatement ps = conn.prepareStatement("SELECT username, email FROM users");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String username = rs.getString("username");
                    String email = rs.getString("email");
                    if (username != null) existingUsernames.add(username.trim().toLowerCase());
                    if (email != null) existingEmails.add(email.trim().toLowerCase());
                }
            }

            if ("student".equals(role)) {
                try (PreparedStatement ps = conn.prepareStatement("SELECT roll_number FROM students");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String roll = rs.getString("roll_number");
                        if (roll != null) existingRollNumbers.add(roll.trim().toLowerCase());
                    }
                }
            } else if ("teacher".equals(role)) {
                try (PreparedStatement ps = conn.prepareStatement("SELECT employee_id FROM teachers");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String emp = rs.getString("employee_id");
                        if (emp != null) existingEmployeeIds.add(emp.trim().toLowerCase());
                    }
                }
            }
        } catch (Exception ignored) {
            // Do not block parsing if duplicate pre-check query fails.
        } finally {
            SQLConnection.closeResources(conn);
        }
    }

    // ========== CSV PARSING ==========

    private List<Map<String, String>> parseCsv(InputStream is) throws IOException {
        List<Map<String, String>> rows = new ArrayList<>();
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        String headerLine = reader.readLine();
        if (headerLine == null) return rows;

        String[] headers = parseCsvLine(headerLine);
        for (int i = 0; i < headers.length; i++) {
            headers[i] = normalizeHeader(headers[i].trim());
        }

        String line;
        while ((line = reader.readLine()) != null) {
            if (line.trim().isEmpty()) continue;
            String[] values = parseCsvLine(line);
            Map<String, String> row = new LinkedHashMap<>();
            for (int i = 0; i < headers.length; i++) {
                row.put(headers[i], i < values.length ? values[i].trim() : "");
            }
            rows.add(row);
        }
        reader.close();
        return rows;
    }

    /** RFC 4180 compliant CSV line parser — handles quoted fields with commas inside. */
    private String[] parseCsvLine(String line) {
        List<String> fields = new ArrayList<>();
        StringBuilder sb = new StringBuilder();
        boolean inQuotes = false;
        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (inQuotes) {
                if (c == '"') {
                    if (i + 1 < line.length() && line.charAt(i + 1) == '"') {
                        sb.append('"'); i++; // escaped quote ""
                    } else {
                        inQuotes = false; // closing quote
                    }
                } else {
                    sb.append(c);
                }
            } else {
                if (c == '"') {
                    inQuotes = true;
                } else if (c == ',') {
                    fields.add(sb.toString());
                    sb.setLength(0);
                } else {
                    sb.append(c);
                }
            }
        }
        fields.add(sb.toString());
        return fields.toArray(new String[0]);
    }

    // ========== EXCEL PARSING ==========

    private List<Map<String, String>> parseExcel(InputStream is, boolean isXlsx) throws IOException {
        List<Map<String, String>> rows = new ArrayList<>();
        Workbook workbook = isXlsx ? new XSSFWorkbook(is) : new HSSFWorkbook(is);
        if (workbook.getNumberOfSheets() == 0) {
            workbook.close();
            return rows;
        }
        Sheet sheet = workbook.getSheetAt(0);

        if (sheet.getPhysicalNumberOfRows() == 0) {
            workbook.close();
            return rows;
        }

        // Read header row
        Row headerRow = sheet.getRow(0);
        if (headerRow == null || headerRow.getLastCellNum() <= 0) {
            workbook.close();
            return rows;
        }

        String[] headers = new String[headerRow.getLastCellNum()];
        for (int i = 0; i < headerRow.getLastCellNum(); i++) {
            Cell cell = headerRow.getCell(i);
            String normalized = normalizeHeader(getCellValueAsString(cell));
            headers[i] = normalized.isEmpty() ? ("column_" + i) : normalized;
        }

        // Read data rows
        for (int r = 1; r <= sheet.getLastRowNum(); r++) {
            Row row = sheet.getRow(r);
            if (row == null) continue;

            boolean allEmpty = true;
            Map<String, String> rowMap = new LinkedHashMap<>();
            for (int c = 0; c < headers.length; c++) {
                String val = getCellValueAsString(row.getCell(c)).trim();
                rowMap.put(headers[c], val);
                if (!val.isEmpty()) allEmpty = false;
            }
            if (!allEmpty) rows.add(rowMap);
        }

        workbook.close();
        return rows;
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null) return "";
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                    return sdf.format(cell.getDateCellValue());
                }
                double num = cell.getNumericCellValue();
                if (num == Math.floor(num)) {
                    return String.valueOf((long) num);
                }
                return String.valueOf(num);
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                try { return String.valueOf(cell.getStringCellValue()); }
                catch (Exception e) {
                    try { return String.valueOf((long) cell.getNumericCellValue()); }
                    catch (Exception e2) { return ""; }
                }
            default:
                return "";
        }
    }

    // ========== UTILITIES ==========

    /**
     * Normalize Excel/CSV headers to match our internal key format.
     * e.g., "First Name" -> "first_name", "DOB" -> "dob", "Roll Number" -> "roll_number"
     */
    private String normalizeHeader(String header) {
        if (header == null) return "";
        header = header.trim().toLowerCase()
                .replace(" ", "_")
                .replace("date_of_birth", "dob")
                .replace("student_roll_numbers", "student_roll_numbers");
        return header;
    }

    private String getVal(Map<String, String> row, String key) {
        String v = row.get(key);
        return (v == null) ? "" : v.trim();
    }

    private String getFileName(Part part) {
        if (part == null) return "unknown";
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null || contentDisp.isEmpty()) return "unknown";
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "unknown";
    }

    // ========== JSON OUTPUT ==========

    private String toJson(List<Map<String, String>> rows) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < rows.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("{");
            Map<String, String> row = rows.get(i);
            int j = 0;
            for (Map.Entry<String, String> entry : row.entrySet()) {
                if (j > 0) sb.append(",");
                sb.append("\"").append(escapeJson(entry.getKey())).append("\":\"")
                  .append(escapeJson(entry.getValue())).append("\"");
                j++;
            }
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String val) {
        if (val == null) return "";
        return val.replace("\\", "\\\\").replace("\"", "\\\"")
                  .replace("\n", "\\n").replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
