/* ===========================================
   STEP 3 : PARTITIONING STRATEGY
   Partition by Academic Year using DateKey
   =========================================== */

-- 1. Create Partition Function (by Academic Year)
CREATE PARTITION FUNCTION PF_AcademicYear (INT)
AS RANGE RIGHT FOR VALUES
(
    20200801, -- 2020/2021
    20210801, -- 2021/2022
    20220801, -- 2022/2023
    20230801, -- 2023/2024
    20240801, -- 2024/2025
    20250801  -- 2025/2026
);
GO

-- 2. Create Partition Scheme
CREATE PARTITION SCHEME PS_AcademicYear
AS PARTITION PF_AcademicYear
ALL TO ([PRIMARY]);
GO


-- 3. Create Partitioned Fact Table (FULL STRUCTURE)
CREATE TABLE dbo.Fact_Enrollment_Partitioned
(
    EnrollmentKey     INT IDENTITY(1,1) NOT NULL,
    DateKey           INT NOT NULL,
    StudentKey        INT NOT NULL,
    CourseKey         INT NOT NULL,
    ProgramKey        INT NOT NULL,
    Credits           INT NULL,
    Grade             VARCHAR(5) NULL,
    TuitionFee        DECIMAL(18,2) NULL,
    AttendanceRate    DECIMAL(5,2) NULL,

    -- Primary Key (Clustered) placed on the partition scheme
    CONSTRAINT PK_Fact_Enrollment_Partitioned PRIMARY KEY CLUSTERED (EnrollmentKey, DateKey)
) 
ON PS_AcademicYear(DateKey);  -- <=== THIS IS THE PARTITIONING COLUMN
GO
