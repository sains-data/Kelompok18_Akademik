CREATE DATABASE DM_Akademik_DW
ON PRIMARY
(
    NAME = N'DM_Akademik_DW_Data',
    FILENAME = N'E:\Data\DM_Akademik_DW_Data.mdf',
    SIZE = 1GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 256MB
)
LOG ON
(
    NAME = N'DM_Akademik_DW_Log',
    FILENAME = N'E:\Logs\DM_Akademik_DW_Log.ldf',
    SIZE = 256MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 64MB
);
GO

USE DM_Akademik_DW;
GO
