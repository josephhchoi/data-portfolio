----- Platform Used: SQL Server Management -----



-- SELECTING DESIRED DATABASE --

USE SupplyChainOptimizationDB
GO;



-- CREATING NECESSARY SCHEMAS --

CREATE SCHEMA SupplyChain;
	-- Table: 'OrderList'
	-- Table: 'FreightRates'
CREATE SCHEMA Warehouse;
	-- Table: 'WhCosts'
	-- Table: 'WhCapacities'
CREATE SCHEMA Product;
	-- Table: 'ProductsPerPlant'
CREATE SCHEMA Customer;
	-- Table: 'VmiCustomers'
CREATE SCHEMA Port;
	-- Table: 'PlantPorts'
CREATE SCHEMA Reporting;
	-- Table: 'CarrierOnTimeScorecard'
	-- Table: 'ShippingCost'
	-- Table: 'WarehousingCost'

-- Moving tables into their respective schemas --

ALTER SCHEMA SupplyChain TRANSFER dbo.OrderList;
ALTER SCHEMA SupplyChain TRANSFER dbo.FreightRates;
ALTER SCHEMA Warehouse TRANSFER dbo.WhCosts;
ALTER SCHEMA Warehouse TRANSFER dbo.WhCapacities;
ALTER SCHEMA Product TRANSFER dbo.ProductsPerPlant;
ALTER SCHEMA Customer TRANSFER dbo.VmiCustomers;
ALTER SCHEMA Port TRANSFER dbo.PlantPorts;



-- CARRIER ON-TIME PERFORMANCE REPORT --

	-- Creating an empty table and naming it 'CarrierOnTimeScorecard'

CREATE TABLE Reporting.CarrierOnTimeScorecard
(
	Order_ID INT,
	Order_Date DATE, 
	Origin_Port NVARCHAR(50),
	Destination_Port NVARCHAR(50),
	Carrier NVARCHAR(50),
	Scheduled_Pickup_Date DATE,
	Requested_Delivery_Date DATE,
	Number_of_Delays TINYINT,
	Actual_Pickup_Date DATE,
	Actual_Delivery_Date DATE,
	On_Time_Delivery BIT
);

	-- Inserting data into 'CarrierOnTimeScorecard' table

INSERT INTO Reporting.CarrierOnTimeScorecard
(
	Order_ID,
	Order_Date, 
	Origin_Port,
	Destination_Port,
	Carrier,
	Scheduled_Pickup_Date,
	Requested_Delivery_Date,
	Number_of_Delays,
	Actual_Pickup_Date,
	Actual_Delivery_Date,
	On_Time_Delivery
)
SELECT 
	SOH.Order_ID AS Order_ID,
	SOH.Order_Date AS Order_Date, 
	SOH.Origin_Port AS Origin_Port,
	SOH.Destination_Port AS Destination_Port,
	SOH.Carrier AS Carrier,
	DATEADD(DAY, SOH.Ship_ahead_day_count, SOH.Order_Date) AS Scheduled_Pickup_Date,
	DATEADD(DAY, 10, SOH.Order_Date) AS Requested_Delivery_Date,
	SOH.Ship_Late_Day_count AS Number_of_Delays,
	DATEADD(DAY, SOH.Ship_Late_Day_count, DATEADD(DAY, SOH.Ship_ahead_day_count, SOH.Order_Date)) AS Actual_Pickup_Date,
	DATEADD(DAY, SOH.Ship_Late_Day_count, DATEADD(DAY, 10, SOH.Order_Date))  AS Actual_Delivery_Date,
	CASE
		WHEN DATEADD(DAY, 10, SOH.Order_Date) <= DATEADD(DAY, SOH.Ship_Late_Day_count, DATEADD(DAY, 10, SOH.Order_Date)) THEN 1
		ELSE 0
	END AS On_Time_Delivery
FROM
    SupplyChain.OrderList SOH;



-- SHIPPING COST REPORT -- 

	-- Adding a new column called Freight_Unique for both 'SupplyChain.OrderList' & 'SupplyChain.FreightRates' for join purposes
ALTER TABLE SupplyChain.OrderList
ADD Freight_Unique NVARCHAR(50);

ALTER TABLE SupplyChain.FreightRates
ADD Freight_Unique NVARCHAR(50);

	-- Populating the Freight_Unique column with concatenated values
UPDATE SupplyChain.OrderList
SET Freight_Unique = Origin_Port + '_' + Carrier + '_' + Destination_Port;

UPDATE SupplyChain.FreightRates
SET Freight_Unique = orig_port_cd + '_' + Carrier + '_' + dest_port_cd;


	-- Creating an empty table and naming it 'ShippingCost'
CREATE TABLE Reporting.ShippingCost
(
	Order_ID INT,
	Order_Date DATE, 
	Origin_Port NVARCHAR(50),
	Destination_Port NVARCHAR(50),
	Carrier NVARCHAR(50),
	Freight_Unique NVARCHAR(50), 
	Freight_Rate MONEY,
	Freight_Weight FLOAT,
	Number_of_Units INT,
	Freight_Cost MONEY
);

	-- Inserting data into 'ShippingCost' table

INSERT INTO Reporting.ShippingCost
(
	Order_ID,
	Order_Date, 
	Origin_Port,
	Destination_Port,
	Carrier,
	Freight_Unique, 
	Freight_Rate,
	Freight_Weight,
	Number_of_Units,
	Freight_Cost
)
SELECT
	SOL.Order_ID AS Order_ID,
	SOL.Order_Date AS Order_Date, 
	SOL.Origin_Port AS Origin_Port,
	SOL.Destination_Port AS Destination_Port,
	SOL.Carrier AS Carrier,
	SOL.Freight_Unique AS Freight_Unique, 
	SUM(SFR.rate) AS Freight_Rate,
	MAX(SOL.Weight) AS Freight_Weight,
	MAX(SOL.Unit_quantity) AS Number_of_Units,
	SUM(SFR.rate) * SUM(SOL.Weight) AS Freight_Cost
FROM
	SupplyChain.OrderList SOL
	LEFT JOIN SupplyChain.FreightRates SFR
		ON SOL.Freight_Unique = SFR.Freight_Unique
GROUP BY 
	SOL.Order_ID,
	SOL.Order_Date,
	SOL.Origin_Port,
	SOL.Destination_Port,
	SOL.Carrier,
	SOL.Freight_Unique;



-- WAREHOUSE COST REPORT -- 

	-- Creating an empty table and naming it 'WarehouseCost'
CREATE TABLE Reporting.WarehouseCost
(
	Order_ID INT,
	Order_Date DATE, 
	Origin_Port NVARCHAR(50),
	Destination_Port NVARCHAR(50),
	Carrier NVARCHAR(50),
	Plant_Code NVARCHAR(50),
	Number_of_Units INT,
	Rate Float,
	Warehouse_Cost MONEY
);

	-- Inserting data into 'WarehouseCost' table

INSERT INTO Reporting.WarehouseCost
(
	Order_ID,
	Order_Date, 
	Origin_Port,
	Destination_Port,
	Carrier,
	Plant_Code,
	Number_of_Units,
	Rate,
	Warehouse_Cost
)
SELECT
	SOL.Order_ID AS Order_ID,
	SOL.Order_Date AS Order_Date, 
	SOL.Origin_Port AS Origin_Port,
	SOL.Destination_Port AS Destination_Port,
	SOL.Carrier AS Carrier,
	SOL.Plant_Code AS Plant_Code,
	SOL.Unit_quantity AS Number_of_Units,
	WC.Cost_unit AS Rate,
	WC.Cost_unit * SOL.Unit_quantity AS Warehouse_Cost
FROM
	SupplyChain.OrderList SOL
	LEFT JOIN Warehouse.WhCosts WC
		ON SOL.Plant_Code = WC.WH



-- CREATING STORED PROCEDURES FOR THE THREE REPORTING CODES --

	-- Stored Procedure 1: 'upsUpdateCarrierOnTimeScorecard'

CREATE PROCEDURE Reporting.upsUpdateCarrierOnTimeScorecard

AS
BEGIN
	SET NOCOUNT ON;

	-- Clearing table
	TRUNCATE TABLE Reporting.CarrierOnTimeScorecard

    -- Inserting new records
	INSERT INTO Reporting.CarrierOnTimeScorecard
	(
		Order_ID,
		Order_Date, 
		Origin_Port,
		Destination_Port,
		Carrier,
		Scheduled_Pickup_Date,
		Requested_Delivery_Date,
		Number_of_Delays,
		Actual_Pickup_Date,
		Actual_Delivery_Date,
		On_Time_Delivery
	)
	SELECT 
		SOH.Order_ID AS Order_ID,
		SOH.Order_Date AS Order_Date, 
		SOH.Origin_Port AS Origin_Port,
		SOH.Destination_Port AS Destination_Port,
		SOH.Carrier AS Carrier,
		DATEADD(DAY, SOH.Ship_ahead_day_count, SOH.Order_Date) AS Scheduled_Pickup_Date,
		DATEADD(DAY, 10, SOH.Order_Date) AS Requested_Delivery_Date,
		SOH.Ship_Late_Day_count AS Number_of_Delays,
		DATEADD(DAY, SOH.Ship_Late_Day_count, DATEADD(DAY, SOH.Ship_ahead_day_count, SOH.Order_Date)) AS Actual_Pickup_Date,
		DATEADD(DAY, SOH.Ship_Late_Day_count, DATEADD(DAY, 10, SOH.Order_Date))  AS Actual_Delivery_Date,
		CASE
			WHEN DATEADD(DAY, 10, SOH.Order_Date) <= DATEADD(DAY, SOH.Ship_Late_Day_count, DATEADD(DAY, 10, SOH.Order_Date)) THEN 1
			ELSE 0
		END AS On_Time_Delivery
	FROM
		SupplyChain.OrderList SOH;

END
GO

	-- Stored Procedure 2: 'upsUpdateShippingCost'

CREATE PROCEDURE Reporting.upsUpdateShippingCost

AS
BEGIN
	SET NOCOUNT ON;

	-- Clearing table
	TRUNCATE TABLE Reporting.ShippingCost

    -- Inserting new records
		INSERT INTO Reporting.ShippingCost
	(
		Order_ID,
		Order_Date, 
		Origin_Port,
		Destination_Port,
		Carrier,
		Freight_Unique, 
		Freight_Rate,
		Freight_Weight,
		Number_of_Units,
		Freight_Cost
	)
	SELECT
		SOL.Order_ID AS Order_ID,
		SOL.Order_Date AS Order_Date, 
		SOL.Origin_Port AS Origin_Port,
		SOL.Destination_Port AS Destination_Port,
		SOL.Carrier AS Carrier,
		SOL.Freight_Unique AS Freight_Unique, 
		SUM(SFR.rate) AS Freight_Rate,
		MAX(SOL.Weight) AS Freight_Weight,
		MAX(SOL.Unit_quantity) AS Number_of_Units,
		SUM(SFR.rate) * SUM(SOL.Weight) AS Freight_Cost
	FROM
		SupplyChain.OrderList SOL
		LEFT JOIN SupplyChain.FreightRates SFR
			ON SOL.Freight_Unique = SFR.Freight_Unique
	GROUP BY 
		SOL.Order_ID,
		SOL.Order_Date,
		SOL.Origin_Port,
		SOL.Destination_Port,
		SOL.Carrier,
		SOL.Freight_Unique;

END
GO

	-- Stored Procedure 3: 'upsUpdateWarehouseCost'

CREATE PROCEDURE Reporting.upsUpdateWarehouseCost

AS
BEGIN
	SET NOCOUNT ON;

	-- Clearing table
	TRUNCATE TABLE Reporting.WarehouseCost

    -- Inserting new records
	INSERT INTO Reporting.WarehouseCost
	(
		Order_ID,
		Order_Date, 
		Origin_Port,
		Destination_Port,
		Carrier,
		Plant_Code,
		Number_of_Units,
		Rate,
		Warehouse_Cost
	)
	SELECT
		SOL.Order_ID AS Order_ID,
		SOL.Order_Date AS Order_Date, 
		SOL.Origin_Port AS Origin_Port,
		SOL.Destination_Port AS Destination_Port,
		SOL.Carrier AS Carrier,
		SOL.Plant_Code AS Plant_Code,
		SOL.Unit_quantity AS Number_of_Units,
		WC.Cost_unit AS Rate,
		WC.Cost_unit * SOL.Unit_quantity AS Warehouse_Cost
	FROM
		SupplyChain.OrderList SOL
		LEFT JOIN Warehouse.WhCosts WC
			ON SOL.Plant_Code = WC.WH

END
GO

	-- Executing stored procedures

EXEC Reporting.upsUpdateCarrierOnTimeScorecard
EXEC Reporting.upsUpdateShippingCost
EXEC Reporting.upsUpdateWarehouseCost



-- CREATING A FUNCTION TO CALCULATE TOTAL SHIPPING COST --

	-- Function: 'TotalShippingCost'

CREATE FUNCTION Reporting.ufnTotalShippingCost 
(
	@Order_Date Date
)
RETURNS MONEY
AS
BEGIN
	-- Declare the return variable here
	DECLARE @TotalShippingCost AS MONEY;

	-- Add the T-SQL statements to compute the return value here
	SELECT @TotalShippingCost = SUM(Freight_Cost)
	FROM Reporting.ShippingCost
	WHERE Order_Date = @Order_Date;

	-- Return the result of the function
	RETURN @TotalShippingCost;

END
GO

	-- Executing function

SELECT Reporting.ufnTotalShippingCost('2013-05-26');