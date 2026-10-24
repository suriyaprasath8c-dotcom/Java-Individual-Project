# Kongu Engineering College (Autonomous) - Regulation 2024 (R2024)
## Student Academic & Continuous Evaluation System using Java JDBC

---

### Project Overview
The **KEC R2024 Student Academic & Continuous Evaluation System** is a database-driven Java application built with JDBC to manage student academic records, implement phased continuous internal assessments (CIA) and end semester examinations (ESE), enforce attendance eligibility and medical condonation policies, calculate semester grade point averages (SGPA), and produce official academic reports.

---

### System Architecture & Database Deliverables

#### 1. Database Schema (`kec_schema.sql`)
The relational database `kec_academic` enforces referential integrity, constraints, and valid ranges:
- **`students`**: Stores student registration records (`roll_no` [PK], `name`, `department`, `current_semester`).
- **`courses`**: Course catalog (`course_code` [PK], `title`, `credits`, `course_type` [`THEORY`, `PRACTICAL`, `EMBEDDED`]).
- **`enrollments`**: Enrolls students into courses per semester, tracks attendance (`classes_held`, `classes_attended`), and medical condonation approval (`medical_approved`).
- **`assessment_marks`**: Stores incremental marks across assessment phases (`cia1`, `cia2`, `activities`, `ese`, `ese_absent`).

---

### Evaluation Engine & Weightage Rules (KEC R2024)

| Course Type | CIA Weightage | ESE Weightage | ESE Minimum Threshold | Overall Pass Minimum |
| :--- | :---: | :---: | :---: | :---: |
| **THEORY** | 40% | 60% | 45% (27/60 marks) | 50.0 Marks |
| **PRACTICAL** | 60% | 40% | 50% (20/40 marks) | 50.0 Marks |
| **EMBEDDED** | 50% | 50% | 45% (22.5/50 marks) | 50.0 Marks |

#### Continuous Internal Assessment (CIA) Aggregate
$$\text{CIA Aggregate (out of 100)} = \frac{\text{CIA Test 1} + \text{CIA Test 2} + \text{Assignments/Activities}}{3.0}$$

#### Total Weighted Score
$$\text{Total Marks} = (\text{CIA Aggregate} \times \text{CIA Weight}) + (\text{ESE Raw Mark} \times \text{ESE Weight})$$

---

### Attendance Eligibility & Grading Rules

#### Attendance Filter:
- $\ge 75\%$: Fully eligible to appear for ESE.
- $65\%$ to $74.9\%$: Conditionally eligible; requires formal **Medical Condonation** approval.
- $< 65\%$: Awarded **SA** (Shortage of Attendance) grade (0 Grade Points); barred from taking ESE.

#### 10-Point Grading Scale:
| Range of Marks | Letter Grade | Grade Point (GP) | Result Status |
| :---: | :---: | :---: | :---: |
| 91 – 100 | **O** (Outstanding) | 10 | PASS |
| 81 – 90 | **A+** (Excellent) | 9 | PASS |
| 71 – 80 | **A** (Very Good) | 8 | PASS |
| 61 – 70 | **B+** (Good) | 7 | PASS |
| 50 – 60 | **B** (Above Average) | 6 | PASS |
| Failed ESE Min or < 50 | **RA** (Re-Appearance) | 0 | FAIL |
| Attendance < 65% | **SA** (Shortage of Attendance) | 0 | FAIL / BARRED |
| Absent in ESE | **AB** (Absent) | 0 | ABSENT |

#### SGPA & Equivalent Percentage Formulas:
$$\text{SGPA} = \frac{\sum (\text{Course Credits} \times \text{Grade Points Earned})}{\sum (\text{Total Enrolled Credits})}$$

$$\text{Equivalent Percentage} = \text{SGPA} \times 10$$

---

### Phased Incremental Marks Entry ("Then and Now")

1. **Phase 1 (Mid-Semester)**:
   Record CIA Test 1 (0–100) and CIA Test 2 (0–100).
2. **Phase 2 (End of Semester - CIA)**:
   Record Assignments / Quizzes / Lab Evaluations (0–100).
3. **Phase 3 (Post Semester)**:
   Record End Semester Examination (ESE) Marks (0–100) or Mark Absence (`AB`). Attendance eligibility is verified beforehand.

---

### Project File Structure

```
KECEval/
├── kec_schema.sql                  # Database creation and seed records
├── run.bat                         # Windows batch launcher
├── run.ps1                         # PowerShell runner
├── README.md                       # Complete documentation
├── lib/
│   └── mysql-connector-j-8.4.0.jar # MySQL JDBC Type 4 Driver
├── src/
│   ├── DBConnection.java           # JDBC Connection Manager
│   ├── StudentDAO.java             # Student, Course, Enrollment & Attendance DAO
│   ├── AcademicDAO.java            # Assessment Engine, Marks Entry, & Reports DAO
│   └── MainApp.java                # Menu-driven CLI Interface
└── out/                            # Compiled bytecode (.class files)
```

---

### How to Compile and Run

#### Prerequisites:
- Java JDK 17 or later (installed: JDK 21)
- MySQL Server (configured on port 3307 or 3306)
- MySQL Connector/J (included in `lib/`)

#### Step 1: Initialize Database (if needed)
```powershell
Get-Content kec_schema.sql | & "C:\Program Files\MySQL\MySQL Server 26.10\bin\mysql.exe" -P 3307 -u root
```

#### Step 2: Compile
```powershell
javac -cp "lib/*" -d out src\DBConnection.java src\StudentDAO.java src\AcademicDAO.java src\MainApp.java
```

#### Step 3: Run
```powershell
java -cp "out;lib/*" MainApp
```
Or simply double-click `run.bat` or run `.\run.ps1` in PowerShell.

---

### Menu Operations & Reporting Outputs

1. **Add Student Registration**: Register student with Roll No, Name, Dept, Current Semester.
2. **View Students Directory**: Formatted table of registered students.
3. **Add Course**: Add THEORY, PRACTICAL, or EMBEDDED courses.
4. **View Course Catalog**: Display course codes, titles, credits, and evaluation types.
5. **Enroll Student**: Register a student into a course for a semester.
6. **View Enrollments & Attendance**: Display attendance percentages and eligibility flags.
7. **Record Attendance**: Update classes held and attended.
8. **Approve Medical Condonation**: Validates and approves condonation for students between 65% and 74.9%.
9. **Phase 1 Marks Entry**: Mid-semester CIA 1 & CIA 2 scores.
10. **Phase 2 Marks Entry**: End-of-semester assignments, quizzes, and lab scores.
11. **Phase 3 Marks Entry**: Post-semester ESE marks or ESE absence (AB).
12. **Student Semester Mark Sheet**: Complete academic transcript report with detailed breakdown, credits, SGPA, and equivalent percentage.
13. **Attendance Defaulter Report**: Lists students with attendance < 65% barred from ESE with SA grade, plus condonation tracker.
14. **Class Performance & Result Summary**: Department-wise pass/fail counts, pass percentage, grade distribution, and class average SGPA.

