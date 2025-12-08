/* ==========================================
   STAGING TABLES
   ========================================== */

-------------------------
-- 1. STAGING STUDENT
-------------------------
IF OBJECT_ID('dbo.Stg_Student', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_Student;
GO

CREATE TABLE dbo.Stg_Student (
    -- Natural keys & attributes from source
    NIM             VARCHAR(20)     NULL,
    StudentName     VARCHAR(100)    NULL,
    Gender          VARCHAR(20)     NULL,   -- "Laki-laki" / "Perempuan"
    ProgramStudy    VARCHAR(100)    NULL,
    Faculty         VARCHAR(100)    NULL,
    EntryYear       SMALLINT        NULL,
    StudentStatus   VARCHAR(20)     NULL,   -- "Aktif" / "Cuti" / "Nonaktif"
    Semester        TINYINT         NULL,
    IPK             DECIMAL(3,2)    NULL,
    Nilai           INT             NULL,

    -- Audit / technical columns
    SourceSystem    VARCHAR(50)     NULL,
    SourceFileName  VARCHAR(255)    NULL,
    SourceRowNumber INT             NULL,
    BatchID         INT             NULL,
    LoadDate        DATETIME        NOT NULL DEFAULT(GETDATE())
);
GO


-------------------------
-- 2. STAGING PROGRAM STUDY
-------------------------
IF OBJECT_ID('dbo.Stg_ProgramStudy', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_ProgramStudy;
GO

CREATE TABLE dbo.Stg_ProgramStudy (
    ProgramCode     VARCHAR(50)     NULL,   
    ProgramStudy    VARCHAR(100)    NULL,
    Faculty         VARCHAR(100)    NULL,

    -- Audit
    SourceSystem    VARCHAR(50)     NULL,
    SourceFileName  VARCHAR(255)    NULL,
    SourceRowNumber INT             NULL,
    BatchID         INT             NULL,
    LoadDate        DATETIME        NOT NULL DEFAULT(GETDATE())
);
GO


-------------------------
-- 3. STAGING STATUS
-------------------------
IF OBJECT_ID('dbo.Stg_Status', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_Status;
GO

CREATE TABLE dbo.Stg_Status (
    StatusCode      VARCHAR(20)     NULL,   
    StatusName      VARCHAR(20)     NULL,   -- "Aktif", "Cuti", "Nonaktif"

    -- Audit
    SourceSystem    VARCHAR(50)     NULL,
    SourceFileName  VARCHAR(255)    NULL,
    SourceRowNumber INT             NULL,
    BatchID         INT             NULL,
    LoadDate        DATETIME        NOT NULL DEFAULT(GETDATE())
);
GO


-------------------------
-- 4. STAGING GENDER
-------------------------
IF OBJECT_ID('dbo.Stg_Gender', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_Gender;
GO

CREATE TABLE dbo.Stg_Gender (
    GenderCode      VARCHAR(10)     NULL,   -- contoh: "L", "P"
    GenderName      VARCHAR(20)     NULL,   -- "Laki-laki", "Perempuan"

    -- Audit
    SourceSystem    VARCHAR(50)     NULL,
    SourceFileName  VARCHAR(255)    NULL,
    SourceRowNumber INT             NULL,
    BatchID         INT             NULL,
    LoadDate        DATETIME        NOT NULL DEFAULT(GETDATE())
);
GO


-------------------------
-- 5. STAGING ENROLLMENT (FACT)
-------------------------
IF OBJECT_ID('dbo.Stg_Enrollment', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_Enrollment;
GO

CREATE TABLE dbo.Stg_Enrollment (
    -- Natural keys & source attributes
    EnrollmentID        VARCHAR(50)     NULL,
    EnrollmentDate      DATE            NULL,   -- akan di-mapping ke Dim_Date.DateKey (YYYYMMDD)
    NIM                 VARCHAR(20)     NULL,   -- akan di-mapping ke Dim_Student (StudentKey)
    ProgramStudy        VARCHAR(100)    NULL,   -- akan di-mapping ke Dim_ProgramStudy (ProgramKey)
    ClassCode           VARCHAR(20)     NULL,

    Credits             DECIMAL(3,1)    NULL,
    Grade               DECIMAL(3,2)    NULL,   -- nilai angka dari sumber
    GradePoint          DECIMAL(3,2)    NULL,   -- kalau ada di source
    AttendanceCount     INT             NULL,
    AttendanceRate      DECIMAL(5,2)    NULL,   -- dalam persen (0-100)
    TuitionFee          DECIMAL(12,2)   NULL,

    IsPassed            BIT             NULL,
    IsDropped           BIT             NULL,

    -- Audit
    SourceSystem        VARCHAR(50)     NULL,
    SourceFileName      VARCHAR(255)    NULL,
    SourceRowNumber     INT             NULL,
    BatchID             INT             NULL,
    LoadDate            DATETIME        NOT NULL DEFAULT(GETDATE())
);
GO

IF OBJECT_ID('dbo.Stg_Date', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_Date;
GO

CREATE TABLE dbo.Stg_Date (
    -- Data tanggal dari sumber (bisa dari kalender, transaksi, dsb.)
    FullDate        DATE            NULL,   -- contoh: '2024-09-01'
    Year            INT             NULL,   -- 2024
    Month           TINYINT         NULL,   -- 1-12
    MonthName       VARCHAR(20)     NULL,   -- Januari, Februari, dst (atau English)
    Day             TINYINT         NULL,   -- 1-31

    -- Optional tambahan kalau mau:
    DayOfWeek       TINYINT         NULL,   -- 1-7 (Senin–Minggu, atau sesuai aturan)
    DayName         VARCHAR(20)     NULL,   -- Senin, Selasa, dst
    WeekOfYear      TINYINT         NULL,   -- 1-53
    IsWeekend       BIT             NULL,   -- 1 = Sabtu/Minggu (atau sesuai definisi)

    -- Audit / teknis
    SourceSystem    VARCHAR(50)     NULL,
    SourceFileName  VARCHAR(255)    NULL,
    SourceRowNumber INT             NULL,
    BatchID         INT             NULL,
    LoadDate        DATETIME        NOT NULL DEFAULT(GETDATE())
);
GO