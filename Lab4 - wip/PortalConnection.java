
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
      
      String query = "INSERT INTO Registered VALUES (?,?)";

      try(PreparedStatement ps = conn.prepareStatement(query);) {
          ps.setInt(1,Integer.parseInt(student));
          ps.setString(2,courseCode);
          ps.executeUpdate();
          ps.close();
      } catch (SQLException e) {
          return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }
      return "{\"success\":true}";
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
      String query = "DELETE FROM Registered WHERE student=? AND course=?";

      try(PreparedStatement ps = conn.prepareStatement(query);) {
          ps.setInt(1,Integer.parseInt(student));
          ps.setString(2,courseCode);
          ps.executeUpdate();
          ps.close();
      } catch (SQLException e) {
          return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }
      return "{\"success\":true}";
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{

        //BIG DOUBT THIS WORKS
        
        Arraylist basicInfo = new ArrayList<>();
        Arraylist finished = new ArrayList<>();
        Arraylist registered = new ArrayList<>();
        ArrayList pathToGraduation = new ArrayList<>();
        ArrayList coursesName = new ArrayList<>();
        ArrayList coursesCode = new ArrayList<>();
        ArrayList position = new ArrayList<>();
        String query = "SELECT * FROM BasicInformation WHERE idnr=?";
        String query2 = "SELECT * FROM FinishedCourses WHERE idnr=?";
        String query3 = "SELECT * FROM Registrations WHERE idnr=?";
        String query4 = "SELECT * FROM PathToGraduation WHERE idnr=?";
        String query5 = "SELECT * FROM Courses";
        String query6 = "SELECT * FROM WaitingList WHERE student=? AND course=?";

        try(PreparedStatement ps = conn.prepareStatement(query);) {
            ps.setInt(1,Integer.parseInt(student));
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
            ps.setInt(1,Integer.parseInt(student));
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                finished.add([rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4)]);
            }
            ps.close();
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        } 

        try(PreparedStatement ps = conn.prepareStatement(query3);) {
            ps.setInt(1,Integer.parseInt(student));
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                registered.add([rs.getString(1),rs.getString(2),rs.getString(3)]);
            }
            ps.close();
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        } 

        try(PreparedStatement ps = conn.prepareStatement(query4);) {
            ps.setInt(1,Integer.parseInt(student));
            ResultSet rs = ps.executeQuery();
            if(rs.next()) {
                finished.add([rs.getString(6),rs.getString(4),rs.getString(5),rs.getString(2),rs.getString(7)]);
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

        for (i = 0; i < registered.length(); i++) {
            String[] touple = registered.get(i);
            String student = touple(0);
            String course = touple(1);

            try(PreparedStatement ps = conn.prepareStatement(query6);) {
                ps.setInt(1,Integer.parseInt(student));
                ps.setString(2,course);
                ResultSet rs = ps.executeQuery();
                while(rs.next()) {
                    waitingList.add(rs.getString(3));
                }
                ps.close();          
                } catch (SQLException e) {
                    return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
                } 

        }


        //Building JSON
        
        String json_basic = "{\"student\": \"" + basicInfo.get(0) + "\", \"name\": \"" + basicInfo.get(1) + "\", \"login\": \"" + basicInfo.get(2) + "\", \"program\": \"" + basicInfo.get(3) + "\", \"branch\": \"" + basicInfo.get(4) + "\",";

        String json_finished = "\"finished\": [";
        for (i = 0; i < finished.length(); i++) {
            if (i > 0) {
                json_finished = json_finished + ",";
            }
            String[] touple = finished.get(i);
            String courseName = coursesName.get(coursesCode.indexOf(touple(1)));
            json_finished = json_finished + "{\"course\": \"" + courseName + "\", \"code\": \"" + touple(1) + "\", \"credits\": " + touple(3) + ", \"grade\": \"" + touple(2) + "\", }";
        }
        json_finished = json_finished + "],";

        String json_registered = "\"registered\": [";
        for (i = 0; i < registered.length(); i++) {
            if (i > 0) {
                json_registered = json_registered + ",";
            }
            String[] touple = registered.get(i);
            String courseName = coursesName.get(coursesCode.indexOf(touple(1)));
            Int position = waitingList.get(i);

            json_registered = json_registered + "{\"course\": \"" + courseName + "\", \"code\": \"" + touple(1) + "\", \"status\": \"" + touple(2) + "\", \"position\": " + position + ", }";
        }
        json_registered = json_registered + "],";

        String json_path = "{\"seminarCourses\": " + pathToGraduation.get(0) + ", \"mathCredits\": " + pathToGraduation.get(1) + ", \"researchCredits\": " + pathToGraduation.get(2) + ", \"totalCredits\": " + pathToGraduation.get(3) + ", \"canGraduate\": " + pathToGraduation.get(4) + "}";


        String json = json_basic + json_finished + json_registered + json_path;

        return json;


        /*
        try(PreparedStatement st = conn.prepareStatement(

            // replace this with something more useful
            "SELECT jsonb_build_object('student',idnr,'name',name) AS jsondata FROM BasicInformation WHERE idnr=?"
            );){
            
            st.setString(1, student);
            
            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
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