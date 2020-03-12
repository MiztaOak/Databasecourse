CREATE OR REPLACE FUNCTION registerToList() RETURNS trigger AS $$
	DECLARE 
        prerequisitesCount Integer;
        takenPrerequisitesCount Integer;
	BEGIN
		--Amount of prerequisites required
		SELECT COUNT(prerequisite) INTO prerequisitesCount FROM prerequisites WHERE course = NEW.course;
		--Amount of taken courses overlapping with prerequisites
        SELECT COUNT(prerequisites.course) INTO takenPrerequisitesCount FROM prerequisites, taken WHERE student = NEW.student AND prerequisites.course = NEW.course AND taken.course = prerequisites.prerequisite AND taken.grade != 'U';

		--If amount of prerequisites taken is not equal the amount of courses in both taken and prerequisites the student has not taken all the prerequisites.
		IF (prerequisitesCount <> takenPrerequisitesCount) THEN
            RAISE EXCEPTION 'Has not taken prerequisites';
            RETURN NULL;
        END IF;
		--Check if the student has already taken the course
		IF (SELECT student FROM Taken WHERE course = New.course AND student = New.Student) IS NOT NULL THEN
			RAISE EXCEPTION 'already taken course';
			RETURN NULL;
		END IF;
		--Check if the student is already registred on the course
		IF (SELECT student FROM Registrations WHERE student = NEW.Student AND course = NEW.course) IS NOT NULL THEN
			RAISE EXCEPTION 'already registered to the course';
			RETURN NULL;
		END IF;
		--check for prereq
		
		-- is limited
		IF (SELECT code FROM LimitedCourses WHERE code = NEW.course) IS NOT NULL THEN
			IF ((SELECT COUNT(student) FROM Registered WHERE course = NEW.course) >= (SELECT capacity FROM LimitedCourses WHERE code = NEW.course)) THEN
				INSERT INTO WaitingList VALUES (NEW.student,NEW.course);
				RETURN NEW;
			END IF;
		END IF;
		INSERT INTO Registered VALUES (NEW.Student,New.Course);
		RETURN NEW;
	END;
$$ LANGUAGE  plpgsql;

DROP TRIGGER IF EXISTS check_can_register ON Registrations;
CREATE TRIGGER check_can_register INSTEAD OF INSERT ON Registrations FOR EACH ROW EXECUTE PROCEDURE registerToList();

CREATE OR REPLACE FUNCTION removeFromList() RETURNS trigger AS $$
	DECLARE 
		firstStudent Text;
	BEGIN
		SELECT student INTO firstStudent FROM WaitingList WHERE position = 1 AND course = OLD.course;

		IF OLD.status = 'waiting' THEN
			DELETE FROM WaitingList WHERE course = OLD.course AND student = OLD.student;
		ELSE
			DELETE FROM Registered WHERE course = OLD.course AND student = OLD.student;
			IF ((SELECT COUNT(student) FROM Registered WHERE course = OLD.course) < (SELECT capacity FROM LimitedCourses WHERE code = OLD.course)) THEN
				IF firstStudent IS NOT NULL THEN
					INSERT INTO Registered VALUES (firstStudent,OLD.course);
					DELETE FROM WaitingList WHERE position = 1 AND course = OLD.course;
				END IF;
			END IF;
		END IF;
		RETURN OLD;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS student_unregister ON Registrations;
CREATE TRIGGER student_unregister INSTEAD OF DELETE ON Registrations FOR EACH ROW EXECUTE PROCEDURE removeFromList();

CREATE OR REPLACE FUNCTION inser_waitingList() RETURNS trigger AS $$
	DECLARE newPos INTEGER;
	BEGIN
		SELECT COALESCE(MAX(position),0)+1 INTO newPos FROM WaitingList WHERE course = NEW.course;
		New.position := newPos;
		return New;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_position_insert ON WaitingList;
CREATE TRIGGER set_position_insert BEFORE INSERT ON WaitingList FOR EACH ROW EXECUTE PROCEDURE inser_waitingList();

CREATE OR REPLACE FUNCTION delete_from_waitinglist() RETURNS trigger AS $$
	BEGIN
		UPDATE WaitingList SET position = position-1 WHERE position >= OLD.position AND course = OLD.course;
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_positions ON WaitingList;
CREATE TRIGGER update_positions AFTER DELETE ON WaitingList FOR EACH ROW EXECUTE FUNCTION delete_from_waitinglist();
