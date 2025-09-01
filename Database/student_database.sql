create database student_details;
show databases;
use student_details;
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



CREATE TABLE Courses (
    Course_ID VARCHAR(20) PRIMARY KEY,
    Course_Name VARCHAR(100),
    Credits INT,
    Department_ID VARCHAR(20),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE Department (
    Department_ID VARCHAR(20) PRIMARY KEY,
    Department_Name VARCHAR(100)
);

CREATE TABLE Department_Head (
    Head_ID VARCHAR(20) PRIMARY KEY,
    Head_Name VARCHAR(100),
    Department_ID VARCHAR(20),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE Enrollment (
    Student_ID VARCHAR(20),
    Course_ID VARCHAR(20),
    Semester VARCHAR(10),
    Grade CHAR(2),
    PRIMARY KEY (Student_ID, Course_ID, Semester),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID)
);

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
show tables;
INSERT INTO Department (Department_ID, Department_Name)
VALUES 
    ('DCSE001', 'Computer Science'),
    ('DMATH001', 'Mathematics'),
    ('DCCE001', 'Computer and Communication Engineering'),
    ('DPHY001','Physics'),
    ('DCHEM001','Chemistry');
select * from Department; 
INSERT INTO Department_Head (Head_ID, Head_Name,Department_ID)
VALUES 
    ('HCSE001', 'Dr. Smith','DCSE001'),
    ('HMATH001', 'Dr. Jones','DMATH001'),
    ('HCCE001', 'Dr. Mukherjee','DCCE001'),
    ('HPHY001','Dr. Deshmukh','DPHY001'),
    ('HCHEM001','Dr. Khanna','DCHEM001');
 select * from Department_Head;   

INSERT INTO Courses (Course_ID, Course_Name, Credits, Department_ID)
VALUES 
    ('CCSE001', 'Programming in Modern C++', 4,'DCSE001'),
    ('CCSE002', 'Data Structures and Algorithms', 4,'DCSE001'),
    ('CMATH001', 'Calculus I', 3, 'DMATH001'),
    ('CPHY001', 'Engineering Physics', 4, 'DPHY001'),
    ('CCHEM001','Engineering Chemistry',4,'DCHEM001');
select * from Courses;    
INSERT INTO Student (Student_ID, First_Name, Last_Name, DOB, Year, Department_ID, CGPA)
VALUES 
    ('SCSE2001', 'Rajesh', 'Aggarwal', '2004-01-19', 2, 'DCSE001',NULL),
    ('SCES2002', 'Jane', 'Smith', '2004-06-05', 2, 'DCSE001',NULL),
    ('SCSE1001','Ryan','Sehgal','2005-07-08',1,'DCSE001',NULL);
select * from Student;
UPDATE  Student
SET Student_ID='SCSE2002'
WHERE First_Name='Jane' AND Last_Name='Smith';
    
INSERT INTO Enrollment (Student_ID, Course_ID, Semester, Grade)
VALUES 
    ('SCSE2001','CCSE001', 'THIRD','A'),
    ('SCSE2001','CCSE002', 'THIRD','A+'),
    ('SCSE2002','CCSE001', 'THIRD','B+'),
    ('SCSE2002','CCSE002', 'THIRD','A'),
    ('SCSE1001','CMATH001', 'FIRST','B'),
    ('SCSE1001','CCHEM001', 'FIRST','A');
select * from Enrollment;  
INSERT INTO Attendance (Student_ID, Course_ID, Semester, Total_Classes_Present, Total_Classes_Absent, Total_Classes_Held, Attendance_Percentage)
VALUES 
    ('SCSE2001','CCSE001', 'THIRD',16,6,22,72.72),
    ('SCSE2001','CCSE002', 'THIRD',19,4,23,82.60),
    ('SCSE2002','CCSE001', 'THIRD',21,1,22,95.45),
    ('SCSE2002','CCSE002', 'THIRD',20,3,23,86.95),
    ('SCSE1001','CMATH001', 'FIRST',24,0,24,100.00),
    ('SCSE1001','CCHEM001', 'FIRST',18,5,23,78.26);
-- select * from Attendance;
-- select Course_name from Courses;
-- select distinct student_id from Enrollment;
-- select * from Attendance where Attendance_Percentage>75 AND Attendance_Percentage<85;
-- select * from Attendance where Attendance_Percentage>80 OR Attendance_Percentage>90;
-- select COUNT(distinct Course_ID) from Attendance where semester='THIRD';
-- select * from Student ORDER BY Last_Name DESC;
-- select Student_ID,	AVG(Attendance_Percentage) from Attendance GROUP BY Student_ID;
-- select * from Student GROUP BY Student_ID,DOB HAVING DOB>='2005-01-01';
-- select * from Department where Department_ID LIKE '%1';
-- select * from Student where First_Name LIKE 'R%_';
-- DROP TABLE Enrollment;
-- select * from Student;
-- select * from Courses;
-- SELECT * FROM Enrollment;
-- select Course_Name from Courses where Department_ID='DCSE001';
-- SELECT  First_Name,Last_Name,Semester,Grade FROM Student,Enrollment WHERE   Student.Student_ID=Enrollment.Student_ID;
-- SELECT First_Name,Last_Name,Course_Name,Attendance_Percentage FROM (Student INNER JOIN Attendance ON Student.Student_ID=Attendance.Student_ID) INNER JOIN Courses ON Courses.Course_ID=Attendance.Course_ID WHERE Attendance_Percentage>75;
-- SELECT * FROM Department LEFT JOIN Courses ON Department.Department_ID=Courses.Department_ID;
-- SELECT * FROM Department RIGHT JOIN Courses ON Department.Department_ID=Courses.Department_ID;
-- SELECT * FROM Department LEFT JOIN Courses ON Department.Department_ID=Courses.Department_ID UNION ALL SELECT * FROM Department RIGHT JOIN Courses ON Department.Department_ID=Courses.Department_ID;
-- CREATE VIEW Student_view AS SELECT Student.first_name,Enrollment.semester FROM Student,Enrollment WHERE semester LIKE "_H%" WITH CHECK OPTION;
-- SELECT * FROM Student_view;
-- SELECT * FROM Student;
-- SELECT * FROM Enrollment;
-- DROP VIEW Student_view;
-- SELECT * FROM Student_view1;
-- CREATE INDEX index1 on Student(DOB);
-- DESCRIBE Student_view1;
-- DESCRIBE Student;
-- SHOW INDEXES FROM Student;
INSERT INTO Student (Student_ID, First_Name, Last_Name, DOB, Year, Department_ID, CGPA)
VALUES 
    ('SCSE1002', 'Raj', 'Sinha', '2006-04-19', 2, 'DCSE001',NULL),
    ('SCES1003', 'Lily', 'Sinha', '2004-08-05', 2, 'DCSE001',NULL);
Select * from Student;
INSERT INTO Enrollment (Student_ID, Course_ID, Semester, Grade)
VALUES 
    ('SCSE1002','CMATH001', 'FIRST','A+'),
    ('SCSE1002','CCHEM001', 'FIRST','A'),
    ('SCSE1003','CCHEM001', 'FIRST','B+'),
    ('SCSE1003','CMATH001', 'FIRST','B+');
INSERT INTO Attendance (Student_ID, Course_ID, Semester, Total_Classes_Present, Total_Classes_Absent, Total_Classes_Held, Attendance_Percentage)
VALUES 
	('SCSE1002','CMATH001', 'FIRST',22,2,24,91.67),
    ('SCSE1002','CCHEM001', 'FIRST',21,2,23,91.30),
    ('SCSE1003','CCHEM001', 'FIRST',19,4,23,82.60),
    ('SCSE1003','CMATH001', 'FIRST',19,5,24,79.16);
-- DROP View Student_View;
-- DROP View Student_View1;
-- CREATE View Department_Course AS SELECT Department.Department_ID,Department.Department_Name,Courses.Course_Name FROM Department,Courses   WHERE Department.Department_ID=Courses.Department_ID;
-- SELECT * FROM Department_Course;
-- Describe Department_Course;
-- DELIMITER $$

-- CREATE TRIGGER validate_credits
-- BEFORE INSERT ON Courses
-- FOR EACH ROW
-- BEGIN
--     IF NEW.Credits < 0 THEN
--         SIGNAL SQLSTATE '45000'
--         SET MESSAGE_TEXT = 'Credits cannot be negative.';
--     END IF;
-- END$$

-- DELIMITER ;
INSERT INTO Courses (Course_ID, Course_Name, Credits, Department_ID)
VALUES ('CCSE003', 'Database Mnagement System', 4, 'DCSE001');

INSERT INTO Courses (Course_ID, Course_Name, Credits, Department_ID)
VALUES ('CCSE003', 'Database Mnagement System', -4, 'DCSE001');
-- SHOW TRIGGERS;
-- UPDATE  Courses
-- SET Course_Name='Database Management System'
-- WHERE Course_ID='CCSE003';
-- select * from Courses;
