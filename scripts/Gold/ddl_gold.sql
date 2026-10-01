/*
===============================================================================
Gold Layer
===============================================================================

Purpose:
The Gold Layer contains business-ready views designed for analytics,
reporting, and data consumption.

It organizes data into:
- Dimension Views: descriptive information about customers and products.
- Fact View: transactional sales data used for analysis and reporting.

The Gold Layer is built from the cleaned and transformed Silver Layer.
===============================================================================
*/

USE DataWareHouse
GO

-- ============================================================================
-- Dimension: Customers
-- Purpose: Provides customer attributes for analysis and reporting.
-- ============================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY C.cst_id) AS customers_key,
    C.cst_id AS customers_id,
    C.cst_key AS customers_number,
    C.cst_firstname + ' ' + C.cst_lastname AS customers_name,
    C.cst_material_status AS material_status,
    CASE
        WHEN C.cst_gndr != B.gen THEN C.cst_gndr
        ELSE COALESCE(B.gen, 'n/a')
    END AS gen,
    B.bdate AS birthdate,
    L.cntry AS country,
    C.cst_creat_date AS creat_date

FROM silver.crm_cust_info C

LEFT JOIN silver.erp_cust_az12 B
    ON C.cst_key = B.cid

LEFT JOIN silver.erp_loc_a101 L
    ON C.cst_key = L.cid
GO


-- ============================================================================
-- Dimension: Products
-- Purpose: Provides product attributes for analysis and reporting.
-- ============================================================================

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY P.prd_start_dt, P.prd_key
    ) AS product_key,
    P.prd_id AS product_id,
    P.prd_nm AS product_name,
    P.prd_key AS product_number,
    P.cat_id AS category_id,
    C.cat AS category,
    C.subcat AS sub_category,
    C.maintenance,
    P.prd_cost AS product_cost,
    P.prd_line AS product_line,
    P.prd_start_dt AS start_date

FROM silver.crm_prd_info P

LEFT JOIN silver.erp_px_cat_g1v2 C
    ON P.cat_id = C.id

WHERE P.prd_end_dt IS NULL
GO


-- ============================================================================
-- Fact: Sales
-- Purpose: Provides sales transactions and measures for analysis and reporting.
-- ============================================================================

CREATE VIEW gold.fact_sales AS
SELECT
    SD.sls_ord_num AS order_number,
    PR.product_key,
    CU.customers_key,
    SD.sls_order_dt AS order_date,
    SD.sls_ship_dt AS ship_date,
    SD.sls_due_dt AS due_date,
    SD.sls_sales AS sales,
    SD.sls_quantity AS quantity,
    SD.sls_price AS price

FROM silver.crm_sales_details SD

LEFT JOIN gold.dim_products PR
    ON SD.sls_prd_key = PR.product_number

LEFT JOIN gold.dim_customers CU
    ON SD.sls_cust_id = CU.customers_id
GO
