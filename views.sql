-- This file will contain all your views

-- Basic information about students like name and login in addition to Student branches if they exist. 

CREATE VIEW BasicInformation AS (
    SELECT Students.idnr, Students.name AS Name, Students.login, Students.program, StudentBranches.branch AS Branch
    FROM Students 
    LEFT OUTER JOIN
    StudentBranches ON Students.idnr = StudentBranches.student); 

-- all finished courses in a tabel with name of the students and the name of the courses. This is 
-- done with the combination of tabel Taken and Courses

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

--PassedCourses is made of the tabel FinishedCourses but we exclude the students with the not passing grade

CREATE VIEW PassedCourses AS (
    SELECT student, course, credits FROM FinishedCourses
    WHERE grade != 'U'
);

--Registrations is created with the combination of registered and waiting students 

CREATE VIEW Registrations AS (
    SELECT Registered.student, Registered.course, 'Registered' AS status
    FROM Registered
    UNION
    SELECT WaitingList.student, WaitingList.course, 'Waiting' AS status
    FROM WaitingList
);

--Mandatory courses that students haven't passed yet. Its created with taking all the table of student and the 
-- mandatory courses and cheacking it against the PassedCourses tabel 

CREATE VIEW UnreadMandatory AS (
    SELECT 
    Students.idnr AS student,
    MandatoryProgram.course AS course
    FROM Students
    JOIN MandatoryProgram ON Students.program = MandatoryProgram.program
    WHERE MandatoryProgram.course NOT IN (
        SELECT course FROM PassedCourses
        WHERE PassedCourses.student = Students.idnr
    )
    UNION
    SELECT
    Students.idnr AS student,
    MandatoryBranch.course AS course
    FROM Students
    JOIN StudentBranches ON Students.idnr = StudentBranches.student
    JOIN MandatoryBranch ON StudentBranches.branch = MandatoryBranch.branch AND StudentBranches.program = MandatoryBranch.program
    WHERE MandatoryBranch.course NOT IN (
        SELECT course FROM PassedCourses
        WHERE PassedCourses.student = Students.idnr
    )
);

-- Calculates:Total accumulated credits, remaining mandatory courses, math-specific credits,
-- completed seminar courses, qualification status based on credit thresholds

CREATE VIEW PathToGraduation AS (
    SELECT Students.idnr AS student,
    COALESCE(totalCredits,0) AS totalCredits,
    COALESCE(UnreadMandatory.mandatoryLeft, 0) AS mandatoryLeft,
    COALESCE(mathCredits, 0) AS mathCredits,
    COALESCE(SeminarCourses.seminarCourses, 0) AS seminarCourses,
    (COALESCE(PassedCourses.totalCredits, 0) > 10 AND 
    COALESCE(mathCredits, 0) >= 19 AND 
    COALESCE(seminarCourses, 0) >= 0)AS qualified
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