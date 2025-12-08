CREATE CLUSTERED INDEX CIX_Fact_Enrollment_DateKey
ON dbo.Fact_Enrollment(DateKey, EnrollmentKey);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Enrollment_Student
ON dbo.Fact_Enrollment(StudentKey)
INCLUDE (Credits, Grade);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Enrollment_Program
ON dbo.Fact_Enrollment(ProgramKey, DateKey)
INCLUDE (StudentKey, Grade);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Enrollment_Covering
ON dbo.Fact_Enrollment(DateKey, ProgramKey)
INCLUDE (StudentKey, Credits, Grade, TuitionFee);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fact_Enrollment
ON dbo.Fact_Enrollment
(
    DateKey,
    StudentKey,
    ProgramKey,
    Credits,
    Grade,
    GradePoint,
    TuitionFee,
    AttendanceRate,
    AttendanceCount
);
GO

