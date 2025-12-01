USE dwmisi2;
GO

-- 1. Clustered Index pada Fact Table (untuk Partisi)
CREATE CLUSTERED INDEX CIX_Fact_Enrollment_DateKey
ON dbo.Fact_Enrollment (DateKey, EnrollmentKey);
GO



USE dwmisi2;
GO

-- 2. Non-Clustered Indexes untuk Foreign Keys
CREATE NONCLUSTERED INDEX IX_Fact_Enrollment_Student
ON dbo.Fact_Enrollment (StudentKey);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Enrollment_Program
ON dbo.Fact_Enrollment (ProgramKey);
GO



USE dwmisi2;
GO

-- 3. Columnstore Index
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCIX_Fact_Enrollment
ON dbo.Fact_Enrollment (
    DateKey, 
    StudentKey, 
    ProgramKey,
    Nilai, 
    IPK
);
GO



