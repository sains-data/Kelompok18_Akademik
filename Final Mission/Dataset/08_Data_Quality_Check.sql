/* ==========================================
   1. Data Quality Checks
   ========================================== */

------------------------------------------------
-- Check 1: Completeness - NULL / kosong
------------------------------------------------
SELECT
    'Dim_Student' AS TableName,
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN NIM IS NULL OR LTRIM(RTRIM(NIM)) = '' THEN 1 ELSE 0 END)       AS NullOrEmptyNIM,
    SUM(CASE WHEN StudentName IS NULL OR LTRIM(RTRIM(StudentName)) = '' THEN 1 ELSE 0 END) AS NullOrEmptyName,
    SUM(CASE WHEN Gender IS NULL OR LTRIM(RTRIM(Gender)) = '' THEN 1 ELSE 0 END) AS NullOrEmptyGender,
    SUM(CASE WHEN ProgramStudy IS NULL OR LTRIM(RTRIM(ProgramStudy)) = '' THEN 1 ELSE 0 END) AS NullOrEmptyProgram,
    SUM(CASE WHEN Faculty IS NULL OR LTRIM(RTRIM(Faculty)) = '' THEN 1 ELSE 0 END) AS NullOrEmptyFaculty
FROM dbo.Dim_Student;


------------------------------------------------
-- Check 2: Consistency - Referential Integrity
-- Orphan di Fact_Enrollment terhadap Dim_Student
------------------------------------------------
SELECT
    COUNT(*) AS OrphanStudentKey
FROM dbo.Fact_Enrollment f
LEFT JOIN dbo.Dim_Student s
    ON f.StudentKey = s.StudentKey
WHERE s.StudentKey IS NULL;


-- Orphan terhadap Dim_Date
SELECT
    COUNT(*) AS OrphanDateKey
FROM dbo.Fact_Enrollment f
LEFT JOIN dbo.Dim_Date d
    ON f.DateKey = d.DateKey
WHERE d.DateKey IS NULL;


-- Orphan terhadap Dim_ProgramStudy
SELECT
    COUNT(*) AS OrphanProgramKey
FROM dbo.Fact_Enrollment f
LEFT JOIN dbo.Dim_ProgramStudy p
    ON f.ProgramKey = p.ProgramKey
WHERE p.ProgramKey IS NULL;


------------------------------------------------
-- Check 3: Accuracy - Valid ranges (Fact_Enrollment)
------------------------------------------------
-- Nilai Grade di luar range 0–4
SELECT
    COUNT(*) AS InvalidGrades
FROM dbo.Fact_Enrollment
WHERE Grade < 0 OR Grade > 4.00;


-- AttendanceRate seharusnya 0–100
SELECT
    COUNT(*) AS InvalidAttendanceRate
FROM dbo.Fact_Enrollment
WHERE AttendanceRate < 0 OR AttendanceRate > 100;


-- Credits seharusnya > 0 (mis: 1–24)
SELECT
    COUNT(*) AS InvalidCredits
FROM dbo.Fact_Enrollment
WHERE Credits <= 0;


------------------------------------------------
-- Check 4: Duplicates - EnrollmentID di Fact
------------------------------------------------
SELECT
    EnrollmentID,
    COUNT(*) AS DuplicateCount
FROM dbo.Fact_Enrollment
GROUP BY EnrollmentID
HAVING COUNT(*) > 1;   -- hanya yang duplikat


------------------------------------------------
-- Check 5: Record Counts Reconciliation
-- Perbandingan jumlah baris antara sumber (staging)
-- dan fact di data warehouse
------------------------------------------------
SELECT
    'Staging_Enrollment' AS DataSource,
    COUNT(*) AS RecordCount
FROM dbo.Stg_Enrollment
UNION ALL
SELECT
    'Fact_Enrollment' AS DataSource,
    COUNT(*) AS RecordCount
FROM dbo.Fact_Enrollment;


------------------------------------------------
-- (Opsional) Rekonsiliasi jumlah mahasiswa
------------------------------------------------
SELECT
    'Staging_Student' AS DataSource,
    COUNT(*) AS RecordCount
FROM dbo.Stg_Student
UNION ALL
SELECT
    'Dim_Student (IsCurrent=1)' AS DataSource,
    COUNT(*) AS RecordCount
FROM dbo.Dim_Student
WHERE IsCurrent = 1;