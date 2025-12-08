USE DM_Akademik_DW;
GO

------------------------------------------------
-- Tambahan: Create Views yang Diperlukan (Sesuai Konteks)
-- Ini diperlukan agar grant permission untuk db_viewer berhasil.
------------------------------------------------

-- View untuk Performa Mahasiswa (Mirip Query 3 & 4 dari 09_Test_Queries.sql)
IF OBJECT_ID('dbo.vw_Student_Performance', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Student_Performance;
GO

CREATE VIEW dbo.vw_Student_Performance
AS
SELECT
    s.NIM,
    s.StudentName,
    s.ProgramStudy,
    s.Faculty,
    s.EntryYear,
    s.StudentStatus,
    SUM(f.Credits) AS TotalCreditsTaken,
    AVG(f.Grade) AS AverageGrade,
    SUM(f.TuitionFee) AS TotalTuition
FROM dbo.Fact_Enrollment f
INNER JOIN dbo.Dim_Student s
    ON f.StudentKey = s.StudentKey
GROUP BY
    s.NIM, s.StudentName, s.ProgramStudy, s.Faculty, s.EntryYear, s.StudentStatus;
GO

-- View untuk Analisis Program Studi (Mirip Query 1 dari 09_Test_Queries.sql)
IF OBJECT_ID('dbo.vw_Program_Analytics', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Program_Analytics;
GO

CREATE VIEW dbo.vw_Program_Analytics
AS
SELECT
    p.ProgramStudy,
    p.Faculty,
    d.Year,
    COUNT(DISTINCT f.StudentKey) AS TotalStudentsInYear,
    AVG(f.Grade) AS ProgramAvgGrade,
    SUM(f.TuitionFee) AS TotalRevenue
FROM dbo.Fact_Enrollment f
INNER JOIN dbo.Dim_ProgramStudy p
    ON f.ProgramKey = p.ProgramKey
INNER JOIN dbo.Dim_Date d
    ON f.DateKey = d.DateKey
GROUP BY
    p.ProgramStudy, p.Faculty, d.Year;
GO

-- Pastikan menggunakan database Data Warehouse yang benar
USE DM_Akademik_DW;
GO

------------------------------------------------
-- 1. Create Database Roles
------------------------------------------------
CREATE ROLE db_executive;
CREATE ROLE db_analyst;
CREATE ROLE db_viewer;
CREATE ROLE db_etl_operator;
GO

------------------------------------------------
-- 2. Grant Permissions (Sesuai Gambar dan Struktur DB)
------------------------------------------------

-- ===========================================
-- Grant Permissions for db_executive
-- ===========================================
-- Akses baca seluruh schema (Dimensi/Fact)
GRANT SELECT ON SCHEMA::dbo TO db_executive;
-- Izin menjalankan prosedur master ETL (dbo.usp_Master_ETL)
GRANT EXECUTE ON OBJECT::dbo.usp_Master_ETL TO db_executive;
GO

-- ===========================================
-- Grant Permissions for db_analyst
-- ===========================================
-- Akses baca seluruh schema (Dimensi/Fact)
GRANT SELECT ON SCHEMA::dbo TO db_analyst;
-- Akses penuh (CRUD) ke semua tabel Staging (Menggunakan tabel spesifik karena di skrip Anda staging ada di schema dbo)
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Stg_Student TO db_analyst;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Stg_Enrollment TO db_analyst;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Stg_Date TO db_analyst;
-- (Tambahkan grant untuk Stg_ProgramStudy, Stg_Status, Stg_Gender jika Analis membutuhkannya)
GO

-- ===========================================
-- Grant Permissions for db_viewer (Sekarang View-nya sudah ada)
-- ===========================================
GRANT SELECT ON OBJECT::dbo.vw_Student_Performance TO db_viewer;
GRANT SELECT ON OBJECT::dbo.vw_Program_Analytics TO db_viewer;
GRANT SELECT ON OBJECT::dbo.Dim_Date TO db_viewer;
GO

-- ===========================================
-- Grant Permissions for db_etl_operator
-- ===========================================
-- Izin menjalankan semua Stored Procedure di schema dbo (untuk menjalankan ETL)
GRANT EXECUTE ON SCHEMA::dbo TO db_etl_operator;

-- Akses penuh (CRUD) ke semua tabel Staging
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Stg_Student TO db_etl_operator;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Stg_Enrollment TO db_etl_operator;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Stg_Date TO db_etl_operator;

-- Izin INSERT ke semua tabel di schema dbo (untuk memuat data Fact/Dimensi)
GRANT INSERT ON SCHEMA::dbo TO db_etl_operator;
GO

-- Create SQL Server Logins (Server Level)
-- Logins ini dibuat di tingkat server (master database), tetapi akan digunakan untuk masuk ke DM_Akademik_DW.
USE [master];
GO

CREATE LOGIN [user_executive] WITH PASSWORD = N'[Kelompok18DW]', CHECK_POLICY = ON, DEFAULT_DATABASE = [DM_Akademik_DW];
CREATE LOGIN [user_analyst] WITH PASSWORD = N'[Kelompok18DW]', CHECK_POLICY = ON, DEFAULT_DATABASE = [DM_Akademik_DW];
CREATE LOGIN [user_viewer] WITH PASSWORD = N'[Kelompok18DW]', CHECK_POLICY = ON, DEFAULT_DATABASE = [DM_Akademik_DW];
CREATE LOGIN [user_etl] WITH PASSWORD = N'[Kelompok18DW]', CHECK_POLICY = ON, DEFAULT_DATABASE = [DM_Akademik_DW];
GO

-- Create Database Users and Assign Roles (Database Level)
USE [DM_Akademik_DW];
GO

------------------------------------------------
-- 1. Create Database Users (Map Login ke User)
------------------------------------------------

-- Membuat User di database DM_Akademik_DW, yang terhubung ke Login yang sudah dibuat.
CREATE USER [user_executive] FOR LOGIN [user_executive];
CREATE USER [user_analyst] FOR LOGIN [user_analyst];
CREATE USER [user_viewer] FOR LOGIN [user_viewer];
CREATE USER [user_etl] FOR LOGIN [user_etl]; -- Digunakan untuk ETL Operator
GO

------------------------------------------------
-- 2. Assign Users to Roles
------------------------------------------------

-- Menetapkan (Add) setiap User ke Database Role yang sesuai.
-- Database Role ini telah memiliki izin (Grant) yang Anda atur sebelumnya.

-- Executive
ALTER ROLE [db_executive] ADD MEMBER [user_executive];
GO

-- Analyst
ALTER ROLE [db_analyst] ADD MEMBER [user_analyst];
GO

-- Viewer (Read-only)
ALTER ROLE [db_viewer] ADD MEMBER [user_viewer];
GO

-- ETL Operator
ALTER ROLE [db_etl_operator] ADD MEMBER [user_etl];
GO

USE DM_Akademik_DW;
GO

-- ==============================================================
-- 1. Implement Dynamic Data Masking (DDM) pada kolom PII yang ADA
-- Kolom Target: NIM dan StudentName (keduanya ada di dbo.Dim_Student)
-- ==============================================================

-- 1.1. Masking kolom NIM
-- Menggunakan fungsi 'partial' untuk menyembunyikan bagian tengah NIM,
-- hanya menampilkan 3 karakter pertama dan 4 karakter terakhir.
-- Contoh: 121XXXX1234
ALTER TABLE dbo.Dim_Student 
ALTER COLUMN NIM ADD MASKED WITH (FUNCTION = 'partial(3,"XXXX",4)');
GO

-- 1.2. Masking kolom StudentName (Nama Mahasiswa)
-- Menggunakan fungsi 'default()' yang akan mengganti nama dengan 'XXXX'
-- atau 'aXXXXa' tergantung tipe data. Karena ini VARCHAR, hasilnya 'XXXX'.
ALTER TABLE dbo.Dim_Student 
ALTER COLUMN StudentName ADD MASKED WITH (FUNCTION = 'default()');
GO

-- ==============================================================
-- 2. Grant UNMASK Permission
-- ==============================================================

-- Memberikan izin UNMASK (melihat data asli) kepada Role yang berwenang:
-- db_executive dan db_analyst.
-- db_viewer dan db_etl_operator akan melihat data yang disembunyikan (masked).

GRANT UNMASK TO db_executive;
GRANT UNMASK TO db_analyst;
GO

-- Audit Trail Menggunakan Trigger (Database Level)
USE DM_Akademik_DW;
GO
-- Gunakan CREATE OR ALTER untuk memastikan trigger dibuat jika belum ada
CREATE OR ALTER TRIGGER dbo.TR_Audit_Fact_Enrollment
ON dbo.Fact_Enrollment
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventType VARCHAR(50);
    DECLARE @RowsAffected INT;
    DECLARE @IPAddress_Varchar VARCHAR(50);

    -- Tentukan Event Type (INSERT, UPDATE, atau DELETE)
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @EventType = 'UPDATE';
    ELSE IF EXISTS (SELECT 1 FROM inserted)
        SET @EventType = 'INSERT';
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        SET @EventType = 'DELETE';
    ELSE
        RETURN; -- Tidak ada baris yang terpengaruh

    SET @RowsAffected = @@ROWCOUNT;

    -- Konversi Alamat IP ke VARCHAR secara eksplisit (Mengatasi Msg 257)
    SET @IPAddress_Varchar = CONVERT(VARCHAR(50), CONNECTIONPROPERTY('client_net_address'));

    -- Masukkan catatan audit ke tabel AuditLog
    INSERT INTO dbo.AuditLog (EventType, SchemaName, ObjectName, RowsAffected, IPAddress)
    VALUES (
        @EventType,
        'dbo',
        'Fact_Enrollment',
        @RowsAffected,
        @IPAddress_Varchar
    );
END
GO

-- Implementasi SQL Server Audit (Server & Database Level)
USE DM_Akademik_DW;
GO

-- 1. Bersihkan tabel AuditLog untuk pengujian
DELETE FROM dbo.AuditLog;
GO

-- 2. Lakukan Operasi DML pada dbo.Fact_Enrollment (Contoh: INSERT)
BEGIN TRY
    INSERT INTO dbo.Fact_Enrollment (
        DateKey, StudentKey, ProgramKey, EnrollmentID, ClassCode,
        Credits, Grade, GradePoint, AttendanceCount, AttendanceRate,
        TuitionFee, IsPassed, IsDropped, SourceSystem
    )
    VALUES (
        20250101, -- Ganti dengan DateKey yang valid
        100,      -- Ganti dengan StudentKey yang valid
        1,        -- Ganti dengan ProgramKey yang valid
        'ENR-TEST-001', 'CLS001', 3.0, 3.5, 3.5, 10, 80.00, 5000000.00, 1, 0, 'TEST_AUDIT'
    );
END TRY
BEGIN CATCH
    PRINT 'Gagal INSERT. Pastikan kunci asing (DateKey, StudentKey, ProgramKey) sudah ada.';
    -- Lanjutkan jika gagal, karena fokus kita adalah pada AuditLog
END CATCH
GO

-- 3. Cek Log: Verifikasi apakah trigger mencatat operasi INSERT
SELECT 
    AuditTimestamp, 
    UserName, 
    EventType, -- Seharusnya 'INSERT'
    ObjectName,
    RowsAffected,
    IPAddress,
    ApplicationName
FROM dbo.AuditLog
ORDER BY AuditID DESC;
GO

-- 4. Lakukan Operasi UPDATE (Jika INSERT berhasil)
UPDATE dbo.Fact_Enrollment
SET Grade = 4.00
WHERE EnrollmentID = 'ENR-TEST-001';
GO

-- 5. Cek Log Lagi: Verifikasi apakah trigger mencatat operasi UPDATE
SELECT 
    AuditTimestamp, 
    UserName, 
    EventType, -- Seharusnya 'UPDATE'
    ObjectName
FROM dbo.AuditLog
ORDER BY AuditID DESC;
GO

-- 6. Bersihkan data pengujian
DELETE FROM dbo.Fact_Enrollment WHERE EnrollmentID = 'ENR-TEST-001';
GO

-- 7. Cek Log Terakhir: Verifikasi apakah trigger mencatat operasi DELETE
SELECT 
    AuditTimestamp, 
    UserName, 
    EventType, -- Seharusnya 'DELETE'
    ObjectName
FROM dbo.AuditLog
ORDER BY AuditID DESC;
GO

USE master;
GO

-- Ganti string 'E:\SQL_Audit_Logs' dengan jalur file
SELECT
    event_time,
    succeeded,
    server_principal_name,
    database_name,
    schema_name,
    object_name,
    action_id,
    statement
FROM 
    sys.fn_get_audit_file(
        -- Langsung masukkan string path + wildcard
        N'E:\SQL_Audit_Logs\*.sqlaudit', 
        DEFAULT, 
        DEFAULT
    )
ORDER BY
    event_time DESC;
GO