
-- =======================================
-- Gold layer
-- =======================================
SELECT customer_key, count(*)
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
