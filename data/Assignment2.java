import java.sql.*;
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
        return null;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {

	List<Integer> finalanswer = new ArrayList<>();

        try {

		String queryString1 = "SELECT description FROM politician_president WHERE id = ?;";
		String queryString2 = "SELECT id, description FROM politician_president;";


		PreparedStatement query1 = connection.prepareStatement(queryString1);
		PreparedStatement query2 = connection.prepareStatement(queryString2);

		query1.setInt(1, politicianName);
		ResultSet answer = query1.executeQuery();

		// get the description of the politician.
		String description = "";
		while (answer.next()) {
		    description = answer.getString("description");
		}

		ResultSet answer2 = query2.executeQuery();

		while(query2.next()) {
			double similarity = similarity(answer2.getString("description", description);
			int id;
			if (similarity >= threshold)	 {
				id = query2.getInt("id");
				if (id != politicianName) {
					finalanswer.add(id);
				}
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
    }

}

