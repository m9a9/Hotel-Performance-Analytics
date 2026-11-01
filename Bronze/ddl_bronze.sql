use hotelwarehouse;
/*
 ===============================================================================
 DDL Script: Create Bronze Tables
 ===============================================================================
 Script Purpose:
 This script creates tables in the 'bronze' schema, dropping existing tables
 if they already exist.
 Run this script to re-define the DDL structure of 'bronze' Tables
 ===============================================================================
 */
GO
    if object_id('bronze.bookings', 'u') is not null DROP table bronze.bookings;

GO
    create table bronze.bookings (
        booking_number NVARCHAR(50) null,
        booking_status nvarchar (50) null,
        appartment NVARCHAR(200) null,
        customer NVARCHAR (500) null,
        mobile nvarchar(50) null,
        CheckIn nvarchar (20) null,
        CheckOut nvarchar(20) null,
        period NVARCHAR(50) null,
        booking_amount nvarchar(50) null,
        amount nvarchar(50) null,
        taxes nvarchar(50) null,
        total NVARCHAR(50) null,
        paid_amount NVARCHAR(50) null,
        debtor nvarchar(50),
    )
GO
    if object_id('bronze.CustomerReport', 'u') is NOT NULL drop TABLE bronze.CustomerReport;

GO
    create table bronze.CustomerReport (
        Room_Appartment nvarchar(200) null,
        Customer_ID_No NVARCHAR(50) null,
        Customer nvarchar(500) null,
        Booking_No NVARCHAR(50) null,
        Check_in_Date NVARCHAR(20) null,
        Checkout_Date NVARCHAR(20) null,
        Actual_Checkin_Date NVARCHAR(20) null,
        Actual_Checkin_Time NVARCHAR(20) null,
        Actual_Checkout_Date NVARCHAR(20) null,
        Actual_Checkout_Time NVARCHAR(20) null,
        Booking_Source_No NVARCHAR(50) null,
        Creation_DateTime nvarchar (50) null,
        Created_By NVARCHAR(500) null,
    )
GO
    if object_id('bronze.InvoiceReports', 'u') is NOT NULL drop TABLE bronze.InvoiceReports;

GO
    create table bronze.InvoiceReports (
        Invoice_Number nvarchar(50) null,
        From_Date NVARCHAR(20) null,
        To_Date NVARCHAR(20) null,
        Amount_Without_Tax NVARCHAR(50) null,
        Taxes nvarchar(50) null,
        Total nvarchar(50) null,
        Booking_No NVARCHAR(50) null,
        Room_No nvarchar (50) null,
        Customer nvarchar(500) null,
        Creation_Date nvarchar(20) null,
    )
GO
    if object_id('bronze.occupancy', 'u') is not null drop TABLE bronze.Occupancy;

GO
    create TABLE bronze.Occupancy(
        Row_No NVARCHAR(10) null,
        Room_Type nvarchar(100) null,
        Rooms_Count NVARCHAR(10) null,
        Rental_Days NVARCHAR(10) null,
        Vacant_Days NVARCHAR(20) null,
        Occupancy_Rate nvarchar(20) null,
        Average_Rental_Price NVARCHAR(20) null,
    )
GO
    if OBJECT_id('bronze.employees', 'u') is NOT NULL drop table bronze.Employees;

GO
    create Table bronze.Employees(
        Bronze_Employee_SK BIGINT IDENTITY(1, 1) NOT NULL,
        Employee_Id NVARCHAR(50) null,
        Employee_Name nvarchar(500) null,
    )
GO
    if object_id ('bronze.rooms', 'u') is NOT NULL drop table bronze.Rooms;

GO
    create TABLE bronze.Rooms(
        Bronze_Rooms_SK BIGINT IDENTITY(1, 1) NOT NULL,
        Room_Numebr NVARCHAR(20) null,
        Room_Type NVARCHAR(100) null
    )