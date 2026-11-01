use Hotelwarehouse;

/*
 ===============================================================================
 DDL Script: Create Gold Views
 ===============================================================================
 Script Purpose:
 This script creates views for the Gold layer in the data warehouse.
 The Gold layer represents the final dimension and fact tables (Star Schema)
 
 Each view performs transformations and combines data from the Silver layer
 to produce a clean, enriched, and business-ready dataset.
 
 Usage:
 - These views can be queried directly for analytics and reporting.
 ===============================================================================
 */
--TODO :: Create dim rooms
if OBJECT_ID('gold.dim_rooms') is not null drop view gold.dim_rooms
GO
    create VIEW gold.dim_rooms as
SELECT
    ROW_NUMBER() over(
        ORDER BY
            room_number
    ) as room_key,
    Room_Number,
    Room_Type
from
    silver.rooms;

GO
    --TODO :: Create dim customers
    if object_id('gold.dim_customers', 'u') is NOT NULL drop view gold.dim_customers
GO
    create view gold.dim_customers as
select
    ROW_NUMBER() over(
        ORDER BY
            customer
    ) as customer_key,
    Customer
from
    (
        select
            Distinct customer
        from
            silver.CustomerReport
        where
            Customer is not null
    ) as customers;

GO
    --TODO :: Create dim Booking Status
    if object_id('gold.dim_bookingStatus', 'u') is not null drop view gold.dim_bookingStatus
GO
    create view gold.dim_bookingStatus as
SELECT
    ROW_NUMBER() OVER(
        order by
            booking_status
    ) as Status_key,
    booking_status
from
    (
        select
            Distinct booking_status
        FROM
            silver.bookings
        where
            booking_status is not null
    ) as booking_status
GO
    --TODO :: Create dim Booking Source
    if OBJECT_ID('gold.dim_BookingSource', 'u') is not null drop view gold.dim_BookingSource
GO
    create view gold.dim_BookingSource as
select
    ROW_NUMBER() over(
        ORDER BY
            Booking_Source_No
    ) as Booking_Source_Key,
    Booking_Source_No
from
    (
        select
            Distinct Booking_Source_No
        from
            silver.CustomerReport
        where
            Booking_Source_No is not null
    ) as Booking_Source
GO
    -- TODO::creating fact booking table
    -- grain of fact bookings ==> each row represents one booking
    if OBJECT_ID('gold.fact_bookings', 'u') is not null drop view gold.fact_bookings
GO
    create view gold.fact_bookings as
select
    CONCAT(
        booking_nubmer,
        appartment,
        REPLACE(check_in, '-', 0)
    ) as booking_key,
    booking_nubmer,
    booking_status,
    appartment as Room_Number,
    customer as Customer_Name,
    mobile,
    check_in as Checkin_Date,
    check_out as CheckOut_Date,
    period as staying_period,
    booking_amount as Daily_Rate,
    amount as Booking_Amount,
    taxes,
    total as Total_Amount,
    paid_amount
from
    silver.bookings;

GO
    -- TODO::creating fact stay table 
    -- stay grain : one row represents one complete booking
    if OBJECT_ID('gold.fact_stay', 'u') is not null drop view gold.fact_stay
GO
    create view gold.fact_stay as
select
    CONCAT(
        Booking_No,
        Room_Appartment,
        REPLACE(Check_in_Date, '-', 0)
    ) as stay_key,
    Room_Appartment as Room_Number,
    Customer_ID_No as Customer_Id,
    Customer AS Customer_Name,
    Booking_No as Booking_number,
    Check_in_Date,
    Checkout_Date,
    Actual_Checkin_Date,
    Actual_Checkin_Time,
    Actual_Checkout_Date,
    Actual_Checkout_Time,
    Booking_Source_No as Booking_Source,
    cast(Creation_DateTime as date) as Creation_Date,
    cast(Creation_DateTime as time) as creation_time,
    Created_By as Recieptionest
from
    silver.CustomerReport
GO
    -- TODO::creating fact invoice table 
    if OBJECT_ID('gold.fact_Invoices', 'u') is not null drop view gold.fact_Invoices
GO
    create view gold.fact_Invoices as
SELECT
    Invoice_Number,
    From_Date as CheckIn_Date,
    To_Date as CheckOut_Date,
    Amount_Without_Tax,
    Taxes,
    Total as Total_Amount,
    Booking_No as Booking_Number,
    Room_No as Room_Number,
    Customer as Customer_Name,
    CASE
        WHEN creation_date is null THEN cast(To_Date as date)
        ELSE creation_date
    END AS creation_date
FROM
    silver.InvoiceReports;

GO
    -- TODO::creating fact occupancy table 
    if object_id('gold.fact_occupancy', 'u') is not null drop view gold.fact_occupancy
GO
    create view gold.fact_occupancy as
SELECT
    case
        when Room_Type = 'VIP' THEN 'Vip Suite'
        when Room_Type = 'Single Room' THEN 'Single Room'
        when Room_Type = 'Triple Room' THEN 'Triple Room'
        when Room_Type = 'Room with Hall' THEN 'One Bedroom Suite'
        when Room_Type = 'Two Rooms with Hall' THEN 'Two Bedroom Suite'
        else 'N/A'
    END AS Room_Type,
    Rooms_count,
    Rental_Days,
    Vacant_Days,
    Occupancy_Rate,
    Average_Rental_Price
FROM
    silver.Occupancy
Go
    -- TODO::creating fact Employees(receptionest) table 
    if OBJECT_ID('gold.dim_Employee', 'u') is not null drop view gold.dim_Employee
GO
    create view gold.dim_Employee as
select
    *
from
    silver.Employees;