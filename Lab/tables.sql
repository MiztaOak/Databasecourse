CREATE TABLE Students (
	idnr CHAR(10) PRIMARY KEY,
	name TEXT NOT NULL, 
	login TEXT NOT NULL,
	program TEXT NOT NULL
);

CREATE TABLE Branches (
	name TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY(name, program)
);

CREATE TABLE Courses (
	code TEXT PRIMARY KEY,
	name TEXT NOT NULL,
	credits FLOAT NOT NULL,
	department TEXT NOT NULL,
	CHECK (credits >= 0)
);

CREATE TABLE LimitedCourses (
	code TEXT PRIMARY KEY,
	capacity INT NOT NULL,
	FOREIGN KEY (code) REFERENCES Courses(code)
);

CREATE TABLE StudentBranches (
	student CHAR(10) PRIMARY KEY,
	name TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (name, program) REFERENCES Branches(name,program)
);

CREATE TABLE Classifications (
	name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
	course TEXT,
	classification TEXT,
	PRIMARY KEY (course,classification),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (classification) REFERENCES Classifications(name)
);

CREATE TABLE MandatoryProgram (
	course TEXT,
	program TEXT,
	PRIMARY KEY (course,program),
	FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE MandatoryBranch (
	course TEXT,
	branch TEXT, 
	program TEXT,
	PRIMARY KEY (course,branch,program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE RecommendedBranch (
	course TEXT,
	branch TEXT,
	program TEXT,
	PRIMARY KEY (course,branch,program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Registered (
	student CHAR(10),
	course TEXT,

	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Taken (
	student CHAR(10),
	course TEXT,
	grade CHAR(1) NOT NULL,
	CHECK (grade = '3' OR grade = '4' OR grade = '5' OR grade = 'U'),

	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE WaitingList (
	student CHAR(10),
	course TEXT,
	position INT NOT NULL,
	CHECK (position >= 0),

	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES LimitedCourses(code)
);