USE dwmisi2;
GO

-- A. Dim_Date 
CREATE TABLE dbo.Dim_Date (
    DateKey INT PRIMARY KEY NOT NULL,
    FullDate DATE NOT NULL,
    DayNumberOfWeek TINYINT NOT NULL,
    DayName VARCHAR(10) NOT NULL,
    MonthNumber TINYINT NOT NULL,
    MonthName VARCHAR(10) NOT NULL,
    Year SMALLINT NOT NULL,
    AcademicYear VARCHAR(9) NULL,
    Semester TINYINT NULL
);
GO
ALTER TABLE dbo.Dim_Date ADD CONSTRAINT CK_Dim_Date_Month CHECK (MonthNumber BETWEEN 1 AND 12);
GO

-- B. Dim_Program (dari 'Program Studi' dan 'Fakultas')
CREATE TABLE dbo.Dim_Program (
    ProgramKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ProgramName VARCHAR(100) NOT NULL, 
    Faculty VARCHAR(100) NOT NULL      
);
GO

-- C. Dim_Student (dari 'NIM', 'Nama', 'Jenis Kelamin', 'Status Mahasiswa', 'Angkatan')
CREATE TABLE dbo.Dim_Student (
    StudentKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    StudentRegID VARCHAR(20) NOT NULL,  -- NIM (Natural Key)
    StudentName VARCHAR(100) NOT NULL,  -- Nama
    Gender CHAR(1) CHECK (Gender IN ('M','F')) NOT NULL, -- Jenis Kelamin
    EnrollmentDate DATE NULL,           -- Derivasi dari Angkatan
    Status VARCHAR(20) NOT NULL,        -- Status Mahasiswa

    -- SCD Type 2 attributes
    EffectiveDate DATE NOT NULL DEFAULT GETDATE(),
    ExpiryDate DATE NULL,
    IsCurrent BIT NOT NULL DEFAULT 1 
);
GO
CREATE UNIQUE NONCLUSTERED INDEX IX_Dim_Student_NK ON dbo.Dim_Student(StudentRegID) WHERE IsCurrent = 1; 
GO



