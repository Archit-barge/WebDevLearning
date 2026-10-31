<%@ page import="java.util.*" %>

<html>
<head>
<title>Posted Events</title>
<style>
table { width:90%; margin:auto; border-collapse: collapse; }
th, td { padding:10px; border:1px solid #ccc; }
</style>
</head>

<body>

<h2 align="center">Posted Events</h2>

<table>
<tr>
    <th>Title</th>
    <th>Date</th>
    <th>Template</th>
</tr>

<%
List<Map<String,Object>> events =
    (List<Map<String,Object>>)request.getAttribute("events");

for(Map<String,Object> e : events) {
%>
<tr>
    <td><%=e.get("title")%></td>
    <td><%=e.get("date")%></td>
    <td>
        <%= (int)e.get("template")==1 ? "Festival" :
             (int)e.get("template")==2 ? "Holiday" : "Announcement" %>
    </td>
</tr>
<% } %>

</table>

</body>
</html>
