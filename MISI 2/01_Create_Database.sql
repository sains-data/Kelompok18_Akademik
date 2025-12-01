-- 1. Create Database dwmisi2
CREATE DATABASE dwmisi2
ON PRIMARY
(
    NAME = N'dwmisi2_Data',
    FILENAME = N'E:\SQLData\dwmisi2_Data.mdf', 
    SIZE = 1GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 256MB
)
LOG ON
(
    NAME = N'dwmisi2_Log',
    FILENAME = N'E:\SQLLog\dwmisi2_log.ldf', 
    SIZE = 256MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 64MB
);
GO

-- 2. Use the new database
USE dwmisi2;
GO



