
import java.sql.*; // JDBC stuff.
import java.util.ArrayList;
import java.util.Properties;

public class PortalConnection {

    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/portal";
    static final String USERNAME = "postgres";
    static final String PASSWORD = "asda";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://ate.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){

        String query = "INSERT INTO Registrations VALUES (?,?)";

        try(PreparedStatement ps = conn.prepareStatement(query);) {
            ps.setString(1,student);
            ps.setString(2,courseCode);
            ps.executeUpdate();
            ps.close();
            return "{\"success\":true}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        String query1 = "SELECT FROM Registrations WHERE student=? AND course=?";

        try(PreparedStatement ps = conn.prepareStatement(query1);) {
            ps.setString(1, student);
            ps.setString(2, courseCode);
            ResultSet rs = ps.executeQuery();
            if(!rs.next()) {
                return "{\"success\":false, \"error\":\"not registered on course\"}";
            }
            ps.close();


        } catch(SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        String query = "DELETE FROM Registrations WHERE student=? AND course=?";

        try(PreparedStatement ps = conn.prepareStatement(query);) {
            ps.setString(1,student);
            ps.setString(2,courseCode);
            ps.executeUpdate();
            ps.close();
            return "{\"success\":true}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{


        try(PreparedStatement st = conn.prepareStatement(
                // replace this with something more useful
                "WITH Finished as (SELECT json_agg(jsonb_build_object('course',Courses.name,'code',Courses.code," +
                        "'grade',grade,'credits',Courses.credits)) AS finishedArray FROM FinishedCourses,Courses " +
                        "WHERE student = ? AND FinishedCourses.course = Courses.Code), Registered AS " +
                        "(SELECT json_agg(jsonb_build_object('course',Courses.name,'code',Courses.code,'status',status)) AS " +
                        "registeredArray FROM Registrations,Courses WHERE student = ? AND Registrations.course = Courses.Code) " +
                        "SELECT jsonb_build_object('student',idnr,'name',name,'login',login,'program',program,'branch'," +
                        "branch,'finished',finishedArray,'registered',registeredArray,'seminarCourses',seminarCourses," +
                        "'mathCredits',mathCredits,'researchCredits',researchCredits,'totalCredits',totalCredits," +
                        "'canGraduate',qualified) AS jsondata FROM BasicInformation,PathToGraduation,Finished," +
                        "Registered WHERE BasicInformation.idnr=? AND BasicInformation.idnr = PathToGraduation.student"
        );){

            st.setString(1, student);
            st.setString(2, student);
            st.setString(3, student);


            ResultSet rs = st.executeQuery();

            if(rs.next())
                return rs.getString("jsondata");
            else
                return "{\"student\":\"does not exist :(\"}";

        }



        /*

        ArrayList basicInfo = new ArrayList<String>();
        ArrayList<String[]> finished = new ArrayList<String[]>();
        ArrayList<String[]> registered = new ArrayList<String[]>();
        ArrayList pathToGraduation = new ArrayList<>();
        ArrayList<String> coursesName = new ArrayList<>();
        ArrayList<String> coursesCode = new ArrayList<>();
        ArrayList<Integer> waitingList = new ArrayList<Integer>();
        String query = "SELECT * FROM BasicInformation WHERE BasicInformation.idnr = ?";
        String query2 = "SELECT * FROM FinishedCourses WHERE student=?";
        String query3 = "SELECT * FROM Registrations WHERE student=?";
        String query4 = "SELECT * FROM PathToGraduation WHERE student=?";
        String query5 = "SELECT * FROM Courses";
        String query6 = "SELECT * FROM WaitingList WHERE student=? AND course=?";

        try(PreparedStatement ps = conn.prepareStatement(query);) {
            ps.setString(1,student);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                basicInfo.add(rs.getString(1));
                basicInfo.add(rs.getString(2));
                basicInfo.add(rs.getString(3));
                basicInfo.add(rs.getString(4));
                basicInfo.add(rs.getString(5));
            }
            ps.close();
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        try(PreparedStatement ps = conn.prepareStatement(query2);) {
            ps.setString(1,student);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                String[] s = {rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4)};
                finished.add(s);
            }
            ps.close();
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        try(PreparedStatement ps = conn.prepareStatement(query3);) {
            ps.setString(1,student);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                String[] s = {rs.getString(1),rs.getString(2),rs.getString(3)};
                registered.add(s);
            }
            ps.close();
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        try(PreparedStatement ps = conn.prepareStatement(query4);) {
            ps.setString(1,student);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                String[] s = {rs.getString(6),rs.getString(4),rs.getString(5),rs.getString(2),rs.getString(7)};
                finished.add(s);
            }
            ps.close();
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        try(PreparedStatement ps = conn.prepareStatement(query5);) {

            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                coursesName.add(rs.getString(1));
                coursesCode.add(rs.getString(2));
            }
            ps.close();
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }

        for (int i = 0; i < registered.size(); i++) {
            String[] touple = registered.get(i);
            String studentt = touple[0];
            String course = touple[1];

            try(PreparedStatement ps = conn.prepareStatement(query6);) {
                ps.setString(1,studentt);
                ps.setString(2,course);
                ResultSet rs = ps.executeQuery();
                while(rs.next()) {
                    waitingList.add(Integer.parseInt(rs.getString(3)));
                }
                ps.close();
            } catch (SQLException e) {
                return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
            }

        }


        //Building JSON

        String json_basic = "{\"student\": \"" + basicInfo.get(0) + "\", \"name\": \"" + basicInfo.get(1) + "\", \"login\": \"" + basicInfo.get(2) + "\", \"program\": \"" + basicInfo.get(3) + "\", \"branch\": \"" + basicInfo.get(4) + "\",";

        String json_finished = "\"finished\": [";
        for (int i = 0; i < finished.size(); i++) {
            if (i > 0) {
                json_finished = json_finished + ",";
            }
            String[] touple = finished.get(i);
            String courseName = coursesName.get(coursesCode.indexOf(touple[i]));
            json_finished = json_finished + "{\"course\": \"" + courseName + "\", \"code\": \"" + touple[1] + "\", \"credits\": " + touple[3]+ ", \"grade\": \"" + touple[2] + "\", }";
        }
        json_finished = json_finished + "],";

        String json_registered = "\"registered\": [";
        for (int i = 0; i < registered.size(); i++) {
            if (i > 0) {
                json_registered = json_registered + ",";
            }
            String[] touple = registered.get(i);
            String courseName = coursesName.get(coursesCode.indexOf(touple[1]));
            int position = waitingList.get(i);

            json_registered = json_registered + "{\"course\": \"" + courseName + "\", \"code\": \"" + touple[1] + "\", \"status\": \"" + touple[2] + "\", \"position\": " + position + ", }";
        }
        json_registered = json_registered + "],";

        String json_path = "{\"seminarCourses\": " + pathToGraduation.get(0) + ", \"mathCredits\": " + pathToGraduation.get(1) + ", \"researchCredits\": " + pathToGraduation.get(2) + ", \"totalCredits\": " + pathToGraduation.get(3) + ", \"canGraduate\": " + pathToGraduation.get(4) + "}";


        String json = json_basic + json_finished + json_registered + json_path;

        return json;

*/

    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
        String message = e.getMessage();
        int ix = message.indexOf('\n');
        if (ix > 0) message = message.substring(0, ix);
        message = message.replace("\"","\\\"");
        return message;
    }
}