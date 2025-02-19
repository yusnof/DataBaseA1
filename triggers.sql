CREATE FUNCTION CountRegistered() RETURNS trigger AS $$
    --Check if student is allowed to join course(pre)
    --Check if LC
        --count capacity
        --Add student to waitingList or Registered
        --helper function to WaitingList insert and update positions.
        --
    DECLARE
    total INT; 
    help INT; 
    BEGIN 

    SELECT NEW.course FROM

    IF EXISTS (SELECT code FROM LimitedCourses WHERE new.course = code) THEN 
     total := (SELECT COUNT(course) FROM Registered WHERE course=NEW.course);
     help := (SELECT capacity FROM LimitedCourses WHERE course=NEW.course);
     IF (total >= help) THEN 
     RAISE EXCEPTION 'shit is illegal/You cannot join the course, you are too late';
     ELSE
     INSERT INTO Registered Values (NEW.s, New.code);
     END IF; 
    ELSE 
        INSERT INTO Registered VALUES (NEW.student, NEW.code);
    END IF;
         
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER RegisteredTrigger BEFORE INSERT ON Registered
    FOR EACH ROW EXECUTE FUNCTION CountRegistered();