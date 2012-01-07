<%--

 Marmoset: a student project snapshot, submission, testing and code review
 system developed by the Univ. of Maryland, College Park
 
 Developed as part of Jaime Spacco's Ph.D. thesis work, continuing effort led
 by William Pugh. See http://marmoset.cs.umd.edu/
 
 Copyright 2005 - 2011, Univ. of Maryland
 
 Licensed under the Apache License, Version 2.0 (the "License"); you may not
 use this file except in compliance with the License. You may obtain a copy of
 the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations under
 the License.

--%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ss" uri="http://www.cs.umd.edu/marmoset/ss"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix='fn' uri='http://java.sun.com/jsp/jstl/functions'%>
<!DOCTYPE HTML>
<html>

<ss:head
	title="Administrative actions" />
<body>
<ss:header />
<ss:instructorBreadCrumb />
<h1>Administrative info/status</h1>

<c:if test="${! empty recentErrors }">
<h2>Recent errors</h2>

<table>
<tr><th><th>When<th>Message
    <c:forEach var="error" items="${recentErrors}" varStatus="counter">
        <tr class="$rowKind">
        <td>${error.errorPK}
        <td><fmt:formatDate value="${error.when}"
                pattern="dd MMM, hh:mm a" /></td>
                <td class="description"><c:out value="${error.message}"/>
                </td>
                </tr>
                </c:forEach>
                
  </table>
  </c:if>

<c:if test="${! empty coursesThatNeedBuildServers }">
<h2>Courses that need build servers</h2>
<ul>
    <c:forEach var="course" items="${coursesThatNeedBuildServers}">
        <c:url var="courseLink" value="/view/instructor/course.jsp">
            <c:param name="coursePK" value="${course.coursePK}" />
        </c:url> 
        <li>
        <a href="${courseLink}">
        <c:out value="${course.courseName}"/><c:if test="${not empty course.section}"><c:out value="${course.section}"/></c:if>:
        <c:out value="${course.description}"/> </a>
    </c:forEach>
    </ul>
</c:if>
<p>Server load: ${systemLoad}
<h2>BuildServers</h2>
<table>
<tr><th>Host<th>Last request<th>Last job<th>Last success<th>Load</th></tr>

    <c:forEach var="buildServer" items="${buildServers}" varStatus="counter">
        <tr class="$rowKind">
        <td><c:out value="${buildServer.name}"/>
        <td><fmt:formatDate value="${buildServer.lastRequest}"
                pattern="dd MMM, hh:mm a" /></td>
                 <td><fmt:formatDate value="${buildServer.lastSuccess}"
                pattern="dd MMM, hh:mm a" /></td>
              
                <td><fmt:formatDate value="${buildServer.lastSuccess}"
                pattern="dd MMM, hh:mm a" /></td>
                <td class="description"><c:out value="${buildServer.load}"/>
                </td>
                </tr>
                </c:forEach>
                </table>
                
        
        
<h2>Upcoming project deadlines</h2>
<table>
	<tr><th rowspan="2">Course</th><th rowspan="2">Project</th><th colspan="2">Deadlines</th><th colspan ="5">build status</th></tr>
    <tr><th>ontime</th><th>late</th>
    <th>new</th>
     <th>pending</th>
      <th>complete</th>
       <th>retest</th>
        <th>broken</th>
    </tr>

	<c:forEach var="project" items="${upcomingProjects}" varStatus="counter">
		<tr class="$rowKind">

			<td class="description"><c:out value="${courseMap[project.coursePK].courseName}"/></td>

			<td class="description"><c:url var="projectLink" value="/view/instructor/project.jsp">
				<c:param name="projectPK" value="${project.projectPK}" />
			</c:url> <a href="${projectLink}"> ${project.projectNumber}:  ${project.title}  </a></td>
			<td><fmt:formatDate value="${project.ontime}"
				pattern="dd MMM, hh:mm a" /></td>
				<td><fmt:formatDate value="${project.late}"
				pattern="dd MMM, hh:mm a" /></td>
			<c:choose>
			<c:when test="${project.tested}">
			<td><c:out value="${buildStatusCount[project]['new']}"/></td>
			<td><c:out value="${buildStatusCount[project]['pending']}"/></td>
			<td><c:out value="${buildStatusCount[project]['complete']}"/></td>
			<td><c:out value="${buildStatusCount[project]['retest']}"/></td>
			<td><c:out value="${buildStatusCount[project]['broken']}"/></td>
			</c:when>
			<c:otherwise>
			<td colspan="5" >
			<c:out value="${buildStatusCount[project]['accepted']}"/> accepted </td>
			</c:otherwise>
			</c:choose>
			</tr>

	</c:forEach>
	</table>


	<c:if test="${! empty slowSubmissions}">
		<h2>Submissions that took a long time to test</h2>
		<table>

			<tr>
			 <th>Course
			             <th>Project
               
				<th>sub pk
				<th>delay
				<th>build status
				<th>submitted</th>

			</tr>
			<c:forEach var="submission" items="${slowSubmissions}"
				varStatus="counter">
				
				<c:set var="project" value="${projectMap[submission.projectPK]}" />
                <c:set var="course" value="${courseMap[project.coursePK]}" />
                
				<c:url var="submissionLink" value="/view/instructor/submission.jsp">
					<c:param name="submissionPK" value="${submission.submissionPK}" />
				</c:url>
				<c:url var="projectLink" value="/view/instructor/project.jsp">
					<c:param name="projectPK" value="${project.projectPK}" />
				</c:url>
				<c:url var="courseLink" value="/view/instructor/course.jsp">
					<c:param name="coursePK" value="${course.coursePK}" />
				</c:url>

				<tr class="$rowKind">
				<td class="description"><a href="${courseLink}"> <c:out
                                value="${course.courseName}" /> </a>
                    </td>
                    
				<td class="description"><a href="${projectLink}"> <c:out
                                value="${project.projectNumber}" /> <c:out
                                value="${project.title}" /> </a>
                    </td>
                    <td><a href="${submissionLink}">${submission.submissionPK}</a> 
					</td>
					<td>${testDelay[submission]}</td>
					<td>${submission.buildStatus}</td>
					<td><fmt:formatDate value="${submission.submissionTimestamp}"
							pattern="dd MMM h:mm a" /></td>
					


				</tr>
			</c:forEach>
		</table>
	</c:if>

	<h1>Administrative actions</h1>
<h2>Synchronize with
        <a href="http://grades.cs.umd.edu">grades.cs.umd.edu</a></h2>
<c:url var="importInstructorsLink" value="/action/admin/ImportInstructors"/>
<c:url var="syncStudentsLink" value="/action/admin/SyncStudents"/>
            
	<table class="form">
		<tbody>
		<form action="${importInstructorsLink}" method="post" name="importInstructorsForm">
		
		<tr>
			<td class="label">Semester:</td>
			<td class="input">
				<input type="text" name="semester" value="${initParam['semester']}"/>
			</td>
		</tr>
		<tr  class="submit"><td colspan=2>
			<input type="submit" value="Import all instructors">
			</form></tbody>
			<tbody>
			
			<form action="${syncStudentsLink}" method="post" name="syncStudents">
			<tr  class="submit"><td colspan=2><input type="submit" value="Synchronize students"></td></tr></form>
			</tbody>
			
	</table>
	</form>


<h2>Create course</h2>
<p>
<c:url var="createCourseLink" value="/action/admin/CreateCourse"/>
	<form action="${createCourseLink}" method="post" name="createCourseForm">
	<table class="form">
		<tr><th colspan=2>Create new course</th></tr>
		<tr>
			<td class="label">Course Name:</td>
			<td class="input"><input type="text" name="courseName"></td>
		</tr>
		<tr>
			<td class="label">Semester:</td>
			<td class="input">
				<input type="text" name="semester" value="${initParam['semester']}"/>
			</td>
		</tr>
		<tr>
			<td class="label">Description <br>(can be empty): </td>
			<td class="input">
				<textarea cols="40" rows="6" name="description"></textarea>
			</td>
		</tr>
		<tr>
			<td class="label">URL:</td>
			<td class="input"><input type="url" name="url" size="60"></td>
		</tr>
		<tr>
            <td class="label">allows baseline/starter code download:</td>
            <td class="input"><input name="download" type="checkbox" checked  />
            </td>
        </tr>
		<tr  class="submit"><td colspan=2>
			<input type="submit" value="Create course">
	</table>


	</form>

	<h2>Authenticate as...</h2>
<p>This allows you to log in as any other user, and allow you to view the submit server
as that user would.
Once you have authenticated as another user, you will have to log out and log in as yourself in order
to perform actions as yourself.


<p>
<table>
<tr><th>Name</th><th>directory name</th><th>Authenticate</th>

	<c:forEach var="student" items="${allStudents}"
		varStatus="counter">
		<c:url var="loginLink" value="/authenticate/PerformLogin"/>

		<tr class="r${counter.index % 2}">
		<td class="description">
		<c:url var="studentLink" value="/view/instructor/student.jsp">
                        <c:param name="studentPK" value="${student.studentPK}" />
                    </c:url>
                
		<a href="${studentLink}"><c:out value="${student.lastname}"/>, <c:out value="${student.firstname}"/></a>
		<td class="description"><c:out value="${student.loginName}"/>
		<td>		<form name="PerformLogin" method="post" action="${loginLink}" >
				<input type="hidden" name="loginName" value="${student.loginName}"/>
				<input type="submit" value="as"/>
				</form>
				</td>

				</tr>

				</c:forEach>
</table>


	<ss:footer/>
  </body>
</html>