-- This file will contain all your tables
--Creates a table for the students
--The table contains the idnr, name, login, and program of the students
--The idnr is the primary key of the table and is checked to be a 10-digit number
CREATE TABLE
    Students (
        idnr TEXT PRIMARY KEY CHECK (idnr SIMILAR TO '[0-9]{10}'),
        name TEXT NOT NULL,
        login TEXT NOT NULL,
        program TEXT,
        UNIQUE (login),
        UNIQUE (idnr, program)
    );

CREATE TABLE Programs (
    name TEXT PRIMARY KEY,
    abbr TEXT NOT NULL,
    UNIQUE (name, abbr)
    );

CREATE TABLE
    Branches (
        name Text,
        program Text,
        PRIMARY KEY (name, program)
    );

CREATE TABLE
    Departments (
        name TEXT PRIMARY KEY, 
        abbr TEXT NOT NULL,
        UNIQUE(abbr)
        );

--Creates a table for the courses
--The table contains the code, name, credits, and department of the courses
--The code is the primary key of the table
--The credits are checked to be between 0 and 60
CREATE TABLE
    Courses (
        code CHAR(6) PRIMARY KEY,
        name TEXT NOT NULL,
        credits FLOAT NOT NULL CHECK (credits >= 0),
        department TEXT NOT NULL,
        FOREIGN KEY (department) REFERENCES Departments(name)
    );

--Creates a table for the limited courses
CREATE TABLE
    LimitedCourses (
        code CHAR(6) PRIMARY KEY,
        capacity INT NOT NULL CHECK (
            capacity >= 0
            AND capacity <= 100
        ),
        FOREIGN KEY (code) REFERENCES Courses (code),
        UNIQUE(code)
    );

--Creates a table for the student branches
CREATE TABLE
    StudentBranches (
        student TEXT PRIMARY KEY CHECK (student SIMILAR TO '[0-9]{10}'),
        branch TEXT NOT NULL,
        program TEXT NOT NULL,
        FOREIGN KEY (branch, program) REFERENCES Branches (name, program),
        FOREIGN KEY (student, program) REFERENCES Students(idnr, program)
    );

--Creates a table for the classifications
CREATE TABLE
    Classifications (name TEXT PRIMARY KEY);

    --Creates a table for the classified courses
CREATE TABLE
    Classified (
        course CHAR(6),
        classification TEXT,
        PRIMARY KEY (course, classification),
        FOREIGN KEY (course) REFERENCES Courses (code),
        FOREIGN KEY (classification) REFERENCES Classifications (name)
    );

--Creates a table for the passed courses
CREATE TABLE
    MandatoryProgram (
        course CHAR(6),
        program TEXT,
        PRIMARY KEY (course, program),
        FOREIGN KEY (course) REFERENCES Courses(code),
        FOREIGN KEY (program) REFERENCES Programs(name)
    );

--Creates a table for the mandatory branches
CREATE TABLE
    MandatoryBranch (
        course CHAR(6),
        branch TEXT,
        program TEXT,
        PRIMARY KEY (course, branch, program),
        FOREIGN KEY (course) REFERENCES Courses (code),
        FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
    );

--Creates a table for the recommended courses
CREATE TABLE
    RecommendedBranch (
        course CHAR(6),
        branch TEXT,
        program TEXT,
        PRIMARY KEY (course, branch, program),
        FOREIGN KEY (course) REFERENCES Courses (code),
        FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
    );

--Creates a table for the recommended branches
CREATE TABLE
    Registered (
        student TEXT CHECK (student SIMILAR TO '[0-9]{10}'),
        course CHAR(6),
        PRIMARY KEY (student, course),
        FOREIGN KEY (student) REFERENCES Students (idnr),
        FOREIGN KEY (course) REFERENCES Courses (code)
    );

--Creates a table for the taken courses
--The table contains the student, course, and grade of the taken courses
--The grade is checked to be one of 'U', '3', '4', or '5'
CREATE TABLE
    Taken (
        student TEXT CHECK (student SIMILAR TO '[0-9]{10}'),
        course CHAR(6),
        grade CHAR(1) DEFAULT 'U' NOT NULL,
        CONSTRAINT okgrade CHECK (grade in ('U', '3', '4', '5')),
        PRIMARY KEY (student, course),
        FOREIGN KEY (student) REFERENCES Students (idnr),
        FOREIGN KEY (course) REFERENCES Courses (code)
    );

--Creates a table for the waiting list
CREATE TABLE
    WaitingList (
        student TEXT CHECK (student SIMILAR TO '[0-9]{10}'),
        courseCode CHAR(6),
        position INT NOT NULL,
        PRIMARY KEY (student),
        FOREIGN KEY (student) REFERENCES Students (idnr),
        FOREIGN KEY (courseCode) REFERENCES LimitedCourses (code),
        CHECK (position >= 0),
        UNIQUE(position, courseCode) 
    );

CREATE TABLE GivenBy (
        program TEXT,
        abbr TEXT,
        department TEXT,
        PRIMARY KEY (program, department),
        FOREIGN KEY (program, abbr) REFERENCES Programs(name, abbr),
        FOREIGN KEY (department) REFERENCES Departments(name)
);

CREATE TABLE PreRequisites (
    course TEXT,
    preName TEXT,
    PRIMARY KEY (course, preName),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (preName) REFERENCES Courses(code)
);