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
<%@ taglib prefix="ss" uri="http://www.cs.umd.edu/marmoset/ss"%>

<!DOCTYPE HTML>
<html>

<ss:head
	title="Submit project ${project.projectNumber} for ${course.courseName} in ${course.semester}" />

<body>
<ss:header />
<ss:breadCrumb />

<c:if test="${project.testSetupPK == 0 or testSetup.jarfileStatus != 'active'}">
<h2>
<font color=red><b>NOTE:</b></font></h2>
<p>This project is not yet active for automated testing of submissions.  This probably means
that the instructor has not yet uploaded a working reference implementation and assigned
point values to each test case.
<p>
You can still submit your implementation, but the server will not test your
submission until the project has been activated by the instructor.
</c:if>

<div class="sectionTitle">
	<h1>File Upload for Project Submission</h1>

	<p class="sectionDescription">Submit Project ${project.projectNumber}
			for ${course.courseName} in ${course.semester}</p>
</div>

<h2>Submitting a zip file</h2>
<p>You may upload a Zip archive containing your project submission.
<p>The Zip archive must contain the <b>entire</b> project directory,
including all of your source files.
<br>If you are using Eclipse, this means your archive should include have the .project file
and src/ directories at the root of the archive.
<p>Files generated during compilation (i.e. .class or .o files) will be discarded by the server,
so don't worry if your submission includes them.

<h2>Submitting a flat list of files</h2>
<p>You can also submit a set of files from a single directory. 
All of the submitted files need to come from the same directory.
This works only on browsers that support HTML 5, and
 won't work if you need to submit files from different directories.
 <p><em>This is probably won't work for Java projects</em>, since they generally require 
 the files to be submitted within a certain directory structure. Instead, use the <a href="http://www.cs.umd.edu/~pugh/eclipse">
 Course Project Manager plugin for eclipse</a>, the command line submission tool, or create and submit a zip file.


<form name="submitform" enctype="multipart/form-data"
	action="<c:url value="/action/SubmitProjectViaWeb"/>" method="POST"><input type="hidden"
	name="projectPK" value="${project.projectPK}" /> <input type="hidden"
	name="submitClientTool" value="web" />
<table class="form">
<tr><th colspan=2>file(s) for submission</th>
<tr><td>File(s) to Submit: <td class="input"><input type="file" name="file" size=40 multiple/>
<tr class="submit"><td class="submit" colspan="2"><input type="submit" value="Submit project!">
</table>
</form>

<ss:footer />
</body>
</html>