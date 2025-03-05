SELECT jsonb_build_object('student',idnr,'name',name,'login',login, 'program', program , 'branch', branch, 
    'finshed', (SELECT jsonb_agg(jsonb_build_object('course', courseName, 'code', course , 'credits', credits, 'grade', grade)) FROM FinishedCourses WHERE student='2222222222'),
    'registered', (SELECT jsonb_agg(jsonb_build_object('course', name, 'code', course, 'status', status, position, 'position')) FROM 
    (SELECT  c.name , r.course, r.status, w.position
    FROM Registrations r
    JOIN Courses c ON r.course = c.code, 
    JOIN WaitingList w ON w.student = c.name
    WHERE r.student = '2222222222' ),
    'seminarCourses', (SELECT jsonb_build_object('seminarCourses', seminarCourses) FROM PathToGraduation WHERE student='2222222222'),
    'mathCredits', (SELECT jsonb_build_object('mathCredits', mathCredits) FROM PathToGraduation WHERE student='2222222222'),
    'totalCredits', (SELECT jsonb_build_object('number', totalCredits) FROM PathToGraduation WHERE student='2222222222'),
    'canGraduate', (SELECT jsonb_build_object('canGraduate', qualified) FROM PathToGraduation WHERE student='2222222222')
) AS jsondata FROM BasicInformation WHERE idnr='2222222222';