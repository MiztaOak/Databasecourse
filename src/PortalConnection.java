
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/portal";
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

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
        String query = "INSERT INTO Registrations VALUES (?,?);";
        try(PreparedStatement ps = conn.prepareStatement(query);){
            ps.setString(1,student);
            ps.setString(2,courseCode);
            ps.execute();
            ps.close();
            return "{\"success\":true}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        String query = "DELETE FROM Registrations WHERE student = ? AND course = ?;";
        try(PreparedStatement ps = conn.prepareStatement(query);){
            ps.setString(1,student);
            ps.setString(2,courseCode);
            int n = ps.executeUpdate();
            ps.close();
            if(n == 0)
                return "{\"success\":false, \"error\":\" Student " + student + " is not registered to the course " + courseCode + "\"}";
            else
                return "{\"success\":true}";
        }catch (SQLException e){
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{

        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "WITH Finished as (SELECT COALESCE(json_agg(jsonb_build_object('course',Courses.name,'code',Courses.code," +
                    "'grade',grade,'credits',Courses.credits)),'[]'::json) AS finishedArray FROM FinishedCourses,Courses " +
                    "WHERE student = ? AND FinishedCourses.course = Courses.Code), Registered AS " +
                    "(SELECT COALESCE(json_agg(jsonb_build_object('course',Courses.name,'code',Courses.code,'status',status)),'[]'::json)" +
                    "AS registeredArray FROM Registrations,Courses WHERE student = ? AND Registrations.course = Courses.Code) " +
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