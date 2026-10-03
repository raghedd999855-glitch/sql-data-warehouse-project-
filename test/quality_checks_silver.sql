/*
===============================================================================
Silver Layer - Quality Checks
===============================================================================

Purpose:
Validate data quality in the Silver Layer before using it
in the Gold Layer for analytics and reporting.

Checks:
- Invalid Dates
- Invalid Order Dates
- Sales Data Consistency
===============================================================================
*/

USE DataWareHouse
GO

-- ============================================================================
-- Check 1: Invalid Sales Dates
-- ============================================================================

SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 202500101
   OR sls_order_dt < 19000101


-- ============================================================================
-- Check 2: Invalid Order Dates
-- ============================================================================

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt < sls_ship_dt
   OR sls_order_dt < sls_due_dt


-- ============================================================================
-- Check 3: Sales Data Consistency
-- Expected: Sales = Quantity * Price
-- ============================================================================

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
