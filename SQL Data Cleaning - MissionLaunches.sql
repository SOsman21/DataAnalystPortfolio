/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM MissionLaunches

--Splitting Location into Site, Address and Country
SELECT Location
FROM MissionLaunches

SELECT REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 1)) AS Site,
		REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 2)) AS Launch_Center,
		REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 3)) AS Country
FROM MissionLaunches

SELECT REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 4)) AS USACountry
FROM MissionLaunches

ALTER TABLE MissionLaunches
Add Country VarChar(255)

ALTER TABLE MissionLaunches
Add Launch_Center VarChar(255)

ALTER TABLE MissionLaunches
Add Site VarChar(255)

UPDATE MissionLaunches -- Fills in USA
SET Country = REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 4))
WHERE REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 3)) IS NOT NULL

UPDATE MissionLaunches -- Fills in other countries
SET Country = REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 3))
WHERE Country IS NULL

UPDATE MissionLaunches
SET Launch_Center = REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 2))

UPDATE MissionLaunches
SET Site = REVERSE(PARSENAME(REPLACE(REVERSE(Location), ',', '.'), 1))

-- Standardize Date Format
-- Extracting Time and Converting into Time Format
SELECT Date
FROM MissionLaunches

SELECT SUBSTRING(Date,18,5)
FROM MissionLaunches

ALTER TABLE MissionLaunches
ADD Time Time

UPDATE MissionLaunches
SET Time = SUBSTRING(Date,18,5)

SELECT Time
FROM MissionLaunches

-- Standardizing Date Using Substring (Month, Day, Year)
SELECT Date
FROM MissionLaunches

SELECT SUBSTRING(Date,5,LEN(Date)-4)
From MissionLaunches

UPDATE MissionLaunches
SET Date = SUBSTRING(Date,5,LEN(Date)-4)

SELECT SUBSTRING(Date,1,12) -- Remove UTC
From MissionLaunches

UPDATE MissionLaunches
SET Date = SUBSTRING(Date,1,12)

SELECT REPLACE(Date,',','')
FROM MissionLaunches

UPDATE MissionLaunches
SET Date = REPLACE(Date,',','') 

UPDATE MissionLaunches
SET Date = REPLACE(Date,' ','/')

SELECT REPLACE(Date,'Jan','01')
FROM MissionLaunches

UPDATE MissionLaunches SET Date = REPLACE(Date,'Jan','01')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Feb','02')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Mar','03')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Apr','04')
UPDATE MissionLaunches SET Date = REPLACE(Date,'May','05')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Jun','06')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Jul','07')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Aug','08')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Sep','09')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Oct','10')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Nov','11')
UPDATE MissionLaunches SET Date = REPLACE(Date,'Dec','12')

SELECT CONVERT(date,Date)
FROM MissionLaunches

UPDATE MissionLaunches
SET Date = CONVERT(date,Date)

SELECT Date
FROM MissionLaunches

-- Change Rocket Status from StatusRetired/StatusActive to Retired/Active
SELECT DISTINCT Rocket_Status
FROM MissionLaunches
GROUP BY Rocket_Status

SELECT REPLACE(Rocket_Status,'StatusRetired','Retired')
FROM MissionLaunches

SELECT REPLACE(Rocket_Status,'StatusActive','Active')
FROM MissionLaunches

UPDATE MissionLaunches
SET Rocket_Status = REPLACE(Rocket_Status,'StatusRetired','Retired')

UPDATE MissionLaunches
SET Rocket_Status = REPLACE(Rocket_Status,'StatusActive','Active')

SELECT Rocket_Status
FROM MissionLaunches
 
--Removing Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY Organisation,
				Location,
				Detail,
				Rocket_Status,
				Mission_Status
				 ORDER BY
					F1
					) rowNum
From MissionLaunches
)
DELETE 
From RowNumCTE
Where rowNum > 1

--Order by Organisation, Launch Center and Date
SELECT *
FROM MissionLaunches
ORDER BY 2,10,4

--Delete Redundant Columns
ALTER TABLE MissionLaunches
DROP COLUMN [Unnamed: 0]

SELECT *
FROM MissionLaunches