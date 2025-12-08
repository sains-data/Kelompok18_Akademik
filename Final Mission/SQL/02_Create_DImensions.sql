-- CREATE TABLE DIM_STUDENT --

CREATE TABLE dbo.Dim_Student (
    StudentKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,   -- Surrogate key

    -- Natural Keys & Personal Info
    NIM VARCHAR(20) UNIQUE NOT NULL,
    StudentName VARCHAR(100) NOT NULL,
    Gender VARCHAR(10) NOT NULL,            -- Laki-laki / Perempuan
    ProgramStudy VARCHAR(100) NOT NULL,
    Faculty VARCHAR(50) NOT NULL,
    EntryYear SMALLINT NOT NULL,            -- Angkatan
    StudentStatus VARCHAR(20) NOT NULL,     -- Aktif / Cuti / Nonaktif
    Semester TINYINT NOT NULL,

    -- Academic Attributes
    IPK DECIMAL(3,2) NULL,
    Nilai INT NULL,

    -- SCD Type 2
    EffectiveDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    ExpiryDate DATE NULL,
    IsCurrent BIT NOT NULL DEFAULT 1,

    -- Metadata
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- Indexing
CREATE INDEX IX_Dim_Student_NIM ON dbo.Dim_Student(NIM);
CREATE INDEX IX_Dim_Student_EntryYear ON dbo.Dim_Student(EntryYear);
CREATE INDEX IX_Dim_Student_IsCurrent ON dbo.Dim_Student(IsCurrent)
WHERE IsCurrent = 1;
GO


-- CREATE TABLE Dim_ProgramStudy --

CREATE TABLE dbo.Dim_ProgramStudy (
    ProgramKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ProgramStudy VARCHAR(100) NOT NULL,
    Faculty VARCHAR(100) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- CREATE TABLE Dim_Status --

CREATE TABLE dbo.Dim_Status (
    StatusKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    StatusName VARCHAR(20) NOT NULL
);
GO

-- CREATE TABLE Dim_Gender --

CREATE TABLE dbo.Dim_Gender (
    GenderKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    GenderName VARCHAR(20) NOT NULL
);
GO

-- CREATE TABLE Dim_Date

CREATE TABLE dbo.Dim_Date (
    DateKey INT PRIMARY KEY,       -- Format YYYYMMDD
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(15) NOT NULL,
    Day INT NOT NULL
);
GO

