public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();

         /*
            Some notes to help:
            CCC222 - overfull course
            CCC333 - normal full course

            CCC444 - course with prereq
            CCC111 - standard course

            1111111111 - student that gets manipulated

          */

         // Write your tests here. Add/remove calls to pause() as desired. 
         // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)

          //show basic info
          prettyPrint(c.getInfo("1111111111"));
          pause();

          //register to normal course
          System.out.println(c.register("1111111111","CCC111"));
          prettyPrint(c.getInfo("1111111111"));
          pause();

          //try to register to course that is already registered to
          System.out.println(c.register("1111111111","CCC111"));
          pause();

          // unregister twice showing that the first work but the second one fails
          System.out.println(c.unregister("1111111111","CCC111"));
          System.out.println(c.unregister("1111111111","CCC111"));
          prettyPrint(c.getInfo("1111111111"));
          pause();

          //register for course lacking prerequisites and showing it fails
          System.out.println(c.register("1111111111","CCC444"));
          pause();

          //unregister student from a course that has at least two students waiting in line for and the reregister
          //for the course showing that your last in line now
          System.out.println(c.unregister("1111111111","CCC333"));
          System.out.println(c.register("1111111111","CCC333"));
          prettyPrint(c.getInfo("1111111111"));
          pause();

          //unregister and then reregister the student showing that they end up at the end of the queue
          System.out.println(c.unregister("1111111111","CCC333"));
          System.out.println(c.register("1111111111","CCC333"));
          prettyPrint(c.getInfo("1111111111"));
          pause();

          //unregister a student from a overfull course and show that no new student got their spot
          System.out.println(c.unregister("2222222222","CCC333"));
          prettyPrint(c.getInfo("4444444444"));
          prettyPrint(c.getInfo("5555555555"));
          
          //unregister with sql injection causing all registrations to be removed
          //god plz help
      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.2.8.jar) in your runtime classpath!");
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