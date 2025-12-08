CREATE TABLE dbo.Fact_Enrollment (
    EnrollmentKey BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,

    -- Foreign Keys
    DateKey INT NOT NULL,
    StudentKey INT NOT NULL,
    ProgramKey INT NOT NULL,   -- Pengganti CourseKey & InstructorKey
                               -- karena tidak ada tabelnya

    -- Degenerate Dimensions
    EnrollmentID VARCHAR(50) NOT NULL,
    ClassCode VARCHAR(20) NOT NULL,

    -- Measures
    Credits DECIMAL(3,1) NOT NULL,
    Grade DECIMAL(3,2) NULL,
    GradePoint DECIMAL(3,2) NULL,
    AttendanceCount INT DEFAULT 0,
    AttendanceRate DECIMAL(5,2) NULL,
    TuitionFee DECIMAL(12,2) NOT NULL,

    -- Flags
    IsPassed BIT NULL,
    IsDropped BIT DEFAULT 0,

    -- Metadata
    SourceSystem VARCHAR(50) NOT NULL,
    LoadDate DATETIME DEFAULT GETDATE(),

    -- Foreign Key Constraints
    CONSTRAINT FK_Fact_Enrollment_Date
        FOREIGN KEY (DateKey) REFERENCES dbo.Dim_Date(DateKey),

    CONSTRAINT FK_Fact_Enrollment_Student
        FOREIGN KEY (StudentKey) REFERENCES dbo.Dim_Student(StudentKey),

    CONSTRAINT FK_Fact_Enrollment_ProgramStudy
        FOREIGN KEY (ProgramKey) REFERENCES dbo.Dim_ProgramStudy(ProgramKey)
);
GO

