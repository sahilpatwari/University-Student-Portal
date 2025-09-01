-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS student_details;
USE student_details;

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS Attendance;
DROP TABLE IF EXISTS Enrollment;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Department_Head;
DROP TABLE IF EXISTS Department;

-- Create Department Table
CREATE TABLE Department (
    Department_ID VARCHAR(20) PRIMARY KEY,
    Department_Name VARCHAR(100)
);

-- Create Department Head Table
CREATE TABLE Department_Head (
    Head_ID VARCHAR(20) PRIMARY KEY,
    Head_Name VARCHAR(100),
    Department_ID VARCHAR(20),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

-- Create Courses Table
CREATE TABLE Courses (
    Course_ID VARCHAR(20) PRIMARY KEY,
    Course_Name VARCHAR(100),
    Credits INT,
    Department_ID VARCHAR(20),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

-- Create Student Table
CREATE TABLE Student (
    Student_ID VARCHAR(20) PRIMARY KEY,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    DOB DATE,
    Year INT,
    Department_ID VARCHAR(20),
    CGPA DECIMAL(3,2),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

-- Create Enrollment Table
CREATE TABLE Enrollment (
    Student_ID VARCHAR(20),
    Course_ID VARCHAR(20),
    Semester VARCHAR(10),
    Grade CHAR(2),
    PRIMARY KEY (Student_ID, Course_ID, Semester),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID)
);

-- Create Attendance Table
CREATE TABLE Attendance (
    Student_ID VARCHAR(20),
    Course_ID VARCHAR(20),
    Semester VARCHAR(10),
    Total_Classes_Present INT,
    Total_Classes_Absent INT,
    Total_Classes_Held INT,
    Attendance_Percentage DECIMAL(5,2),
    PRIMARY KEY (Student_ID, Course_ID, Semester),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID)
);

-- Create index on Student DOB
CREATE INDEX index1 ON Student(DOB);

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
    ('SCSE2002', 'Jane', 'Smith', '2004-06-05', 2, 'DCSE001', NULL),
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

-- Create Department_Course view
CREATE VIEW Department_Course AS 
SELECT Department.Department_ID, Department.Department_Name, Courses.Course_Name 
FROM Department, Courses 
WHERE Department.Department_ID = Courses.Department_ID;

-- Create a trigger to validate credits
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

-- Create a stored procedure to calculate CGPA
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