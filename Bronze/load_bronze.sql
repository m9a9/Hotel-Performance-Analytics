use HotelWarehouse;
/*
 ===============================================================================
 Stored Procedure: Load Bronze Layer (Source -> Bronze)
 ===============================================================================
 Script Purpose:
 This stored procedure loads data into the 'bronze' schema from external CSV files.
 It performs the following actions:
 - Truncates the bronze tables before loading data.
 - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.
 
 Parameters:
@ TableName
 This stored procedure does not accept any parameters or return any values.
 

 ===============================================================================
 */
GO
CREATE
OR ALTER PROCEDURE bronze.LoadCSV @FilePath NVARCHAR(1000),
@TableName SYSNAME AS BEGIN
SET
    NOCOUNT ON;

DECLARE @SQL NVARCHAR(MAX);

SET
    @SQL = CONCAT(
        'BULK INSERT bronze.',
        QUOTENAME(@TableName),
        ' FROM ',
        QUOTENAME(@FilePath, ''''),
        ' WITH (
            FORMAT = ''CSV'',
            FIRSTROW = 2,
            FIELDQUOTE = ''"'',
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            CODEPAGE = ''65001'',
            TABLOCK
        );'
    );

PRINT @SQL;

EXEC sp_executesql @SQL;

END;

GO  
--!>> Loading Bookings >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--? loading 2022 Bookings
exec bronze.LoadCSV
@TableName='bookings',
@FilePath='FILE PATH';
GO
--? loading 2023 Bookings
exec bronze.LoadCSV @TableName = 'bookings',
@FilePath = "FILE PATH"

--? loading 2024 Bookings
exec bronze.LoadCSV @TableName = 'bookings',
@FilePath = "FILE PATH"
--? loading 2025 Bookings
exec bronze.LoadCSV @TableName = 'bookings',
@FilePath = "FILE PATH"
--? loading 2026 Bookings
exec bronze.LoadCSV @TableName = 'bookings',
@FilePath = "FILE PATH"

--!>> Loading Customer Report >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--? loading 2022 customer report
exec bronze.LoadCSV @TableName = 'CustomerReport',
@FilePath = "FILE PATH";

--? loading 2023 customer report
exec bronze.LoadCSV @TableName = 'CustomerReport',
@FilePath = "FILE PATH";
--? loading 2024 customer report
exec bronze.LoadCSV @TableName = 'CustomerReport',
@FilePath = "FILE PATH";
--? loading 2025 customer report
exec bronze.LoadCSV @TableName = 'CustomerReport',
@FilePath = "FILE PATH";
--? loading 2026 customer report
exec bronze.LoadCSV @TableName = 'CustomerReport',
@FilePath = "FILE PATH";

--! >>> Loading Invoice Reports >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--? loading 2022 InvoiceReports
exec bronze.LoadCSV @TableName = 'InvoiceReports',
@FilePath = "FILE PATH";
--? loading 2023 InvoiceReports
exec bronze.LoadCSV @TableName = 'InvoiceReports',
@FilePath = "FILE PATH";
--? loading 2024 InvoiceReports
exec bronze.LoadCSV @TableName = 'InvoiceReports',
@FilePath = "FILE PATH";
--? loading 2025 InvoiceReports
exec bronze.LoadCSV @TableName = 'InvoiceReports',
@FilePath = "FILE PATH";
--? loading 2026 InvoiceReports
exec bronze.LoadCSV @TableName = 'InvoiceReports',
@FilePath = "FILE PATH";

--! >>> loading occupany data >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--? loading 2022 ocupancy
exec bronze.LoadCSV @TableName = 'Occupancy',
@FilePath = "FILE PATH";

--? loading 2023 ocupancy
exec bronze.LoadCSV @TableName = 'Occupancy',
@FilePath = "FILE PATH";
--? loading 2024 ocupancy
exec bronze.LoadCSV @TableName = 'Occupancy',
@FilePath = "FILE PATH";
--? loading 2025 ocupancy
exec bronze.LoadCSV @TableName = 'Occupancy',
@FilePath = "FILE PATH";
--? loading 2026 ocupancy
exec bronze.LoadCSV @TableName = 'Occupancy',
@FilePath = "FILE PATH";

--! inserting manual data for employees and rooms

insert into bronze.Rooms(Room_Numebr,Room_Type)
VALUES(101,'Single Room'),
(102,'One Bedroom Suite'),
(103, 'One Bedroom Suite'),
(104, 'Triple Room'),
(105, 'Single Room'),
(106, 'single Room'),
(107, 'One Bedroom Suite'),
(108, 'Two Bedrooms Suite'),
(201, 'Single Room'),
(202, 'One Bedroom Suite'),
(203, 'One Bedroom Suite'),
(204, 'Triple Room'),
(205, 'Single Room'),
(206, 'Single Room'),
(207, 'One Bedroom Suite'),
(208, 'Two Bedrooms Suite'),
(301, 'Vip Suite'),
(302, 'Single Room'),
(303, 'Vip Suite');

--! Employees
insert into bronze.employees(Employee_Id,Employee_Name)
VALUES(1,'EMPLOYEE NAME'),
(2,'EMPLOYEE NAME'),
(3,'EMPLOYEE NAME')






