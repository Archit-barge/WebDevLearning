package com.seh.servlet;

import jakarta.servlet.http.HttpServletRequest;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

final class TeacherTasksQueryHelper {

    private TeacherTasksQueryHelper() {
    }

    static final class Filters {
        Integer teacherId;
        Integer classId;
        Integer subjectId;
        String startDate;
        String endDate;
    }

    static Filters fromRequest(HttpServletRequest request) {
        Filters filters = new Filters();
        filters.teacherId = parsePositiveInt(request.getParameter("teacherId"));
        filters.classId = parsePositiveInt(request.getParameter("classId"));
        filters.subjectId = parsePositiveInt(request.getParameter("subjectId"));
        filters.startDate = parseIsoDate(request.getParameter("startDate"));
        filters.endDate = parseIsoDate(request.getParameter("endDate"));
        return filters;
    }

    static String buildSql(String selectClause, Filters filters) {
        StringBuilder sql = new StringBuilder(selectClause);
        sql.append(" WHERE 1=1 ");

        if (filters.teacherId != null) {
            sql.append(" AND t.teacher_id = ? ");
        }
        if (filters.classId != null) {
            sql.append(" AND t.class_id = ? ");
        }
        if (filters.subjectId != null) {
            sql.append(" AND t.subject_id = ? ");
        }

        if (filters.startDate != null && filters.endDate != null) {
            sql.append(" AND DATE(t.task_date) BETWEEN ? AND ? ");
        } else if (filters.startDate != null) {
            sql.append(" AND DATE(t.task_date) >= ? ");
        } else if (filters.endDate != null) {
            sql.append(" AND DATE(t.task_date) <= ? ");
        }

        sql.append(" ORDER BY t.task_date DESC");
        return sql.toString();
    }

    static int bindFilters(PreparedStatement ps, Filters filters) throws SQLException {
        int i = 1;
        if (filters.teacherId != null) {
            ps.setInt(i++, filters.teacherId);
        }
        if (filters.classId != null) {
            ps.setInt(i++, filters.classId);
        }
        if (filters.subjectId != null) {
            ps.setInt(i++, filters.subjectId);
        }
        if (filters.startDate != null && filters.endDate != null) {
            ps.setString(i++, filters.startDate);
            ps.setString(i++, filters.endDate);
        } else if (filters.startDate != null) {
            ps.setString(i++, filters.startDate);
        } else if (filters.endDate != null) {
            ps.setString(i++, filters.endDate);
        }
        return i - 1;
    }

    private static Integer parsePositiveInt(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String parseIsoDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim()).toString();
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
