USE dwmisi2;
GO

-- 1. Create Partition Function (PF_AcademicYear)
CREATE PARTITION FUNCTION PF_AcademicYear (INT)
AS RANGE RIGHT FOR VALUES
(
    20200801, -- Batas Akademik Year
    20210801, 
    20220801,
    20230801,
    20240801,
    20250801
);
GO

-- 2. Create Partition Scheme (PS_AcademicYear)
CREATE PARTITION SCHEME PS_AcademicYear
AS PARTITION PF_AcademicYear
ALL TO ([PRIMARY]); 
GO

-- 3. Create Partitioned Fact Table
CREATE TABLE dbo.Fact_Enrollment_Partitioned (
    EnrollmentKey BIGINT IDENTITY(1,1) NOT NULL,
    DateKey INT NOT NULL,           
    StudentKey INT NOT NULL,        
    ProgramKey INT NOT NULL,        
    Semester TINYINT NOT NULL,         
    Nilai DECIMAL(3,1) NOT NULL,       
    IPK DECIMAL(3,2) NOT NULL,         
    SourceSystem VARCHAR(50) NOT NULL DEFAULT 'Data_Mahasiswa',
    LoadDate DATETIME DEFAULT GETDATE()
)
ON PS_AcademicYear(DateKey); -- Terapkan Partisi
GO



