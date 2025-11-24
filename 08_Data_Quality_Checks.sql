USE dwmisi2;
GO

-- 1. Check Completeness: NULL Values pada Dim_Student
SELECT 
    'Completeness: NULL Values' AS [Check],
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN StudentName IS NULL THEN 1 ELSE 0 END) AS Null_StudentName,
    SUM(CASE WHEN BirthDate IS NULL THEN 1 ELSE 0 END) AS Null_BirthDate,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Null_Gender
FROM dbo.Dim_Student;
GO

-- 2. Check Consistency: Orphan Fact Enrollment (fact tanpa master)
SELECT 
    'Consistency: Orphan Fact_Enrollment' AS [Check],
    COUNT(*) AS OrphanRecordCount
FROM dbo.Fact_Enrollment f
LEFT JOIN dbo.Dim_Student s ON f.StudentKey = s.StudentKey
WHERE s.StudentKey IS NULL;
GO

-- 3. Check Accuracy: Valid range Grade/IPK pada Fact_Enrollment
SELECT 
    'Accuracy: Invalid Grade Range' AS [Check],
    COUNT(*) AS InvalidGradeCount
FROM dbo.Fact_Enrollment
WHERE Grade < 0.00 OR Grade > 4.00;
GO

-- 4. Check Duplicates pada Dim_Student
SELECT
    'DuplicateCheck: StudentRegID' AS [Check],
    StudentRegID,
    COUNT(*) AS DuplicateCount
FROM dbo.Dim_Student
GROUP BY StudentRegID
HAVING COUNT(*) > 1;
GO

-- 5. Record Count Reconciliation
SELECT 
    'RecordCount: Dim_Student' AS [Check],
    COUNT(*) AS RecordCount 
FROM dbo.Dim_Student
UNION ALL
SELECT 
    'RecordCount: Fact_Enrollment', COUNT(*) FROM dbo.Fact_Enrollment;
GO
