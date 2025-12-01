CREATE PROCEDURE dbo.usp_Load_Dim_Program
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Dim_Program (
        ProgramName,
        Faculty
    )
    SELECT DISTINCT
        TRIM(p.ProgramName),
        TRIM(p.Faculty)
    FROM stg.Program p
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Dim_Program dp
        WHERE TRIM(dp.ProgramName) = TRIM(p.ProgramName)
          AND TRIM(dp.Faculty) = TRIM(p.Faculty)
    );
END;
GO

CREATE PROCEDURE dbo.usp_Load_Dim_Student
AS
BEGIN
    SET NOCOUNT ON;
    -- Expire old records (SCD2)
    UPDATE d
    SET ExpiryDate = GETDATE(), IsCurrent = 0
    FROM dbo.Dim_Student d
    INNER JOIN stg.Student s ON d.StudentRegID = s.NIM
    WHERE d.IsCurrent = 1
      AND (
         d.StudentName <> UPPER(TRIM(s.StudentName))
         OR d.Gender <> CASE WHEN s.Gender = 'L' THEN 'M' ELSE 'F' END
         OR d.Status <> s.Status
      );
    -- Insert new/changed records
    INSERT INTO dbo.Dim_Student (
        StudentRegID,
        StudentName,
        Gender,
        EnrollmentDate,
        Status,
        EffectiveDate,
        IsCurrent
    )
    SELECT
        s.NIM,
        UPPER(TRIM(s.StudentName)),
        CASE WHEN s.Gender = 'L' THEN 'M' ELSE 'F' END,
        CAST(s.EnrollmentDate AS DATE),
        s.Status,
        GETDATE(),
        1
    FROM stg.Student s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Dim_Student d
        WHERE s.NIM = d.StudentRegID AND d.IsCurrent = 1
    );
END;
GO

CREATE PROCEDURE dbo.usp_Load_Fact_Enrollment
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Fact_Enrollment (
        DateKey,
        StudentKey,
        ProgramKey,
        Semester,
        Nilai,
        IPK,
        SourceSystem,
        LoadDate
    )
    SELECT
        CAST(CONVERT(VARCHAR(8), e.EnrollmentDate, 112) AS INT) AS DateKey,
        ds.StudentKey,
        dp.ProgramKey,
        CONVERT(TINYINT, e.Semester),
        CONVERT(DECIMAL(3,1), e.Grade),
        CONVERT(DECIMAL(3,2), e.IPK),
        'Data_Mahasiswa',
        GETDATE()
    FROM stg.Enrollment e
    INNER JOIN dbo.Dim_Student ds ON e.NIM = ds.StudentRegID AND ds.IsCurrent = 1
    INNER JOIN dbo.Dim_Program dp ON e.ProgramName = dp.ProgramName
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Fact_Enrollment fe
        WHERE fe.StudentKey = ds.StudentKey
          AND fe.ProgramKey = dp.ProgramKey
          AND fe.DateKey = CAST(CONVERT(VARCHAR(8), e.EnrollmentDate, 112) AS INT)
          AND fe.Semester = CONVERT(TINYINT, e.Semester)
    );
END;
GO

CREATE PROCEDURE dbo.usp_Master_ETL
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Step 1: Load Dimensions
        EXEC dbo.usp_Load_Dim_Program;
        EXEC dbo.usp_Load_Dim_Student;
        -- Step 2: Load Fact
        EXEC dbo.usp_Load_Fact_Enrollment;
        -- Step 3: Update Statistics
        UPDATE STATISTICS dbo.Dim_Student;
        UPDATE STATISTICS dbo.Dim_Program;
        UPDATE STATISTICS dbo.Fact_Enrollment;
        COMMIT TRANSACTION;
        PRINT 'ETL Completed Successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

