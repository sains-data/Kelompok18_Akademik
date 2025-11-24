-- Query 1: Total students per program
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT
    p.ProgramName,
    COUNT(DISTINCT f.StudentKey) AS TotalStudents,
    SUM(f.Credit) AS TotalCredits
FROM
    Fact_Enrollment f
    INNER JOIN Dim_Program p ON f.ProgramKey = p.ProgramKey
    INNER JOIN Dim_Date d ON f.DateKey = d.DateKey
WHERE
    d.AcademicYear = '2024/2025'
GROUP BY
    p.ProgramName
ORDER BY
    TotalStudents DESC;

-- Query 2: Monthly enrollments trend
SELECT
    d.MonthNumber,
    d.MonthName,
    COUNT(DISTINCT f.EnrollmentKey) AS TotalEnrollments,
    COUNT(f.StudentKey) AS TotalStudents
FROM
    Fact_Enrollment f
    INNER JOIN Dim_Date d ON f.DateKey = d.DateKey
GROUP BY
    d.Year, d.MonthNumber, d.MonthName
ORDER BY
    d.Year, d.MonthNumber, d.MonthName;




