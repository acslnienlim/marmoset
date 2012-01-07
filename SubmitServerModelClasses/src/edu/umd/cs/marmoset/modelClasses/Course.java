/**
 * Marmoset: a student project snapshot, submission, testing and code review
 * system developed by the Univ. of Maryland, College Park
 * 
 * Developed as part of Jaime Spacco's Ph.D. thesis work, continuing effort led
 * by William Pugh. See http://marmoset.cs.umd.edu/
 * 
 * Copyright 2005 - 2011, Univ. of Maryland
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 * 
 */

package edu.umd.cs.marmoset.modelClasses;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

import javax.annotation.CheckForNull;

import edu.umd.cs.marmoset.utilities.SqlUtilities;

/**
 * @author jspacco
 *
 */
public class Course {
	public static final String TABLE_NAME = "courses";

	private static SecureRandom random = new SecureRandom();
	
	private static String generateRandomKey() {
	    String result = Long.toHexString(random.nextLong());
	    while (result.length() < 16)
	        result = "0" + result;
	    return result;
	    
	}
	/**
	 * List of all attributes for courses table.
	 */
     static final String[] ATTRIBUTE_NAME_LIST = {
            "course_pk",
            "semester",
            "coursename",
            "section",
            "description",
            "url",
            "course_ids",
            "allows_baseline_download",
            "buildserver_key",
            "submit_key"
	};

	/**
	 * Fully-qualified attributes for courses table.
	 */
	 public static final String ATTRIBUTES = Queries.getAttributeList(TABLE_NAME,
			ATTRIBUTE_NAME_LIST);

	private Integer coursePK; // non-NULL, autoincrement
	private String semester;
	private String courseName;
	private String section;
	private String description;
	private String url;
	private String courseIDs;
	private String buildserverKey;
	private String submitKey;
	private boolean allowsBaselineDownload;
	
	public Course() {
		
	}

	public boolean getAllowsBaselineDownload() {
		return allowsBaselineDownload;
	}
	public void setAllowsBaselineDownload(boolean allowsBaselineDownload) {
		this.allowsBaselineDownload = allowsBaselineDownload;
	}
	/**
	 * @return Returns the courseName.
	 */
	public String getCourseName() {
		return courseName;
	}
	public String getBuildserverKey() {
	    return buildserverKey;
	}
	private void setBuildserverKey(String buildserverKey) {
        this.buildserverKey = buildserverKey;
    }
	public String getSubmitKey() {
        return submitKey;
    }

    private void setSubmitKey(String submitKey) {
        this.submitKey = submitKey;
    }

    /**
	 * @param courseName The courseName to set.
	 */
	public void setCourseName(String courseName) {
		this.courseName = courseName;
	}
	/**
	 * @return Returns the coursePK.
	 */
	public Integer getCoursePK() {
		return coursePK;
	}
	/**
	 * @param coursePK The coursePK to set.
	 */
	public void setCoursePK(Integer coursePK) {
		this.coursePK = coursePK;
	}
	/**
	 * @return Returns the description.
	 */
	public String getDescription() {
		return description;
	}
	/**
	 * @param description The description to set.
	 */
	public void setDescription(String description) {
		this.description = description;
	}
	/**
	 * @return Returns the section.
	 */
	public String getSection() {
		return section;
	}
	/**
	 * @param section The section to set.
	 */
	public void setSection(String section) {
		this.section = section;
	}
	/**
	 * @return Returns the semester.
	 */
	public String getSemester() {
		return semester;
	}
	/**
	 * @param semester The semester to set.
	 */
	public void setSemester(String semester) {
		this.semester = semester;
	}
	/**
	 * @return Returns the url.
	 */
	public String getUrl() {
		return url;
	}
	/**
	 * @param url The url to set.
	 */
	public void setUrl(String url) {
		this.url = url;
	}

	public String getCourseIDs() {
		return courseIDs;
	}
	public void setCourseIDs(String courseIDs) {
		this.courseIDs = courseIDs;
	}
	public void insert(Connection conn)
	throws SQLException
	{
	    if (buildserverKey != null)
	        throw new IllegalStateException();
	    buildserverKey = generateRandomKey();
	    if (submitKey != null)
	        throw new IllegalStateException();
	    buildserverKey = generateRandomKey();
	      
	    String insert = Queries.makeInsertStatementUsingSetSyntax(ATTRIBUTE_NAME_LIST, TABLE_NAME, true);

	    PreparedStatement stmt = null;
	    try {
	        stmt = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS);
	        putValues(stmt,1);
	        stmt.executeUpdate();
	        setCoursePK(Queries.getGeneratedPrimaryKey(stmt));
	    } finally {
	        Queries.closeStatement(stmt);
	    }
	}
	/**
	 * @param stmt
	 * @throws SQLException
	 */
	private int putValues(PreparedStatement stmt, int col) throws SQLException {
		stmt.setString(col++, getSemester());
		stmt.setString(col++, getCourseName());
		stmt.setString(col++, getSection());
		stmt.setString(col++, getDescription());
		stmt.setString(col++, getUrl());
		stmt.setString(col++, getCourseIDs());
		stmt.setBoolean(col++, getAllowsBaselineDownload());
		stmt.setString(col++, getBuildserverKey());
		stmt.setString(col++, getSubmitKey());
		return col;
	}

	public void update(Connection conn)
	throws SQLException
	{
	    String whereClause = " WHERE course_pk = ? ";

	    String update = Queries.makeUpdateStatementWithWhereClause(
	            ATTRIBUTE_NAME_LIST,
	            TABLE_NAME,
	            whereClause);

	    PreparedStatement stmt = null;
	    try {
	        stmt = conn.prepareStatement(update);
	        int col = putValues(stmt, 1);
	        SqlUtilities.setInteger(stmt, col, getCoursePK());

	        stmt.executeUpdate();
	    } finally {
	        Queries.closeStatement(stmt);
	    }
	}

	
	public int fetchValues(ResultSet resultSet, int startingFrom) throws SQLException
	{
		setCoursePK(resultSet.getInt(startingFrom++));
		setSemester(resultSet.getString(startingFrom++));
		setCourseName(resultSet.getString(startingFrom++));
		setSection(resultSet.getString(startingFrom++));
		setDescription(resultSet.getString(startingFrom++));
		setUrl(resultSet.getString(startingFrom++));
		setCourseIDs(resultSet.getString(startingFrom++));
		setAllowsBaselineDownload(resultSet.getBoolean(startingFrom++));
		setBuildserverKey(resultSet.getString(startingFrom++));
		setSubmitKey(resultSet.getString(startingFrom++));
		return startingFrom;
	}

	/**
	 * Finds a cousre in the database based in the name of the course.
	 * @param courseName
	 * @param conn
	 * @return the Course object representing the row found in the DB; null if it can't be found
	 * @throws SQLException
	 */
	public static Collection<Course> lookupCourseByCourseNameSemester(String courseName,
			String semester,
			Connection conn) throws SQLException
	{
		String query = "SELECT " +ATTRIBUTES+ " " +
				"FROM courses " +
				"WHERE courses.coursename = ? " +
				"AND courses.semester = ? ";

		PreparedStatement stmt = null;

		stmt = conn.prepareStatement(query);
		stmt.setString(1, courseName);
		stmt.setString(2, semester);

		return getAllFromPreparedStatement(stmt);
	}

	/**
	 * Finds a course based on its course PK.
	 *
	 * @param coursePK the PK of the course
	 * @param conn the connection to the database
	 * @return the course if it's found.  If it's not found, SQLException will be
	 * thrown.  This method never returns null.
	 * @throws SQLException if an error occurrs or the course is not found
	 */
	public static Course getByCoursePK(Integer coursePK, Connection conn)
	throws SQLException
	{
	    Course course = lookupByCoursePK(coursePK, conn);
	    if (course == null)
	        throw new SQLException("Course with PK " +coursePK+ " does not exist!");
	    return course;
	}

	/**
	 * Gets the course for which a particular project has been assigned.
	 *
	 * @param projectPK the PK of the project
	 * @param conn the connection to the database
	 * @return the course if it's found; if not SQLException is thrown.  Will never
	 * return null.
	 * @throws SQLException
	 */
	public static Course getByProjectPK(Integer projectPK, Connection conn)
	throws SQLException
	{
	    String query = " SELECT " +ATTRIBUTES+ " " +
	    " FROM courses, projects " +
	    " WHERE coures.course_pk = projects.project_pk " +
	    " AND projects.project_pk = ? ";

	    PreparedStatement stmt = conn.prepareStatement(query);
	    SqlUtilities.setInteger(stmt, 1, projectPK);

	    Course course = getCourseFromPreparedStatement(stmt);
	    if (course == null)
	        throw new SQLException("Cannot find course referenced by project with PK " +projectPK);
	    return course;
	}

	/**
	 * Looks up a a course based on the coursePK.
	 *
	 * @param coursePK the course PK
	 * @param conn the connection to the database
	 * @return the Course if the coursePK is found; null otherwise
	 * @throws SQLException
	 */
	public static Course lookupByCoursePK(Integer coursePK, Connection conn)
	throws SQLException
	{
		String query = "SELECT " +ATTRIBUTES+ " " +
		"FROM courses " +
		"WHERE courses.course_pk = ?";

		PreparedStatement stmt = null;

		stmt = conn.prepareStatement(query);
		SqlUtilities.setInteger(stmt, 1, coursePK);

		return getCourseFromPreparedStatement(stmt);
	}

	private static Course getCourseFromPreparedStatement(PreparedStatement stmt)
	throws SQLException
	{
		try {
			ResultSet rs = stmt.executeQuery();

			if (rs.next())
			{
				Course course = new Course();
				course.fetchValues(rs, 1);
				return course;
			}
			return null;
		}
		finally {
			Queries.closeStatement(stmt);
		}
	}
    /**
     * Gets a course based on the studentRegistrationPK of someone registered for the course.
     * @param studentRegistrationPK
     * @param conn the connection to the database.
     * @return the Course if it is found; null if it doesn't exist.
     */
    public static Course lookupByStudentRegistrationPK(@StudentRegistration.PK Integer studentRegistrationPK, Connection conn)
    throws SQLException
    {
        String query =
            " SELECT " +ATTRIBUTES+
            " FROM courses, student_registration " +
            " WHERE student_registration.course_pk = courses.course_pk " +
            " AND student_registration.student_registration_pk = ? ";

        PreparedStatement stmt = conn.prepareStatement(query);
        SqlUtilities.setInteger(stmt, 1, studentRegistrationPK);
        return getCourseFromPreparedStatement(stmt);
    }
    /**
     * Gets a course from the databse by its courseName.
     * @param courseName The name of the course.
     * @param conn The connection to the database.
     * @return The course object; null if it can't be found.
     * @throws SQLException
     */
    public static Course lookupByCourseName(String courseName, Connection conn)
    throws SQLException
    {
        String query=
            " SELECT " +ATTRIBUTES+
            " FROM courses " +
            " WHERE coursename = ? ";
        PreparedStatement stmt=conn.prepareStatement(query);
        stmt.setString(1,courseName);
        return getCourseFromPreparedStatement(stmt);
    }


    public static List<Integer> lookupAllPKByBuildserverKey(Connection conn, String keys)
    throws SQLException
    {
        String k[] = keys.split("[ ,]");
        String query =
            " SELECT course_pk  FROM courses WHERE ";
        for(int i = 0; i < k.length; i++) {
            if (i > 0)
                query += " OR ";
            query += " buildserver_key = ? ";
        }
        ArrayList<Integer> result = new ArrayList<Integer>();
        PreparedStatement stmt = null;
        try {
            stmt=conn.prepareStatement(query);
            for(int i = 0; i < k.length; i++) {
                stmt.setString(i+1, k[i]);
            }
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                result.add(rs.getInt(1));
            }
            return result;
        } finally {
            Queries.closeStatement(stmt);
        }
    }
    
    public static List<Course> lookupAll(Connection conn)
    throws SQLException
    {
        String query =
            " SELECT " +ATTRIBUTES+
            " FROM courses " +
            " ORDER BY semester DESC, coursename ASC, section ASC";
        PreparedStatement stmt = null;
        try {
            stmt=conn.prepareStatement(query);
            return getAllFromPreparedStatement(stmt);
        } finally {
            Queries.closeStatement(stmt);
        }
    }

    private static List<Course> getAllFromPreparedStatement(PreparedStatement stmt)
    throws SQLException
    {
        ResultSet rs = stmt.executeQuery();

        List<Course> list=new LinkedList<Course>();
        while (rs.next())
        {
            Course course = new Course();
            course.fetchValues(rs, 1);
            list.add(course);
        }
        return list;
    }

    public static List<Course> lookupAllByStudentPK(
    		@Student.PK Integer studentPK, Connection conn)
    throws SQLException
    {
        String query = " SELECT " +ATTRIBUTES+ " "+
        " FROM courses, student_registration "+
        " WHERE student_registration.student_pk = ? "+
        " AND student_registration.course_pk = courses.course_pk " +
        " ORDER BY courses.semester DESC, courses.coursename ASC, courses.section ASC";

        PreparedStatement stmt = null;
        try {
            stmt=conn.prepareStatement(query);
            SqlUtilities.setInteger(stmt, 1, studentPK);
            return getAllFromPreparedStatement(stmt);
        } finally {
            Queries.closeStatement(stmt);
        }
    }


    public static @CheckForNull Course lookupByCourseIdsAndSemester(String courseIds, String semester, Connection conn)
    throws SQLException
    {
        String query =
            " SELECT " +Course.ATTRIBUTES+ " " +
            " FROM courses " +
            " WHERE semester = ? " +
            " AND course_ids = ? " ;

        PreparedStatement stmt = null;
        try {
            stmt=conn.prepareStatement(query);
            Queries.setStatement(stmt, semester, courseIds);
            return getCourseFromPreparedStatement(stmt);
        } finally {
            Queries.closeStatement(stmt);
        }
    }

    public static List<Course> lookupallWithReadOnlyCapability(
    		@Student.PK Integer studentPK, Connection conn)
    throws SQLException
    {
        String query =
            " SELECT " +Course.ATTRIBUTES+ " " +
            " FROM courses, student_registration " +
            " WHERE student_registration.student_pk = ? " +
            " AND student_registration.course_pk = courses.course_pk " +
            " AND ( student_registration.instructor_capability = ? OR " +
            "       student_registration.instructor_capability = ?) " +
            " ORDER BY courses.semester DESC, courses.coursename ASC, courses.section ASC";

        PreparedStatement stmt = null;
        try {
            stmt=conn.prepareStatement(query);
            SqlUtilities.setInteger(stmt, 1, studentPK);
            stmt.setString(2, StudentRegistration.READ_ONLY_CAPABILITY);
            stmt.setString(3, StudentRegistration.MODIFY_CAPABILITY);
            return getAllFromPreparedStatement(stmt);
        } finally {
            Queries.closeStatement(stmt);
        }
    }
}