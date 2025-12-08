CREATE PROCEDURE dbo.usp_Load_Dim_ProgramStudy
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Dim_ProgramStudy (ProgramStudy, Faculty, CreatedDate)
    SELECT DISTINCT
        s.ProgramStudy,
        s.Faculty,
        GETDATE()
    FROM dbo.Stg_ProgramStudy s
    LEFT JOIN dbo.Dim_ProgramStudy d 
        ON d.ProgramStudy = s.ProgramStudy
       AND d.Faculty = s.Faculty
    WHERE d.ProgramKey IS NULL;
END
GO

CREATE PROCEDURE dbo.usp_Load_Dim_Status
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Dim_Status (StatusName)
    SELECT DISTINCT s.StatusName
    FROM dbo.Stg_Status s
    LEFT JOIN dbo.Dim_Status d 
        ON d.StatusName = s.StatusName
    WHERE d.StatusKey IS NULL;
END
GO

CREATE PROCEDURE dbo.usp_Load_Dim_Gender
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Dim_Gender (GenderName)
    SELECT DISTINCT s.GenderName
    FROM dbo.Stg_Gender s
    LEFT JOIN dbo.Dim_Gender d 
        ON d.GenderName = s.GenderName
    WHERE d.GenderKey IS NULL;
END
GO

CREATE PROCEDURE dbo.usp_Load_Dim_Date
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Dim_Date (DateKey, FullDate, Year, Month, MonthName, Day)
    SELECT DISTINCT
        ISNULL(s.DateKey, CONVERT(INT, FORMAT(s.FullDate,'yyyyMMdd'))),
        s.FullDate,
        s.Year,
        s.Month,
        s.MonthName,
        s.Day
    FROM dbo.Stg_Date s
    LEFT JOIN dbo.Dim_Date d
        ON d.DateKey = ISNULL(s.DateKey, CONVERT(INT, FORMAT(s.FullDate,'yyyyMMdd')))
    WHERE d.DateKey IS NULL;
END
GO

CREATE PROCEDURE dbo.usp_Load_Dim_Student
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Today DATE = GETDATE();

    -- ❗ Expire old records (detect change)
    UPDATE d
    SET d.ExpiryDate = @Today,
        d.IsCurrent = 0,
        d.ModifiedDate = GETDATE()
    FROM dbo.Dim_Student d
    INNER JOIN dbo.Stg_Student s
        ON d.NIM = s.NIM
    WHERE d.IsCurrent = 1
      AND (
            d.StudentName  <> s.StudentName  OR
            d.StudentStatus<> s.StudentStatus OR
            d.ProgramStudy <> s.ProgramStudy OR
            d.Semester     <> s.Semester     OR
            d.IPK          <> s.IPK          OR
            d.Nilai        <> s.Nilai
          );


    -- ❗ Insert new students or changed-records
    INSERT INTO dbo.Dim_Student (
        NIM, StudentName, Gender, ProgramStudy, Faculty,
        EntryYear, StudentStatus, Semester, IPK, Nilai,
        EffectiveDate, ExpiryDate, IsCurrent,
        CreatedDate, ModifiedDate
    )
    SELECT
        s.NIM,
        UPPER(TRIM(s.StudentName)),
        s.Gender,
        s.ProgramStudy,
        s.Faculty,
        s.EntryYear,
        s.StudentStatus,
        s.Semester,
        s.IPK,
        s.Nilai,
        @Today,
        NULL,
        1,
        GETDATE(),
        GETDATE()
    FROM dbo.Stg_Student s
    LEFT JOIN dbo.Dim_Student d
        ON d.NIM = s.NIM
       AND d.IsCurrent = 1
    WHERE d.NIM IS NULL    -- new
       OR d.IsCurrent = 0; -- expired versions need new row
END
GO

CREATE PROCEDURE dbo.usp_Load_Fact_Enrollment
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Fact_Enrollment (
        DateKey,
        StudentKey,
        ProgramKey,
        EnrollmentID,
        ClassCode,
        Credits,
        Grade,
        GradePoint,
        AttendanceCount,
        AttendanceRate,
        TuitionFee,
        IsPassed,
        IsDropped,
        SourceSystem,
        LoadDate
    )
    SELECT
        d.DateKey,
        st.StudentKey,
        p.ProgramKey,
        s.EnrollmentID,
        s.ClassCode,
        s.Credits,
        s.Grade,
        s.GradePoint,
        s.AttendanceCount,
        s.AttendanceRate,
        s.TuitionFee,
        CASE WHEN s.Grade >= 2.00 THEN 1 ELSE 0 END,
        s.IsDropped,
        s.SourceSystem,
        GETDATE()
    FROM dbo.Stg_Enrollment s
    INNER JOIN dbo.Dim_Student st
        ON st.NIM = s.NIM
       AND st.IsCurrent = 1
    INNER JOIN dbo.Dim_ProgramStudy p
        ON p.ProgramStudy = s.ProgramStudy
    INNER JOIN dbo.Dim_Date d
        ON d.FullDate = s.EnrollmentDate
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Fact_Enrollment f
        WHERE f.EnrollmentID = s.EnrollmentID
    );
END
GO

CREATE PROCEDURE dbo.usp_Master_ETL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Step 1: Load Dimensions
        EXEC dbo.usp_Load_Dim_ProgramStudy;
        EXEC dbo.usp_Load_Dim_Gender;
        EXEC dbo.usp_Load_Dim_Status;
        EXEC dbo.usp_Load_Dim_Date;
        EXEC dbo.usp_Load_Dim_Student;

        -- Step 2: Load Facts
        EXEC dbo.usp_Load_Fact_Enrollment;

        -- Step 3: Refresh Statistics (opsional tapi sesuai contohmu)
        UPDATE STATISTICS dbo.Dim_Student;
        UPDATE STATISTICS dbo.Fact_Enrollment;

        COMMIT TRANSACTION;
        PRINT 'ETL Completed Successfully';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH;
END
GO

IF OBJECT_ID('dbo.usp_Load_Dim_Date', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Load_Dim_Date;
GO

CREATE PROCEDURE dbo.usp_Load_Dim_Date
AS
BEGIN
    SET NOCOUNT ON;

    /* 
        Asumsi struktur Stg_Date:
        FullDate    DATE
        Year        INT
        Month       INT
        MonthName   VARCHAR(15)
        Day         INT
        (+ kolom audit lain, tidak dipakai di sini)
    */

    INSERT INTO dbo.Dim_Date (DateKey, FullDate, Year, Month, MonthName, Day)
    SELECT DISTINCT
        CONVERT(INT, FORMAT(s.FullDate, 'yyyyMMdd')) AS DateKey,
        s.FullDate,
        s.Year,
        s.Month,
        s.MonthName,
        s.Day
    FROM dbo.Stg_Date s
    LEFT JOIN dbo.Dim_Date d
        ON d.DateKey = CONVERT(INT, FORMAT(s.FullDate, 'yyyyMMdd'))
    WHERE d.DateKey IS NULL;   -- hanya tanggal yang belum ada di Dim_Date
END
GO

-- Recreate / alter master ETL kalau perlu, lalu jalankan:
EXEC dbo.usp_Load_Dim_Date;
-- atau:
EXEC dbo.usp_Master_ETL;