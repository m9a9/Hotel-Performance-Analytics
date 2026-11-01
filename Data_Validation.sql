use hotelwarehouse;
/*
 ===============================================================================

 Script Purpose:
 This script is used to validate the data in the silver layer after merging the data from bronze layer.
 used this scripts to protect the numbers from duplication and to check the validaty of the data in the silver layer.
 ===============================================================================
 */
--* test 1 : check if there are any duplicate booking numbers in the bookings table and it allowed because the data is coming from different years from 2022-2026 
select
    booking_nubmer,
    count(*) as COUNT
from
    silver.bookings
group by
    booking_nubmer
having
    count(*) > 1
ORDER BY
    booking_nubmer;

--?------------------------------------------------------------------------
select
    booking_nubmer,
    customer,
    appartment,
    check_in,
    check_out,
    booking_status,
    COUNT(*) as row_count
from
    silver.bookings
GROUP BY
    booking_nubmer,
    customer,
    appartment,
    check_in,
    check_out,
    booking_status
HAVING
    count(*) > 1
ORDER by
    booking_nubmer;

--?-------------------------------------------------
SELECT
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
    debtor,
    COUNT(*) AS Duplicate_Count
FROM
    Silver.Bookings
GROUP BY
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
HAVING
    COUNT(*) > 1
ORDER BY
    booking_nubmer;

--* test 2 : check the validaty of dates check out date after check in date 
select
    *
from
    silver.bookings
where
    check_out < check_in;

--* test 3: check the validaty of the total amount in the bookings table by comparing it with the sum of amount and taxes
select
    *
from
    silver.bookings
where
    abs((amount + taxes) - total) > 0.01;

--! test 4 :so there is a reservations paid greater than the total so the hotel لbiils of exchange to customer
select
    *
from
    silver.bookings
where
    paid_amount > total;

--* test 5 : check if the room number in the customer report table exists in the rooms table
select
    Distinct Room_Appartment
from
    silver.customerreport sc
    left join silver.Rooms sr on sc.Room_Appartment = sr.Room_Number
where
    sr.Room_Number is null;

--* test 6 : check the revenue comes from bookings tables and invoices tables
select
    SUM(sb.paid_amount) - SUM(sb.paid_amount - sb.total) as revenue_bookings,
    SUM(SI.Total) AS revenue_invoices
from
    silver.bookings sb
    LEFT JOIN silver.InvoiceReports SI ON SB.booking_nubmer = SI.Booking_No
where
    booking_status = 'checked out';

--* test 7 : Bookings Data Profiling
select
    count(*) as total_bookings
from
    silver.bookings
where
    year(check_in) = 2022;

--* test 8 : unique booking numbers in bookings [5797]
select
    count(distinct booking_nubmer) as unique_numbers
from
    silver.bookings;

--* check duplication in booking_numbers
select
    year(check_in) as booking_year,
    booking_nubmer,
    count(*) as bookings_count
from
    silver.bookings
group by
    booking_nubmer,
    year(check_in)
having
    count(*) > 1
order by
    booking_nubmer,
    booking_year;

--? another way deatailed to check duplications and check if a booking is duplicated or not
with DupplicateBookings as (
    select
        year(check_in) as booking_year,
        booking_nubmer
    from
        silver.bookings
    GROUP BY
        year(check_in),
        booking_nubmer
    HAVING
        COUNT(*) > 1
)
select
    b.*
from
    silver.bookings b
    inner join DupplicateBookings d on YEAR(b.check_in) = d.booking_year
    and b.booking_nubmer = d.booking_nubmer
where
    YEAR(check_in) = 2024
ORDER BY
    YEAR(b.check_in),
    b.booking_nubmer;

--? >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--* check invoices report to make sure that invoice id didn't repeat for the same booking
--? >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
select
    Invoice_Number,
    From_Date,
    count(*) as invoices_count
from
    silver.invoiceReports
GROUP BY
    Invoice_Number,
    From_Date
HAVING
    COUNT(*) > 1;

--! check duplication in invoicereports
SELECT
    *
FROM
    Silver.InvoiceReports
WHERE
    Invoice_Number = 8942;

--! check duplication in invoicereports
SELECT
    Invoice_Number,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT Booking_No) AS Booking_Count
FROM
    Silver.InvoiceReports
GROUP BY
    Invoice_Number
HAVING
    COUNT(*) > 1
ORDER BY
    Row_Count DESC;

--! check duplication in invoicereports
SELECT
    Invoice_Number,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT Booking_No) AS Booking_Count,
    COUNT(DISTINCT Customer) AS Customer_Count,
    COUNT(DISTINCT Total) AS Total_Count
FROM
    Silver.InvoiceReports
GROUP BY
    Invoice_Number
HAVING
    COUNT(*) > 1
ORDER BY
    Invoice_Number;

--! check if the same invoice was duplicated to the same user
SELECT
    Booking_No,
    From_Date,
    COUNT(DISTINCT Customer) AS Customer_Count
FROM
    Silver.InvoiceReports
GROUP BY
    Booking_No,
    From_Date
HAVING
    COUNT(DISTINCT Customer) > 1;

--! check all the duplicate fields
SELECT
    *
FROM
    Silver.InvoiceReports
WHERE
    Invoice_Number IN (
        1380,
        8932,
        8933,
        8935,
        8938,
        8942,
        8962,
        8963,
        8964
    )
ORDER BY
    Invoice_Number,
    Booking_No;

--*
SELECT
    Invoice_Number,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT Booking_No) AS Booking_Count,
    COUNT(DISTINCT Room_No) AS Room_Count
FROM
    Silver.InvoiceReports
GROUP BY
    Invoice_Number
HAVING
    COUNT(*) > 1
ORDER BY
    Invoice_Number;

--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--* making sure that we found 8 invoices duplicated
--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT
    Invoice_Number,
    Booking_No,
    Room_No,
    Customer,
    From_Date,
    To_Date,
    Amount_Without_Tax,
    Taxes,
    Total,
    Creation_Date,
    COUNT(*) AS Duplicate_Count
FROM
    Silver.InvoiceReports
GROUP BY
    Invoice_Number,
    Booking_No,
    Room_No,
    Customer,
    From_Date,
    To_Date,
    Amount_Without_Tax,
    Taxes,
    Total,
    Creation_Date
HAVING
    COUNT(*) > 1;

--! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--* make cte to delete duplicate invoices
--!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
with duplicated_invoices as(
    select
        *,
        ROW_NUMBER() OVER(
            Partition by Invoice_number,
            Booking_No,
            Room_No,
            Customer,
            From_Date,
            To_Date,
            Amount_Without_Tax,
            Taxes,
            Total,
            Creation_Date
            ORDER BY
                Invoice_Number
        ) as row_number
    from
        silver.InvoiceReports
)
delete from
    duplicated_invoices
where
    [row_number] > 1;

--? >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--? Check Silver.bookings validaty 
--? >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--![1] 
select
    booking_nubmer,
    --* number booking isn't unique beacuse it repeat for diffrents reservation in diffrent year
    count(*) as cnt_rows
from
    silver.bookings
GROUP BY
    booking_nubmer
HAVING
    COUNT(*) > 1
ORDER BY
    booking_nubmer;

--! [2] we found the exact rows duplicated
SELECT
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
    debtor,
    COUNT(*) AS Duplicate_Count
FROM
    Silver.Bookings
GROUP BY
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
HAVING
    COUNT(*) > 1
ORDER BY
    booking_nubmer;

--* --------------------------------------------------------------------------------------------------
--* Remove Duplicates rows
WITH Duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY booking_nubmer,
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
            ORDER BY
                booking_nubmer
        ) AS rn
    FROM
        Silver.Bookings
)
select
    *
FROM
    Duplicates
WHERE
    rn > 1;

--? >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--? Check Silver.customerReports validaty 
--? >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--!
select
    Booking_No,
    count(*) as cnt_rows
from
    silver.CustomerReport
GROUP BY
    Booking_No
ORDER BY
    Booking_No --! check exact duplicates rows
select
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
    Created_By,
    COUNT(*) as cnt
from
    silver.CustomerReport
GROUP BY
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
HAVING
    COUNT(*) > 1
ORDER BY
    Booking_No
select
    count(*) as COUNT,
    count(Distinct Booking_No) as distinct_bookings
from
    silver.CustomerReport
select
    count(*) as COUNT,
    count(Distinct booking_nubmer) as distinct_bookings
from
    silver.bookings --! check reason for Booking_no Duplication
select
    Booking_No,
    COUNT(*) as row_count,
    COUNT(Distinct Room_Appartment) as room_count,
    COUNT(Distinct Customer) as customer_count,
    COUNT(Distinct Check_in_Date) as checkinDate_count,
    COUNT(Distinct Checkout_Date) as checkoutDate_count
from
    silver.CustomerReport
GROUP BY
    Booking_No
HAVING
    COUNT(*) > 1
ORDER BY
    room_count DESC,
    Booking_No;

--* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--? check the relationship between bookings and customer reports to make an unique id
--* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
select
    *
from
    silver.bookings
where
    booking_nubmer = 2950
    and booking_status = 'checked out'
select
    *
from
    silver.CustomerReport
where
    Booking_No = 2950;

--? making new unque mixed id for bookings table
with generate_bookingID AS(
    select
        booking_nubmer,
        CONCAT(
            booking_nubmer,
            appartment,
            REPLACE(check_in, '-', 0)
        ) as booking_key,
        booking_status,
        appartment,
        customer,
        check_in,
        check_out
    from
        silver.bookings
)
select
    *
from
    generate_bookingID
where
    booking_nubmer = 1650;
--* check if this way correct of return zer0 row it right
SELECT
    booking_nubmer,
    appartment,
    check_in,
    COUNT(*) AS duplicate_count
FROM
    Silver.Bookings
GROUP BY
    booking_nubmer,
    appartment,
    check_in
HAVING
    COUNT(*) > 1;
--* making new unique mixed id for Stay table
with generate_StayID as (
    select
        Booking_No,
        CONCAT(
            Booking_No,
            Room_Appartment,
            REPLACE(Check_in_Date, '-', 0)
        ) as stay_key,
        Room_Appartment,
        Customer,
        Check_in_Date
    from
        silver.CustomerReport
)
select
    *
from
    generate_StayID
where
    Booking_No = 1650
--! =========  Exploring the unique key for customers table is from customer report or bookings ========================
--? test the customer id validation to make dim customer
select 
count(*) as total_rows,
count(Customer_ID_No) as non_null_id,
count(Distinct Customer_ID_No) as Distinct_count,
COUNT(Customer) AS Non_Null_Customer,
COUNT(DISTINCT Customer) AS Distinct_Customer
from silver.CustomerReport;

--? check if the id related into many customers :: result is empty
select 
Customer_ID_No,
COUNT(Distinct Customer_ID_No) as customers_count
 from silver.CustomerReport
 where Customer_ID_No is not null
 GROUP BY Customer_ID_No
 HAVING COUNT(Distinct Customer_ID_No)>1
 ORDER BY customers_count desc;

 --? check if the name related into many id :: result is empty 
select 
Customer,
count(Distinct Customer) as customers_name
from silver.CustomerReport
where Customer is NOT NULL
group by Customer
HAVING count(Distinct Customer)>1
order by customers_name DESC;
--********************************

--? check if the all customers in bookings matches the all customers in customer report
select
    COUNT(*) as total_bookings_rows,
    COUNT(dc.customer_key) as match_customers,
    COUNT(*) - COUNT(dc.customer_key) as unmatched_customers
from
    silver.bookings b
    LEFT join gold.dim_customers dc on b.customer = dc.Customer
 --? explore the unmatching names
select b.customer,
b.booking_status,
COUNT(*) as booking_rows
 from silver.bookings b
 LEFT JOIN gold.dim_customers dc on b.customer=dc.Customer
 where dc.customer_key is NULL
 GROUP BY b.customer,b.booking_status
 ORDER by booking_rows desc;

--? check if the un matched customers all of them are cancelled bookings
SELECT
    b.booking_status,
    COUNT(*) AS Booking_Rows,
    COUNT(dc.customer_key) AS Matched_Customers,
    COUNT(*) - COUNT(dc.customer_key) AS Unmatched_Customers
FROM
    Silver.Bookings b
    LEFT JOIN gold.dim_customers dc ON b.customer = dc.Customer
GROUP BY
    b.booking_status
ORDER BY
    Booking_Rows DESC;

--? check if the 634 unmatched customers not founded in dim cusstomers or there is a porblem
select top 50 b.customer as customername,
COUNT(*) as boookings_rows
from silver.bookings b
left join gold.dim_customers dc on b.customer=dc.Customer
where b.booking_status='checked out' and dc.customer_key is NULL
group by b.customer
ORDER BY boookings_rows DESC;
GO


select sum(paid_amount)  from gold.fact_bookings where booking_status='checked out';
select booking_status,sum(paid_amount) from silver.bookings group by booking_status;

select top 5 * from gold.fact_Invoices
select
    sum(amount_without_tax) as total_amount_without_tax,
    sum(taxes) as total_taxes,
    sum(Total_Amount) as total_amount
from
    gold.fact_invoices


--!-------------------------------------------------------------------------
select count(*) as total_invoices,count(distinct invoice_number) as distinct_invoices
from gold.fact_invoices
--!-------------------------------------------------------------------------
select
    invoice_number,
    count(*) as invoice_count
from
    gold.fact_invoices
group by
    invoice_number,
    year(creation_date)
having
    count(*) > 1



--!-------------------------------------------------------------------------

WITH duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY invoice_number,
            YEAR(creation_date)
            ORDER BY
                Booking_Number DESC -- يحدد أي نسخة تتحفظ
        ) AS rn
    FROM
        gold.fact_invoices
)
DELETE FROM
    duplicates
WHERE
    rn > 1;



select count(distinct stay_key) as distinct_stays from gold.fact_stay;

select
    count(distinct booking_key) as distinct_stays
from
    gold.fact_bookings;


