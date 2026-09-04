/* =========================================================
   CUSTOMER DATA CLEANING
   ========================================================= */

-- 1. Create backup
SELECT *
INTO customers_backup
FROM customer_data;

-- 2. Check NULL values
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_email
FROM customers_backup;

-- 3. Check NULL / empty emails
SELECT 
    customer_id,
    email
FROM customers_backup
WHERE email IS NULL
   OR LTRIM(RTRIM(email)) = '';

-- 4. Replace missing emails with Unknown
UPDATE customers_backup
SET email = 'Unknown'
WHERE email IS NULL
   OR LTRIM(RTRIM(email)) = '';

-- 5. Check Gender values
SELECT DISTINCT gender
FROM customers_backup;

SELECT *
FROM customers_backup
WHERE gender = '???';

SELECT 
    gender,
    COUNT(*) AS total_count
FROM customers_backup
GROUP BY gender;

-- 6. Replace unknown gender value
UPDATE customers_backup
SET gender = 'Unknown'
WHERE gender = '???';

-- 7. Check City values
SELECT DISTINCT city
FROM customers_backup;

-- 8. Check Age values
SELECT DISTINCT age
FROM customers_backup
ORDER BY age;

-- 9. Create Age Group
ALTER TABLE customers_backup
ADD age_group VARCHAR(20);

UPDATE customers_backup
SET age_group =
    CASE 
        WHEN age < 25 THEN 'Youth (16-24)'
        WHEN age BETWEEN 25 AND 45 THEN 'Adult (25-45)'
        WHEN age BETWEEN 46 AND 60 THEN 'Middle-aged (46-60)'
        WHEN age > 60 THEN 'Senior'
        ELSE 'UNKnown'
    END;

-- 10. Analyze Age Groups
SELECT 
    age_group,
    COUNT(*) AS customer_count
FROM customers_backup
GROUP BY age_group
ORDER BY customer_count DESC;

-- 11. Check duplicate Customer IDs
SELECT 
    customer_id,
    COUNT(*) AS repeat_count
FROM customers_backup
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 16. Display cleaned Customer table
SELECT *
FROM customers_backup;
/* =========================================================
   SALES DATA CLEANING
   ========================================================= */

-- 1. Create backup
SELECT *
INTO sales_backup
FROM sales_data;

-- 2. Display Sales data
SELECT *
FROM sales_backup;

-- 3. Check NULL values
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS null_store_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
    SUM(CASE WHEN returned IS NULL THEN 1 ELSE 0 END) AS null_returned
FROM sales_backup;

-- 4. Check missing Customer IDs
SELECT *
FROM sales_backup
WHERE customer_id IS NULL
   OR LTRIM(RTRIM(customer_id)) = '';

-- 6. Replace missing Discount with 0
UPDATE sales_backup
SET discount = 0.0
WHERE discount IS NULL;

-- 7. Check remaining NULL discounts
SELECT COUNT(*) AS null_discounts
FROM sales_backup
WHERE discount IS NULL;

-- 8. Check Store IDs
SELECT DISTINCT store_id
FROM sales_backup;

-- 9. Delete fake Store 999
DELETE FROM sales_backup
WHERE store_id = 'S999';

-- 10. Check duplicate Transaction IDs
SELECT 
    transaction_id,
    COUNT(*) AS repeat_count
FROM sales_backup
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 11. Set Transaction ID as Primary Key
ALTER TABLE sales_backup
ALTER COLUMN transaction_id VARCHAR(20) NOT NULL;

ALTER TABLE sales_backup
ADD CONSTRAINT PK_sales_backup
PRIMARY KEY (transaction_id);

 Select * from sales_backup;

 

-- 15. Add Date Analysis Columns
ALTER TABLE sales_backup
ADD 
    sale_year INT,
    sale_month INT,
    sale_quarter INT,
    day  VARCHAR(15);

UPDATE sales_backup
SET 
    sale_year = YEAR(date),
    sale_month = MONTH(date),
    sale_quarter = DATEPART(QUARTER, date),
    day = DATENAME(WEEKDAY, date);

-- 16. Set Discount data type
ALTER TABLE sales_backup
ALTER COLUMN discount DECIMAL(5,2);

-- 17. Check Date Analysis
SELECT TOP 10
    transaction_id,
    date,
    sale_year,
    sale_month,
    sale_quarter,
    day,
    discount
FROM sales_backup;

/* =========================================================
   INSIGHTS
   ========================================================= */

-- 1. Sales by Quarter
SELECT 
    sale_quarter,
    CASE sale_quarter
        WHEN 1 THEN 'Q1 (Winter / Start of Year)'
        WHEN 2 THEN 'Q2 (Spring)'
        WHEN 3 THEN 'Q3 (Summer)'
        WHEN 4 THEN 'Q4 (Year-End / Holiday Season)'
    END AS season_name,
    COUNT(transaction_id) AS total_transactions,
    SUM(quantity) AS total_quantity_sold
FROM sales_backup
GROUP BY sale_quarter
ORDER BY total_quantity_sold DESC;

-- 2. Purchases by Age Group
SELECT 
    c.age_group,
    COUNT(s.transaction_id) AS total_purchases,
    SUM(s.quantity) AS total_items_bought,
    ROUND(AVG(CAST(s.quantity AS FLOAT)), 2) AS avg_items_per_order
FROM sales_backup s
JOIN customers_backup c
    ON s.customer_id = c.customer_id
WHERE c.age_group <> 'Unknown'
GROUP BY c.age_group
ORDER BY total_items_bought DESC;