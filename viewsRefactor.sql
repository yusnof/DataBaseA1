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

