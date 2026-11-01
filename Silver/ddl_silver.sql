use HotelWarehouse;
/*
 ===============================================================================
 DDL Script: Create Silver Tables
 ===============================================================================
 Script Purpose:
 This script creates tables in the 'silver' schema, dropping existing tables
 if they already exist.
 Run this script to re-define the DDL structure of 'silver' Tables
 ===============================================================================
 */
GO
    --? Create Silver Bookings
    if object_id('silver.bookings', 'u') is not null DROP table silver.bookings
GO
    create table silver.bookings(
        booking_nubmer int,
        booking_status nvarchar(50),
        appartment nvarchar(200),
        customer nvarchar(500),
        mobile nvarchar(100),
        check_in date,
        check_out date,
        period int,
        booking_amount decimal(10, 2),
        amount decimal(10, 2),
        taxes decimal(10, 2),
        total decimal(10, 2),
        paid_amount decimal(10, 2),
        debtor decimal(10, 2),
    )
GO
    --? Create Silver Customer Report
    if OBJECT_ID('silver.CustomerReport', 'u') is not null drop table silver.CustomerReport
GO
    create table silver.CustomerReport(
        Room_Appartment NVARCHAR(100),
        Customer_ID_No nvarchar(50),
        Customer nvarchar(500),
        Booking_No bigint,
        Check_in_Date date,
        Checkout_Date date,
        Actual_Checkin_Date date,
        Actual_Checkin_Time TIME,
        Actual_Checkout_Date date,
        Actual_Checkout_Time TIME,
        Booking_Source_No NVARCHAR(50),
        Creation_DateTime DATETIME,
        Created_By NVARCHAR(500)
    )
GO
    --? Create silver Invoice reports
    if OBJECT_ID('silver.InvoiceReports', 'u') is not null drop table silver.InvoiceReports
GO
    create TABLE silver.InvoiceReports(
        Invoice_Number bigint,
        From_Date date,
        To_Date date,
        Amount_Without_Tax decimal(10, 2),
        Taxes decimal(10, 2),
        Total decimal(10, 2),
        Booking_No bigint,
        Room_No int,
        Customer nvarchar(500),
        Creation_Date DATE
    );
    GO
     --? creating silver oocupancy
    if OBJECT_ID('silver.Occupancy', 'u') is not null drop table silver.Occupancy;

GO
    create table silver.Occupancy(
        Row_No int,
        Room_Type NVARCHAR(200),
        Rooms_count int,
        Rental_Days bigint,
        Vacant_Days bigint,
        Occupancy_Rate decimal(10, 2),
        Average_Rental_Price DECIMAL(10, 2)
    ); --? creating silver employees
    if OBJECT_ID('silver.Employees', 'u') is not null drop table silver.Employees
GO
    create table silver.Employees(
        Bronze_Employee_SK INT,
        Employee_Id int,
        Employee_Name nvarchar(500)
    ) --? creating silver rooms
    if OBJECT_ID('silver.Rooms', 'u') is not null drop table silver.Rooms
GO
    create table silveR.Rooms(
        Bronze_Rooms_SK INT,
        Room_Number int,
        Room_Type NVARCHAR(200)
    )