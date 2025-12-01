-- 1. CREATE STAGING SCHEMA
CREATE SCHEMA stg;
GO

-- 2. STAGING TABLE: STUDENT
CREATE TABLE stg.Student (
    NIM VARCHAR(20),
    StudentName VARCHAR(100),
    Gender VARCHAR(20),             
    BirthDate DATE NULL,
    EnrollmentDate DATE NULL,       
    ProgramName VARCHAR(100),
    Faculty VARCHAR(100),
    Status VARCHAR(20),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

-- 3. STAGING TABLE: PROGRAM
CREATE TABLE stg.Program (
    ProgramName VARCHAR(100),
    Faculty VARCHAR(100),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

-- 4. STAGING TABLE: ENROLLMENT (NILAI)
CREATE TABLE stg.Enrollment (
    EnrollmentID VARCHAR(50),
    NIM VARCHAR(20),
    EnrollmentDate DATE NULL,
    ProgramName VARCHAR(100),
    Semester VARCHAR(10),
    AcademicYear VARCHAR(9),
    Grade DECIMAL(3,1),
    IPK DECIMAL(3,2),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO
