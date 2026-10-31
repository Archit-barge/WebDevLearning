package com.seh.servlet;

import com.seh.util.SQLConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/teacher/EnterMarksServlet")
public class EnterMarksServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/teacher/enter_marks.jsp")
               .forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String classIdStr   = request.getParameter("classId");
        String subjectIdStr = request.getParameter("subjectId");
        String rowsStr      = request.getParameter("rows");
        String examType     = request.getParameter("examType");

        if(examType == null) examType = "ut";

        int classId   = Integer.parseInt(classIdStr);
        int subjectId = Integer.parseInt(subjectIdStr);
        int rows      = Integer.parseInt(rowsStr);

        try(Connection conn = SQLConnection.getConnection()){

            for(int i=1;i<=rows;i++){

                String studentIdStr = request.getParameter("studentId_"+i);
                if(studentIdStr == null) continue;

                int studentId = Integer.parseInt(studentIdStr);

                Integer mark1 = null;
                Integer mark2 = null;
                Float average = null;

                String firstName="";
                String lastName="";
                String subjectName="";

                // Fetch student name
                PreparedStatement ps1 = conn.prepareStatement(
                        "SELECT first_name,last_name FROM students WHERE student_id=?");
                ps1.setInt(1,studentId);

                ResultSet rs1 = ps1.executeQuery();
                if(rs1.next()){
                    firstName = rs1.getString("first_name");
                    lastName  = rs1.getString("last_name");
                }

                rs1.close();
                ps1.close();

                // Fetch subject name
                PreparedStatement ps2 = conn.prepareStatement(
                        "SELECT subject_name FROM subjects WHERE subject_id=?");
                ps2.setInt(1,subjectId);

                ResultSet rs2 = ps2.executeQuery();
                if(rs2.next()){
                    subjectName = rs2.getString("subject_name");
                }

                rs2.close();
                ps2.close();


                if(examType.equals("ut")){

                    String ut1Str = request.getParameter("ut1_"+i);
                    String ut2Str = request.getParameter("ut2_"+i);

                    if(ut1Str!=null && !ut1Str.isEmpty())
                        mark1 = Integer.parseInt(ut1Str);

                    if(ut2Str!=null && !ut2Str.isEmpty())
                        mark2 = Integer.parseInt(ut2Str);

                }else{

                    String sem1Str = request.getParameter("sem1_"+i);
                    String sem2Str = request.getParameter("sem2_"+i);

                    if(sem1Str!=null && !sem1Str.isEmpty())
                        mark1 = Integer.parseInt(sem1Str);

                    if(sem2Str!=null && !sem2Str.isEmpty())
                        mark2 = Integer.parseInt(sem2Str);
                }


                if(mark1!=null && mark2!=null)
                    average = (mark1+mark2)/2f;
                else if(mark1!=null)
                    average = mark1.floatValue();
                else if(mark2!=null)
                    average = mark2.floatValue();


                PreparedStatement check = conn.prepareStatement(
                        "SELECT id FROM marks WHERE student_id=? AND subject_id=?");

                check.setInt(1,studentId);
                check.setInt(2,subjectId);

                ResultSet rs = check.executeQuery();

                if(rs.next()){

                    if(examType.equals("ut")){

                        PreparedStatement update = conn.prepareStatement(

                                "UPDATE marks SET ut1=?,ut2=?,average=?,first_name=?,last_name=?,subject_name=? WHERE student_id=? AND subject_id=?"
                        );

                        if(mark1!=null) update.setInt(1,mark1); else update.setNull(1,Types.INTEGER);
                        if(mark2!=null) update.setInt(2,mark2); else update.setNull(2,Types.INTEGER);
                        if(average!=null) update.setFloat(3,average); else update.setNull(3,Types.FLOAT);

                        update.setString(4,firstName);
                        update.setString(5,lastName);
                        update.setString(6,subjectName);

                        update.setInt(7,studentId);
                        update.setInt(8,subjectId);

                        update.executeUpdate();
                        update.close();

                    }else{

                        PreparedStatement update = conn.prepareStatement(

                                "UPDATE marks SET sem1=?,sem2=?,sem_average=?,first_name=?,last_name=?,subject_name=? WHERE student_id=? AND subject_id=?"
                        );

                        if(mark1!=null) update.setInt(1,mark1); else update.setNull(1,Types.INTEGER);
                        if(mark2!=null) update.setInt(2,mark2); else update.setNull(2,Types.INTEGER);
                        if(average!=null) update.setFloat(3,average); else update.setNull(3,Types.FLOAT);

                        update.setString(4,firstName);
                        update.setString(5,lastName);
                        update.setString(6,subjectName);

                        update.setInt(7,studentId);
                        update.setInt(8,subjectId);

                        update.executeUpdate();
                        update.close();
                    }

                }else{

                    if(examType.equals("ut")){

                        PreparedStatement insert = conn.prepareStatement(

                                "INSERT INTO marks(student_id,first_name,last_name,subject_id,subject_name,ut1,ut2,average) VALUES(?,?,?,?,?,?,?,?)"
                        );

                        insert.setInt(1,studentId);
                        insert.setString(2,firstName);
                        insert.setString(3,lastName);
                        insert.setInt(4,subjectId);
                        insert.setString(5,subjectName);

                        if(mark1!=null) insert.setInt(6,mark1); else insert.setNull(6,Types.INTEGER);
                        if(mark2!=null) insert.setInt(7,mark2); else insert.setNull(7,Types.INTEGER);
                        if(average!=null) insert.setFloat(8,average); else insert.setNull(8,Types.FLOAT);

                        insert.executeUpdate();
                        insert.close();

                    }else{

                        PreparedStatement insert = conn.prepareStatement(

                                "INSERT INTO marks(student_id,first_name,last_name,subject_id,subject_name,sem1,sem2,sem_average) VALUES(?,?,?,?,?,?,?,?)"
                        );

                        insert.setInt(1,studentId);
                        insert.setString(2,firstName);
                        insert.setString(3,lastName);
                        insert.setInt(4,subjectId);
                        insert.setString(5,subjectName);

                        if(mark1!=null) insert.setInt(6,mark1); else insert.setNull(6,Types.INTEGER);
                        if(mark2!=null) insert.setInt(7,mark2); else insert.setNull(7,Types.INTEGER);
                        if(average!=null) insert.setFloat(8,average); else insert.setNull(8,Types.FLOAT);

                        insert.executeUpdate();
                        insert.close();
                    }

                }

                rs.close();
                check.close();

            }

        }catch(Exception e){
            e.printStackTrace();
        }

        response.sendRedirect(
                request.getContextPath() +
                "/teacher/EnterMarksServlet?classId="+classId+
                "&subjectId="+subjectId+
                "&examType="+examType
        );
    }
}