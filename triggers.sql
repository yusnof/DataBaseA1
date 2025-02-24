CREATE FUNCTION CountRegistered() RETURNS trigger AS $$
    --Check if student is allowed to join course(pre)
    --Check if LC
        --count capacity
        --Add student to waitingList or Registered
        --helper function to WaitingList insert and update positions.
        --
    DECLARE
    totalReg INT; 
    capacity INT; 
    waiting INT;
    BEGIN    
    IF NOT EXISTS ((SELECT course FROM PreRequisites WHERE NEW.course = course)
        EXCEPT
        (SELECT course FROM Taken WHERE NEW.student = student))
    THEN 
        IF EXISTS (SELECT code FROM LimitedCourses WHERE new.course = code) THEN 
        totalReg := (SELECT COUNT(course) FROM Registrations WHERE course=NEW.course);
        capacity := (SELECT LimitedCourses.capacity FROM LimitedCourses WHERE code=NEW.course);
        waiting := (SELECT COUNT(Registrations.status) FROM Registrations where Registrations.status='waiting');
         IF (totalReg >= capacity) THEN
            INSERT INTO WaitingList Values (NEW.student, NEW.course, (waiting+1));
        --RAISE EXCEPTION 'shit is illegal/You cannot join the course, you are too late';
         ELSE
            INSERT INTO Registered Values (NEW.student, NEW.course);
         END IF; 
        ELSE 
            INSERT INTO Registered VALUES (NEW.student, NEW.course);
        END IF;  
    ELSE
    RAISE EXCEPTION 'You do not meet the Pre-requirements for the course, git g0d slacker(SIMON)';
    END IF; 
    RETURN NEW;      
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unRegister() RETURNS trigger AS $$
DECLARE
BEGIN 
  IF EXISTS (SELECT student FROM Registrations WHERE Registrations.status = 'registered' AND NEW.student = student and new.course = course) 
  THEN    
    DELETE FROM Registrations WHERE NEW.student = student;
  ELSEIF EXISTS (SELECT student FROM Registrations WHERE registrations.status = 'waiting' AND NEW.student = student and new.course = course)
  THEN  
   DELETE FROM WaitingList WHERE NEW.student = student;
  END IF;
  RETURN OLD; 
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER RegisteredTrigger 
INSTEAD OF INSERT ON Registrations
FOR EACH ROW 
EXECUTE FUNCTION CountRegistered();

CREATE OR REPLACE TRIGGER unregistered
INSTEAD OF DELETE ON Registrations
FOR EACH ROW
EXECUTE FUNCTION unRegister();