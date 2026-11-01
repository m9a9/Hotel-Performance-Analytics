use HotelWarehouse;
--?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

/*
 ===============================================================================
 Stored Procedure: Load Silver Layer (Bronze -> Silver)
 ===============================================================================
 Script Purpose:
 This stored procedure performs the ETL (Extract, Transform, Load) process to
 populate the 'silver' schema tables from the 'bronze' schema.
 Actions Performed:
 - Truncates Silver tables.
 - Inserts transformed and cleansed data from Bronze into Silver tables.
 
 Parameters:
 None.
 This stored procedure does not accept any parameters or return any values.
 
 Usage Example:
 EXEC Silver.load_silver;
 ===============================================================================
 */

--?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
GO
    create
    or alter procedure silver.LoadSilver AS BEGIN --!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    --* inserting data into Silver Bookings'
    --!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    truncate table silver.bookings
insert into
    silver.bookings(
        booking_nubmer,
        booking_status,
        appartment,
        customer,
        mobile,
        check_in,
        check_out,
        period,
        booking_amount,
        amount,
        taxes,
        total,
        paid_amount,
        debtor
    )
select
    booking_number,
    booking_status,
    trim(SUBSTRING(appartment, 2, 4)) as Room_Number,
    customer,
    case
        when mobile is null
        or trim(mobile) = '' then null
        when mobile like '%E+%'
        OR mobile like '%e+%' THEN CONVERT(
            NVarCHAR(20),
            CONVERT(bigint, CONVERT(FLOAT, MOBILE))
        )
        else TRIM(mobile)
    end as Mobile_Number,
COALESCE(
    TRY_CONVERT(date, CheckIn, 103),
    TRY_CONVERT(date, CheckIn, 23)
) AS CheckIn_Date,
COALESCE(
    TRY_CONVERT(date, CheckOut, 103),
    TRY_CONVERT(date, CheckOut, 23)
) AS CheckOut_Date,
    TRY_CONVERT(int, nullif(PERIOD, '')),
    TRY_CONVERT(DECIMAL(18, 2), NULLIF(booking_amount, '')),
    TRY_CONVERT(DECIMAL(18, 2), NULLIF(amount, '')),
    TRY_CONVERT(DECIMAL(18, 2), NULLIF(taxes, '')),
    TRY_CONVERT(DECIMAL(18, 2), NULLIF(total, '')),
    TRY_CONVERT(DECIMAL(18, 2), NULLIF(paid_amount, '')),
    TRY_CONVERT(DECIMAL(18, 2), NULLIF(debtor, ''))
from
    bronze.bookings;

PRINT '>> -------------';

--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--* inserting data into Silver customer report
--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

truncate table silver.CustomerReport
insert into
    silver.CustomerReport(
        Room_Appartment,
        Customer_ID_No,
        Customer,
        Booking_No,
        Check_in_Date,
        Checkout_Date,
        Actual_Checkin_Date,
        Actual_Checkin_Time,
        Actual_Checkout_Date,
        Actual_Checkout_Time,
        Booking_Source_No,
        Creation_DateTime,
        Created_By
    )
SELECT
    TRY_CONVERT(
        INT,
        SUBSTRING(
            Room_Appartment,
            PATINDEX('%[0-9]%', Room_Appartment),
            PATINDEX(
                '%[^0-9]%',
                SUBSTRING(
                    Room_Appartment,
                    PATINDEX('%[0-9]%', Room_Appartment),
                    LEN(Room_Appartment)
                ) + 'X'
            ) - 1
        )
    ) as Room_Number,
    TRY_CONVERT(bigint, nullif(Customer_ID_No, '')) as Customer_ID,
    trim(Customer) as customer_name,
    TRY_CONVERT(int, nullif(Booking_No, '')) as Booking_Number,
COALESCE(
    TRY_CONVERT(date, Check_in_Date, 103),
    TRY_CONVERT(date, Check_in_Date, 23)
) AS CheckIn_Date,
COALESCE(
    TRY_CONVERT(date, Checkout_Date, 103),
    TRY_CONVERT(date, Checkout_Date, 23)
) AS CheckOut_Date,
COALESCE(
    TRY_CONVERT(date, Actual_Checkin_Date, 103),
    TRY_CONVERT(date, Actual_Checkin_Date, 23)
) AS Actual_Checkin_Date,
   -- TRY_CONVERT(date, Actual_Checkin_Date, 103) as Actual_Checkin_Date,
    TRY_CONVERT(time, Actual_Checkin_Time, 103) as Actual_Checkin_Time,
    COALESCE(
    TRY_CONVERT(date, Actual_Checkout_Date, 103),
    TRY_CONVERT(date, Actual_Checkout_Date, 23)
) AS Actual_Checkout_Date,
   -- TRY_CONVERT(date, Actual_Checkout_Date, 103) as Actual_Checkout_Date,
    TRY_CONVERT(time, Actual_Checkout_Time, 103) as Actual_Checkout_Time,
    trim(nullif(Booking_Source_No, '')) as Booking_Source,
    try_convert(DATETIME, Creation_DateTime, 103) as Creation_DateTime,
    trim(Created_By) as Created_by
from
    bronze.CustomerReport;

--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--* inserting data into Silver Invoices Reports
-- this function extracts the number only from the mixed text and number from room_number
--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
GO
    CREATE FUNCTION dbo.ExtractFirstNumber_itvf (@input NVARCHAR(200)) RETURNS TABLE AS RETURN (
        SELECT
            CASE
                WHEN PATINDEX('%[0-9]%', @input) = 0 THEN NULL
                ELSE TRY_CONVERT(
                    INT,
                    SUBSTRING(
                        @input,
                        PATINDEX('%[0-9]%', @input),
                        PATINDEX('%[0-9][^0-9]%', @input + 'X') - PATINDEX('%[0-9]%', @input) + 1
                    )
                )
            END AS Room_No_Clean
    )
GO

    truncate table silver.InvoiceReports
insert into
    silver.InvoiceReports(
        Invoice_Number,
        From_Date,
        To_Date,
        Amount_Without_Tax,
        Taxes,
        Total,
        Booking_No,
        Room_No,
        Customer,
        Creation_Date
    )
select
    TRY_CONVERT(int, nullif(Invoice_Number, '')) as Invoice_Number,
    COALESCE(
    TRY_CONVERT(date, From_Date, 103),
    TRY_CONVERT(date, From_Date, 23)
) AS From_Date,
    --try_convert(date, From_Date, 103) as From_Date,
   -- try_convert(date, To_Date, 103) as To_Date,
    COALESCE(
    TRY_CONVERT(date, To_Date, 103),
    TRY_CONVERT(date, To_Date, 23)
) AS To_Date,
    try_convert(DECIMAL(18, 2), nullif(Amount_Without_Tax, '')) as Amount_Without_Tax,
    try_convert(DECIMAL(18, 2), nullif(Taxes, '')) as Taxes,
    try_convert(DECIMAL(18, 2), nullif(Total, '')) as Total,
    try_convert(int, nullif(Booking_No, '')) as Booking_Number,
    coalesce(rn.Room_No_Clean, 205) as Room_Number,
    trim(nullif(Customer, '')) as Customer,
    try_convert(Date, left(Creation_Date, 10), 103) as Creation_Date
from
    bronze.InvoiceReports b
    cross apply dbo.ExtractFirstNumber_itvf(b.Room_No) rn;

--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--* inserting data into Silver occupancy
--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

truncate table silver.Occupancy
insert into
    silver.Occupancy(
        Row_No,
        Room_Type,
        Rooms_Count,
        Rental_Days,
        Vacant_Days,
        Occupancy_Rate,
        Average_Rental_Price
    )
select
    try_convert(int, nullif(Row_No, '')) as Row_No,
    trim(nullif(Room_Type, '')) as Room_Type,
    try_convert(int, nullif(Rooms_Count, '')) as Rooms_Count,
    try_convert(
        int,
        nullif(replace(trim(rental_days), ',', ''), '')
    ) as Rental_Days,
    try_convert(
        int,
        nullif(replace(trim(Vacant_Days), ',', ''), '')
    ) as Vacant_Days,
    try_convert(Decimal(5, 2), nullif(Occupancy_Rate, '')) as Occupancy_Rate,
    TRY_CONVERT(
        DECIMAL(18, 2),
        TRIM(
            REPLACE(
                REPLACE(Average_Rental_Price, CHAR(13), ''),
                CHAR(10),
                ''
            )
        )
    ) as Average_Rental_Price
from
    bronze.Occupancy;

--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--* inserting data into Silver Rooms
--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
truncate table silver.rooms
insert into
    silver.Rooms(Room_Number, Room_Type)
select
    try_convert(int, nullif(Room_Numebr, '')) as Room_Number,
    trim(nullif(Room_Type, '')) as Room_Type
from
    bronze.Rooms;

--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--* inserting data into Silver Employees
--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
truncate table silver.Employees
insert into
    silver.Employees(Employee_Id, Employee_Name)
select
    try_convert(int, nullif(Employee_Id, '')) as Employee_Id,
    trim(nullif(Employee_Name, '')) as Employee_Name
from
    bronze.Employees;

END

