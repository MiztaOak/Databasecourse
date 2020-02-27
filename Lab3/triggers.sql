CREATE OR REPLACE FUNCTION registerToList() RETURNS trigger AS $$
	BEGIN

		IF (SELECT student FROM Taken WHERE course = New.course AND student = New.Student) IS NOT NULL THEN
			RAISE EXCEPTION 'already taken course';
			RETURN NULL;
		END IF;
		IF (SELECT student FROM Registrations WHERE student = NEW.Student AND course = NEW.course) IS NOT NULL THEN
			RAISE EXCEPTION 'already registered to the course';
			RETURN NULL;
		END IF;
		--check for prereq
		
		-- is limited
		IF (SELECT code FROM LimitedCourses WHERE code = NEW.course) IS NOT NULL THEN
			IF ((SELECT COUNT(student) FROM Registered WHERE course = NEW.course) >= (SELECT capacity FROM LimitedCourses WHERE code = NEW.course))
				THEN RAISE EXCEPTION 'that course is full atm';
				RETURN NULL;
			END IF;
			RAISE EXCEPTION 'limited course but ok';
			RETURN NULL;
		END IF;
		INSERT INTO Registered VALUES (NEW.Student,New.Course);
		-- RETURN NEW;
		RAISE EXCEPTION 'should be ok to add';
		RETURN NULL;
	END;
$$ LANGUAGE  plpgsql;

DROP TRIGGER IF EXISTS check_can_register ON Registrations;
CREATE TRIGGER check_can_register INSTEAD OF INSERT ON Registrations FOR EACH ROW EXECUTE PROCEDURE registerToList();

CREATE OR REPLACE FUNCTION removeFromList() RETURNS trigger AS $$
	BEGIN
		IF OLD.status = 'waiting' THEN
			DELETE FROM WaitingList WHERE course = OLD.course AND student = OLD.student;
			--fix positions should we make small triggers for waiting list that fix the postions or is that not allowed?
		ELSE
			DELETE FROM Registered WHERE course = OLD.course AND student = OLD.student;
			IF ((SELECT COUNT(student) FROM Registered WHERE course = OLD.course) < (SELECT capacity FROM LimitedCourses WHERE code = OLD.course)) THEN
					INSERT INTO Registered VALUES (SELECT student,course FROM WaitingList WHERE positions = 1 AND course = OLD.course); --this will not work
					DELETE FROM WaitingList WHERE positions = 1 AND course = OLD.course;
					--fix postions
					RAISE EXCEPTION 'that course is full atm';
					RETURN NULL;
			END IF;
		END IF;
		RETURN OLD;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS student_unregister ON Registrations;
CREATE TRIGGER student_unregister INSTEAD OF DELETE ON Registrations FOR EACH ROW EXECUTE PROCEDURE removeFromList();

CREATE OR REPLACE FUNCTION next_postion() RETURNS INT AS $$
	SELECT COALESCE(MAX(position),0)+1 FROM WaitingList
$$ LANGUAGE SQL;

ALTER TABLE WaitingList ALTER position SET DEFAULT next_postion();

CREATE OR REPLACE FUNCTION delete_from_waitinglist() RETURNS trigger AS $$
	BEGIN
		UPDATE WaitingList SET position = position-1 WHERE position >= OLD.position;
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_positions ON Registrations;
CREATE TRIGGER update_positions AFTER DELETE ON WaitingList FOR EACH ROW EXECUTE FUNCTION delete_from_waitinglist();
