-- Platform Used: SSMS --

-- 1. SETUP: 

-- Specified database
USE jhc;
GO

-- Verified that all tables were imported successfully
SELECT * FROM es_share_yr_0;
SELECT * FROM es_share_yr_1;
SELECT * FROM cost_table;

-- 2. ADDRESSED DATA TYPE AND FORMATTING ERROR:
	-- 'dteday' column imported as 'nvarchar' with dates in 'day/month/year' format
	-- Converted 'dteday' to 'date' format and reformat to 'month/day/year'

-- Queried for unique 'dteday' values to verify error
WITH CombinedESData AS (
	SELECT * FROM es_share_yr_0
	UNION
	SELECT * FROM es_share_yr_1
)
SELECT DISTINCT dteday
FROM CombinedESData;

-- Added new 'dteday_date' columns
ALTER TABLE es_share_yr_0 ADD dteday_date DATE;
ALTER TABLE es_share_yr_1 ADD dteday_date DATE;

-- Updated new columns with converted dates
UPDATE es_share_yr_0
SET dteday_date = CONVERT(DATE, dteday, 103);

UPDATE es_share_yr_1
SET dteday_date = CONVERT(DATE, dteday, 103);

-- Dropped old 'dteday' columns and renamed new columns
ALTER TABLE es_share_yr_0 DROP COLUMN dteday;
ALTER TABLE es_share_yr_1 DROP COLUMN dteday;

EXEC sp_rename 'dbo.es_share_yr_0.dteday_date', 'dteday', 'COLUMN';
EXEC sp_rename 'dbo.es_share_yr_1.dteday_date', 'dteday', 'COLUMN';

-- 3. QUERY FOR POWER BI PLUG-IN:

-- Combined the 3 tables via CTE & JOIN
WITH CombinedESData AS (
	SELECT * FROM es_share_yr_0
	UNION
	SELECT * FROM es_share_yr_1
)
SELECT
	cbd.dteday,
	cbd.season,
	cbd.yr,
	cbd.weekday,
	cbd.hr,
	cbd.renter_type,
	cbd.renters,
	ct.rental_price,
	ct.COGS,
	cbd.renters * ct.rental_price AS revenue,
	(cbd.renters * ct.rental_price) - (cbd.renters * ct.COGS) AS profit
FROM CombinedESData cbd
JOIN cost_table ct
	ON cbd.yr = ct.yr;
