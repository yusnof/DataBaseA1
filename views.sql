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
    -- List all program-mandatory courses for each student
    SELECT
        Students.idnr AS student,
        MandatoryProgram.course AS course
    FROM Students
    JOIN MandatoryProgram ON
        MandatoryProgram.program = Students.program
    LEFT JOIN PassedCourses ON
        Students.idnr = PassedCourses.student AND
        MandatoryProgram.course = PassedCourses.course
    WHERE PassedCourses.course IS NULL

    UNION

    -- List all branch-mandatory courses for each student
    SELECT
        Students.idnr AS student,
        MandatoryBranch.course AS course
    FROM Students
    JOIN StudentBranches ON
        Students.idnr = StudentBranches.student
    JOIN MandatoryBranch ON
        StudentBranches.branch = MandatoryBranch.branch AND
        StudentBranches.program = MandatoryBranch.program
    LEFT JOIN PassedCourses ON
        Students.idnr = PassedCourses.student AND
        MandatoryBranch.course = PassedCourses.course
    WHERE PassedCourses.course IS NULL
);

CREATE VIEW PathToGraduation AS (
    SELECT Students.idnr AS student,
    COALESCE(totalCredits,0) AS totalCredits,
    COALESCE(UnreadMandatory.mandatoryLeft, 0) AS mandatoryLeft,
    COALESCE(mathCredits, 0) AS mathCredits,
    COALESCE(SeminarCourses.seminarCourses, 0) AS seminarCourses,
    (COALESCE(PassedCourses.totalCredits, 0) > 10) AS qualified
    FROM Students
    LEFT JOIN (
        SELECT student, SUM(credits) AS totalCredits FROM PassedCourses 
        GROUP BY student) PassedCourses ON Students.idnr = PassedCourses.student
    LEFT JOIN (
        SELECT student, COUNT(course) AS mandatoryLeft FROM UnreadMandatory 
        GROUP BY student) UnreadMandatory ON Students.idnr = UnreadMandatory.student
    LEFT JOIN (SELECT student, SUM(credits) AS mathCredits FROM PassedCourses
        NATURAL JOIN Classified
        WHERE classifications = 'math'
        GROUP BY student)
        mathCredits ON Students.idnr = MathCredits.student
    LEFT JOIN (SELECT student, COUNT(course) AS seminarCourses FROM PassedCourses
        NATURAL JOIN Classified
        WHERE classifications = 'seminar'
        GROUP BY student)
        SeminarCourses ON Students.idnr = SeminarCourses.student
);