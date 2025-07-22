-- ========================================================
-- silver.crm_cust_info
-- =======================================================

INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)

SELECT
	cst_id, cst_key, 
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE			-- Normalized marital status values to readable format
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		ELSE 'n/a' 
	END AS cst_marital_status,
	CASE			-- Normalized Gender values to readable format
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		ELSE 'n/a' 
	END AS cst_gndr,
	cst_create_date
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM 
		bronze.crm_cust_info
	WHERE
		cst_id IS NOT NULL
	) t 
	WHERE flag_last = 1  -- Select most recent record;


-- ======================================================================
-- silver.crm_prd_info
-- ==================================================================


-- Note: yet to complete the query

SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,	
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	CAST (prd_start_dt AS DATE) AS prd_start_dt,
	CAST (
		LEAD(prd_start_dt) 
			OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
		AS DATE 
	) AS prd_end_dt
FROM 
	bronze.crm_prd_info;

