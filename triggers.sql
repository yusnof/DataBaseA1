CREATE FUNCTION CountRegistered() RETURNS trigger AS $$
    DECLARE
    totalReg INT; 
    capacity INT; 
    waiting INT;
    BEGIN 
    --We first cheack if the student aldready taken the course
    IF EXISTS (SELECT course FROM PassedCourses WHERE NEW.student = student AND NEW.course = course) THEN 
    RAISE EXCEPTION 'Student has passed course';
    ELSE 
    --We cheack if the student meet the prerequisites of this specific course. 
    IF NOT EXISTS (((SELECT prerequisite FROM PreRequisites WHERE NEW.course = course))
        EXCEPT
        (SELECT course FROM PassedCourses WHERE NEW.student = student )) 
    THEN 
        -- The cheack if the course is limited or not. 
        IF EXISTS (SELECT code FROM LimitedCourses WHERE new.course = code) THEN 
        totalReg := (SELECT COUNT(course) FROM Registrations WHERE course=NEW.course AND Registrations.status = 'registered');
        capacity := (SELECT LimitedCourses.capacity FROM LimitedCourses WHERE code=NEW.course);
        waiting := (SELECT COUNT(Registrations.status) FROM Registrations where course = NEW.course AND Registrations.status='waiting');
        --if the calculation results that is no space we add to WaitingList
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
    END IF; 
    RETURN NEW;      
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unRegister() RETURNS trigger AS $$
DECLARE
removed_position INT;
next_student TEXT;
next_course TEXT;
lc_cap INT;
totalReg INT;
BEGIN
-- we check if the student is registered in the course
IF NOT EXISTS (SELECT student FROM Registrations WHERE OLD.student = student AND OLD.course = course)
    THEN
    RAISE EXCEPTION 'Student is not registered or in waiting list';
    ELSE
    IF EXISTS (SELECT student FROM Registrations WHERE OLD.student = student AND OLD.course = course)
    THEN 
        DELETE FROM Registered WHERE OLD.student = student AND OLD.course = course;
        
        SELECT student, course INTO next_student, next_course FROM WaitingList WHERE OLD.course = course ORDER BY position ASC LIMIT 1;
        SELECT capacity INTO lc_cap FROM LimitedCourses WHERE OLD.course = code;
        SELECT COUNT(course) INTO totalReg FROM Registered WHERE OLD.course = course;

        -- if this student is on the waitingList and there is space in the course 
        IF (next_student IS NOT NULL AND lc_cap > totalReg) 
        THEN
            INSERT INTO Registered VALUES (next_student, next_course);
            DELETE FROM WaitingList WHERE student = next_student AND course = next_course;
            UPDATE WaitingList SET position = position - 1 WHERE OLD.course = course;
        END IF;
    END IF;
    -- Here we check if the student is on the waitingList and if its true, we remove from 
    -- the waitingList and the shift the position of the remaining students to insure the 
    --correct position 
    IF EXISTS (SELECT 1 FROM WaitingList WHERE OLD.student = student AND OLD.course = course)
    THEN
        SELECT position INTO removed_position FROM WaitingList WHERE OLD.student = student AND OLD.course = course;
        DELETE FROM WaitingList WHERE OLD.student = student AND OLD.course = course;
        UPDATE WaitingList SET position = position - 1 WHERE OLD.course = course AND position > removed_position;
    END IF;
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