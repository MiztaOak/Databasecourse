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
	PRIMARY KEY (course,prerequist),
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