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


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="ss" uri="http://www.cs.umd.edu/marmoset/ss"%>

<!DOCTYPE HTML>
<html>
<ss:head title="Instructor view of course ${course.courseName}" />
<body>
	<ss:header />
	<ss:instructorBreadCrumb />

	<div class="sectionTitle">
		<h1>
			<a href="${course.url}">${course.courseName}</a>, ${course.semester}:
			${course.description} (Instructor View)
		</h1>

		<p class="sectionDescription">Welcome ${user.firstname}</p>
	</div>

	<script type="text/javascript">
		function toggle(item) {
			obj = document.getElementById(item);
			if (obj.style.display == "none") {
				obj.style.display = "block";
			} else {
				obj.style.display = "none";
			}
		}
	</script>
	
	<div class="projectMenu">
	<a href="#projects">Projects</a>
	&nbsp;|&nbsp;
	<a href="#students">Students</a>
	&nbsp;|&nbsp;
	<a href="#staff">Staff</a>
	   &nbsp;|&nbsp;
    <a href="#status">Status</a>
	&nbsp;|&nbsp;
	<a href="#update">Update</a>
	</div>

	<ss:codeReviews title="Pending Code reviews"/>
	<h2><a id="projects">Projects</a></h2>
	<p></p>
	<table>
		<tr>
			<th>Project</th>
			<th>Overview</th>
			<th>testing<br> setup</th>
			<th># to test</th>
			<th># retesting</th>
			<th>Visible</th>
			<th>Due</th>
			<th class="description">Title</th>
		</tr>

		<c:forEach var="project" items="${projectList}" varStatus="counter">
			<c:choose>
				<c:when test="${project.visibleToStudents}">
					<c:set var="rowKind" value="ir${counter.index % 2}" />
				</c:when>
				<c:otherwise>
					<c:set var="rowKind" value="r${counter.index % 2}" />
				</c:otherwise>
			</c:choose>
			<tr class="$rowKind">

				<td>${project.projectNumber}</td>

				<td><c:url var="projectLink"
						value="/view/instructor/project.jsp">
						<c:param name="projectPK" value="${project.projectPK}" />
					</c:url> <a href="${projectLink}"> view </a>
				</td>

				<c:choose>
					<c:when test="${project.tested}">
						<td><c:choose>
								<c:when test="${project.testSetupPK > 0}">active</c:when>
								<c:otherwise>
									<c:url var="uploadTestSetupLink"
										value="/view/instructor/uploadTestSetup.jsp">
										<c:param name="projectPK" value="${project.projectPK}" />
									</c:url>
									<a href="${uploadTestSetupLink}"> upload </a>
								</c:otherwise>
							</c:choose></td>

						<td>${ss:numToTest(project.projectPK, connection)}</td>

						<td>${ss:numForRetest(project.projectPK, connection)}</td>
					</c:when>
					<c:otherwise>
						<td colspan="3" />
					</c:otherwise>
				</c:choose>

				<td>${project.visibleToStudents}</td>
				<td><fmt:formatDate value="${project.ontime}"
						pattern="dd MMM, hh:mm a" />
				</td>
				<td class="description">${project.title}</td>
			</tr>
		</c:forEach>
	</table>

	<c:if test="${instructorActionCapability}">

		<ul>
			<li><c:url var="createProjectLink"
					value="/view/instructor/createProject.jsp">
					<c:param name="coursePK" value="${course.coursePK}" />
				</c:url> <a href="${createProjectLink}"> create new project </a></li>
			<li>Import a project <c:url var="importProjectLink"
					value="/action/instructor/ImportProject" />

				<form name="importProjectForm" enctype="multipart/form-data"
					method="post" action="${importProjectLink}">
					Canonical Account: <select name="canonicalStudentRegistrationPK">
						<c:forEach var="studentRegistration" items="${courseInstructors}">
							<c:choose>
								<c:when
									test="${studentRegistration.studentRegistrationPK == studentRegistrationPK}">
									<option value="${studentRegistration.studentRegistrationPK}"
										selected="selected">
										${studentRegistration.classAccount}</option>
								</c:when>
								<c:otherwise>
									<option value="${studentRegistration.studentRegistrationPK}">
										${studentRegistration.classAccount}</option>
								</c:otherwise>
							</c:choose>
						</c:forEach>
					</select> <input type="file" name="file" size="40" /> <input type="submit"
						value="Import project!"> <input type="hidden"
						name="coursePK" value="${course.coursePK}">
				</form></li>
		</ul>
	</c:if>

	<h2>
		<a href="javascript:toggle('studentList')" title="Click to toggle display of students" id="students">
        <c:out value="${fn:length(justStudentRegistrationSet)}"/>
        Students</a>
	</h2>

	<c:if test="${ fn:length(courseIds) > 0}">
	<c:url var="syncCourseLink" value="/action/instructor/SyncCourse"/>
	<p><form name="syncCourseForm"
                    method="post" action="${syncCourseLink}">
                    <input type="hidden" name="coursePK" value="${course.coursePK}"/>
                    <input type="submit" 
                    name="submit"
                    value="Update students from grade server"/>
                    </form>
	</c:if>
	
	<div id="studentList" style="display: none">

		<table>
			<tr>
				<th>Active</th>
				<th>Name</th>
				<th>class account</th>
			</tr>
			<c:forEach var="studentRegistration"
				items="${justStudentRegistrationSet}" varStatus="counter">
				<tr class="r${counter.index % 2}">
					<c:url var="studentLink" value="/view/instructor/student.jsp">
						<c:param name="studentPK" value="${studentRegistration.studentPK}" />
						<c:param name="coursePK" value="${course.coursePK}" />
					</c:url>
					<td
						title="registration status is controlled through grades.cs.umd.edu"><input
						name="active" type="checkbox"
						${ss:isChecked(studentRegistration.active)}  disabled />
					</td>
					<td class="description"><a href="${studentLink}">${studentRegistration.lastname},
							${studentRegistration.firstname} </a></td>
					<td><a href="${studentLink}">${studentRegistration.classAccount}</a>
					</td>
				</tr>
			</c:forEach>
		</table>
	</div>


	<h2><a id="staff" >Staff</a></h2>
	<table>
		<tr>
			<th>Active</th>
			<th>Name</th>
			<th>class account</th>
			<th>can update course</th>
		</tr>
		<c:forEach var="studentRegistration"
			items="${staffStudentRegistrationSet}" varStatus="counter">
			<tr class="r${counter.index % 2}">
				<c:url var="studentLink" value="/view/instructor/student.jsp">
					<c:param name="studentPK" value="${studentRegistration.studentPK}" />
					<c:param name="coursePK" value="${course.coursePK}" />
				</c:url>
				<td><input name="active" type="checkbox"
					${ss:isChecked(studentRegistration.active)}  disabled />
				</td>
				<td class="description"><a href="${studentLink}">${studentRegistration.lastname},
						${studentRegistration.firstname} </a></td>
				<td><a href="${studentLink}">${studentRegistration.classAccount}</a>
				</td>

				<c:set var="modifyPermission"
					value="${studentRegistration.instructorCapability == 'modify'}" />
				<td><input name="modify" type="checkbox"
					${ss:isChecked(modifyPermission)}  disabled /></td>

			</tr>
		</c:forEach>
	</table>

        <h3><a id="status">Status</a></h3>
<p>Server load: ${systemLoad}
<c:choose>
<c:when test="${empty buildServers}">
<p>There are no build servers for your course.  </p>
</c:when>
<c:otherwise>
<p>There are ${fn:length(buildServers)} build servers that can build code for your course. 
(<a href="javascript:toggle('buildServers')" >details</a>)

<div id="buildServers" style="display: none">

<table>
<tr><th>Host<th>Last request<th>Last success<th>Load</th></tr>

    <c:forEach var="buildServer" items="${buildServers}" varStatus="counter">
        <tr class="$rowKind">
        <td><c:out value="${buildServer.name}"/>
        <td><fmt:formatDate value="${buildServer.lastRequest}"
                pattern="dd MMM, hh:mm a" /></td>
                <td><fmt:formatDate value="${buildServer.lastSuccess}"
                pattern="dd MMM, hh:mm a" /></td>
                <td><c:out value="${buildServer.load}"/>
                </td>
                </tr>
                </c:forEach>
                </table>
                </div>
                </c:otherwise>
                </c:choose>
                

	<c:if test="${instructorActionCapability}">
		<h3><a id="update" name="update">Update</a></h3>
		<c:url var="updateCourseLink" value="/action/instructor/UpdateCourse" />
		<c:set var="currentURL">
		<c:out value="${course.url}"/>
		</c:set>
		      <c:set var="currentDescription">
        <c:out value="${course.description}"/>
        </c:set>
		<form action="${updateCourseLink}" method="post"
			name="updateCourseForm">
			<input type="hidden" name="coursePK" value="${course.coursePK}">

			<table class="form">
				<tr>
					<th colspan="2">Update course info</th>
				</tr>
				<tr>
					<td class="label">Course Name:</td>
					<td class="input"><c:out value="${course.courseName}" />
					</td>
				</tr>
				<tr>
					<td class="label">Description:</td>
					<td class="input"><input type="text" name="description" size="60"
					value="${currentDescription}" placeholder="course description (optional)" /></td>
				</tr>
				<tr>
					<td class="label">URL:</td>
					<td class="input"><input type="url"  name="url" size="60" value="${currentURL}" placeholder="course web page (optional)" />
					</td>
				</tr>
				<tr>
					<td class="label">allows baseline/starter code download:</td>
					<td class="input"><input name="download" type="checkbox" ${ss:isChecked(course.allowsBaselineDownload)}  />
					</td>
				</tr>
				<tr class="submit">
					<td colspan="2"><input type="submit" value="Update course">
					</td>
				</tr>
			</table>

		</form>

		<ul>
			<li><c:url var="studentAccountForInstructorLink"
					value="/action/instructor/StudentAccountForInstructor" />
				<form action="${studentAccountForInstructorLink}" method="post"
					name="studentAccountForInstructorForm">
					<input type="hidden" name="coursePK" value="${course.coursePK}" />
					Create and go to pseudo-student account for instructor
					<c:out value="${studentRegistration.fullname}" />
					<input type="submit" value="Go">
				</form></li>
			<li><c:url var="registerStudentsLink"
					value="/view/instructor/registerStudents.jsp">
					<c:param name="coursePK" value="${course.coursePK}" />
				</c:url> <a href="${registerStudentsLink}"> Register students for this
					course by uploading a text file </a></li>
			<li><c:url var="registerPersonLink"
					value="/view/instructor/registerPerson.jsp">
					<c:param name="coursePK" value="${course.coursePK}" />
				</c:url> <a href="${registerPersonLink}"> Register one person course
					using a web interface</a></li>
		</ul>
	</c:if>
	
	<c:if test="${! empty hiddenProjects }">
	
	<h2><a id="projects">Hidden Projects</a></h2>
    <p></p>
    <table>
        <tr>
            <th>Project</th>
            <th>Overview</th>
            <th>unhide
            <th class="description">Title</th>
        </tr>

        <c:forEach var="project" items="${hiddenProjects}" varStatus="counter">
            <c:choose>
                <c:when test="${project.visibleToStudents}">
                    <c:set var="rowKind" value="ir${counter.index % 2}" />
                </c:when>
                <c:otherwise>
                    <c:set var="rowKind" value="r${counter.index % 2}" />
                </c:otherwise>
            </c:choose>
            <tr class="$rowKind">

                <td>${project.projectNumber}</td>

						<td><c:url var="projectLink"
								value="/view/instructor/project.jsp">
								<c:param name="projectPK" value="${project.projectPK}" />
							</c:url> <a href="${projectLink}"> view </a></td>

						<td><c:url var="makeVisibleHidden"
								value="/action/instructor/MakeProjectHidden" />
							<form method="post" action="${makeVisibleHidden}">
								<input type="hidden" name="projectPK"
									value="${project.projectPK}" /> <input type="hidden"
									name="newValue" value="false" /> <input type="submit"
									value="Unhide" style="color: #003399" />
							</form></td>

						<td class="description">${project.title}</td>
					</tr>
        </c:forEach>
    </table>
    </c:if>
	
	
	<ss:footer />
</body>
</html>