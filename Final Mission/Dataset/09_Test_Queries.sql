/* ==========================================
   1. CREATE TEST QUERIES
   ========================================== */

-- Aktifkan statistik untuk cek performa (opsional)
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

/* ------------------------------------------
   Query 1:
   Ringkasan mahasiswa per Program Studi
   (untuk tahun akademik 2024/2025)
   ------------------------------------------ */
SELECT
    p.ProgramStudy                              AS ProgramName,
    COUNT(DISTINCT f.StudentKey)               AS TotalStudents,
    AVG(f.Grade)                               AS AvgGrade,
    SUM(f.Credits)                             AS TotalCredits,
    SUM(f.TuitionFee)                          AS TotalTuitionFee
FROM dbo.Fact_Enrollment f
INNER JOIN dbo.Dim_ProgramStudy p
        ON f.ProgramKey = p.ProgramKey
INNER JOIN dbo.Dim_Date d
        ON f.DateKey = d.DateKey
CROSS APPLY (
    SELECT AcademicYear =
        CASE 
            WHEN d.Month >= 8 THEN 
                CONCAT(d.Year, '/', d.Year + 1)   -- Aug–Dec -> Year/Year+1
            ELSE 
                CONCAT(d.Year - 1, '/', d.Year)   -- Jan–Jul -> Year-1/Year
        END
) ay
WHERE ay.AcademicYear = '2024/2025'
GROUP BY
    p.ProgramStudy
ORDER BY
    TotalStudents DESC;
GO


/* ------------------------------------------
   Query 2:
   Tren enrollment & revenue bulanan
   (semua tahun)
   ------------------------------------------ */
SELECT
    d.Year,
    d.Month              AS MonthNumber,
    d.MonthName,
    COUNT(DISTINCT f.EnrollmentKey) AS TotalEnrollments,
    SUM(f.TuitionFee)               AS TotalRevenue
FROM dbo.Fact_Enrollment f
INNER JOIN dbo.Dim_Date d
        ON f.DateKey = d.DateKey
GROUP BY
    d.Year,
    d.Month,
    d.MonthName
ORDER BY
    d.Year,
    d.Month;
GO


/* ------------------------------------------
   Query 3:
   Ringkasan per Fakultas
   ------------------------------------------ */
SELECT
    s.Faculty,
    COUNT(DISTINCT f.StudentKey)    AS TotalStudents,
    COUNT(DISTINCT f.EnrollmentKey) AS TotalEnrollments,
    AVG(f.Grade)                    AS AvgGrade,
    SUM(f.TuitionFee)              AS TotalTuition
FROM dbo.Fact_Enrollment f
INNER JOIN dbo.Dim_Student s
        ON f.StudentKey = s.StudentKey
GROUP BY
    s.Faculty
ORDER BY
    TotalStudents DESC;
GO


/* ------------------------------------------
   Query 4:
   Top 10 mahasiswa berdasarkan total SKS
   ------------------------------------------ */
SELECT TOP 10
    s.StudentKey,
    s.NIM,
    s.StudentName,
    s.ProgramStudy,
    s.Faculty,
    SUM(f.Credits)          AS TotalCredits,
    AVG(f.Grade)            AS AvgGrade,
    SUM(f.TuitionFee)       AS TotalTuition
FROM dbo.Fact_Enrollment f
INNER JOIN dbo.Dim_Student s
        ON f.StudentKey = s.StudentKey
GROUP BY
    s.StudentKey,
    s.NIM,
    s.StudentName,
    s.ProgramStudy,
    s.Faculty
ORDER BY
    TotalCredits DESC,
    AvgGrade DESC;
GO