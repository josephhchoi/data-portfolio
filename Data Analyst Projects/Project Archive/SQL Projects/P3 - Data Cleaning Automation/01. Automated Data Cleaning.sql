-- AUTOMATED DATA CLEANING PROJECT --

USE us_house_income;

SELECT *
FROM us_household_income;

-- Project Agenda:
	# Create stored procedures that is going to clean all the data automatically
    # Within the stored procedures, create a duplicate table and insert all the data into it with few modifications
    # Create an event that runs the stored procedures on a specified timer

-- Data Cleaning Steps:

	# Remove duplicates
DELETE FROM us_household_income
WHERE row_id IN ( 
SELECT row_id
FROM (    
	SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
    FROM us_household_income
    ) AS duplicates
WHERE row_num > 1
);

	# Standardization
UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name ='georia';

UPDATE us_household_income
SET County = UPPER(County);

UPDATE us_household_income
SET City = UPPER(City);

UPDATE us_household_income
SET Place = UPPER(Place);

UPDATE us_household_income
SET State_Name = UPPER(State_Name);

UPDATE us_household_income
SET `Type` = 'CDP'
WHERE `Type` = 'CPD';

UPDATE us_household_income
SET `Type` = 'Borough'
WHERE `Type` = 'Boroughs';

-- Stored Procedures Steps:
	# Part 1: Create a copy table
    # Part 2: Copy data into new table
    # Part 3: Add data cleaning queries

DELIMITER $$
DROP PROCEDURE IF EXISTS copy_and_data_clean;
CREATE PROCEDURE copy_and_data_clean()
BEGIN

	# Part 1:
	CREATE TABLE IF NOT EXISTS `us_household_income_cleaned` (
	  `row_id` int DEFAULT NULL,
	  `id` int DEFAULT NULL,
	  `State_Code` int DEFAULT NULL,
	  `State_Name` text,
	  `State_ab` text,
	  `County` text,
	  `City` text,
	  `Place` text,
	  `Type` text,
	  `Primary` text,
	  `Zip_Code` int DEFAULT NULL,
	  `Area_Code` int DEFAULT NULL,
	  `ALand` int DEFAULT NULL,
	  `AWater` int DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL,
	  `TimeStamp` TIMESTAMP DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	# Part 2:
	INSERT INTO us_household_income_cleaned
	SELECT *, CURRENT_TIMESTAMP # CURRENT_TIMESTAMP: Taking in current day, month, year, time
	FROM us_household_income;
    
    # Part 3:
	DELETE FROM us_household_income_cleaned
	WHERE row_id IN ( 
	SELECT row_id
	FROM (    
		SELECT row_id, id, 
			ROW_NUMBER() OVER(
				PARTITION BY id, 
                `TimeStamp` 
                ORDER BY id, `TimeStamp`) AS row_num # Removing duplicates by 'TimeStamp' dataset
		FROM us_household_income_cleaned
		) AS duplicates
	WHERE row_num > 1
	);

	UPDATE us_household_income_cleaned
	SET State_Name = 'Georgia'
	WHERE State_Name ='georia';

	UPDATE us_household_income_cleaned
	SET County = UPPER(County);

	UPDATE us_household_income_cleaned
	SET City = UPPER(City);

	UPDATE us_household_income_cleaned
	SET Place = UPPER(Place);

	UPDATE us_household_income_cleaned
	SET State_Name = UPPER(State_Name);

	UPDATE us_household_income_cleaned
	SET `Type` = 'CDP'
	WHERE `Type` = 'CPD';

	UPDATE us_household_income_cleaned
	SET `Type` = 'Borough'
	WHERE `Type` = 'Boroughs';

END $$
DELIMITER ;

CALL copy_and_data_clean();

-- Debugging or Checking Stored Procedure Performance
SELECT row_id, id, row_num
FROM (    
	SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
	FROM us_household_income_cleaned
	) AS duplicates
WHERE row_num > 1;

SELECT DISTINCT State_Name
FROM us_household_income_cleaned;

SELECT DISTINCT `Type`
FROM us_household_income_cleaned;

-- Creating Event

DROP EVENT IF EXISTS run_data_cleaning;
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 2 MINUTE
    DO CALL copy_and_data_clean();

SELECT DISTINCT TimeStamp FROM us_household_income_cleaned;

SHOW EVENTS;