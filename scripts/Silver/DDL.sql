USE [DataWareHouse]
GO

-- ============================================================
-- SILVER LAYER - DATABASE SCHEMA
-- ============================================================
-- Purpose:
-- The Silver Layer stores cleaned, standardized, and transformed
-- data from the Bronze Layer.
--
-- The tables below contain data after applying data cleaning,
-- standardization, validation, and transformation rules.
-- This layer prepares the data for further analysis and the
-- Gold Layer.
-- ============================================================


-- ============================================================
-- Create Silver Schema
-- ============================================================
-- The Silver schema is used to organize all cleaned and
-- transformed tables separately from the Bronze and Gold layers.
-- ============================================================

CREATE SCHEMA [silver]
GO


-- ============================================================
-- CRM Customer Information
-- ============================================================
-- Purpose:
-- Stores cleaned and standardized customer information
-- originating from the CRM source.
--
-- Transformations applied before loading this table include:
-- - Removing unnecessary spaces from names.
-- - Standardizing marital status.
-- - Standardizing gender values.
-- - Removing duplicate customer records.
-- ============================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [silver].[crm_cust_info](
	[cst_id] [int] NULL,
	[cst_key] [nvarchar](50) NULL,
	[cst_firstname] [nvarchar](50) NULL,
	[cst_lastname] [nvarchar](50) NULL,
	[cst_material_status] [nvarchar](50) NULL,
	[cst_gndr] [nvarchar](50) NULL,
	[cst_creat_date] [date] NULL,
	[dwh_create_date] [datetime2](7) NULL
) ON [PRIMARY]
GO


-- ============================================================
-- CRM Product Information
-- ============================================================
-- Purpose:
-- Stores cleaned and standardized product information
-- originating from the CRM source.
--
-- Transformations applied before loading this table include:
-- - Standardizing the category ID.
-- - Cleaning the product key.
-- - Replacing NULL product costs with 0.
-- - Standardizing product line values.
-- - Creating product end dates based on the next product
--   start date.
-- ============================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [silver].[crm_prd_info](
	[prd_id] [int] NULL,
	[cat_id] [nvarchar](50) NULL,
	[prd_key] [nvarchar](50) NULL,
	[prd_nm] [nvarchar](50) NULL,
	[prd_cost] [int] NULL,
	[prd_line] [nvarchar](50) NULL,
	[prd_start_dt] [date] NULL,
	[prd_end_dt] [date] NULL,
	[dwh_create_date] [datetime] NULL
) ON [PRIMARY]
GO


-- ============================================================
-- CRM Sales Details
-- ============================================================
-- Purpose:
-- Stores cleaned and standardized sales transaction data
-- originating from the CRM source.
--
-- The table contains order, product, customer, date,
-- sales, quantity, and price information.
--
-- Date and numeric values are validated and standardized
-- before being loaded into the Silver Layer.
-- ============================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [silver].[crm_sales_details](
	[sls_ord_num] [nvarchar](50) NULL,
	[sls_prd_key] [nvarchar](50) NULL,
	[sls_cust_id] [int] NULL,
	[sls_order_dt] [date] NULL,
	[sls_ship_dt] [date] NULL,
	[sls_due_dt] [date] NULL,
	[sls_sales] [int] NULL,
	[sls_quantity] [int] NULL,
	[sls_price] [int] NULL,
	[dwh_create_date] [datetime2](7) NULL
) ON [PRIMARY]
GO


-- ============================================================
-- ERP Customer Information
-- ============================================================
-- Purpose:
-- Stores cleaned customer demographic information
-- originating from the ERP system.
--
-- The table contains customer ID, birth date, and gender
-- information after standardization and validation.
-- ============================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [silver].[erp_cust_az12](
	[cid] [nvarchar](50) NULL,
	[bdate] [date] NULL,
	[gen] [nvarchar](50) NULL,
	[dwh_create_date] [datetime2](7) NULL
) ON [PRIMARY]
GO


-- ============================================================
-- ERP Customer Location
-- ============================================================
-- Purpose:
-- Stores standardized customer location information
-- originating from the ERP system.
--
-- The table contains customer IDs and their associated
-- country information.
-- ============================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [silver].[erp_loc_a101](
	[cid] [nvarchar](50) NULL,
	[cntry] [nvarchar](50) NULL,
	[dwh_create_date] [datetime2](7) NULL
) ON [PRIMARY]
GO


-- ============================================================
-- ERP Product Category Information
-- ============================================================
-- Purpose:
-- Stores standardized product category information
-- originating from the ERP system.
--
-- The table contains product/category IDs, categories,
-- subcategories, and maintenance information.
-- ============================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [silver].[erp_px_cat_g1v2](
	[id] [nvarchar](50) NULL,
	[cat] [nvarchar](50) NULL,
	[subcat] [nvarchar](50) NULL,
	[maintenance] [nvarchar](50) NULL,
	[dwh_create_date] [datetime2](7) NULL
) ON [PRIMARY]
GO


-- ============================================================
-- Data Warehouse Load Timestamp
-- ============================================================
-- Purpose:
-- Automatically records the date and time when a record
-- is inserted into each Silver Layer table.
--
-- GETDATE() is used as the default value, so the timestamp
-- does not need to be manually provided during INSERT operations.
-- ============================================================

ALTER TABLE [silver].[crm_cust_info]
ADD DEFAULT (getdate()) FOR [dwh_create_date]
GO

ALTER TABLE [silver].[crm_prd_info]
ADD DEFAULT (getdate()) FOR [dwh_create_date]
GO

ALTER TABLE [silver].[crm_sales_details]
ADD DEFAULT (getdate()) FOR [dwh_create_date]
GO

ALTER TABLE [silver].[erp_cust_az12]
ADD DEFAULT (getdate()) FOR [dwh_create_date]
GO

ALTER TABLE [silver].[erp_loc_a101]
ADD DEFAULT (getdate()) FOR [dwh_create_date]
GO

ALTER TABLE [silver].[erp_px_cat_g1v2]
ADD DEFAULT (getdate()) FOR [dwh_create_date]
GO
