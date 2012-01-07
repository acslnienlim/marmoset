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

/*
 * Created on Jan 9, 2005
 *
 * @author jspacco
 */
package edu.umd.cs.submitServer.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import edu.umd.cs.marmoset.modelClasses.BackgroundData;
import edu.umd.cs.marmoset.modelClasses.Course;
import edu.umd.cs.marmoset.modelClasses.Student;
import edu.umd.cs.marmoset.modelClasses.StudentRegistration;
import edu.umd.cs.marmoset.utilities.Charsets;
import edu.umd.cs.submitServer.BadPasswordException;
import edu.umd.cs.submitServer.CanNotFindDirectoryIDException;
import edu.umd.cs.submitServer.ClientRequestException;
import edu.umd.cs.submitServer.GenericStudentPasswordAuthenticationService;
import edu.umd.cs.submitServer.IAuthenticationService;
import edu.umd.cs.submitServer.RequestParser;
import edu.umd.cs.submitServer.TeamAuthenticationService;
import edu.umd.cs.submitServer.UserSession;

/**
 * @author jspacco
 *
 */
public class PerformLogin extends SubmitServerServlet {

	/**
	 * The doPost method of the servlet. <br>
	 *
	 * This method is called when a form has its tag value method equals to
	 * post.
	 *
	 * @param request
	 *            the request send by the client to the server
	 * @param response
	 *            the response send by the server to the client
	 * @throws ServletException
	 *             if an error occurred
	 * @throws IOException
	 *             if an error occurred
	 */
	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		RequestParser parser = new RequestParser(request,
				getSubmitServerServletLog(), strictParameterChecking());
		boolean superUserLogin = false;
		Integer superUserStudentPK = null;
		HttpSession session = request.getSession(false);
		if (session != null) {
			UserSession userSession = (UserSession) session
					.getAttribute(USER_SESSION);
			if (userSession != null) {
				superUserLogin = userSession.isSuperUser();
				superUserStudentPK = userSession.getStudentPK();
			}
			session.invalidate();
		}
		boolean skipAuthentication = "true".equals(this.getServletContext()
				.getInitParameter(SKIP_LDAP));

		session = request.getSession(true);
		String campusUID = parser.getOptionalCheckedParameter("loginName");
		if (campusUID == null || campusUID.trim().equals("")) {
			request.setAttribute("missingIDOrPasswordException", Boolean.TRUE);
			request.getRequestDispatcher("/index.jsp").forward(request,
					response);
			return;
		}
		String uidPassword = parser.getOptionalPasswordParameter("uidPassword");
		if (!superUserLogin  &!skipAuthentication
				&& (uidPassword == null || uidPassword.trim().equals(""))) {
			request.setAttribute("missingIDOrPasswordException", Boolean.TRUE);
			request.getRequestDispatcher("/index.jsp").forward(request,
					response);
			return;
		}
		String keepMeLoggedIn = parser.getOptionalPasswordParameter("keepMeLoggedIn");
		
		if ("checked".equals(keepMeLoggedIn) && !campusUID.endsWith("-admin"))
			session.setMaxInactiveInterval((int)TimeUnit.SECONDS.convert(14, TimeUnit.DAYS)); 
		Connection conn = null;
		try {
			conn = getConnection();

			
			// [NAT P001]
			Student student = authenticateStudent(conn, campusUID, uidPassword,
					superUserLogin || skipAuthentication,
					getIAuthenticationService());
			// [end NAT P001]

			if (superUserLogin) {
				getAuthenticationLog().info(
						"studentPK " + superUserStudentPK
								+ " just authenticated as "
								+ student.getStudentPK());
			}

			// Sets required information in the user's session.
			setUserSession(session, student, conn);

			// check to see if user tried to view a page before logging in
			String target = parser.getOptionalCheckedParameter("target");

			if (target != null && !target.equals("")) {
				target = Charsets.decodeURL(target);
				response.sendRedirect(target);
				return;
			}

			// otherwise redirect to the main view page
			response.sendRedirect(request.getContextPath() + "/view/index.jsp");
		} catch (SQLException e) {
			handleSQLException(e);
			throw new ServletException(e);
		} catch (NamingException e) {
			// TODO Catch this exception and send the students some other
			// message
			throw new ServletException(e);
		} catch (CanNotFindDirectoryIDException e) {
			getAuthenticationLog().error(e.getMessage(), e);
			request.setAttribute("canNotFindDirectoryID", Boolean.TRUE);
			request.setAttribute("campusUID", campusUID);
			request.getRequestDispatcher("/index.jsp").forward(request,
					response);
		} catch (BadPasswordException e) {
			getAuthenticationLog().error(e.getMessage(), e);
			request.setAttribute("badPassword", Boolean.TRUE);
			request.setAttribute("campusUID", campusUID);
			request.getRequestDispatcher("/index.jsp").forward(request,
					response);
		} catch (ClientRequestException e) {
			getAuthenticationLog().error(e.getMessage(), e);
			if (e.getMessage().startsWith("Cannot find user")) {
				request.setAttribute("noSuchStudentInDB", Boolean.TRUE);
			} else {
				request.setAttribute("otherError", Boolean.TRUE);
			}
			request.getRequestDispatcher("/index.jsp").forward(request,
					response);
		} finally {
			releaseConnection(conn);
		}
	}

	/**
	 * @param session
	 * @param conn
	 * @param student
	 * @throws SQLException
	 */
	public static void setUserSession(HttpSession session, Student student,
			Connection conn) throws SQLException {
		// look up list of student registrations for this studentPK
		List<StudentRegistration> collection = StudentRegistration
				.lookupAllByStudentPK(student.getStudentPK(), conn);

		UserSession userSession = new UserSession();

		// set studentPK and superUser
		userSession.setStudentPK(student.getStudentPK());
		userSession.setSuperUser(student.isSuperUser());
		// has this user returned a conset form?
		// we don't care if they've consented or not, just that they've returned
		// a form
		userSession.setGivenConsent(student.getGivenConsent());


		if (student.isSuperUser()) {
			for(Course course : Course.lookupAll(conn))  {
				userSession.addInstructorActionCapability(course.getCoursePK());
			}

		}
		// set flag for backgroundData in the session
		BackgroundData backgroundData = BackgroundData.lookupByStudentPK(
				student.getStudentPK(), conn);
		if (backgroundData != null)
			userSession.setBackgroundDataComplete(backgroundData.isComplete());

		for (StudentRegistration registration : collection) {
			Course course = Course.lookupByStudentRegistrationPK(
					registration.getStudentRegistrationPK(), conn);

			// in my current database implementation, I give the modify
			// capability
			// to mean that someone has both modify and read-only capability
			// it might be a better idea to specifically give someone both
			// abilities
			// but it doesn't make any sense to have modify capability without
			// read-only
			// for this software.
			if (StudentRegistration.MODIFY_CAPABILITY.equals(registration
					.getInstructorCapability())) {
				userSession.addInstructorActionCapability(course.getCoursePK());
			}
			else if (StudentRegistration.READ_ONLY_CAPABILITY.equals(registration
					.getInstructorCapability())) {
				// read-only capability does not necessarily imply any other
				// privileges
				userSession.addInstructorCapability(course.getCoursePK());
			}
		}
		// set background data
		session.setAttribute(USER_SESSION, userSession);
	}

	/**
	 * Authenticate a student using the appropriate methods. Team accounts
	 * authenticate differently from normal accounts. Normal Accounts with a
	 * password in the `password` field will use the
	 * GenericAuthenticationService, while others will used the passed in
	 * authenticationService
	 *
	 * @param conn
	 * @param campusUID
	 * @param uidPassword
	 * @param skipLDAP
	 * @param authenticationService
	 *            - the service to use for normal students if the password is
	 *            null
	 * @return
	 * @throws SQLException
	 * @throws NamingException
	 * @throws ClientRequestException
	 */
	public static Student authenticateStudent(Connection conn,
			String campusUID, String uidPassword, boolean skipLDAP,
			IAuthenticationService authenticationService) throws SQLException,
			NamingException, ClientRequestException {
		// [NAT P001]
		// Lookup campusUID
		Student student = Student.lookupByLoginName(campusUID, conn);
		if (student == null)
			throw new ClientRequestException("Cannot find user " + campusUID);

		// If student is a team account, then authenticate its members
		if (student.isTeamAccount()) {
			student = new TeamAuthenticationService().authenticateLDAP(
					campusUID, uidPassword, conn, skipLDAP,
					authenticationService);
		}

		// Otherwise, if it has a password, authenticate generically
		else if (student.getPassword() != null
				&& !"0".equals(student.getPassword())) {
			student = new GenericStudentPasswordAuthenticationService()
					.authenticateLDAP(campusUID, uidPassword, conn, skipLDAP);

		}

		// otherwise authenticate via default service
		else {

			// Note: this is a read-only query.
			// So, we do not start a transaction here.

			student = authenticationService.authenticateLDAP(campusUID,
					uidPassword, conn, skipLDAP);
		}
		// [end NAT P001]
		return student;
	}
}