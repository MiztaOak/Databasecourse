CREATE FUNCTION registerToList() RETURNS trigger AS $$
	BEGIN
		IF ((SELECT SUM(idnr) FROM WaitingList WHERE course = NEW.course) >= (SELECT capacity FROM Courses WHERE code = NEW.course))
			THEN RAISE EXCEPTION 'that course is full atm';
		END IF;
	END;
$$ LANGUAGE  plpgsql;

CREATE TRIGGER check_can_register BEFORE INSERT ON Registered FOR EACH ROW EXECUTE PROCEDURE registerToList();