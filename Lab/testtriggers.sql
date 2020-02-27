CREATE OR REPLACE FUNCTION addToList() RETURNS trigger AS $$
    DECLARE 
        prerequisitesCount Integer := SELECT COUNT(prerequisite) FROM prerequisites WHERE course = NEW.course;
        takenPrerequisitesCount Integer := SELECT COUNT(course) FROM prerequisites, taken WHERE student = NEW.student AND prerequisites.course = NEW.course AND taken.course = prerequisites.prerequisite;
    BEGIN
        IF (prerequisitesCount <> takenPrerequisitesCount) THEN
            RAISE EXCEPTION 'Has not taken prerequisites';
            RETURN NULL;
        END IF;
        IF (SELECT student FROM Registrations WHERE student = NEW.student AND course = NEW.course) IS NOT NULL THEN
            RAISE EXCEPTION '% already on course';
            RETURN NULL;
        END IF;
        INSERT INTO WaitingList VALUES (NEW.student, NEW.course);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS register_student ON Registrations;
CREATE TRIGGER register_student INSTEAD OF INSERT ON Registrations FOR EACH ROW EXECUTE PROCEDURE addToList();