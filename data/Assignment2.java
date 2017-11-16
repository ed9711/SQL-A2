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

	Connection conn;
	PreparedStatement pStatement;
    ResultSet rs;
    String queryString;

	public Assignment2() throws ClassNotFoundException {

		Class.forName("org.postgresql.Driver");
	}

	@Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
       
        try
        {
            conn = DriverManager.getConnection(url, username, password);
            
            
            }
        catch (SQLException e) {
            return false;
    }
        return true;
	}

	@Override
	public boolean disconnectDB() {
		try {
	        if (conn != null && !conn.isClosed()) {
	            conn.close();
	        }
	        if (rs != null && !rs.isClosed()) rs.close();
	        if (pStatement != null && !pStatement.isClosed()) pStatement.close();
	        return (connection == null || connection.isClosed());
	    }
	    catch (SQLException e) {
	        return false;
	}
	}

	@SuppressWarnings("null")
	@Override
	public ElectionCabinetResult electionSequence(String countryName) {
		// Implement this method!
		List<Integer> elections = null;
		List<Integer> cabinets = null;
		queryString = "select e1.id" +
						"from election e1, country, election e2" + 
						"where e1.country_id = country.id and country.name =" + countryName +
						"and (e2.previous_parliament_election_id = e1.id or e2.previous_ep_election_id = e1.id)" +
						"order by e1.e_date desc;";
		try {
			pStatement = conn.prepareStatement(queryString);
			rs = pStatement.executeQuery();
			while (rs.next()){
				elections.add(rs.getInt("id"));
			}
			
		} catch (SQLException e) {
			System.out.println("error1");
				return null;
		}
		
		queryString = "select e1.e_date as start_date, e2.e_date as next_date" +
						"from election e1, country, election e2" + 
						"where e1.country_id = country.id and country.name =" + countryName +
						"and (e2.previous_parliament_election_id = e1.id or e2.previous_ep_election_id = e1.id)" +
						"order by e1.e_date desc;";
		try {
			pStatement = conn.prepareStatement(queryString);
			rs = pStatement.executeQuery();
			Date d1 = null;
			Date d2 = null;
			while (rs.next()){
				d1 = rs.getDate("start_date");
				d2 = rs.getDate("next_date");
				String qsl = "select id" +
								"where country_id = " + countryName +
								"and start_date <" + d2 + " and start_date >=" + d1 + ";";
				PreparedStatement ps = conn.prepareStatement(qsl);
				ResultSet rs1 = ps.executeQuery();
				while (rs1.next()){
					cabinets.add(rs1.getInt("id"));
				}
				
				
			}
		} catch (SQLException e) {
				System.out.println("error2");
				return null;
		}
		
		ElectionCabinetResult result = new ElectionCabinetResult(elections, cabinets);
		return result;
	}

	@SuppressWarnings("null")
	@Override
	public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
		// Implement this method!
		List<Integer> result = null;
		queryString = "select p2.id, p1.description as d1, p2.description as d2, p1.comment as c1, p2.comment as c2" +
						"from politician_president p1, politician_president p2" +
						"where p1.id = " + politicianName + " and p1.id <> p2.id;";
		try {
			pStatement = conn.prepareStatement(queryString);
			rs = pStatement.executeQuery();
			while (rs.next()){
				String a; //Politician 1
				String b; //Politician 2
				a = rs.getString("d1") + " " + rs.getString("c1");
				b = rs.getString("d2") + " " + rs.getString("c2");
				Double sim = similarity(a, b);
				if (sim >= threshold){
					result.add(rs.getInt("id"));
				}
				
			}
		} catch (SQLException e) {
			return null;
		}
		
		return result;
	}

	public static void main(String[] args) {
		// You can put testing code in here. It will not affect our autotester.
		Assignment2 a2 = null;
		try {
			a2 = new Assignment2();
		} catch (ClassNotFoundException e) {
			System.out.println("problem\n");
			e.printStackTrace();
		}
		boolean result = a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-nizhison", "nizhison", "");
		
		String countryName = "Germany";
        ElectionCabinetResult temp = a2.electionSequence(countryName);     
        System.out.println(temp);
        boolean result1 = a2.disconnectDB();
		
		System.out.println("Hello");
		System.out.println(result);
		System.out.println(result1);
	}

}
