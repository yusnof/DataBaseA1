public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();
   
         // Write your tests here. Add/remove calls to pause() as desired. 
         // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)
        // System.out.println(c.register("2222222222", "CCC333"));
        // pause();

        //1
         System.out.println("Test 1 - Fetching information");
         prettyPrint(c.getInfo("2222222222"));
         pause();

         //2
         System.out.println("Test 2 - Register and unregister");
         System.out.println(c.register("6666666666", "CCC111"));
         pause();

         prettyPrint(c.getInfo("6666666666"));
         pause();

         //3
         System.out.println("Test 3 - Register same student, expected error");
         System.out.println(c.register("6666666666", "CCC111"));
         pause();

         //4
         System.out.println("Test 4");
         c.getInfo("6666666666"); 
         System.out.println(c.unregister("6666666666", "CCC222"));
         System.out.println(c.unregister("6666666666", "CCC222"));
         pause();

         //5
         System.out.println("Test 5 - Register the student for a course that he/she does not have the prerequisites for, and check that an error is generated.");
         System.out.println(c.register("3333333333", "CCC444"));
         pause();

         // 6 Will not work ;D
         System.out.println("Test 6 - Unregister a student from a restricted course that he/she is registered to, and which has at least two students in the queue. Register the student again to the same course and check that the student gets the correct (last) position in the waiting list.");
         c.register("1111111111", "CCC777");
         c.register("2222222222", "CCC777");
         c.register("3333333333", "CCC777");
         c.unregister("3333333333", "CCC777");
         c.register("3333333333", "CCC777");
         prettyPrint(c.getInfo("3333333333"));
         pause();




      
      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.5.1.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
   
   
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}
