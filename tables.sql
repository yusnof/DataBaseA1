-- This file will contain all your tables
CREATE TABLE Students (
    idnr TEXT PRIMARY KEY
    CHECK (idnr SIMILAR TO '[0-9]{10}'),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT
    );

CREATE TABLE Branches (
    name Text, 
    program Text, 
    PRIMARY KEY (name, program)
); 

CREATE TABLE Courses (
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL
    CHECK (credits >= 0 AND credits <= 60),
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses (
    code CHAR(6) PRIMARY KEY,
    capacity INT,
    FOREIGN KEY (code) REFERENCES Courses(code)
);

CREATE TABLE StudentBranches (
    student TEXT PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL, 
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Classifications (
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
    course TEXT,
    classifications TEXT,
    PRIMARY KEY (course, classifications),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (classifications) REFERENCES Classifications(name)
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
    program TEXT,
    PRIMARY KEY (course, branch, program), 
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program) 
);

CREATE TABLE RecommendedBranch(
    course TEXT,
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program), 
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)    
);

CREATE TABLE Registered (
    student TEXT,
    course TEXT,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Taken (
    student TEXT, 
    course TEXT,
    grade CHAR(1) DEFAULT 'U',
    CONSTRAINT okgrade CHECK (grade in ('U', '3', '4', '5')),

    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE WaitingList (
    student TEXT,
    course TEXT,
    positon INT,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses(code)
);