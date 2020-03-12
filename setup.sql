CREATE TABLE Students (
	idnr CHAR(10) PRIMARY KEY,
	name TEXT NOT NULL, 
	login TEXT NOT NULL UNIQUE
);

CREATE TABLE Programs(
	name TEXT PRIMARY KEY,
	abr TEXT NOT NULL
);

CREATE TABLE StudentProgram(
	student CHAR(10) PRIMARY KEY,
	program TEXT NOT NULL,
	UNIQUE(student,program),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (program) REFERENCES Programs(name)
);


CREATE TABLE Departments(
	name TEXT PRIMARY KEY,
	abr TEXT UNIQUE NOT NULL 
);

CREATE TABLE DepartmentHosts(
	department TEXT,
	program TEXT,
	PRIMARY KEY (department,program),
	FOREIGN KEY (department) REFERENCES Departments(name),
	FOREIGN KEY (program) REFERENCES Programs(name)
);

CREATE TABLE Branches (
	name TEXT,
	program TEXT,
	PRIMARY KEY(name, program),
	FOREIGN KEY (program) REFERENCES Programs(name)
);

CREATE TABLE StudentBranches (
	student CHAR(10) PRIMARY KEY,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (student,program) REFERENCES StudentProgram(student,program),
	FOREIGN KEY (branch, program) REFERENCES Branches(name,program)
);

CREATE TABLE Courses (
	code CHAR(6) PRIMARY KEY,
	name TEXT NOT NULL,
	credits FLOAT NOT NULL,
	CHECK (credits >= 0)
);

CREATE TABLE LimitedCourses (
	code CHAR(6) PRIMARY KEY,
	capacity INT NOT NULL,
	FOREIGN KEY (code) REFERENCES Courses(code)
);

CREATE TABLE CoursesGivenBy( 
	course CHAR(6) PRIMARY KEY,
	department TEXT NOT NULL,
	FOREIGN KEY (department) REFERENCES Departments(name)
);

CREATE TABLE Prerequisites (
	course CHAR(6),
	prerequisite CHAR(6) NOT NULL,
	PRIMARY KEY (course,prerequisite),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (prerequisite) REFERENCES Courses(code)
);


CREATE TABLE Classifications (
	name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
	course CHAR(6),
	classification TEXT,
	PRIMARY KEY (course,classification),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (classification) REFERENCES Classifications(name)
);

CREATE TABLE MandatoryProgram (
	course CHAR(6),
	program TEXT,
	PRIMARY KEY (course,program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (program) REFERENCES Programs(name)
);

CREATE TABLE MandatoryBranch (
	course CHAR(6),
	branch TEXT, 
	program TEXT,
	PRIMARY KEY (course,branch,program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE RecommendedBranch (
	course CHAR(6),
	branch TEXT,
	program TEXT,
	PRIMARY KEY (course,branch,program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Registered (
	student CHAR(10),
	course CHAR(6),

	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Taken (
	student CHAR(10),
	course CHAR(6),
	grade CHAR(1) NOT NULL,
	CHECK (grade = '3' OR grade = '4' OR grade = '5' OR grade = 'U'),

	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE WaitingList (
	student CHAR(10),
	course CHAR(6),
	position INT NOT NULL,
	CHECK (position >= 0),
	UNIQUE(course,position),
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES LimitedCourses(code)
);

INSERT INTO Departments VALUES ('Dep1','d1');
INSERT INTO Departments VALUES ('Dep2','d2');

INSERT INTO Programs VALUES ('Prog1','p1');
INSERT INTO Programs VALUES ('Prog2','p1');

INSERT INTO DepartmentHosts VALUES ('Dep1','Prog1');
INSERT INTO DepartmentHosts VALUES ('Dep2','Prog1');
INSERT INTO DepartmentHosts VALUES ('Dep1','Prog2');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1');
INSERT INTO Students VALUES ('2222222222','N2','ls2');
INSERT INTO Students VALUES ('3333333333','N3','ls3');
INSERT INTO Students VALUES ('4444444444','N4','ls4');
INSERT INTO Students VALUES ('5555555555','Nx','ls5');
INSERT INTO Students VALUES ('6666666666','Nx','ls6');

INSERT INTO StudentProgram VALUES ('1111111111','Prog1');
INSERT INTO StudentProgram VALUES ('2222222222','Prog1');
INSERT INTO StudentProgram VALUES ('3333333333','Prog2');
INSERT INTO StudentProgram VALUES ('4444444444','Prog1');
INSERT INTO StudentProgram VALUES ('5555555555','Prog2');
INSERT INTO StudentProgram VALUES ('6666666666','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5);
INSERT INTO Courses VALUES ('CCC222','C2',20);
INSERT INTO Courses VALUES ('CCC333','C3',30);
INSERT INTO Courses VALUES ('CCC444','C4',40);
INSERT INTO Courses VALUES ('CCC555','C5',50);

INSERT INTO Prerequisites VALUES ('CCC444','CCC333');

INSERT INTO CoursesGivenBy VALUES ('CCC111','Dep1');
INSERT INTO CoursesGivenBy VALUES ('CCC222','Dep1');
INSERT INTO CoursesGivenBy VALUES ('CCC333','Dep1');
INSERT INTO CoursesGivenBy VALUES ('CCC444','Dep1');
INSERT INTO CoursesGivenBy VALUES ('CCC555','Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',1);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');

INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC555', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');

CREATE OR REPLACE VIEW BasicInformation AS (
	SELECT Students.idnr, Students.name, Students.login, StudentProgram.program as program, StudentBranches.branch as branch 
	FROM Students FULL OUTER JOIN StudentProgram ON Students.idnr = StudentProgram.student FULL OUTER JOIN StudentBranches ON Students.idnr = StudentBranches.student
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
	SELECT StudentProgram.student as student, MandatoryProgram.course FROM StudentProgram, MandatoryProgram
	WHERE StudentProgram.program = MandatoryProgram.program
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
			SELECT StudentBranches.student, SUM(PassedCourses.credits) AS passedRecomended FROM StudentBranches, RecommendedBranch, PassedCourses
			WHERE StudentBranches.branch = RecommendedBranch.branch AND StudentBranches.Program = RecommendedBranch.Program AND
			RecommendedBranch.course = PassedCourses.course AND StudentBranches.student = PassedCourses.student GROUP BY StudentBranches.student
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

CREATE OR REPLACE VIEW CourseQueuePositions AS(
	SELECT student, course, position AS place FROM WaitingList ORDER BY course
);
