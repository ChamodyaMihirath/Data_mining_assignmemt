-- ============================================================
-- Online Retail II Data Warehouse
-- OLAP Queries
-- MySQL 8.0
-- ============================================================


-- ============================================================
-- Q1 - ROLLUP
-- Business Question:
-- What is the total sales revenue by country and year,
-- including subtotals for each country and the grand total?
-- ============================================================
USE retail_dw;
SHOW TABLES;

SELECT
    COALESCE(c.Country, 'Grand Total') AS Country,
    COALESCE(CAST(t.Year AS CHAR), 'Subtotal') AS Year,
    ROUND(SUM(f.SalesAmount),2) AS TotalRevenue
FROM fact_sales f
JOIN dim_customer c
ON f.CustomerKey = c.CustomerKey
JOIN dim_time t
ON f.TimeKey = t.TimeKey
GROUP BY
    c.Country,
    t.Year
WITH ROLLUP;



-- ============================================================
-- Q2 - GROUPING SETS Equivalent
-- Business Question:
-- Compare total revenue by Country, by Year,
-- and the overall grand total.
-- ============================================================

SELECT
    Country,
    NULL AS Year,
    ROUND(SUM(f.SalesAmount),2) AS TotalRevenue
FROM fact_sales f
JOIN dim_customer c
ON f.CustomerKey = c.CustomerKey
GROUP BY Country

UNION ALL

SELECT
    NULL,
    t.Year,
    ROUND(SUM(f.SalesAmount),2)
FROM fact_sales f
JOIN dim_time t
ON f.TimeKey = t.TimeKey
GROUP BY t.Year

UNION ALL

SELECT
    'Grand Total',
    NULL,
    ROUND(SUM(SalesAmount),2)
FROM fact_sales;



-- ============================================================
-- Q3 - LAG()
-- Business Question:
-- How has monthly revenue changed compared to
-- the previous month?
-- ============================================================

WITH MonthlySales AS
(
    SELECT

        t.Year,

        t.Month,

        ROUND(SUM(f.SalesAmount),2) AS MonthlyRevenue

    FROM fact_sales f

    JOIN dim_time t
    ON f.TimeKey=t.TimeKey

    GROUP BY
        t.Year,
        t.Month
)

SELECT

    Year,

    Month,

    MonthlyRevenue,

    LAG(MonthlyRevenue)
    OVER
    (
        ORDER BY
        Year,
        Month
    ) AS PreviousMonthRevenue,

    ROUND(
        MonthlyRevenue
        -
        LAG(MonthlyRevenue)
        OVER
        (
            ORDER BY
            Year,
            Month
        ),
        2
    ) AS RevenueDifference

FROM MonthlySales;



-- ============================================================
-- Q4 - Running Total
-- Business Question:
-- What is the cumulative revenue over time?
-- ============================================================

WITH DailySales AS
(
    SELECT

        t.FullDate,

        ROUND(SUM(f.SalesAmount),2) AS DailyRevenue

    FROM fact_sales f

    JOIN dim_time t
    ON f.TimeKey=t.TimeKey

    GROUP BY
        t.FullDate
)

SELECT

    FullDate,

    DailyRevenue,

    ROUND(
        SUM(DailyRevenue)
        OVER(
            ORDER BY FullDate
        ),
        2
    ) AS RunningTotalRevenue

FROM DailySales;



-- ============================================================
-- Q5 - RANK()
-- Business Question:
-- What are the top 5 highest revenue generating products?
-- ============================================================

WITH ProductSales AS
(
    SELECT

        p.StockCode,

        p.Description,

        ROUND(SUM(f.SalesAmount),2) AS Revenue

    FROM fact_sales f

    JOIN dim_product p
    ON f.ProductKey=p.ProductKey

    GROUP BY

        p.StockCode,

        p.Description
)

SELECT

    RANK()
    OVER
    (
        ORDER BY Revenue DESC
    ) AS ProductRank,

    StockCode,

    Description,

    Revenue

FROM ProductSales

LIMIT 10;



-- ============================================================
-- Q6 - Multi-Dimension Filter
-- Business Question:
-- What are the sales generated in the United Kingdom
-- during the year 2010?
-- ============================================================

SELECT

    t.Year,

    c.Country,

    ROUND(SUM(f.SalesAmount),2) AS TotalRevenue,

    SUM(f.Quantity) AS TotalQuantity,

    COUNT(*) AS TotalTransactions

FROM fact_sales f

JOIN dim_customer c
ON f.CustomerKey=c.CustomerKey

JOIN dim_time t
ON f.TimeKey=t.TimeKey

WHERE

    c.Country='United Kingdom'

    AND

    t.Year=2010

GROUP BY

    t.Year,

    c.Country;