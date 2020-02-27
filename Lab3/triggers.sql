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
		RAISE EXCEPTION 'should be ok to add';
		RETURN NULL;
	END;
$$ LANGUAGE  plpgsql;

DROP TRIGGER IF EXISTS check_can_register ON Registrations;
CREATE TRIGGER check_can_register INSTEAD OF INSERT ON Registrations FOR EACH ROW EXECUTE PROCEDURE registerToList();

CREATE OR REPLACE FUNCTION removeFromList() RETURNS trigger AS $$
	BEGIN
		
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS student_unregister ON Registrations;
CREATE TRIGGER student_unregister INSTEAD OF DELETE ON Registrations FOR EACH ROW EXECUTE PROCEDURE removeFromList();