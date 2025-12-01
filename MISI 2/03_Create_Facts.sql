USE dwmisi2;
GO

CREATE TABLE dbo.Fact_Enrollment (
    EnrollmentKey BIGINT IDENTITY(1,1) NOT NULL,

    -- Foreign Keys
    DateKey INT NOT NULL,           
    StudentKey INT NOT NULL,        
    ProgramKey INT NOT NULL,        
    
    -- Degenerate Dimensions & Measures
    Semester TINYINT NOT NULL,         
    Nilai DECIMAL(3,1) NOT NULL,       
    IPK DECIMAL(3,2) NOT NULL,         
    
    -- Metadata
    SourceSystem VARCHAR(50) NOT NULL DEFAULT 'Data_Mahasiswa',
    LoadDate DATETIME DEFAULT GETDATE(),
    
    -- Primary Key & Constraints
    CONSTRAINT PK_Fact_Enrollment PRIMARY KEY NONCLUSTERED (EnrollmentKey),
    CONSTRAINT FK_Fact_Enrollment_Date FOREIGN KEY (DateKey) REFERENCES dbo.Dim_Date (DateKey),
    CONSTRAINT FK_Fact_Enrollment_Student FOREIGN KEY (StudentKey) REFERENCES dbo.Dim_Student (StudentKey),
    CONSTRAINT FK_Fact_Enrollment_Program FOREIGN KEY (ProgramKey) REFERENCES dbo.Dim_Program (ProgramKey)
);
GO



