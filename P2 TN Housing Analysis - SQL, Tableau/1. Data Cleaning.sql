----- SETUP -----


-- Ensuring that the 'nashvillehousingdata' table imported successfully
SELECT *
FROM portfolioproject.nashvillehousingdata;

----- DATA WRANGLING -----

-- 1.) Date Format Standardization --
SELECT DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%c/%e/%Y') -- Converting text to data & the date format
FROM portfolioproject.nashvillehousingdata;

USE portfolioproject;
UPDATE nashvillehousingdata 
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%c/%e/%Y');

-- 2.) Property Address Data Population --

	-- 'PropertyAddress' column contains blank values when a duplicate ParcelID is present in another row
	-- Populating the blank values in the PropertyAddress column by using JOIN and CASE statements for duplicate ParcelIDs 

	-- 1st Code Block (Setup):
SELECT orig.ParcelID, orig.PropertyAddress, copy.ParcelID, copy. PropertyAddress,
       CASE WHEN orig.PropertyAddress = '' THEN copy.PropertyAddress -- CASE logic: If the original address is empty, then replace with copy address
            ELSE orig.PropertyAddress
       END
FROM portfolioproject.nashvillehousingdata orig
JOIN portfolioproject.nashvillehousingdata copy -- JOIN logic: Matching rows with same 'ParcelID' but different 'UniqueID' to find duplicate address
	ON orig.ParcelID = copy.ParcelID
    AND orig.UniqueID <> copy.UniqueID;

	-- 2nd Code Block (Actual Update):
UPDATE portfolioproject.nashvillehousingdata orig
JOIN portfolioproject.nashvillehousingdata copy 
    ON orig.ParcelID = copy.ParcelID
    AND orig.UniqueID <> copy.UniqueID
SET orig.PropertyAddress = CASE 
							 WHEN orig.PropertyAddress = '' THEN copy.PropertyAddress 
                             ELSE orig.PropertyAddress
							 END;

-- 3.) 'PropertyAddress' breakdown into individual columns (Address & City) via 'SUBSTRING()' --
	-- Syntax: SUBSTRING(str, start, length)

	-- 1st Code Block (Setup):
SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address 
FROM portfolioproject.nashvillehousingdata;

SELECT SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City 
FROM portfolioproject.nashvillehousingdata;

	-- 2nd Code Block (Actual Update):
ALTER TABLE nashvillehousingdata
ADD PropertySplitAddress NVARCHAR(255);
UPDATE nashvillehousingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE nashvillehousingdata
ADD PropertySplitCity NVARCHAR(255);
UPDATE nashvillehousingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

-- 4.) 'OwnerAddress' breakdown into individual columns (Address, City, State) via 'SUBSTRING_INDEX()' --
	-- Syntax: SUBSTRING_INDEX(str, delimiter, count)

	-- 1st Code Block (Setup):    
SELECT
	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS City,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM nashvillehousingdata;

	-- 2nd Code Block (Actual Update):
ALTER TABLE nashvillehousingdata
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE nashvillehousingdata
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashvillehousingdata
ADD OwnerSplitCity NVARCHAR(255);
UPDATE nashvillehousingdata
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);

ALTER TABLE nashvillehousingdata
ADD OwnerSplitState NVARCHAR(255);
UPDATE nashvillehousingdata
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- 5.) Conversion of 'Y' and 'N' to 'Yes' and 'No' in the 'Sold as Vacant' field via CASE STATEMENT --
	-- Syntax: CASE.. WHEN condition1 THEN result1.. WHEN condition2 THEN result2.. ELSE resultN.. END

	-- 1st Code Block (Setup):  
SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END AS UpdatedSoldAsVacant
FROM portfolioproject.nashvillehousingdata
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N';

	-- 2nd Code Block (Actual Update):
UPDATE nashvillehousingdata
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END;

	-- 3rd Code Block (Update Validation):
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS Count
FROM portfolioproject.nashvillehousingdata
GROUP BY SoldAsVacant;

-- 6.) Duplicate Removal --

	-- Assigning a row umber to each row via 'ROW_NUMBER()' & 'OVER()'
    -- Row numbers are deteremined based on specified partition
    -- Output: '1' (1st occurrence of unique partition) and '2' (2nd occurrence of unique partition) 

	-- 1st Code Block (Setup):  
SELECT *, 
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    ORDER BY UniqueID) Row_Num
FROM portfolioproject.nashvillehousingdata
ORDER BY ParcelID;

	-- 2nd Code Block (Actual Delete)
DELETE FROM portfolioproject.nashvillehousingdata
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                ORDER BY UniqueID
            ) AS Row_Num
        FROM portfolioproject.nashvillehousingdata
    ) AS RowNumCTE
    WHERE Row_Num = 2
);

	-- 3rd Code Block (Delete Validation)
SELECT DISTINCT Row_Num, COUNT(Row_Num) AS Count
FROM (
    SELECT *, 
        ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID) Row_Num
    FROM portfolioproject.nashvillehousingdata
) AS subquery
GROUP BY Row_Num
ORDER BY Row_Num;

-- 7.) Obsolete Column Deletion --
ALTER TABLE portfolioproject.nashvillehousingdata
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

-- 8.) CSV Export --
SELECT *
FROM portfolioproject.nashvillehousingdata
INTO OUTFILE '/path/to/your/folder//nashvillehousingdata_cleaned.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
