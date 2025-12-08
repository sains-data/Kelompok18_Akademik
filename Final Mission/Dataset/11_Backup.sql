USE [master];
GO

-- Full Database Backup (Kompresi Dihapus)
BACKUP DATABASE DM_Akademik_DW
TO DISK = N'E:\Backup\DM_Akademik_DW\DM_Akademik_DW_Full.bak' -- Ganti jalur ini!
WITH
    INIT,        -- Menimpa file backup yang sudah ada
    NAME = N'DM_Akademik_DW Full Database Backup',
    STATS = 10;  
GO

USE [master];
GO

-- Differential Backup (Kompresi Dihapus)
BACKUP DATABASE DM_Akademik_DW
TO DISK = N'E:\Backup\DM_Akademik_DW\DM_Akademik_DW_Diff.bak' -- Ganti jalur ini!
WITH
    DIFFERENTIAL, -- Kunci untuk Differential Backup
    INIT,
    NAME = N'DM_Akademik_DW Differential Database Backup',
    STATS = 10;
GO

USE [master];
GO

ALTER DATABASE DM_Akademik_DW
SET RECOVERY FULL;
GO

BACKUP DATABASE DM_Akademik_DW
TO DISK = N'E:\Backup\DM_Akademik_DW\DM_Akademik_DW_Full_NewChain.bak' -- Ganti jalur ini!
WITH
    INIT,
    NAME = N'DM_Akademik_DW Full Backup (New Chain)',
    STATS = 10;
GO
-- Transaction Log Backup (Kompresi Dihapus)
BACKUP LOG DM_Akademik_DW
TO DISK = N'E:\Backup\DM_Akademik_DW\DM_Akademik_DW_log.trn' -- Ganti jalur ini!
WITH
    INIT,
    NAME = N'DM_Akademik_DW Transaction Log Backup',
    STATS = 10;
GO

USE [master];
GO

-- *******************************************************************
-- OPSIONAL: Backup ke Azure Blob Storage
-- Hanya jalankan jika Anda memiliki akun Azure Storage dan SAS Token.
-- *******************************************************************

-- 4.1. Create SQL Credential
-- GANTI 'AzureStorageCredential' DENGAN NAMA CREDENTIAL ANDA
-- GANTI <SAS_TOKEN> DENGAN TOKEN AKSES YANG BENAR
CREATE CREDENTIAL [AzureStorageCredential]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = '<SAS_TOKEN>'; 
GO

-- 4.2. Backup ke Azure URL
-- GANTI [storage_account] dan URL path DENGAN DATA ANDA
BACKUP DATABASE DM_Akademik_DW
TO URL = N'https://[storage_account].blob.core.windows.net/backups/DM_Akademik_DW_Azure.bak'
WITH 
    CREDENTIAL = 'AzureStorageCredential',
    COMPRESSION;
GO