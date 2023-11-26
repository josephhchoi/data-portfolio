# WORLD LIFE EXPECTANCY PROJECT: DATA CLEANING

	# Table of Content: 
		# Removing Duplicates
		# Dealing With Null/Blank Values

	USE world_life_expectancy;
	SELECT * FROM world_life_expectancy;

-- REMOVING DUPLICATES --

	-- Part 1: Verifying if there are duplicate rows
	SELECT 
		Country, 
		Year, 
		CONCAT(Country, Year), 
		COUNT(CONCAT(Country, Year))
	FROM world_life_expectancy
	GROUP BY Country, Year, CONCAT(Country, Year)
	HAVING COUNT(CONCAT(Country, Year)) > 1
	; 

	-- Part 2: Locating Row_Id for duplicate rows
	SELECT Row_Id
	FROM (
		SELECT 
			Row_Id, 
			CONCAT(Country, Year),
			ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
		FROM world_life_expectancy) AS Row_Table
	WHERE Row_Num > 1
	; 

	-- Part 3: Removing duplicate rows from table
	DELETE FROM world_life_expectancy
	WHERE Row_Id IN (
		SELECT Row_Id
		FROM (
			SELECT 
				Row_Id, 
				CONCAT(Country, Year),
				ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
			FROM world_life_expectancy) AS Row_Table
		WHERE Row_Num > 1
		)
	; 

-- DEALING WITH NULL/BLANK VALUES --

	-- 'Status' Column (Part 1): Checking for blank values in 'Status' column
	SELECT * 
	FROM world_life_expectancy
	WHERE Status = ''
	;

	-- 'Status' Column (Part 2): Setting up code to add to UPDATE Statement
	SELECT *
	FROM world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
	WHERE
		t1.Status = ''
		AND t2.Status <> ''
		AND t2.Status = 'Developing'
	;

	SELECT *
	FROM world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
	WHERE
		t1.Status = ''
		AND t2.Status <> ''
		AND t2.Status = 'Developed'
	;

	-- 'Status' Column (Part 3): Updating table to populate 'Status' Column based on information from different rows
	UPDATE world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
	SET t1.Status = 'Developing'
		WHERE t1.Status = ''
		AND t2.Status <> ''
		AND t2.Status = 'Developing'
	;

	UPDATE world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
	SET t1.Status = 'Developed'
		WHERE t1.Status = ''
		AND t2.Status <> ''
		AND t2.Status = 'Developed'
	;
    
	-- 'Life expectancy' Column (Part 1): Checking for blank values in 'Life expectancy' column
	SELECT *
	FROM world_life_expectancy
	WHERE `Life expectancy` = ''
	;
	
	
	-- 'Life expectancy' Column (Part 2): Setting up code to add to UPDATE Statement
	SELECT 
		t1.Country, t1.Year, t1.`Life expectancy`, 
	t2.Country, t2.Year, t2.`Life expectancy`, 
	t3.Country, t3.Year, t3.`Life expectancy`,
	ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
	FROM world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
	JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
	WHERE t1.`Life expectancy` = ''
	;    
	
	-- 'Life expectancy' Column (Part 3): Populating blank 'Life expectancy' values by averaging the previous AND following years' life expectancy
	UPDATE world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
	JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
	SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
	WHERE t1.`Life expectancy` = ''
	;
