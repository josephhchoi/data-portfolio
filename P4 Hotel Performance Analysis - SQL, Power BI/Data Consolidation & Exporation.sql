----- Platform Used: SQL Server Management -----

----- DATA IMPORT & CONSOLIDATION -----

	-- Imported the following tables into a database: 2018 / 2019 / 2020 / market_segment / meal_cost
	-- Consolidating data from 5 tables into one to load dataset into Power BI

	-- Appending tables 2018, 2019, 2020
WITH hotels AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$']);

	-- Joining tables 2018-2020 w/ market_segment & meal_cost
WITH hotels AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

SELECT * FROM hotels h
LEFT JOIN dbo.market_segment$ ms
ON h.market_segment = ms.market_segment
LEFT JOIN dbo.meal_cost$ mc
ON mc.meal = h.meal;

----- DATA EXPLORATION -----

-- 1.) Booking Patterns Analysis
	
	-- Most popular months for reservations
WITH hotels AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

SELECT 
	arrival_date_year, 
	arrival_date_month, 
	COUNT(*) AS num_reservations
FROM 
	hotels
GROUP BY
	arrival_date_year, 
	arrival_date_month
ORDER BY 
	num_reservations DESC;

	-- Booking trends over the years
WITH hotels AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

SELECT 
    arrival_date_year,
    COUNT(*) AS num_reservations
FROM 
    hotels
GROUP BY 
    arrival_date_year
ORDER BY 
    arrival_date_year;

	-- Average lead time for bookings
WITH hotels AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

SELECT 
	AVG(lead_time) AS avg_lead_time
FROM 
	hotels;

-- 2.) Cancellation Analysis

	-- Top reasons for booking cancellations
WITH hotels AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

SELECT 
    reservation_status,
    COUNT(*) AS num_cancellations
FROM 
    hotels
WHERE 
    reservation_status = 'Canceled'
GROUP BY 
    reservation_status
ORDER BY
	num_cancellations;

	-- Percentage of canceled bookings
WITH hotels AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

SELECT 
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN reservation_status = 'Canceled' THEN 1 ELSE 0 END) AS num_cancellations,
    (SUM(CASE WHEN reservation_status = 'Canceled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS cancellation_percentage
FROM 
    hotels;

-- 3.) Revenue Analysis

	-- Total revenue for each year (2018-2020)
WITH hotels AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

SELECT
	arrival_date_year,
	ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights) * adr),2) as revenue
FROM 
	hotels
GROUP BY
	arrival_date_year

	-- Cancellation revenue loss
WITH hotels AS (
    SELECT * FROM dbo.['2018$']
    UNION
    SELECT * FROM dbo.['2019$']
    UNION
    SELECT * FROM dbo.['2020$']
),
canceled_bookings AS (
    SELECT
        arrival_date_year,
        (stays_in_week_nights + stays_in_weekend_nights) * adr AS canceled_revenue
    FROM
        hotels
    WHERE
        reservation_status = 'Canceled'
)
SELECT
    arrival_date_year,
    SUM(canceled_revenue) AS potential_revenue_loss
FROM
    canceled_bookings
GROUP BY
    arrival_date_year;
