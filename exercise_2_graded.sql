/* Create a table medication_stock in your Smart Old Age Home database. The table must have the following attributes:
 1. medication_id (integer, primary key)
 2. medication_name (varchar, not null)
 3. quantity (integer, not null)
 Insert some values into the medication_stock table. 
 Practice SQL with the following:
 */
CREATE TABLE medication_stock(
medication_id SERIAL PRIMARY KEY,
medication_name VARCHAR NOT NULL,
quantity INT NOT NULL
);
CREATE TABLE doctors (
doctor_id SERIAL PRIMARY KEY,
name TEXT NOT NULL,
specialization TEXT NOT NULL
);


CREATE TABLE treatments(
treatment_id SERIAL PRIMARY KEY,
patient_id INT REFERENCES patients(patient_id),
nurse_id INT REFERENCES nurses(nurse_id),
treatment_type TEXT NOT NULL,
treatment_time TIMESTAMP NOT NULL
);

CREATE TABLE nurses(
nurse_id SERIAL PRIMARY KEY,
name TEXT NOT NULL,
shift TEXT NOT NULL
);
CREATE TABLE patients(
    patient_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INT NOT NULL,
    room_no INT NOT NULL,
    doctor_id INT REFERENCES doctors(doctor_id)
);

INSERT INTO doctors (name, specialization) VALUES
('Dr. Smith', 'Geriatrics'),
('Dr. Johnson', 'Cardiology'),
('Dr. Lee', 'Neurology'),
('Dr. Patel', 'Endocrinology'),
('Dr. Adams', 'General Medicine');

INSERT INTO patients (name, age, room_no, doctor_id) 
VALUES
('Alice', 82, 101, 1),
('Bob', 79, 102, 2),
('Carol', 85, 103, 1),
('David', 88, 104, 3),
('Ella', 77, 105, 2),
('Frank', 91, 106, 4),




INSERT INTO nurses (name, shift) VALUES
('Nurse Ann', 'Morning'),
('Nurse Ben', 'Evening'),
('Nurse Eva', 'Night'),
('Nurse Kim', 'Morning'),
('Nurse Omar', 'Evening');

INSERT INTO treatments (patient_id, nurse_id, treatment_type, treatment_time) VALUES
(1, 1, 'Physiotherapy', '2025-09-10 09:00:00'),
(2, 2, 'Medication', '2025-09-10 18:00:00'),
(1, 3, 'Medication', '2025-09-11 21:00:00'),
(3, 1, 'Checkup', '2025-09-12 10:00:00'),
(4, 2, 'Physiotherapy', '2025-09-12 17:00:00'),
(5, 5, 'Medication', '2025-09-12 18:00:00'),
(6, 4, 'Physiotherapy', '2025-09-13 09:00:00');

INSERT INTO medication_stock(medication_id,medication_name,quantity)VALUES
(1,'painkiller',3),
(2,'fighter',4),
(4,'antibiotics',7),
(5,'antacid',8);
 -- Q!: List all patients name and ages 
SELECT name,age FROM patients;



 -- Q2: List all doctors specializing in 'Cardiology'

SELECT * FROM doctors WHERE specialization= 'Cardiology';
 
 -- Q3: Find all patients that are older than 80
SELECT * FROM patients WHERE age> 80;



-- Q4: List all the patients ordered by their age (youngest first)
SELECT * FROM patients ORDER BY age ASC;



-- Q5: Count the number of doctors in each specialization
SELECT specialization,COUNT(*)AS number_of_doctors FROM doctors 
GROUP BY specialization
 ORDER BY number_of_doctors DESC;


-- Q6: List patients and their doctors' names
SELECT d.doctor_id, p.name AS patient_name,d.name AS doctors_name 
FROM patients p INNER JOIN doctors d ON p.doctor_id = d.doctor_id 
ORDER BY d.doctor_id ASC ;


-- Q7: Show treatments along with patient names and doctor names

SELECT t.treatment_type, t.treatment_time,p.name AS patient_name, d.name AS doctor_name
FROM treatments t
JOIN patients p ON t.patient_id = p.patient_id
JOIN doctors d ON p.doctor_id = d.doctor_id 
;


-- Q8: Count how many patients each doctor supervises
SELECT d.name as doctor_name, COUNT(p.patient_id) as patient_count
FROM doctors d
LEFT JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name;


-- Q9: List the average age of patients and display it as average_age
SELECT AVG(age) AS average_age ,patient_id FROM patients GROUP BY patient_id;


-- Q10: Find the most common treatment type, and display only that
SELECT treatment_type, COUNT(*) AS count_type
FROM treatments
GROUP BY treatment_type
ORDER BY count_type DESC
LIMIT 1;


-- Q11: List patients who are older than the average age of all patients
SELECT name, age,patient_id
FROM patients
WHERE age > (SELECT AVG(age) FROM patients)
ORDER BY patient_id;


-- Q12: List all the doctors who have more than 5 patients
SELECT d.name, COUNT(p.patient_id) AS patient_count
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id,d.name
HAVING COUNT(p.patient_id) > 5;






-- Q13: List all the treatments that are provided by nurses that work in the morning shift. List patient name as well. 
SELECT t.treatment_type, p.name AS patient_name, n.name AS nurse_name
FROM treatments t
JOIN patients p ON t.patient_id = p.patient_id
JOIN nurses n ON t.nurse_id = n.nurse_id
WHERE n.shift = 'Morning';



-- Q14: Find the latest treatment for each patient
SELECT p.name,p.patient_id, t.treatment_type AS latest_treatment
FROM patients p
JOIN treatments t ON p.patient_id = t.patient_id
WHERE t.treatment_time = (
    SELECT MAX(treatment_time) 
    FROM treatments 
    WHERE patient_id = p.patient_id
) ORDER BY p.patient_id;



-- Q15: List all the doctors and average age of their patients
SELECT d.doctor_id,d.name as doctor_name, AVG(p.age) AS average_patients_age
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id 
;



-- Q16: List the names of the doctors who supervise more than 3 patients
SELECT d.name
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY  d.name,d.doctor_id
HAVING COUNT(p.patient_id) > 3;


-- Q17: List all the patients who have not received any treatments (HINT: Use NOT IN)
SELECT name AS patient_name
FROM patients
WHERE patient_id NOT IN (SELECT DISTINCT patient_id FROM treatments);



-- Q18: List all the medicines whose stock (quantity) is less than the average stock

SELECT *
FROM medication_stock
WHERE quantity < (SELECT AVG(quantity) FROM medication_stock);


-- Q19: For each doctor, rank their patients by age
SELECT d.name AS doctor_name, p.name AS patient_name, p.age AS age,
    RANK() OVER (PARTITION BY d.doctor_id ORDER BY p.age DESC) AS age_ranking
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id;


-- Q20: For each specialization, find the doctor with the oldest patient
WITH DoctorPatientAges AS (
    SELECT d.specialization, d.name as doctor_name, p.name as patient_name, p.age AS age,
           RANK() OVER (PARTITION BY d.specialization ORDER BY p.age DESC) as rank
    FROM doctors d
    JOIN patients p ON d.doctor_id = p.doctor_id
)
SELECT specialization, doctor_name, patient_name, age
FROM DoctorPatientAges
WHERE rank = 1;





