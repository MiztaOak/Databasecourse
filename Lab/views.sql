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
	(SELECT student, course , 'registered' AS status FROM Registered
	UNION
	SELECT student, course , 'waiting' AS status FROM WaitingList)
	ORDER BY status ASC
);

CREATE OR REPLACE VIEW UnreadMandatory(
	(SELECT Student.idnr, MandatoryProgram.course FROM Student, MandatoryProgram
	WHERE Student.program = MandatoryProgram.program
	UNION
	SELECT Student.student, MandatoryBranches.course FROM StudentBranches, MandatoryBranches
	WHERE StudentBranches.branch = MandatoryBranches.branch)
	EXCEPT
	SELECT * FROM PassedCourses
);