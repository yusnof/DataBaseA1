-- This file will contain all your views


CREATE VIEW BasicInformation AS (
    SELECT Students.idnr, Students.name AS Name, Students.login, Students.program, Branches.name AS Branch
    FROM Students 
    LEFT OUTER JOIN 
    Branches ON Students.program = Branches.program); 

