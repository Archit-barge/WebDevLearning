<%@ page import="java.sql.*, com.seh.util.SQLConnection, com.seh.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    int count = 0;

    if (user != null) {
        try (Connection conn = SQLConnection.getConnection()) {
            String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, user.getUserId());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    out.print(count);
%>
