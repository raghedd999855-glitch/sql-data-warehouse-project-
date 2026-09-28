USE [DataWareHouse]
GO

-- ============================================================
-- SILVER LAYER - STORED PROCEDURES
-- ============================================================
-- Purpose:
-- These stored procedures load data from the Bronze Layer
-- into the Silver Layer.
--
-- The Silver Layer applies data cleaning, standardization,
-- validation, and transformation rules before the data is
-- stored for downstream analysis.
--
-- General loading process:
-- 1. Clear the existing Silver table using TRUNCATE.
-- 2. Read the raw data from the Bronze Layer.
-- 3. Apply the required transformations and validations.
-- 4. Insert the cleaned data into the Silver Layer.
--
-- Using TRUNCATE before each load prevents duplicate records
-- when the stored procedures are executed multiple times.
-- ============================================================


-- ============================================================
-- 1. CRM CUSTOMER INFORMATION
-- ============================================================
-- Procedure:
-- silver.load_crm_cust_info
--
-- Purpose:
-- Loads cleaned customer information from the Bronze CRM
-- customer table into the Silver Layer.
--
-- Transformations:
-- - Removes extra spaces from customer names.
-- - Standardizes marital status:
--      S = Single
--      M = Married
-- - Standardizes gender:
--      F = Female
--      M = Male
-- - Replaces unknown values with 'n/a'.
-- - Removes duplicate customer records.
-- - Keeps the most recent record for each customer ID.
-- - Excludes records where the customer ID is NULL.
-- ============================================================

CREATE OR ALTER PROCEDURE [silver].[load_crm_cust_info]
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear existing Silver data before reloading.
    TRUNCATE TABLE silver.crm_cust_info;

    -- Insert cleaned customer data into the Silver table.
    INSERT INTO silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_material_status,
        cst_gndr,
        cst_creat_date
    )
    SELECT
        cst_id,
        cst_key,

        -- Remove unnecessary spaces from names.
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,

        -- Standardize marital status values.
        CASE
            WHEN UPPER(TRIM(cst_material_status)) = 'S'
                THEN 'Single'
            WHEN UPPER(TRIM(cst_material_status)) = 'M'
                THEN 'Married'
            ELSE 'n/a'
        END AS cst_material_status,

        -- Standardize gender values.
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F'
                THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M'
                THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,

        cst_creat_date

    FROM
    (
        -- Assign a row number to each customer record.
        -- The most recent record receives Flags = 1.
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY cst_id
                ORDER BY cst_creat_date DESC
            ) AS Flags

        FROM bronze.crm_cust_info
    ) t

    -- Keep only the latest record for each customer
    -- and exclude records without a customer ID.
    WHERE Flags = 1
      AND cst_id IS NOT NULL;

END;
GO


-- ============================================================
-- 2. CRM PRODUCT INFORMATION
-- ============================================================
-- Procedure:
-- silver.load_crm_prd_info
--
-- Purpose:
-- Loads cleaned and standardized product information from
-- the Bronze CRM product table.
--
-- Transformations:
-- - Extracts and standardizes the category ID.
-- - Extracts the product key.
-- - Replaces NULL product costs with 0.
-- - Converts product line codes into descriptive values.
-- - Converts product start dates to DATE.
-- - Calculates the product end date using LEAD().
--
-- LEAD() is used to identify the next start date for the
-- same product and set the previous record's end date to
-- one day before that next start date.
-- ============================================================

CREATE OR ALTER PROCEDURE [silver].[load_crm_prd_info]
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear existing Silver data before reloading.
    TRUNCATE TABLE silver.crm_prd_info;

    -- Insert transformed product data.
    INSERT INTO silver.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,

        -- Extract category ID and replace '-' with '_'.
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

        -- Extract the product key.
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,

        prd_nm,

        -- Replace NULL product costs with 0.
        ISNULL(prd_cost, 0) AS prd_cost,

        -- Convert product line codes into descriptive values.
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        -- Convert the product start date to DATE.
        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        -- Determine the end date based on the next start date.
        CAST(
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ) - 1 AS DATE
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;

END;
GO


-- ============================================================
-- 3. CRM SALES DETAILS
-- ============================================================
-- Procedure:
-- silver.load_crm_sales_details
--
-- Purpose:
-- Loads cleaned and validated sales transaction data from
-- the Bronze CRM sales table.
--
-- Transformations:
-- - Validates and converts order, shipping, and due dates.
-- - Recalculates incorrect or missing sales values.
-- - Validates and recalculates incorrect or missing prices.
-- - Prevents division by zero when calculating prices.
-- ============================================================

CREATE OR ALTER PROCEDURE [silver].[load_crm_sales_details]
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear existing Silver data before reloading.
    TRUNCATE TABLE silver.crm_sales_details;

    -- Insert cleaned sales transaction data.
    INSERT INTO silver.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        -- Validate and convert order date.
        CASE
            WHEN sls_order_dt = 0
                OR LEN(sls_order_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR(8)) AS DATE)
        END AS sls_order_dt,

        -- Validate and convert shipping date.
        CASE
            WHEN sls_ship_dt = 0
                OR LEN(sls_ship_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR(8)) AS DATE)
        END AS sls_ship_dt,

        -- Validate and convert due date.
        CASE
            WHEN sls_due_dt = 0
                OR LEN(sls_due_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR(8)) AS DATE)
        END AS sls_due_dt,

        -- Recalculate sales when the value is missing,
        -- invalid, or does not match quantity × price.
        CASE
            WHEN sls_sales IS NULL
                OR sls_sales <= 0
                OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        -- Recalculate price when it is missing or invalid.
        -- NULLIF prevents division by zero.
        CASE
            WHEN sls_price IS NULL
                OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price

    FROM bronze.crm_sales_details;

END;
GO


-- ============================================================
-- 4. ERP CUSTOMER INFORMATION
-- ============================================================
-- Procedure:
-- silver.load_erp_cust_az12
--
-- Purpose:
-- Loads cleaned customer demographic information from the
-- Bronze ERP customer table.
--
-- Transformations:
-- - Removes the 'NAS' prefix from customer IDs when present.
-- - Validates customer birth dates.
-- - Converts invalid dates to NULL.
-- - Standardizes gender values.
-- - Replaces unknown gender values with 'n/a'.
-- ============================================================

CREATE OR ALTER PROCEDURE [silver].[load_erp_cust_az12]
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear existing Silver data before reloading.
    TRUNCATE TABLE silver.erp_cust_az12;

    -- Insert cleaned ERP customer data.
    INSERT INTO silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )
    SELECT

        -- Remove the 'NAS' prefix when present.
        CASE
            WHEN cid LIKE 'NAS%'
                THEN SUBSTRING(cid, 4, LEN(cid))
            ELSE cid
        END AS cid,

        -- Validate birth date.
        -- Future dates and dates before 1924 are treated as invalid.
        CASE
            WHEN bdate > GETDATE()
                OR bdate < '1924-01-01'
            THEN NULL
            ELSE bdate
        END AS bdate,

        -- Standardize gender values.
        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                THEN 'Male'
            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;

END;
GO


-- ============================================================
-- 5. ERP CUSTOMER LOCATION
-- ============================================================
-- Procedure:
-- silver.load_erp_loc_a101
--
-- Purpose:
-- Loads standardized customer location data from the
-- Bronze ERP location table.
--
-- Transformations:
-- - Removes '-' characters from customer IDs.
-- - Converts country codes into full country names.
-- - Replaces NULL or empty country values with 'n/a'.
-- - Trims unnecessary spaces.
-- ============================================================

CREATE OR ALTER PROCEDURE [silver].[load_erp_loc_a101]
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear existing Silver data before reloading.
    TRUNCATE TABLE silver.erp_loc_a101;

    -- Insert standardized location data.
    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )
    SELECT

        -- Remove '-' characters from customer IDs.
        REPLACE(cid, '-', '') AS cid,

        -- Standardize country values.
        CASE
            WHEN TRIM(cntry) = 'DE'
                THEN 'Germany'
            WHEN TRIM(cntry) IN ('USA', 'US')
                THEN 'United States'
            WHEN TRIM(cntry) = ''
                OR cntry IS NULL
                THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry

    FROM bronze.erp_loc_a101;

END;
GO


-- ============================================================
-- 6. ERP PRODUCT CATEGORY
-- ============================================================
-- Procedure:
-- silver.load_erp_px_cat_g1v2
--
-- Purpose:
-- Loads ERP product category information into the Silver Layer.
--
-- This source already contains standardized category,
-- subcategory, and maintenance values, so no major
-- transformations are required.
-- ============================================================

CREATE OR ALTER PROCEDURE [silver].[load_erp_px_cat_g1v2]
AS
BEGIN
    SET NOCOUNT ON;

    -- Clear existing Silver data before reloading.
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    -- Insert product category data.
    INSERT INTO silver.erp_px_cat_g1v2
    (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance

    FROM bronze.erp_px_cat_g1v2;

END;
GO
