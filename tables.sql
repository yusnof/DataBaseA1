-- This file will contain all your tables
--Creates a table for the students
--The table contains the idnr, name, login, and program of the students
--The idnr is the primary key of the table and is checked to be a 10-digit number
CREATE TABLE Students (
    idnr TEXT PRIMARY KEY
    CHECK (idnr SIMILAR TO '[0-9]{10}'),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT
    );

--Creates a table for the branches
CREATE TABLE Branches (
    name Text, 
    program Text, 
    PRIMARY KEY (name, program)
); 

--Creates a table for the courses
--The table contains the code, name, credits, and department of the courses
--The code is the primary key of the table
--The credits are checked to be between 0 and 60
CREATE TABLE Courses (
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL
    CHECK (credits >= 0 AND credits <= 60),
    department TEXT NOT NULL
);

--Creates a table for the limited courses
CREATE TABLE LimitedCourses (
    code CHAR(6) PRIMARY KEY,
    capacity INT,
    FOREIGN KEY (code) REFERENCES Courses(code)
);

--Creates a table for the student branches
CREATE TABLE StudentBranches (
    student TEXT PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL, 
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

--Creates a table for the classifications
CREATE TABLE Classifications (
    name TEXT PRIMARY KEY
);

--Creates a table for the classified courses
CREATE TABLE Classified (
    course TEXT,
    classification TEXT,
    PRIMARY KEY (course, classification),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (classification) REFERENCES Classifications(name)
);

--Creates a table for the passed courses
CREATE TABLE MandatoryProgram (
    course TEXT,
    program TEXT,
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses
);

--Creates a table for the mandatory branches
CREATE TABLE MandatoryBranch (
    course TEXT, 
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program), 
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program) 
);

--Creates a table for the recommended courses
CREATE TABLE RecommendedBranch(
    course TEXT,
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program), 
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)    
);

--Creates a table for the recommended branches
CREATE TABLE Registered (
    student TEXT,
    course TEXT,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

--Creates a table for the taken courses
--The table contains the student, course, and grade of the taken courses
--The grade is checked to be one of 'U', '3', '4', or '5'
CREATE TABLE Taken (
    student TEXT, 
    course TEXT,
    grade CHAR(1) DEFAULT 'U',
    CONSTRAINT okgrade CHECK (grade in ('U', '3', '4', '5')),

    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

--Creates a table for the waiting list
CREATE TABLE WaitingList (
    student TEXT,
    course TEXT,
    position INT,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses(code)
);