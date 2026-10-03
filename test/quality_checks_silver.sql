```sql
USE DataWareHouse
GO

/*
===============================================================================
Silver Layer - Quality Checks
===============================================================================

Purpose:
These queries are used to validate data quality in the Silver Layer
before the data is consumed by the Gold Layer for analytics and reporting.

The checks cover:
- Unwanted spaces
- Standardization and consistency
- Invalid dates
- Invalid order dates
- Data consistency between sales, quantity, and price
===============================================================================
*/


-- ============================================================================
-- Check 1: Unwanted Spaces
-- Purpose: Check for leading or trailing spaces in text columns.
-- ============================================================================

SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance)


-- ============================================================================
-- Check 2: Standardization & Consistency
-- Purpose: Review distinct values to identify inconsistent categories
--          or unexpected values.
-- ============================================================================

SELECT DISTINCT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2


-- ============================================================================
-- Check 3: Invalid Sales Dates
-- Purpose: Identify invalid or incorrectly formatted order dates.
-- ============================================================================

SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 202500101
   OR sls_order_dt < 19000101


-- ============================================================================
-- Check 4: Invalid Order Dates
-- Purpose: Check that the order date is not later than the shipping
--          or due date.
-- ============================================================================

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt < sls_ship_dt
   OR sls_order_dt < sls_due_dt


-- ============================================================================
-- Check 5: Sales Data Consistency
-- Purpose: Verify the relationship between sales, quantity, and price.
--
-- Expected:
-- Sales = Quantity × Price
--
-- Values should not be NULL, zero, or negative.
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
```
