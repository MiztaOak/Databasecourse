--Insert into unlimited course, should pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC111');
--Insert into limited course, should pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC222');
--Insert into same course again, should be rejected
INSERT INTO Registrations VALUES ('1111111111', 'CCC222');
--Should end up in the waiting list
INSERT INTO Registrations VALUES ('2222222222', 'CCC222');

--Delete from unlimited course, should pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';
--Delete from limited course with waiting list, should pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222';
--Delete from limited course without waiting list, should pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC222';

--Adding more people to limited course
INSERT INTO Registrations VALUES ('2222222222', 'CCC222');
INSERT INTO Registrations VALUES ('1111111111', 'CCC222');
INSERT INTO Registrations VALUES ('3333333333', 'CCC222');
INSERT INTO Registrations VALUES ('4444444444', 'CCC222');

SELECT * FROM CourseQueuePositions;

--Remove person with middle position in waiting list
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC222';

SELECT * FROM CourseQueuePositions;

-- Remove the person that is registered to the course and adding them back to the course verifying that they end up at the end of the waitinglist 
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222';
INSERT INTO Registrations VALUES ('2222222222', 'CCC222');
SELECT * FROM CourseQueuePositions;

--Adding more people to the course without using the trigger
INSERT INTO Registered VALUES ('3333333333','CCC222');
SELECT * FROM Registrations;

--Course is now overfull so removing one person should not change the queue
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC222';
SELECT * FROM Registrations;
SELECT * FROM CourseQueuePositions;

DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222';
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC222';
DELETE FROM Registrations WHERE student = '4444444444' AND course = 'CCC222';

--Register student on course which requires prerequisites. Should fail.
INSERT INTO Registrations VALUES ('1111111111', 'CCC333');

--Give student one of two prerequisites
INSERT INTO Taken VALUES('1111111111', 'CCC111','5');

--Try to register on a course already taken. Should fail.
INSERT INTO Registrations VALUES('1111111111','CCC111');

--Attempt to register on course with 1 out of 2 prerequisites again. Should fail.
INSERT INTO Registrations VALUES ('1111111111', 'CCC333');

--Give student last prerequisite.
INSERT INTO Taken VALUES('1111111111', 'CCC222','5');

--Attempt to register again. Should be accepted.
INSERT INTO Registrations VALUES ('1111111111', 'CCC333');

SELECT * FROM Registrations;

--Remove student from courses
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC333';
DELETE FROM Taken WHERE student = '1111111111' AND course = 'CCC222';
DELETE FROM Taken WHERE student = '1111111111' AND course = 'CCC111';
