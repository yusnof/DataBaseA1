-- This file will contain all your views

CREATE VIEW BasicInformation AS (
    SELECT Students.idnr, Students.name AS Name, Students.login, Students.program, StudentBranches.branch AS Branch
    FROM Students 
    LEFT OUTER JOIN
    StudentBranches ON Students.idnr = StudentBranches.student); 

CREATE VIEW FinishedCourses AS (
    SELECT
    Taken.student, 
    Taken.course,
    Courses.name AS courseName,
    Taken.grade,
    Courses.credits
    FROM Taken
    JOIN Courses ON Taken.course = Courses.code
    WHERE Taken.grade IN ('U', '3', '4', '5')
);

CREATE VIEW PassedCourses AS (
    SELECT student, course, credits FROM FinishedCourses
    WHERE grade != 'U'
);

CREATE VIEW Registrations AS (
    SELECT Registered.student, Registered.course, 'Registered' AS status
    FROM Registered
    UNION
    SELECT WaitingList.student, WaitingList.course, 'Waiting' AS status
    FROM WaitingList
);

CREATE VIEW UnreadMandatory AS (
    SELECT
    Students.idnr AS student,
    MandatoryProgram.course AS course
    FROM Students
    JOIN MandatoryProgram ON
    MandatoryProgram.program = Students.program
    LEFT JOIN PassedCourses ON Students.idnr = PassedCourses.student AND MandatoryProgram.course = PassedCourses.course
    UNION
    SELECT
    Students.idnr AS student,
    MandatoryBranch.course
    FROM Students
    JOIN StudentBranches ON Students.idnr = StudentBranches.student
    JOIN MandatoryBranch ON StudentBranches.branch = MandatoryBranch.branch AND StudentBranches.program = MandatoryBranch.program
    LEFT JOIN PassedCourses ON Students.idnr = PassedCourses.student AND MandatoryBranch.course = PassedCourses.course
    WHERE PassedCourses.course IS NULL
);

/*
PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, seminarCourses, qualified)
*/


