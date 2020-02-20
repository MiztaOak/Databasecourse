
-- Use this instead of drop schema if running on the chalmers Postgres server
-- DROP OWNED BY TDA357_XXX CASCADE;

\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false

\i 'C:/Users/mroak/Documents/Chalmers/Databases/Databasecourse/Lab/tables.sql'
\i 'C:/Users/mroak/Documents/Chalmers/Databases/Databasecourse/Lab/inserts.sql'
\i 'C:/Users/mroak/Documents/Chalmers/Databases/Databasecourse/Lab/views.sql'

SELECT idnr, name, login, program, branch FROM BasicInformation;

SELECT student, course, grade, credits FROM FinishedCourses;

SELECT student, course, credits FROM PassedCourses;

SELECT student, course, status FROM Registrations;

SELECT student, course FROM UnreadMandatory;

SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation;
