# US HOUSEHOLD INCOME PROJECT: DATA CLEANING

	# Table of Content: 
		# Removing Duplicates
		# Standardizing Data
        # Dealing With Null/Blank Values
        
USE us_house_income;
SELECT * FROM us_household_income; 
SELECT * FROM us_household_income_statistics;

ALTER TABLE us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`;


-- REMOVING DUPLICATES --

	-- Part 1: Verifying if there are duplicate rows in dataset
	SELECT id, COUNT(id)
	FROM us_household_income
	GROUP BY id
	HAVING COUNT(id) > 1
	;

	-- Part 2: Locating Row_Id for duplicate rows
	SELECT row_id
	FROM (
		SELECT
			row_id,
			id,
			ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS Row_Count
		FROM us_household_income
		) AS Row_Table
	WHERE Row_Count > 1
	;
    
	-- Part 3: Removing duplicate rows from table
    DELETE FROM us_household_income
    WHERE row_id IN (
		SELECT row_id
		FROM (
			SELECT
				row_id,
				id,
				ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS Row_Count
			FROM us_household_income
			) AS Row_Table
		WHERE Row_Count > 1
	)
	;    
    
-- STANDARDIZING DATA --

	-- Column: State_Name 

		-- Part 1: Verifying if there are name outliers in column 'State_Name'
		SELECT State_Name, COUNT(State_Name)
		FROM us_household_income
		GROUP BY State_Name
		;

		-- Part 2: Correcting the state names for misspelled entries in the table
		UPDATE us_household_income
		SET State_Name = 'Georgia'
			WHERE State_Name = 'georia'
		;
			
		UPDATE us_household_income
		SET State_Name = 'Alabama'
			WHERE State_Name = 'alabama'
		;

	-- Column: Type

		-- Part 1: Verifying if there are name outliers in column 'Type'
		SELECT Type, COUNT(Type)
		FROM us_household_income
		GROUP BY Type
		;

		-- Part 2: Correcting the Type for misspelled entries in the table
		UPDATE us_household_income
		SET Type = 'Borough'
			WHERE Type = 'Boroughs'
		;

-- DEALING WITH NULL/BLANK VALUES --

	-- Column: Place
    
		-- Part 1: Verifying if there are missing values in column 'Place'
		SELECT *
		FROM us_household_income
		WHERE Place = ''
		;

		-- Part 2: Populating empty cells with the correct location
		UPDATE us_household_income
		SET Place = 'Autaugaville'
			WHERE 
				County = 'Autauga County' AND
				City = 'Vinemont'
		;
    
    -- Column: ALand

		-- Part 1: Verifying if there are missing values in column 'ALand'
		SELECT State_Name, County, Place, ALand
		FROM us_household_income
		WHERE 
			ALand = 0 OR 
			ALand IS NULL OR
			ALand = ''
		;

		-- Part 2: Setting up code to add to UPDATE Statement

		SELECT State_Name, County, Place, ALand, ROUND(AVG(ALand) OVER(PARTITION BY County)) AS Avg_ALand
		FROM us_household_income
		ORDER BY 4, 1
		;

		SELECT *, 
			CASE 
				WHEN ALand = 0 THEN ROUND(AVG(ALand) OVER(PARTITION BY County))
				ELSE ALand
			END AS Avg_ALand
		FROM us_household_income
		;

		SELECT *
		FROM us_household_income t1
		JOIN (
			SELECT *, 
				CASE 
					WHEN ALand = 0 THEN ROUND(AVG(ALand) OVER(PARTITION BY County))
					ELSE ALand
				END AS Avg_ALand
			FROM us_household_income
			) AS t2
		ON t1.row_id = t2.row_id
		;

		-- Part 3: Populating empty cells with the average ALand value by County 

		UPDATE us_household_income t1
		JOIN (
			SELECT *, 
				CASE 
					WHEN ALand = 0 THEN ROUND(AVG(ALand) OVER(PARTITION BY County))
					ELSE ALand
				END AS Avg_ALand
			FROM us_household_income
			) AS t2
		ON t1.row_id = t2.row_id
		SET t1.ALand = t2.Avg_ALand
		;

	-- Column: AWater
    
		-- Part 1: Verifying if there are missing values in column 'AWater'
		SELECT State_Name, County, Place, AWater
		FROM us_household_income
		WHERE 
			AWater = 0 OR 
			AWater IS NULL OR
			AWater = ''
		;

		-- Part 2: Setting up code to add to UPDATE Statement

		SELECT State_Name, County, Place, AWater, ROUND(AVG(AWater) OVER(PARTITION BY County)) AS Avg_AWater
		FROM us_household_income
		ORDER BY 4, 1
		;

		SELECT *, 
			CASE 
				WHEN AWater = 0 THEN ROUND(AVG(AWater) OVER(PARTITION BY County))
				ELSE AWater
			END AS Avg_AWater
		FROM us_household_income
		;

		SELECT *
		FROM us_household_income t1
		JOIN (
			SELECT *, 
				CASE 
					WHEN AWater = 0 THEN ROUND(AVG(AWater) OVER(PARTITION BY County))
					ELSE AWater
				END AS Avg_AWater
			FROM us_household_income
			) AS t2
		ON t1.row_id = t2.row_id
		;

		-- Part 3: Populating empty cells with the average AWater value by County

		UPDATE us_household_income t1
		JOIN (
			SELECT *, 
				CASE 
					WHEN AWater = 0 THEN ROUND(AVG(AWater) OVER(PARTITION BY County))
					ELSE AWater
				END AS Avg_AWater
			FROM us_household_income
			) AS t2
		ON t1.row_id = t2.row_id
		SET t1.AWater = t2.Avg_AWater
		;