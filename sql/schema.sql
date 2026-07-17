-- =====================================================
-- Online Retail II Data Warehouse
-- Database Creation
-- Database: MySQL
-- =====================================================


CREATE DATABASE IF NOT EXISTS retail_dw;

USE retail_dw;



-- =====================================================
-- DIM_CUSTOMER
-- =====================================================

CREATE TABLE DIM_CUSTOMER
(
    CustomerKey INT AUTO_INCREMENT PRIMARY KEY,

    -- Natural Key from source dataset
    CustomerID INT,

    Country VARCHAR(100) NOT NULL
);



-- =====================================================
-- DIM_PRODUCT
-- =====================================================

CREATE TABLE DIM_PRODUCT
(
    ProductKey INT AUTO_INCREMENT PRIMARY KEY,

    -- Natural Key from source dataset
    StockCode VARCHAR(50) NOT NULL,

    Description VARCHAR(500)
);



-- =====================================================
-- DIM_TIME
-- =====================================================

CREATE TABLE DIM_TIME
(
    TimeKey INT AUTO_INCREMENT PRIMARY KEY,

    FullDate DATE NOT NULL,

    Day INT NOT NULL,

    Month INT NOT NULL,

    MonthName VARCHAR(20) NOT NULL,

    Quarter INT NOT NULL,

    Year INT NOT NULL,

    WeekNumber INT NOT NULL,

    DayOfWeek VARCHAR(20) NOT NULL,

    IsWeekend BOOLEAN NOT NULL
);



-- =====================================================
-- FACT_SALES
-- =====================================================

CREATE TABLE FACT_SALES
(
    SalesKey INT AUTO_INCREMENT PRIMARY KEY,


    -- Foreign Keys
    CustomerKey INT NOT NULL,

    ProductKey INT NOT NULL,

    TimeKey INT NOT NULL,


    -- Degenerate Dimension
    InvoiceNumber VARCHAR(20) NOT NULL,


    -- Measures
    Quantity INT NOT NULL,

    UnitPrice DECIMAL(10,2) NOT NULL,

    SalesAmount DECIMAL(10,2) NOT NULL,


    -- Foreign Key Constraints

    CONSTRAINT FK_FACT_CUSTOMER
        FOREIGN KEY(CustomerKey)
        REFERENCES DIM_CUSTOMER(CustomerKey),


    CONSTRAINT FK_FACT_PRODUCT
        FOREIGN KEY(ProductKey)
        REFERENCES DIM_PRODUCT(ProductKey),


    CONSTRAINT FK_FACT_TIME
        FOREIGN KEY(TimeKey)
        REFERENCES DIM_TIME(TimeKey)
);


CREATE INDEX idx_fact_customer
ON FACT_SALES(CustomerKey);

CREATE INDEX idx_fact_product
ON FACT_SALES(ProductKey);

CREATE INDEX idx_fact_time
ON FACT_SALES(TimeKey);

SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_product;
SELECT COUNT(*) FROM dim_time;
SELECT COUNT(*) FROM fact_sales;

SELECT 
    COUNT(*) AS MissingCustomerKeys
FROM FACT_SALES
WHERE CustomerKey IS NULL;


SELECT 
    COUNT(*) AS MissingProductKeys
FROM FACT_SALES
WHERE ProductKey IS NULL;


SELECT 
    COUNT(*) AS MissingTimeKeys
FROM fact_sales
WHERE TimeKey IS NULL;


SELECT 
    COUNT(*) AS MissingProductKeys
FROM fact_sales
WHERE ProductKey IS NULL;

SELECT 
    COUNT(*) AS MissingTimeKeys
FROM fact_sales
WHERE TimeKey IS NULL;

SELECT 
    SUM(SalesAmount) AS TotalRevenue
FROM fact_sales;

SELECT
    MIN(t.FullDate) AS StartDate,
    MAX(t.FullDate) AS EndDate
FROM fact_sales f
JOIN dim_time t
ON f.TimeKey = t.TimeKey;