-- 08. SQL for Data Analytics: Data Cleaning

-- 1.) Data Cleaning Introduction:
	-- Process of identifying, correcting, or removing invalid, incorrect, or incomplete data from dataset
	-- Data cleaning techniques:
		-- Removing duplicated data, normalization, standardization, populating values, etc
	-- Data cleaning cycle
		-- Import data
		-- Merge data sets
		-- Rebuilding missing data
		-- Standardization
		-- Normalization
		-- De-duplication
		-- Verification & enrichment
		-- Exporting data
		-- Repeat

-- 2.) Setting up TempTable Environment:

DROP TABLE #DataCleaningTable
CREATE TABLE #DataCleaningTable (
	unique_id INT IDENTITY(1,1) PRIMARY KEY, -- Defining column will start at 1 and increment by 1 for each row
	user_id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	phone_number VARCHAR(15),
	birth_date VARCHAR(15),
	address VARCHAR(50),
	item_name VARCHAR(50),
	quantity INT,
	unit_price_usd DECIMAL(10,2),
	total_cost_usd DECIMAL(10,2)
)

TRUNCATE TABLE #DataCleaningTable
INSERT INTO #DataCleaningTable (user_id, first_name, last_name, phone_number, birth_date, address, item_name, quantity, unit_price_usd, total_cost_usd)
	VALUES
		(184876, 'David', 'Evans', '(858)740-4751', '4/28/1989', '1229 Main Street, Scranton, PA', 'Electrical Wiring', 200, 2, 400),
		(118873, 'Olivia', 'Brown',  '/415/-632-9184', '4/11/1965', '123 North Hill Drive, Dallas, TX', 'Insulation Material', 300, 5, 1500),
		(182112, 'John', 'Anderson',  '\312\809-4725', '12/7/1999', '432 Hilly Road, Austin, TX', 'Concrete Mix', 50, 75, 3750),
		(176200, 'Daniel', 'Thompson',  '702(481)2337', '1978/08/20', '101 Apline Avenue, New York, NY', 'Plumbing Pipes', 150,	10,	1500),
		(171262, 'Jessica', 'Miller',  '6467289902', '1987/5/30', '701 North Street, Sarasota, FL', 'Paint', 60, 30, 1800),
		(176200, 'Daniel', 'Thompson',  '702(481)2337', '1978/8/20', '101 Apline Avenue, New York, NY', 'Plumbing Pipes', 150,	10,	1500),
		(141209, 'Michael', 'Foster',  '805431-5678', '7/9/2006', '12 South Main Lane, San Francisco, CA', 'Bricks',	5000, 0.5, 2500),
		(176200, 'Daniel', 'Thompson',  '702(481)2337', '1978/8/20', '101 Apline Avenue, New York, NY', 'Plumbing Pipes', 150,	10,	1500),
		(182112, 'John', 'Anderson',  '\312\809-4725', '12/7/1999', '432 Hilly Road, Austin, TX', 'Concrete Mix', 50, 75, 3750)

SELECT * FROM #DataCleaningTable


-- 3.) Removing Duplicates:

	-- Part 1:
SELECT unique_id -- Querying duplicated user_id's unique_id using FROM SUBQUERY (needs to be single column for DELETE FROM)
FROM 
(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY user_id) AS row_num -- Identifying duplicate rows via ROW_NUMBER + WINDOW function
	FROM #DataCleaningTable
) AS row_num_table
WHERE row_num > 1

	-- Part 2:
DELETE FROM #DataCleaningTable -- Deleting rows from the TempTable
WHERE unique_id IN ( -- Specifying which user_id to remove by pinpointing them using IN and SUBQUERY
	SELECT unique_id
	FROM 
	(
		SELECT 
			*,
			ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY user_id) AS row_num 
		FROM #DataCleaningTable
	) AS duplicate_table
	WHERE row_num > 1
)

SELECT * FROM #DataCleaningTable -- Checking if query removed duplicated rows


-- 4.) Standardize Data:

	-- Part 1.1: Phone Number
SELECT
	CONCAT(SUBSTRING(cleaned_phone_number,1,3), '-', SUBSTRING(cleaned_phone_number,4,3), '-', SUBSTRING(cleaned_phone_number,7,4)) -- Adding '-' via CONCAT and SUBSTRING
FROM
(
	SELECT
		phone_number,
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone_number, -- Replacing all the symbols ['()\/-'] to ''
			'(', ''), 
			')', ''), 
			'\', ''), 
			'/', ''), 
			'-', '') AS cleaned_phone_number
	FROM #DataCleaningTable
) AS standardize_table

	-- Part 1.2: Phone Number (Updating)
UPDATE #DataCleaningTable -- Updating the phone_number column to a standardized format
SET phone_number = 
	CONCAT(SUBSTRING(cleaned_phone_number,1,3), '-', SUBSTRING(cleaned_phone_number,4,3), '-', SUBSTRING(cleaned_phone_number,7,4))
	FROM
	(
		SELECT
			phone_number,
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone_number, 
				'(', ''), 
				')', ''), 
				'\', ''), 
				'/', ''), 
				'-', '') AS cleaned_phone_number
		FROM #DataCleaningTable
	) AS standardize_table
	WHERE #DataCleaningTable.phone_number = standardize_table.phone_number -- Ensuring that each row updates its corresponding cleaned phone number

SELECT * FROM #DataCleaningTable

	-- Part 2.1: Birthday
SELECT -- Version 1
    birth_date,
	CASE
		WHEN CHARINDEX('/', birth_date) IN (2,3) THEN PARSE(birth_date AS DATE USING 'en-US')
		WHEN CHARINDEX('/', birth_date) = 5 THEN CONVERT(DATE, birth_date, 111) 
	END AS formatted_birth_date
FROM #DataCleaningTable

SELECT -- Version 2
    birth_date,
	PARSE(birth_date AS DATE) AS formatted_birth_date
FROM #DataCleaningTable

	-- Part 2.2: Birthday (Updating)
UPDATE #DataCleaningTable
SET birth_date = PARSE(birth_date AS DATE)

SELECT * FROM #DataCleaningTable


-- 5.) Breaking One Column into Multiple Columns:

-- 5.1: Address - Separating columns
SELECT
	address,
	SUBSTRING(address, 1, CHARINDEX(',', address)-1) AS street,
	SUBSTRING(
		address,
		CHARINDEX(',', address) + 2, -- Starting Position: Start of the first comma
		CHARINDEX(',', address, CHARINDEX(',', address) + 1) - CHARINDEX(',', address) - 2) AS city, --Length: Calculating the distance between second comma and first comma
    SUBSTRING(
        address,
        CHARINDEX(',', address, CHARINDEX(',', address) + 1) + 2, -- Starting Position: Start of the second comma
        LEN(address)) AS state -- Length: Total length of string (specifying a large length that guarantees everything to be extracted)
FROM #DataCleaningTable

-- 5.2: Address - Adding new columns into table
ALTER TABLE #DataCleaningTable -- Adding three new columns
ADD 
	street VARCHAR(50),
	city VARCHAR(50),
	state VARCHAR(50)

UPDATE #DataCleaningTable -- Updating 3 columns with data
SET
	street = TRIM(SUBSTRING(address, 1, CHARINDEX(',', address)-1)),
	city = 	TRIM(SUBSTRING(
				address,
				CHARINDEX(',', address) + 2,
				CHARINDEX(',', address, CHARINDEX(',', address) + 1) - CHARINDEX(',', address) - 2)),
	state = TRIM(SUBSTRING(
				address,
				CHARINDEX(',', address, CHARINDEX(',', address) + 1) + 2, 
				LEN(address)))

SELECT * FROM #DataCleaningTable

-- 6.) Working w/ Nulls:
	-- Blanks (Empty Strings '') are counted as values in operations like COUNT, AVERAGE
	-- NULL values are NOT counted in functions like COUNT, AVERAGE
	-- THEREFORE, it is best practice to change blanks into null
	-- Code:
		--UPDATE table
		--SET column = NULL
		--WHERE column - ''

-- If I want to include NULL as 0 in my AVERAGE & COUNTcalculation, use COALESCE
	--SELECT 
		-- AVG(COALESCE(quantity, 0)
		-- COUNT(COALESCE(quantity, 0)
	--FROM #DataCleaningTable


