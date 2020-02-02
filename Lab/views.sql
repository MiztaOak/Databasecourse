CREATE OR REPLACE VIEW BasicInformation AS (
	SELECT Students.idnr, Students.name, Students.login, Students.program, StudentBranches.branch as branch 
	FROM Students FULL OUTER JOIN StudentBranches ON Students.idnr = StudentBranches.student
);


CREATE OR REPLACE VIEW FinishedCourses AS(
	SELECT Taken.student, Taken.course, Taken.grade, Courses.credits
	FROM Taken, Courses
	WHERE Taken.course = Courses.code
);	

CREATE OR REPLACE VIEW PassedCourses AS(
	SELECT student, course, credits
	FROM FinishedCourses
	WHERE grade != 'U'
);

CREATE OR REPLACE VIEW Registrations AS(
	SELECT student, course , 'registered' AS status FROM Registered
	UNION
	SELECT student, course , 'waiting' AS status FROM WaitingList
);

CREATE OR REPLACE VIEW UnreadMandatory AS(
	SELECT Students.idnr as student, MandatoryProgram.course FROM Students, MandatoryProgram
	WHERE Students.program = MandatoryProgram.program
	UNION
	SELECT StudentBranches.student, MandatoryBranch.course FROM StudentBranches, MandatoryBranch
	WHERE StudentBranches.branch = MandatoryBranch.branch AND StudentBranches.program = MandatoryBranch.program
	EXCEPT
	SELECT student, course FROM PassedCourses
);

CREATE OR REPLACE VIEW PathToGraduation AS( 
	WITH
		totalCredits AS (
			SELECT student,SUM(credits) AS totalCredits FROM PassedCourses GROUP BY student
		),
		mandatoryLeft AS (
			SELECT student, COUNT(course) AS mandatoryLeft FROM UnreadMandatory GROUP BY student
		),
		allStudents AS (
			SELECT idnr AS student FROM Students
		),
		mathCredits AS (
			SELECT student, SUM(credits) AS mathCredits 
			FROM PassedCourses, Classified 
			WHERE PassedCourses.course = Classified.course AND Classified.classification = 'math' 
			GROUP BY PassedCourses.student
		),
		researchCredits AS (
			SELECT student, SUM(credits) AS researchCredits
			FROM PassedCourses, Classified 
			WHERE PassedCourses.course = Classified.course AND Classified.classification = 'research' 
			GROUP BY PassedCourses.student
		),
		seminarCourses AS (
			SELECT student, COUNT(PassedCourses.course) AS seminarCourses
			FROM PassedCourses, Classified 
			WHERE PassedCourses.course = Classified.course AND Classified.classification = 'seminar' GROUP BY PassedCourses.student
		),
		passedRecomended AS (
			SELECT StudentBranches.student, SUM(Courses.credits) AS passedRecomended FROM StudentBranches, RecommendedBranch, Courses
			WHERE StudentBranches.branch = RecommendedBranch.branch AND StudentBranches.Program = RecommendedBranch.Program AND
			RecommendedBranch.course = Courses.code GROUP BY StudentBranches.student
		),
		fullTable AS (
			SELECT * FROM allStudents	
			LEFT OUTER JOIN totalCredits USING (student) LEFT OUTER JOIN mandatoryLeft USING (student)
			LEFT OUTER JOIN mathCredits USING (student) LEFT OUTER JOIN researchCredits USING (student)
			LEFT OUTER JOIN seminarCourses USING (student) LEFT OUTER JOIN passedRecomended USING (student)
		)

	SELECT student, COALESCE(totalCredits,0) AS totalCredits, COALESCE(mandatoryLeft,0) AS mandatoryLeft, 
	COALESCE(mathCredits,0) AS mathCredits, COALESCE(researchCredits,0) AS researchCredits,
	COALESCE(seminarCourses,0) AS seminarCourses, (COALESCE(mandatoryLeft,0) = 0 AND 
	COALESCE(mathCredits,0) >= 20 AND COALESCE(researchCredits,0) >= 10 AND COALESCE(seminarCourses,0) >= 1 AND COALESCE(passedRecomended,0) >= 10) AS qualified 
	FROM fullTable
);
