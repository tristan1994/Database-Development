-- Query 1 - This query will select Physician(s) who lives in Atlanta
SELECT  doctor_id AS "Doctor ID", first_name || ' ' || last_name AS "Doctor Name", city || ', ' || state AS "Location", Specialty AS "Specialize In"
FROM Doctor
WHERE city = 'Atlanta' AND specialty = 'Physician'
ORDER BY 1 ASC;


-- Query 2 - This query will show patient information by using their ID
SELECT patient_id AS "Patient ID", first_name || ' ' || last_name AS "Patient Name", date_of_birth AS "Birthday",
street || ', ' || city || ', ' || zip_code AS "Address"
FROM Patient
WHERE patient_id LIKE &patient_id
ORDER BY 1;


-- Query 3 - This query show the top 5 nurses live in Atlanta and Norcross Area
SELECT nurse_id AS "Nurse ID", first_name || ' ' || last_name AS "Nurse Name", city || ', ' || state || ' ' || zip_code AS "Location"
FROM Nurse
WHERE city IN ('Atlanta', 'Norcross')
ORDER BY nurse_id ASC
FETCH FIRST 5 ROWS ONLY;


-- Query 4 - This query will display doctor full name and their specialty
--           by searching just the first letter of their last name
SELECT doctor_id AS "Doctor ID", first_name || ' ' || last_name AS "Full Name", 
LPAD(specialty, 25,'*') AS "Specialty"
FROM Doctor
WHERE UPPER(SUBSTR(last_name,1,1)) LIKE UPPER('&start_letter%')
ORDER BY last_name;


-- Query 5 - This query will display those patients who came for check up 
-- and need to set another 3 months period check up,
-- and also show how many days in between check up
SELECT patient_id AS "Patient ID", date_of_appoint AS "Last Check Up Date", 
ADD_MONTHS(date_of_appoint,3) AS "Next Check Up",
TRUNC(ADD_MONTHS(date_of_appoint,3) - date_of_appoint) AS "Days Since Last Check Up"
FROM Appoinment
WHERE reason LIKE 'Check Up'
ORDER BY patient_id;

-- Query 6 - This query show all patient ID and appointment ID who have appointment on Sep 04
SELECT 'Appoinment ID ' || appoinment_id || ' with patient of ' || patient_id || ' have appoinment on ' || 
TO_CHAR(date_of_appoint, 'Month DD, YYYY') AS "Appoinment"
FROM Appoinment
WHERE date_of_appoint = TO_DATE('September 04, 2019', 'Month DD, YYYY');

-- Query 7 - This query display the nurses in hospital, their specialty and 
--             what degree least require for their specialty
SELECT first_name || ' ' || last_name AS "Full Name",
        specialty AS "Specialty",
        (CASE WHEN specialty = 'Registered' OR specialty = 'ER' THEN 'Associate Degree'
              WHEN specialty = 'General' THEN  'Bachelor'
              WHEN specialty = 'Practitioner' THEN 'Master'
              ELSE 'Unknown'
              END) AS "Degree Requirement"
FROM Nurse
ORDER BY nurse_id;


-- Query 8 - This query display the average salary the nurse 
--          with specific specialty make and count how many 
--          of the specialty nurse in the hospital 
SELECT specialty AS "Specialty", ROUND(AVG(salary)) AS "Average Salary", 
COUNT(*) AS "Count"
FROM Nurse
GROUP BY specialty
ORDER BY 2;

-- Query 9 - This query display the top group of specialist salary 
--          make more than $400,000 a year
SELECT specialty AS "Specialty", ROUND(MAX(salary)) AS "Salary"
FROM Doctor
GROUP BY specialty
HAVING ROUND(MAX(salary)*12) > '400000'
ORDER BY 2 DESC;


-- Query 10 - This query displays test result for patients 
--              with nurse responsible for the test
SELECT p.last_name || ' ' || p.first_name AS "Patient Name", 
       t.subject AS "Subject",
       t.test_result AS "Result", 
       n.first_name AS "Nurse Responsible"
FROM test t INNER JOIN patient p
ON t.patient_id = p.patient_id
JOIN nurse n
ON t.nurse_id = n.nurse_id
ORDER BY 1;

-- Query 11 - This query show the appoinment table with nurse 
            -- and their orphan
SELECT a.appoinment_id AS "Appoinment ID",
       a.patient_id AS "Patient ID",
       a.nurse_id AS "Nurse ID",
       n.nurse_id AS "Nurse ID from Nurse",
       n.first_name AS "Nurse First Name",
       n.last_name AS "Nurse Last Name"
FROM appoinment a LEFT OUTER JOIN nurse n 
ON a.nurse_id = n.nurse_id
ORDER BY 1;


-- Query 12 - This query return all those doctors 
--            who make the same salary as Doctor Robert Gray
SELECT first_name || ' ' || last_name AS "Doctor Name", 
specialty AS "Specialty", salary AS "Salary"
FROM doctor
WHERE salary = (SELECT salary
                FROM doctor 
                WHERE first_name = 'Robert' AND last_name = 'Gray')
AND last_name <> 'Gray'
ORDER BY doctor_id;


-- Query 13 - This query list the nurses who earn an salary
--           the minimum salary for any specialty nurse
SELECT first_name||' '||last_name AS "Nurse Name",
specialty AS "Specialty",
salary AS "Salary"
FROM nurse
WHERE salary IN (SELECT MIN(salary)
                FROM nurse
                GROUP BY specialty)
ORDER BY salary DESC;


-- View 1 -- This view show the doctor's information who had an
--           appoinment on September 04
CREATE OR REPLACE VIEW View1
AS SELECT doctor_id, first_name, last_name,
          specialty,
          phone
   FROM doctor 
   WHERE doctor_id IN (SELECT doctor_id
                        FROM appoinment
                        WHERE date_of_appoint LIKE '04-SEP-19'); 
   
SELECT * FROM View1;
SELECT first_name||' '||last_name "Name", 
specialty AS "Specialty" FROM View1
WHERE specialty LIKE '%ist';


-- View 2 -- Show average salary of specialist 
--           making between 35000 and 40000
CREATE OR REPLACE VIEW View2
AS SELECT first_name,
       specialty,
       AVG(salary) AS "Average Salary"
FROM doctor
GROUP BY specialty, first_name
HAVING AVG(salary) BETWEEN 35000 AND 40000;

SELECT * FROM View2;
SELECT first_name AS "Name",
specialty AS "Specialty" FROM View2 
WHERE specialty LIKE 'Radiologist';

-- Index
CREATE INDEX doctor_last_name_idx
ON doctor (last_name);

-- Flashback
CREATE TABLE TEMP_SP(ID NUMBER);
INSERT INTO TEMP_SP VALUES (10);
SELECT * FROM TEMP_SP;
DROP TABLE TEMP_SP;
SELECT * FROM TEMP_SP;
FLASHBACK TABLE TEMP_SP TO BEFORE DROP;
SELECT * FROM TEMP_SP;


-- Query 14 - This query display all the 
            -- doctor and nurse in the hospital
SELECT first_name||' '||last_name AS "Name",
specialty AS "Specialty", 'Doctor' AS "Doctor or Nurse"
FROM doctor
UNION
SELECT first_name||' '||last_name AS "Name",
specialty AS "Specialty", 'Nurse' AS "Doctor or Nurse"
FROM nurse
ORDER BY 1;

-- Query 15 - This query show patient who do 
--          not yet have a test or test result
SELECT patient_id "Patient ID", 
doctor_id "Doctor ID", nurse_id "Nurse ID"
FROM appoinment
MINUS
SELECT patient_id "Patient ID", 
doctor_id "Doctor ID", nurse_id "Nurse ID"
FROM test
ORDER BY 1;


