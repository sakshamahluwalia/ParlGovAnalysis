import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                return false;
            }
        }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        List<Integer> elections = new ArrayList<>();
        List<Integer> cabinets  = new ArrayList<>();

        try {

            // create the query.
            String queryString1 =   "SELECT e.id as election_id, c.id as cabinet_id"      +
                                    "FROM election e, cabinet c, country co"              +
                                    "WHERE e.id = c.election_id and e.country_id = co.id" +
                                    "AND co.name = ?"                                     +
                                    "ORDER BY e.e_date DESC;";

            // prepare and execute the query.
            PreparedStatement query1  = connection.prepareStatement(queryString1);

            query1.setString(1, countryName);
            ResultSet answer = query1.executeQuery();

            // iterate through teh result and each row to, 'elections' and 'cabinets'.
            while (answer.next()) {
                elections.add(answer.getInt("election_id"));
                cabinets.add(answer.getInt("cabinet_id"));
            }


        } catch (SQLException se) {
            System.out.println(se.getMessage());
        }


        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {

	List<Integer> finalanswer = new ArrayList<>();

        try {

            // create the queries.
    		String queryString1 = "SELECT description FROM politician_president WHERE id = ?;";
    		String queryString2 = "SELECT id, description FROM politician_president WHERE id <> ?;";

            // prepare the queries but only execute the first query first..
    		PreparedStatement query1 = connection.prepareStatement(queryString1);
    		PreparedStatement query2 = connection.prepareStatement(queryString2);

    		query1.setInt(1, politicianName);
            query2.setInt(1, politicianName);

    		ResultSet answer = query1.executeQuery();

    		// get the description of the politician.
    		String description = "";
    		while (answer.next()) {
    		    description = answer.getString("description");
    		}

            //execute the second query.
    		ResultSet answer2 = query2.executeQuery();

            // iterate through all the politicians.
    		while(answer2.next()) {

                // get the similarity value.
    			double similarity = similarity(answer2.getString("description"), description);
    			// int id;

                // if the similarity value > threshold that was given then add the politician's id to 
                // finalanswer
    			if (similarity >= threshold)	 {
    				// id = query2.getInt("id");
    				// if (id != politicianName) {
    					finalanswer.add(answer2.getInt("id"));
    				// }
    			}
    		}


        } catch (SQLException se) {
            System.out.print(se.getMessage());
        }

        return finalanswer;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");

        try {
            Assignment2 test = new Assignment2();

            test.connectDB(
                    "jdbc:postgresql://localhost:5432/csc343h-ahluwa41",
                    "ahluwa41", "");


        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

    }

}

