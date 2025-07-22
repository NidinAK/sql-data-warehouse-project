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
