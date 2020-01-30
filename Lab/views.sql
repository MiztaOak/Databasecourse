CREATE VIEW BasicInformation AS (
	SELECT Students.idnr, Students.name, Students.login, Students.program, StudentBranches.name as branch 
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

SELECT student,COUNT(course) as mandatoryLeft FROM UnreadMandatory GROUP BY student;
