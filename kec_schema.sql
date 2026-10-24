-- =====================================================================
-- KONGU ENGINEERING COLLEGE (AUTONOMOUS) - REGULATION 2024 (R2024)
-- Student Academic & Continuous Evaluation System Database Schema
-- File: kec_schema.sql
-- =====================================================================

CREATE DATABASE IF NOT EXISTS kec_academic;
USE kec_academic;

-- 1. Students Table
DROP TABLE IF EXISTS assessment_marks;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    roll_no VARCHAR(15) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(20) NOT NULL,
    current_semester INT NOT NULL CHECK (current_semester BETWEEN 1 AND 8)
);

-- 2. Course Catalog Table
CREATE TABLE courses (
    course_code VARCHAR(15) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0),
    course_type ENUM('THEORY', 'PRACTICAL', 'EMBEDDED') NOT NULL
);

-- 3. Course Enrollments & Attendance Table
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    roll_no VARCHAR(15) NOT NULL,
    course_code VARCHAR(15) NOT NULL,
    semester INT NOT NULL CHECK (semester BETWEEN 1 AND 8),
    classes_held INT NOT NULL DEFAULT 0 CHECK (classes_held >= 0),
    classes_attended INT NOT NULL DEFAULT 0 CHECK (classes_attended >= 0),
    medical_approved BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE KEY uq_student_course_sem (roll_no, course_code, semester),
    CONSTRAINT fk_enroll_student FOREIGN KEY (roll_no) 
        REFERENCES students(roll_no) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_course FOREIGN KEY (course_code) 
        REFERENCES courses(course_code) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_attendance_valid CHECK (classes_attended <= classes_held)
);

-- 4. Incremental Assessment Marks Table
-- Phase 1: cia1, cia2 (Mid-Semester)
-- Phase 2: activities (Assignments / Quizzes / Lab Evaluations)
-- Phase 3: ese (End Semester Exam) and ese_absent (AB)
CREATE TABLE assessment_marks (
    enrollment_id INT PRIMARY KEY,
    cia1 DECIMAL(5,2) DEFAULT NULL,
    cia2 DECIMAL(5,2) DEFAULT NULL,
    activities DECIMAL(5,2) DEFAULT NULL,
    ese DECIMAL(5,2) DEFAULT NULL,
    ese_absent BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_marks_enrollment FOREIGN KEY (enrollment_id)
        REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    CONSTRAINT chk_cia1_range CHECK (cia1 IS NULL OR (cia1 >= 0 AND cia1 <= 100)),
    CONSTRAINT chk_cia2_range CHECK (cia2 IS NULL OR (cia2 >= 0 AND cia2 <= 100)),
    CONSTRAINT chk_activities_range CHECK (activities IS NULL OR (activities >= 0 AND activities <= 100)),
    CONSTRAINT chk_ese_range CHECK (ese IS NULL OR (ese >= 0 AND ese <= 100)),
    CONSTRAINT chk_ese_absent_consistency CHECK (NOT ese_absent OR ese IS NULL)
);

-- =====================================================================
-- Starter / Demonstration Data (KEC R2024 Evaluation Scenarios)
-- =====================================================================

-- Seed Students
INSERT INTO students (roll_no, name, department, current_semester) VALUES
('25ITR148', 'SURIYAPRASATH K', 'IT', 3),
('24ITR001', 'Arun Kumar S', 'IT', 3),
('24ITR002', 'Priya Dharshini R', 'IT', 3),
('24ITR003', 'Karthik M', 'IT', 3),
('24ITR004', 'Divya Bharathi K', 'IT', 3),
('24ITR005', 'Naveen Prasath P', 'IT', 3),
('24ITR006', 'Suresh Kumar V', 'IT', 3),
('24CSR001', 'Balaji T', 'CSE', 3),
('24ECR001', 'Meena S', 'ECE', 3);

-- Seed Courses (THEORY, PRACTICAL, EMBEDDED)
INSERT INTO courses (course_code, title, credits, course_type) VALUES
('24ITT31', 'Java & Object Oriented Programming', 3, 'THEORY'),
('24ITL31', 'Java Programming Laboratory', 2, 'PRACTICAL'),
('24ITI31', 'Embedded Systems & IoT Design', 4, 'EMBEDDED'),
('24CST31', 'Database Management Systems', 3, 'THEORY'),
('24ECL31', 'Digital Electronics Laboratory', 2, 'PRACTICAL');

-- Seed Enrollments with Attendance
-- Arun Kumar S (Full attendance >= 75%)
INSERT INTO enrollments (enrollment_id, roll_no, course_code, semester, classes_held, classes_attended, medical_approved) VALUES
(101, '24ITR001', '24ITT31', 3, 50, 48, FALSE),  -- 96.0% (Eligible)
(102, '24ITR001', '24ITL31', 3, 30, 29, FALSE),  -- 96.7% (Eligible)
(103, '24ITR001', '24ITI31', 3, 60, 57, FALSE),  -- 95.0% (Eligible)

-- Priya Dharshini R (Eligible attendance >= 75%)
(104, '24ITR002', '24ITT31', 3, 50, 42, FALSE),  -- 84.0% (Eligible)
(105, '24ITR002', '24ITL31', 3, 30, 26, FALSE),  -- 86.7% (Eligible)
(106, '24ITR002', '24ITI31', 3, 60, 49, FALSE),  -- 81.7% (Eligible)

-- Karthik M (Shortage of attendance in 24ITT31 < 65% -> SA Defaulter)
(107, '24ITR003', '24ITT31', 3, 50, 28, FALSE),  -- 56.0% (<65% -> SA Grade)
(108, '24ITR003', '24ITL31', 3, 30, 24, FALSE),  -- 80.0% (Eligible)

-- Divya Bharathi K (Conditionally eligible 65% - 74.9%, Approved Medical Condonation)
(109, '24ITR004', '24ITT31', 3, 50, 35, TRUE),   -- 70.0% (Medical Condoned -> Eligible)
(110, '24ITR004', '24ITL31', 3, 30, 27, FALSE),  -- 90.0% (Eligible)

-- Naveen Prasath P (Absent in ESE)
(111, '24ITR005', '24ITT31', 3, 50, 45, FALSE),  -- 90.0% (Eligible, but Absent in ESE)

-- Suresh Kumar V (Eligible attendance, but failed ESE minimum threshold)
(112, '24ITR006', '24ITT31', 3, 50, 40, FALSE),  -- 80.0% (Eligible, but ESE < 45% -> RA)

-- Balaji T (CSE)
(113, '24CSR001', '24CST31', 3, 50, 45, FALSE),  -- 90.0%

-- Meena S (ECE)
(114, '24ECR001', '24ECL31', 3, 30, 28, FALSE);  -- 93.3%

-- Seed Assessment Marks across Phases
INSERT INTO assessment_marks (enrollment_id, cia1, cia2, activities, ese, ese_absent) VALUES
-- Arun Kumar: High scores -> 'O' and 'A+' grades
-- 24ITT31 (Theory): CIA=(95+92+96)/3=94.33; CIA 40%=37.73; ESE=94 (60%=56.4); Total=94.13 -> Grade O (10 pts)
(101, 95.0, 92.0, 96.0, 94.0, FALSE),
-- 24ITL31 (Practical): CIA=(98+94+95)/3=95.67; CIA 60%=57.4; ESE=92 (40%=36.8); Total=94.20 -> Grade O (10 pts)
(102, 98.0, 94.0, 95.0, 92.0, FALSE),
-- 24ITI31 (Embedded): CIA=(90+88+92)/3=90.00; CIA 50%=45.0; ESE=86 (50%=43.0); Total=88.00 -> Grade A+ (9 pts)
(103, 90.0, 88.0, 92.0, 86.0, FALSE),

-- Priya Dharshini: Solid scores -> 'A' and 'B+' grades
-- 24ITT31 (Theory): CIA=(78+75+80)/3=77.67; CIA 40%=31.07; ESE=74 (60%=44.4); Total=75.47 -> Grade A (8 pts)
(104, 78.0, 75.0, 80.0, 74.0, FALSE),
-- 24ITL31 (Practical): CIA=(82+80+85)/3=82.33; CIA 60%=49.4; ESE=70 (40%=28.0); Total=77.40 -> Grade A (8 pts)
(105, 82.0, 80.0, 85.0, 70.0, FALSE),
-- 24ITI31 (Embedded): CIA=(65+68+72)/3=68.33; CIA 50%=34.17; ESE=64 (50%=32.0); Total=66.17 -> Grade B+ (7 pts)
(106, 65.0, 68.0, 72.0, 64.0, FALSE),

-- Karthik M: Shortage of attendance in 24ITT31 (<65%) -> Grade SA; Practical -> Grade B
(107, 70.0, 65.0, 68.0, 75.0, FALSE),
(108, 60.0, 58.0, 62.0, 55.0, FALSE),

-- Divya Bharathi: Medical condonation approved -> Evaluated normally -> Grade A
(109, 80.0, 78.0, 82.0, 75.0, FALSE),
(110, 85.0, 80.0, 84.0, 80.0, FALSE),

-- Naveen Prasath: Absent in ESE -> Grade AB (0 pts)
(111, 85.0, 82.0, 88.0, NULL, TRUE),

-- Suresh Kumar: Theory ESE raw mark = 35 (< 45% threshold: 21/60 < 27 minimum) -> Grade RA
(112, 75.0, 70.0, 72.0, 35.0, FALSE),

-- Balaji T (CSE): High score -> Grade O
(113, 92.0, 94.0, 90.0, 92.0, FALSE),

-- Meena S (ECE): High score -> Grade O
(114, 90.0, 92.0, 94.0, 95.0, FALSE);

