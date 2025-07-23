/*
============================================================
Quality Checks
============================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
===============================================================
*/

-- ============================================================
-- Checking silver.crm_cust_info
-- ============================================================

-- Checking whether there are duplicates in the primary key
-- Expectation: No Result
SELECT
	cst_id, COUNT(cst_id)
FROM
	silver.crm_cust_info
GROUP BY
	cst_id
HAVING COUNT(cst_id) > 1 AND cst_id IS NULL;

-- ============================================================
-- Check for unwanted spaces
SELECT
	cst_key
FROM 
	silver.crm_cust_info
WHERE 
	cst_key != TRIM(cst_key);

-- ===========================================================
-- Data Standardization & consistency
SELECT 
	DISTINCT cst_marital_status
FROM	
	silver.crm_cust_info;

-- ============================================================
-- Checking silver.crm_prd_info
-- ============================================================
	
-- Check for Nulls or Duplicates in Primary key
-- Expectation: No result
SELECT
	prd_id, COUNT(*)
FROM 
	silver.crm_prd_info
GROUP BY
	prd_id
HAVING 
	COUNT(*) > 1;
-- Check for unwanted spaces 
-- Expectation: No result

SELECT 
	prd_nm
FROM
	bronze.crm_prd_info
WHERE 
	prd_nm != TRIM(prd_nm);

-- Check for nulls or negative numbers
-- Expectation: No result
SELECT
	prd_cost
FROM
	bronze.crm_prd_info
WHERE
	prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT	
	DISTINCT prd_line
FROM
	bronze.crm_prd_info

-- Check for invalid date orders
SELECT *
FROM 
	bronze.crm_prd_info
WHERE
	prd_end_dt < prd_start_dt;

-- ============================================================
-- Checking silver.crm_prd_info
-- ============================================================

-- Check for invalid dates
SELECT 
	NULLIF(sls_order_dt, 0) as sls_order_dt
FROM 
	silver.crm_sales_details
WHERE 
	sls_order_dt <= 0 OR
	LEN(sls_order_dt) != 8 OR
	sls_order_dt > 20500101 OR
	sls_order_dt < 19000101;

-- Checking for invalid date orders
SELECT *
FROM 
	silver.crm_sales_details
WHERE 
	sls_order_dt > sls_due_dt OR
	sls_order_dt > sls_ship_dt;

-- Checking data consistencies: Between sales, quantity, price
--> sales = quantity * price
--> Values must not be null, zero or negative

SELECT DISTINCT
	sls_sales, sls_price, sls_quantity
FROM
	silver.crm_sales_details
WHERE
	sls_sales != sls_price * sls_quantity OR
	sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL OR
	sls_sales <= 0 OR sls_price <= 0 OR sls_quantity <= 0
ORDER BY sls_sales, sls_price, sls_quantity	;
