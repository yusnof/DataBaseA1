-- This file will contain all your views

CREATE VIEW BasicInformation AS (
    SELECT Students.idnr, Students.name AS Name, Students.login, Students.program, StudentBranches.branch AS Branch
    FROM Students 
    LEFT OUTER JOIN
    StudentBranches ON Students.idnr = StudentBranches.student); 

CREATE VIEW PassedCourses AS (
    SELECT 
    Taken.student,
    Taken.course, 
    Courses.credits 
    FROM Taken
    LEFT OUTER JOIN Courses ON Taken.course = Courses.code 
    WHERE Taken.grade != 'U'
    );

CREATE VIEW UnreadMandatory AS (
    SELECT
    Students.idnr,
    MandatoryProgram.course AS course
    FROM Students
    LEFT OUTER JOIN MandatoryProgram ON
    MandatoryProgram.program = Students.program
);

CREATE VIEW FinishedCourses AS (
  SELECT Students.name As Name, 
  Taken.course As Course, 
  Course.name AS courseName, 
  Taken.grade AS grade,  
  Course.credits As credits 
  FROM Students
  LEFT OUTER JOIN PassedCourses 
  ON Taken.course = PassedCourses.course
); 


/*
FinishedCourses(student, course, courseName, grade, credits): for all students, all finished courses, along with their codes, (course) names, grades ('U', '3', '4' or '5') and number of credits. The type of the grade should be a character type, e.g. CHAR(1).
Registrations(student, course, status): all registered and waiting students for all courses, along with their waiting status ('registered' or 'waiting').
PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, seminarCourses, qualified)
*/


