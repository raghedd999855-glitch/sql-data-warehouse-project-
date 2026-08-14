/*
=========================================================
DDL Script: Create Bronze Tables
=========================================================

Script Purpose:
    This script creates the tables in the 'bronze' schema
    to store raw data loaded from the CRM and ERP source files.

    The script defines the structure of the Bronze layer,
    including the required columns and their data types.

Notes:
    - This script is used to create the Bronze layer tables.
    - Data is loaded into these tables using the load_bronze procedure.
    - Existing tables are not dropped by this script.

=========================================================
*/
USE DataWareHouse;
GO

-- =========================================================
-- Create Bronze Tables
-- =========================================================

-- =========================================================
-- CRM: Customer Information
-- =========================================================
CREATE TABLE bronze.crm_cust_info (
    cst_id               INT,
    cst_key              NVARCHAR(50),
    cst_firstname        NVARCHAR(50),
    cst_lastname         NVARCHAR(50),
    cst_material_status  NVARCHAR(50),
    cst_gndr              NVARCHAR(50),
    cst_creat_date       DATE
);
GO

-- =========================================================
-- CRM: Product Information
-- =========================================================
CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);
GO

-- =========================================================
-- CRM: Sales Details
-- =========================================================
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO

-- =========================================================
-- ERP: Customer Information
-- =========================================================
CREATE TABLE bronze.erp_cust_az12 (
    cid   NVARCHAR(50),
    bdate DATE,
    gen   NVARCHAR(50)
);
GO

-- =========================================================
-- ERP: Location Information
-- =========================================================
CREATE TABLE bronze.erp_loc_a101 (
    cid   NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO

-- =========================================================
-- ERP: Product Category Information
-- =========================================================
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO
