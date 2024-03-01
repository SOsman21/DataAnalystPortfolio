/*
PowerCo Data Exploration - How does Price senitivity affect churn and would a discount help reduce it

Skills used: Windows Functions, Aggregate Functions, Subqueries, Converting Data Types, Joins, CTE's, Temp Tables, Creating Views

*/

Select *
FROM ClientData

SELECT *
FROM PriceData

--Percentage of Churn
SELECT SUM(case when churn = 1 then 1 else 0 end) * 100 / count(*) AS [Churn (%)]
FROM ClientData

-- Forecasted Discounts Available
SELECT DISTINCT(forecast_discount_energy) AS [Discounts (%)]
FROM ClientData
ORDER BY [Discounts (%)]

-- Churn based on Forecasted Discounts
SELECT forecast_discount_energy AS [Energy Discount (%)],
	SUM(case when churn = 1 then 1 else 0 end) * 100 / count(*) AS [Churn (%)]
FROM ClientData
GROUP BY forecast_discount_energy
ORDER BY forecast_discount_energy

--Number of Discounts in Relation to Antiquity of the Clients Affect Churn
SELECT num_years_antig AS [Antiquity of Client] , 
	SUM(case when churn = 1 then 1 else 0 end) * 100 / count(*) AS [Churn (%)],
	COUNT(forecast_discount_energy) AS [Number of Discounts]
FROM ClientData
GROUP BY num_years_antig
ORDER BY num_years_antig ASC

--Sales Channels vs Energy Prices Affect Churn
SELECT DISTINCT(cd.channel_sales) AS [Sales Channels], SUM(case when cd.churn = 1 then 1 else 0 end) * 100 / COUNT(*) AS [Churn (%)],
	ROUND(AVG(pd.price_off_peak_var),3) AS [Energy Price 1st Period], ROUND(AVG(pd.price_peak_var),3) AS [Energy Price 2nd Period], ROUND(AVG(pd.price_mid_peak_var),3) AS [Energy Price 3rd Period]
FROM ClientData cd
JOIN PriceData pd
	ON cd.id = pd.id
GROUP BY channel_sales

--Sales Channels CTE 
WITH SalesChannelsCTE(channel_sales, churn, price_off_peak_var,price_peak_var, price_mid_peak_var)
AS(
SELECT DISTINCT(cd.channel_sales) AS [Sales Channels], SUM(case when cd.churn = 1 then 1 else 0 end) * 100 / COUNT(*) AS [Churn (%)],
	ROUND(AVG(pd.price_off_peak_var),3) AS [Energy Price 1st Period], ROUND(AVG(pd.price_peak_var),3) AS [Energy Price 2nd Period], ROUND(AVG(pd.price_mid_peak_var),3) AS [Energy Price 3rd Period]
FROM ClientData cd
JOIN PriceData pd
	ON cd.id = pd.id
GROUP BY channel_sales)
SELECT *
FROM SalesChannelsCTE

-- Average Energy Prices (Peak,Mid-Peak,Off-Peak) Affect Churn

SELECT cd.churn, AVG(price_off_peak_var) AS [Off-Peak], AVG(price_mid_peak_var) AS [Mid-Peak], AVG(price_peak_var) AS [Peak]
FROM ClientData cd
JOIN PriceData pd 
	on cd.id = pd.id
GROUP BY cd.churn

-- Energy Prices per period affect churn
SELECT [Month-Year],
    AVG(cons_12m) AS [Average Current Consumption],
    AVG(price_off_peak_var * cons_12m * 3) AS [Price of Consumption for 1st Period],
    AVG(price_mid_peak_var * cons_12m * 3) AS [Price of Consumption for 2nd Period],
    AVG(price_peak_var * cons_12m * 3) AS [Price of Consumption for 3rd Period],
    AVG(churn * 100) AS [Churn (%)]
FROM (SELECT CONVERT(varchar, YEAR(date_activ)) + '-' + CONVERT(varchar, MONTH(date_activ)) AS [Month-Year], 
        cons_12m, price_off_peak_var, price_mid_peak_var, price_peak_var,
        CASE WHEN churn = 1 THEN 1 ELSE 0 END AS churn
    FROM ClientData cd
    JOIN PriceData pd 
		ON cd.id = pd.id
) AS Subquery
GROUP BY [Month-Year]
ORDER BY [Month-Year]

--TEMP TABLES
DROP Table if exists #PricesvsChurnTemp
Create Table #PricesvsChurnTemp
(
[Month-Year] nvarchar(255),
[Average Current Consumption] int,
[Price of Consumption for 1st Period] float,
[Price of Consumption for 2nd Period] float,
[Price of Consumption for 3rd Period] float,
[Churn (%)] int
)

INSERT INTO #PricesvsChurnTemp
SELECT [Month-Year],
    AVG(cons_12m) AS [Average Current Consumption],
    AVG(price_off_peak_var * cons_12m * 3) AS [Price of Consumption for 1st Period],
    AVG(price_mid_peak_var * cons_12m * 3) AS [Price of Consumption for 2nd Period],
    AVG(price_peak_var * cons_12m * 3) AS [Price of Consumption for 3rd Period],
    AVG(churn * 100) AS [Churn (%)]
FROM (SELECT CONVERT(varchar, YEAR(date_activ)) + '-' + CONVERT(varchar, MONTH(date_activ)) AS [Month-Year], 
        cons_12m, price_off_peak_var, price_mid_peak_var, price_peak_var,
        CASE WHEN churn = 1 THEN 1 ELSE 0 END AS churn
    FROM ClientData cd
    JOIN PriceData pd 
		ON cd.id = pd.id
) AS Subquery
GROUP BY [Month-Year]
ORDER BY [Month-Year]

SELECT * 
FROM #PricesvsChurnTemp

-- Views
CREATE VIEW ForecastedDiscounts AS
SELECT forecast_discount_energy AS [Energy Discount (%)],
	SUM(case when churn = 1 then 1 else 0 end) * 100 / count(*) AS [Churn (%)]
FROM ClientData
GROUP BY forecast_discount_energy

CREATE VIEW AntiquityVSDiscounts AS
SELECT num_years_antig AS [Antiquity of Client] , 
	SUM(case when churn = 1 then 1 else 0 end) * 100 / count(*) AS [Churn (%)],
	COUNT(forecast_discount_energy) AS [Number of Discounts]
FROM ClientData
GROUP BY num_years_antig

CREATE VIEW AverageEnergyPrice AS
SELECT cd.churn, AVG(price_off_peak_var) AS [Off-Peak], AVG(price_mid_peak_var) AS [Mid-Peak], AVG(price_peak_var) AS [Peak]
FROM ClientData cd
JOIN PriceData pd 
	on cd.id = pd.id
GROUP BY cd.churn

CREATE VIEW SalesChannels AS
SELECT DISTINCT(cd.channel_sales) AS [Sales Channels], SUM(case when cd.churn = 1 then 1 else 0 end) * 100 / COUNT(*) AS [Churn (%)],
	ROUND(AVG(pd.price_off_peak_var),3) AS [Energy Price 1st Period], ROUND(AVG(pd.price_peak_var),3) AS [Energy Price 2nd Period], ROUND(AVG(pd.price_mid_peak_var),3) AS [Energy Price 3rd Period]
FROM ClientData cd
JOIN PriceData pd
	ON cd.id = pd.id
GROUP BY channel_sales

CREATE VIEW PricesvsChurn AS
SELECT [Month-Year],
    AVG(cons_12m) AS [Average Current Consumption],
    AVG(price_off_peak_var * cons_12m * 3) AS [Price of Consumption for 1st Period],
    AVG(price_mid_peak_var * cons_12m * 3) AS [Price of Consumption for 2nd Period],
    AVG(price_peak_var * cons_12m * 3) AS [Price of Consumption for 3rd Period],
    AVG(churn * 100) AS [Churn (%)]
FROM (SELECT CONVERT(varchar, YEAR(date_activ)) + '-' + CONVERT(varchar, MONTH(date_activ)) AS [Month-Year], 
        cons_12m, price_off_peak_var, price_mid_peak_var, price_peak_var,
        CASE WHEN churn = 1 THEN 1 ELSE 0 END AS churn
    FROM ClientData cd
    JOIN PriceData pd 
		ON cd.id = pd.id
) AS Subquery
GROUP BY [Month-Year]
ORDER BY [Month-Year]
