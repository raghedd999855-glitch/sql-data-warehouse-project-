USE [DataWareHouse]
GO

/*
=========================================================
Stored Procedure: bronze.load_bronze
=========================================================

Script Purpose:
    This stored procedure loads raw data from the CRM and
    ERP source files into the Bronze layer tables.

    The procedure:
    - Truncates existing Bronze tables before loading new data.
    - Loads CRM and ERP CSV files using BULK INSERT.
    - Tracks the loading duration for each table.
    - Tracks the total Bronze layer loading duration.
    - Handles errors using TRY...CATCH.

Usage:
    EXEC bronze.load_bronze;

=========================================================
*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- EXEC bronze.load_bronze

ALTER PROCEDURE [bronze].[load_bronze]
AS
BEGIN

    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '=================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=================================================';


        -- =================================================
        -- Loading CRM Tables
        -- =================================================

        PRINT '-------------------------------------------------';
        PRINT 'Loading CRM TABLES';
        PRINT '-------------------------------------------------';

        -- CRM: Customer Information
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\lenovo\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration : ' 
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
            + ' seconds';


        -- CRM: Product Information
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\lenovo\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration : ' 
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
            + ' seconds';


        -- CRM: Sales Details
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\lenovo\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration : ' 
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
            + ' seconds';


        -- =================================================
        -- Loading ERP Tables
        -- =================================================

        PRINT '-------------------------------------------------';
        PRINT 'Loading ERP TABLES';
        PRINT '-------------------------------------------------';

        -- ERP: Customer Information
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\lenovo\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration : ' 
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
            + ' seconds';


        -- ERP: Location Information
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\lenovo\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration : ' 
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
            + ' seconds';


        -- ERP: Product Category Information
        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\lenovo\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration : ' 
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
            + ' seconds';


        -- =================================================
        -- Total Load Duration
        -- =================================================

        SET @batch_end_time = GETDATE();

        PRINT '>> Total Load Duration : ' 
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) 
            + ' seconds';


    END TRY

    BEGIN CATCH

        -- =================================================
        -- Error Handling
        -- =================================================

        PRINT '=================================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error message' + ERROR_MESSAGE();
        PRINT 'Error message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=================================================';

    END CATCH

END
GO
