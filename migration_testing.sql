use hotelwarehouse;
/*
 ===============================================================================
 Script Purpose:
 This Script is used to merge the data of august 2026 and september 2026 from bronze layer to silver layer.
 Run this script to merge the data of august 2026 and september 2026 from bronze layer to silver layer.
 Used this to compare the quarters from 2025 to 2026.
 ===============================================================================
 */
EXEC sys.sp_helptext N'silver.LoadSilver';
SELECT
    OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
    OBJECT_NAME(object_id) AS ProcedureName,
    definition AS ProcedureDefinition
FROM
    sys.sql_modules
WHERE
    object_id = OBJECT_ID(N'silver.LoadSilver');

--! Add data for August and september 2026 to Bronze.bookings table
INSERT INTO
    Bronze.bookings (
        booking_number,
        booking_status,
        appartment,
        customer,
        mobile,
        CheckIn,
        CheckOut,
        period,
        booking_amount,
        amount,
        taxes,
        total,
        paid_amount,
        debtor
    )
SELECT
    CAST(d.Booking_No AS NVARCHAR(50)),
    d.Booking_status,
    d.Apartment,
    d.Customer,
    CAST(d.Mobile AS NVARCHAR(50)),
    CONVERT(NVARCHAR(50), d.Check_In, 23),
    CONVERT(NVARCHAR(50), d.Check_Out, 23),
    CAST(d.Period AS NVARCHAR(50)),
    CAST(d.Booking_Amount AS NVARCHAR(50)),
    CAST(d.Amount AS NVARCHAR(50)),
    NULL,
    NULL,
    NULL,
    NULL
FROM
    dbo.Bookings AS d
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            Bronze.bookings AS b
        WHERE
            b.booking_number = CAST(d.Booking_No AS NVARCHAR(50))
            AND b.appartment = d.Apartment
            AND b.CheckIn = CONVERT(NVARCHAR(50), d.Check_In, 23)
            AND b.CheckOut = CONVERT(NVARCHAR(50), d.Check_Out, 23)
    );

select
    count(*) as all_bookings
from
    bronze.bookings;

--! Add data for August and september 2026 to Bronze.CustomerReport table
select
    top 1 *
from
    dbo.CustomerReport
INSERT INTO
    Bronze.CustomerReport (
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
    d.Room_Apartment,
    d.Customer_ID_No,
    d.Customer,
    d.Booking_No,
    CONVERT(NVARCHAR(30), d.Check_in_Date, 23),
    CONVERT(NVARCHAR(30), d.Checkout_Date, 23),
    CONVERT(NVARCHAR(30), d.Actual_Checkin_Date, 23),
    CONVERT(NVARCHAR(30), d.Actual_Checkin_Time, 108),
    CONVERT(NVARCHAR(30), d.Actual_Checkout_Date, 23),
    CONVERT(NVARCHAR(30), d.Actual_Checkout_Time, 108),
    d.Booking_Source,
    CONVERT(NVARCHAR(30), d.Creation_date_time, 120),
    d.Created_By
FROM
    dbo.CustomerReport AS d
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            Bronze.CustomerReport AS b
        WHERE
            b.Booking_No = CONVERT(NVARCHAR(50), d.Booking_No)
            AND b.Room_Appartment = d.Room_Apartment
            AND b.Check_in_Date = CONVERT(NVARCHAR(30), d.Check_in_Date, 23)
            AND b.Checkout_Date = CONVERT(NVARCHAR(30), d.Checkout_Date, 23)
    );

--! Add data for August and september 2026 to Bronze.invoiceReport table
INSERT INTO
    Bronze.InvoiceReports (
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
SELECT
    CONVERT(NVARCHAR(50), d.Invoice_No),
    CONVERT(NVARCHAR(30), d.From_Date, 23),
    CONVERT(NVARCHAR(30), d.To_Date, 23),
    CONVERT(NVARCHAR(50), d.Amount_Without_Tax),
    CONVERT(NVARCHAR(50), d.Taxes),
    CONVERT(NVARCHAR(50), d.Total),
    CONVERT(NVARCHAR(50), d.Booking_No),
    d.Room_No,
    d.Customer,
    CONVERT(NVARCHAR(30), d.Creation_Date, 120)
FROM
    dbo.InvoiceReport AS d
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            Bronze.InvoiceReports AS b
        WHERE
            b.Invoice_Number = CONVERT(NVARCHAR(50), d.Invoice_No)
            AND b.From_Date = CONVERT(NVARCHAR(30), d.From_Date, 23)
            AND b.To_Date = CONVERT(NVARCHAR(30), d.To_Date, 23)
            AND b.Room_No = d.Room_No
    );

--! Add data for August and september 2026 to Bronze.occupancy table
SELECT
    COUNT(*) AS Total_Rows
FROM
    bronze.Occupancy;

select * from bronze.Occupancy

delete from bronze.Occupancy WHERE Row_No is NULL

--? >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--? Editing silver layer to add data 
--? >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
USE HotelWarehouse;

GO
SELECT
    s.name AS SchemaName,
    o.name AS ObjectName,
    o.type_desc AS ObjectType,
    m.definition AS SQLDefinition
FROM
    sys.sql_modules m
    JOIN sys.objects o ON m.object_id = o.object_id
    JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE
    m.definition LIKE '%Occupancy_year%';


--!----------------------------------------------------------------

SELECT
    CASE
        WHEN From_Date < '2026-08-01' THEN 'Before August 2026'
        WHEN From_Date >= '2026-08-01'
        AND From_Date < '2026-09-01' THEN 'August 2026'
        WHEN From_Date >= '2026-09-01'
        AND From_Date < '2026-10-01' THEN 'September 2026'
    END AS Revenue_Period,
    COUNT(*) AS Invoice_Count,
    SUM(Total) AS Total_Revenue,
    SUM(Amount_Without_Tax) AS Revenue_Without_Tax,
    SUM(Taxes) AS Total_Tax
FROM
    silver.invoicereports
WHERE
    From_Date < '2026-10-01'
GROUP BY
    CASE
        WHEN From_Date < '2026-08-01' THEN 'Before August 2026'
        WHEN From_Date >= '2026-08-01'
        AND From_Date < '2026-09-01' THEN 'August 2026'
        WHEN From_Date >= '2026-09-01'
        AND From_Date < '2026-10-01' THEN 'September 2026'
    END
ORDER BY
    MIN(From_Date);



