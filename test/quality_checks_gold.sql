```sql
/*
===============================================================================
Gold Layer - Quality Checks
===============================================================================

Purpose:
Validate the Gold Layer views to ensure data quality and
reliability for analytics and reporting.

Checks:
- Duplicate Dimension Keys
- NULL Values in Important Columns
- Missing Dimension References
- Sales Data Consistency
===============================================================================
*/

USE DataWareHouse
GO


-- ============================================================================
-- Check 1: Duplicate Customer Keys
-- ============================================================================

SELECT
    customers_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customers_key
HAVING COUNT(*) > 1


-- ============================================================================
-- Check 2: Duplicate Product Keys
-- ============================================================================

SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1


-- ============================================================================
-- Check 3: NULL Values in Customer Dimension
-- ============================================================================

SELECT *
FROM gold.dim_customers
WHERE customers_id IS NULL
   OR customers_key IS NULL


-- ============================================================================
-- Check 4: NULL Values in Product Dimension
-- ============================================================================

SELECT *
FROM gold.dim_products
WHERE product_id IS NULL
   OR product_key IS NULL


-- ============================================================================
-- Check 5: Missing Dimension References in Fact Table
-- ============================================================================

SELECT *
FROM gold.fact_sales
WHERE product_key IS NULL
   OR customers_key IS NULL


-- ============================================================================
-- Check 6: Sales Data Consistency
-- Expected: Sales = Quantity * Price
-- ============================================================================

SELECT *
FROM gold.fact_sales
WHERE sales != quantity * price
   OR sales IS NULL
   OR quantity IS NULL
   OR price IS NULL
   OR sales <= 0
   OR quantity <= 0
   OR price <= 0


-- ============================================================================
-- Check 7: Invalid Sales Dates
-- ============================================================================

SELECT *
FROM gold.fact_sales
WHERE order_date > ship_date
   OR order_date > due_date
```
