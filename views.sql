-- This file will contain all your views

-- Basic information about students like name and login in addition to Student branches if they exist. 
--The view is created by joining the Students table with the StudentBranches table
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

CREATE VIEW PassedCourses AS (
    SELECT student, course, credits FROM FinishedCourses
    WHERE grade != 'U'
);

--Creates a view that shows the registrations of the students
--The view is created by joining the Registered table with the WaitingList table
--The status column is added to differentiate between registered and waiting students
CREATE VIEW Registrations AS (
    SELECT Registered.student, Registered.course, 'registered' AS status
    FROM Registered
    UNION
    SELECT WaitingList.student, WaitingList.course, 'waiting' AS status
    FROM WaitingList
);

--Creates a view that shows the mandatory courses that the students have not yet taken
--The view is created by joining the Students table with the MandatoryProgram and MandatoryBranch tables
--The view is created by using a UNION to combine the mandatory courses from the MandatoryProgram and MandatoryBranch tables
CREATE VIEW UnreadMandatory AS (
    SELECT 
    Students.idnr AS student,
    MandatoryProgram.course AS course
    FROM Students
    JOIN MandatoryProgram ON Students.program = MandatoryProgram.program
    --The WHERE clause filters out the courses that the student has already passed
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
    --The WHERE clause filters out the courses that the student has already passed
    WHERE MandatoryBranch.course NOT IN (
        SELECT course FROM PassedCourses
        WHERE PassedCourses.student = Students.idnr
    )
);

-- This view calculates the total credits a student has earned from courses recommended 
-- for their branch and program. It joins `StudentBranches` with `RecommendedBranch` 
-- to find relevant courses, then sums the credits of those the student has passed.
CREATE VIEW Helper AS 
    SELECT StudentBranches.Student, SUM(PassedCourses.credits) AS recommendedBranchCredits
        FROM StudentBranches
        JOIN RecommendedBranch ON StudentBranches.program = RecommendedBranch.program
        AND StudentBranches.branch = RecommendedBranch.branch
        JOIN PassedCourses
        ON StudentBranches.student = PassedCourses.student AND RecommendedBranch.course = PassedCourses.course
        GROUP BY StudentBranches.Student;

--Creates a view that shows the recommended courses for the students
--The view is created by joining the Students table with the RecommendedProgram and RecommendedBranch tables
CREATE VIEW PathToGraduation AS
    SELECT 
        Students.idnr AS student,
        --Coalesce is used to handle NULL values and replace them with 0
        COALESCE(PassedCourses.totalCredits, 0) AS totalCredits,
        COALESCE(UnreadMandatory.mandatoryLeft, 0) AS mandatoryLeft,
        COALESCE(mathCredits.mathCredits, 0) AS mathCredits,
        COALESCE(SeminarCourses.seminarCourses, 0) AS seminarCourses,
        -- Qualification criteria
        (
            COALESCE(PassedCourses.totalCredits, 0) >= 10 AND 
            COALESCE(mathCredits.mathCredits, 0) >= 20 AND 
            COALESCE(SeminarCourses.seminarCourses, 0) >= 1 AND
            COALESCE(UnreadMandatory.mandatoryLeft, 0) = 0 AND
            COALESCE(Helper.recommendedBranchCredits, 0) >= 10
        ) AS qualified
    FROM Students
    -- Calculate total credits
    LEFT JOIN (
        SELECT student, SUM(credits) AS totalCredits 
        FROM PassedCourses 
        GROUP BY student
    ) PassedCourses ON Students.idnr = PassedCourses.student
    -- Calculate number of mandatory courses left
    LEFT JOIN (
        SELECT UnreadMandatory.student, COUNT(UnreadMandatory.course) AS mandatoryLeft 
        FROM UnreadMandatory
        GROUP BY UnreadMandatory.student
    ) UnreadMandatory ON Students.idnr = UnreadMandatory.student
    -- Calculate math credits
    LEFT JOIN (
        SELECT student, SUM(credits) AS mathCredits 
        FROM PassedCourses
        NATURAL JOIN Classified
        WHERE classification = 'math'
        GROUP BY student
    ) mathCredits ON Students.idnr = mathCredits.student
    -- Calculate number of seminar courses
    LEFT JOIN (
        SELECT student, COUNT(course) AS seminarCourses 
        FROM PassedCourses
        NATURAL JOIN Classified
        WHERE classification = 'seminar'
        GROUP BY student
    ) SeminarCourses ON Students.idnr = SeminarCourses.student
    LEFT JOIN Helper ON Students.idnr = Helper.student;