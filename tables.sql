-- This file will contain all your tables
CREATE TABLE Students (
    idnr TEXT PRIMARY KEY
    CHECK (idnr SIMILAR TO ’[0-9]{10}’),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT);

CREATE TABLE Branches (
    name Text, 
    program Text, 
    PRIMARY KEY (name, program)
); 

CREATE TABLE Courses (
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses (
    code CHAR(6) PRIMARY KEY,
    capacity INT,
    FOREIGN KEY (code) REFERENCES Courses(code)
);

CREATE TABLE StudentBranches (
    student TEXT PRIMARY KEY,
    branch TEXT,
    program TEXT, 
    FOREIGN KEY (student) REFERENCES Students(idnr)
    FOREIGN KEY (branch) REFERENCES Branches(name)
    FOREIGN KEY (program) REFERENCES Branches(program)
);

CREATE TABLE Classifications (
    name TEXT PRIMARY KEY
);

CREATE TABLE MandatoryProgram (
    course TEXT,
    program TEXT,
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE MandatoryBranch (
    course TEXT, 
    branch TEXT,
    program TEXT
    PRIMARY KEY (course, branch, program), 
    FOREIGN KEY (course) REFERENCES Courses(code)
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program) 
);

CREATE TABLE Registered (
    student TEXT,
    course TEXT
    PRIMARY KEY (student, course)
    FOREIGN KEY (student) REFERENCES Students(idnr)
    FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Taken (
    student TEXT, 
    course TEXT,
    PRIMARY KEY (student, course)
    FOREIGN KEY (student) REFERENCES Students(idnr)
    FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE WaitingList (
    student TEXT,
    course TEXT,
    positon INT
    PRIMARY KEY (student, course)
    FOREIGN KEY (student) REFERENCES Students(idnr)
    FOREIGN KEY (course) REFERENCES LimitedCourses(code)
);