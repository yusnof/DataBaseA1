
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "portal";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

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
      String query = "INSERT INTO Registered Values (? , ?);";
       try(PreparedStatement s = conn.prepareStatement(query);)
      {
        s.setString(1, student);
        s.setString(2, courseCode); 
        
        s.executeUpdate(); 
        return "{\"success\":true"+"\"}";
      } // here the output will be an error if we didnt register correctly. 
       catch (SQLException e) {
          return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }     
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
      String query = "DELETE FROM Registered WHERE (student = ? AND course = ?);";
       try(PreparedStatement s = conn.prepareStatement(query);)
      {
        s.setString(1, student);
        s.setString(2, courseCode); 
        s.executeUpdate(); 
        // here maybe we should test if its really correct but the trigger should catch this issue. 
        return "{\"success\":true"+ "\"}";
      } 
       catch (SQLException e) {
        return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }     
      
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "SELECT jsonb_build_object('student',idnr,'name',name) AS jsondata FROM BasicInformation WHERE idnr=?"
            );){
            
            st.setString(1, student);
            
            ResultSet rs = st.executeQuery();
            System.out.println(rs.getString("jsondata"));
            
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