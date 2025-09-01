-- Insert data into Department table
INSERT INTO Department (Department_ID, Department_Name)
VALUES 
    ('DCSE001', 'Computer Science'),
    ('DMATH001', 'Mathematics'),
    ('DCCE001', 'Computer and Communication Engineering'),
    ('DPHY001','Physics'),
    ('DCHEM001','Chemistry');

-- Insert data into Department_Head table
INSERT INTO Department_Head (Head_ID, Head_Name, Department_ID)
VALUES 
    ('HCSE001', 'Dr. Smith', 'DCSE001'),
    ('HMATH001', 'Dr. Jones', 'DMATH001'),
    ('HCCE001', 'Dr. Mukherjee', 'DCCE001'),
    ('HPHY001', 'Dr. Deshmukh', 'DPHY001'),
    ('HCHEM001', 'Dr. Khanna', 'DCHEM001');

-- Insert data into Courses table
INSERT INTO Courses (Course_ID, Course_Name, Credits, Department_ID)
VALUES 
    ('CCSE001', 'Programming in Modern C++', 4, 'DCSE001'),
    ('CCSE002', 'Data Structures and Algorithms', 4, 'DCSE001'),
    ('CMATH001', 'Calculus I', 3, 'DMATH001'),
    ('CPHY001', 'Engineering Physics', 4, 'DPHY001'),
    ('CCHEM001', 'Engineering Chemistry', 4, 'DCHEM001');

-- Insert data into Student table
INSERT INTO Student (Student_ID, First_Name, Last_Name, DOB, Year, Department_ID, CGPA)
VALUES 
    ('SCSE2001', 'Rajesh', 'Aggarwal', '2004-01-19', 2, 'DCSE001', NULL),
    ('SCES2002', 'Jane', 'Smith', '2004-06-05', 2, 'DCSE001', NULL),
    ('SCSE1001', 'Ryan', 'Sehgal', '2005-07-08', 1, 'DCSE001', NULL);

-- Insert data into Enrollment table
INSERT INTO Enrollment (Student_ID, Course_ID, Semester, Grade)
VALUES 
    ('SCSE2001', 'CCSE001', 'THIRD', 'A'),
    ('SCSE2001', 'CCSE002', 'THIRD', 'A+'),
    ('SCSE2002', 'CCSE001', 'THIRD', 'B+'),
    ('SCSE2002', 'CCSE002', 'THIRD', 'A'),
    ('SCSE1001', 'CMATH001', 'FIRST', 'B'),
    ('SCSE1001', 'CCHEM001', 'FIRST', 'A');

-- Insert data into Attendance table
INSERT INTO Attendance (Student_ID, Course_ID, Semester, Total_Classes_Present, Total_Classes_Absent, Total_Classes_Held, Attendance_Percentage)
VALUES 
    ('SCSE2001', 'CCSE001', 'THIRD', 16, 6, 22, 72.72),
    ('SCSE2001', 'CCSE002', 'THIRD', 19, 4, 23, 82.60),
    ('SCSE2002', 'CCSE001', 'THIRD', 21, 1, 22, 95.45),
    ('SCSE2002', 'CCSE002', 'THIRD', 20, 3, 23, 86.95),
    ('SCSE1001', 'CMATH001', 'FIRST', 24, 0, 24, 100.00),
    ('SCSE1001', 'CCHEM001', 'FIRST', 18, 5, 23, 78.26);




-- Update Student ID
UPDATE Student
SET Student_ID = 'SCSE2002'
WHERE First_Name = 'Jane' AND Last_Name = 'Smith';

-- Update Course Name
UPDATE Courses
SET Course_Name = 'Database Management System'
WHERE Course_ID = 'CCSE003';






-- Delete Enrollment records
DROP TABLE Enrollment;

-- Remove a student (from the application code)
DELETE FROM Enrollment WHERE Student_ID = ?;
DELETE FROM Attendance WHERE Student_ID = ?;
DELETE FROM Student WHERE Student_ID = ?;

-- Remove a course (from the application code)
DELETE FROM Enrollment WHERE Course_ID = ?;
DELETE FROM Attendance WHERE Course_ID = ?;
DELETE FROM Courses WHERE Course_ID = ?;




-- Create an index on the DOB column of the Student table
CREATE INDEX index1 ON Student(DOB);



-- Select all course names
SELECT Course_Name FROM Courses;

-- Select distinct student IDs from Enrollment
SELECT DISTINCT Student_ID FROM Enrollment;

-- Select attendance records with percentage between 75% and 85%
SELECT * FROM Attendance WHERE Attendance_Percentage > 75 AND Attendance_Percentage < 85;

-- Select attendance records with percentage greater than 80% or 90%
SELECT * FROM Attendance WHERE Attendance_Percentage > 80 OR Attendance_Percentage > 90;

-- Count distinct course IDs for a specific semester
SELECT COUNT(DISTINCT Course_ID) FROM Attendance WHERE Semester = 'THIRD';

-- Order students by last name in descending order
SELECT * FROM Student ORDER BY Last_Name DESC;

-- Group attendance by student ID and calculate average attendance percentage
SELECT Student_ID, AVG(Attendance_Percentage) FROM Attendance GROUP BY Student_ID;

-- Filter students born after 2005-01-01
SELECT * FROM Student GROUP BY Student_ID, DOB HAVING DOB >= '2005-01-01';

-- Select departments with IDs ending with '1'
SELECT * FROM Department WHERE Department_ID LIKE '%1';

-- Select students with first names starting with 'R' and having at least one character after
SELECT * FROM Student WHERE First_Name LIKE 'R%_';

-- Select course names for a specific department
SELECT Course_Name FROM Courses WHERE Department_ID = 'DCSE001';






-- INNER JOIN to get student names, semester, and grades
SELECT First_Name, Last_Name, Semester, Grade 
FROM Student, Enrollment 
WHERE Student.Student_ID = Enrollment.Student_ID;

-- Multiple INNER JOINs to get student names, course names, and attendance percentage
SELECT First_Name, Last_Name, Course_Name, Attendance_Percentage 
FROM (Student INNER JOIN Attendance ON Student.Student_ID = Attendance.Student_ID) 
INNER JOIN Courses ON Courses.Course_ID = Attendance.Course_ID 
WHERE Attendance_Percentage > 75;

-- LEFT JOIN to get all departments and their courses (if any)
SELECT * FROM Department LEFT JOIN Courses ON Department.Department_ID = Courses.Department_ID;

-- RIGHT JOIN to get all courses and their departments
SELECT * FROM Department RIGHT JOIN Courses ON Department.Department_ID = Courses.Department_ID;

-- FULL OUTER JOIN (using UNION ALL with LEFT and RIGHT JOINs in MySQL)
SELECT * FROM Department LEFT JOIN Courses ON Department.Department_ID = Courses.Department_ID 
UNION ALL 
SELECT * FROM Department RIGHT JOIN Courses ON Department.Department_ID = Courses.Department_ID;



-- Create a view to show student names and semesters that match a pattern
CREATE VIEW Student_view AS 
SELECT Student.First_Name, Enrollment.Semester 
FROM Student, Enrollment 
WHERE Semester LIKE "_H%" 
WITH CHECK OPTION;

-- Create a view to show departments and their courses
CREATE VIEW Department_Course AS 
SELECT Department.Department_ID, Department.Department_Name, Courses.Course_Name 
FROM Department, Courses 
WHERE Department.Department_ID = Courses.Department_ID;






-- Create an index on the DOB column of the Student table
CREATE INDEX index1 ON Student(DOB);

-- Show indexes on the Student table
SHOW INDEXES FROM Student;








-- Example stored procedure to calculate and update CGPA for a student
DELIMITER //

CREATE PROCEDURE CalculateAndUpdateCGPA(IN student_id_param VARCHAR(20))
BEGIN
    DECLARE total_credits INT DEFAULT 0;
    DECLARE total_grade_points DECIMAL(10,2) DEFAULT 0;
    DECLARE student_cgpa DECIMAL(3,2);
    
    -- Calculate total grade points and credits
    SELECT SUM(CASE 
        WHEN e.Grade = 'A+' THEN c.Credits * 4.0
        WHEN e.Grade = 'A' THEN c.Credits * 4.0
        WHEN e.Grade = 'A-' THEN c.Credits * 3.7
        WHEN e.Grade = 'B+' THEN c.Credits * 3.3
        WHEN e.Grade = 'B' THEN c.Credits * 3.0
        WHEN e.Grade = 'B-' THEN c.Credits * 2.7
        WHEN e.Grade = 'C+' THEN c.Credits * 2.3
        WHEN e.Grade = 'C' THEN c.Credits * 2.0
        WHEN e.Grade = 'C-' THEN c.Credits * 1.7
        WHEN e.Grade = 'D+' THEN c.Credits * 1.3
        WHEN e.Grade = 'D' THEN c.Credits * 1.0
        ELSE 0
    END) AS total_gp,
    SUM(c.Credits) AS total_cr
    INTO total_grade_points, total_credits
    FROM Enrollment e
    JOIN Courses c ON e.Course_ID = c.Course_ID
    WHERE e.Student_ID = student_id_param AND e.Grade IS NOT NULL;
    
    -- Calculate CGPA
    IF total_credits > 0 THEN
        SET student_cgpa = total_grade_points / total_credits;
        
        -- Update student CGPA
        UPDATE Student SET CGPA = student_cgpa WHERE Student_ID = student_id_param;
        
        SELECT CONCAT('CGPA updated to ', student_cgpa) AS Result;
    ELSE
        SELECT 'No graded courses found for this student' AS Result;
    END IF;
END //

DELIMITER ;









-- Trigger to validate credits before inserting into Courses table
DELIMITER //

CREATE TRIGGER validate_credits
BEFORE INSERT ON Courses
FOR EACH ROW
BEGIN
    IF NEW.Credits < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Credits cannot be negative.';
    END IF;
END//

DELIMITER ;

-- Example usage of the trigger
-- This will succeed
INSERT INTO Courses (Course_ID, Course_Name, Credits, Department_ID)
VALUES ('CCSE003', 'Database Management System', 4, 'DCSE001');

-- This will fail because of the trigger
INSERT INTO Courses (Course_ID, Course_Name, Credits, Department_ID)
VALUES ('CCSE003', 'Database Management System', -4, 'DCSE001');