CREATE VIEW registered_courses_view AS
SELECT 
  r.student,
  jsonb_agg(
    jsonb_build_object(
      'course', c.name,
      'code', r.course,
      'status', r.status,
      'position', COALESCE(w.position, 0)
    )
  ) AS registered_courses
FROM Registrations r
JOIN Courses c ON r.course = c.code
LEFT JOIN WaitingList w ON w.student = r.student AND w.course = r.course
GROUP BY r.student;

CREATE VIEW finished_courses_view AS
SELECT 
  student,
  jsonb_agg(
    jsonb_build_object(
      'course', courseName,
      'code', course,
      'credits', credits,
      'grade', grade
    )
  ) AS finished_courses
FROM FinishedCourses
GROUP BY student;

CREATE VIEW graduation_path_view AS
SELECT 
  student,
  seminarCourses,
  mathCredits,
  totalCredits,
  qualified AS can_graduate
FROM PathToGraduation;


SELECT jsonb_build_object(
  'student', b.idnr,
  'name', b.name,
  'login', b.login,
  'program', b.program,
  'branch', b.branch,
  'finished', f.finished_courses,
  'registered', COALESCE(r.registered_courses, '[]'::jsonb),
  'seminarCourses', g.seminarCourses,
  'mathCredits', g.mathCredits,
  'totalCredits', g.totalCredits,
  'canGraduate', g.can_graduate
) AS jsondata
FROM BasicInformation b
LEFT JOIN finished_courses_view f ON b.idnr = f.student
LEFT JOIN registered_courses_view r ON b.idnr = r.student
LEFT JOIN graduation_path_view g ON b.idnr = g.student
WHERE b.idnr = ?;