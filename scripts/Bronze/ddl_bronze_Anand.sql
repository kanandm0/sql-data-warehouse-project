
IF OBJECT_ID ('[bronze].[crm_cust_info]', 'U') IS NOT NULL
DROP TABLE bronze.crm_cust_info;
CREATE TABLE [bronze].[crm_cust_info](
	[cst_id] [int] NULL,
	[cst_key] [nvarchar](50) NULL,
	[cst_firstname] [nvarchar](50) NULL,
	[cst_lastname] [nvarchar](50) NULL,
	[cst_material_status] [nvarchar](50) NULL,
	[cst_gndr] [nvarchar](50) NULL,
	[cst_create_date] [date] NULL
) ;

-- CREATE CRM Product info table
IF OBJECT_ID ('[bronze].[crm_prd_info]', 'U') IS NOT NULL
DROP TABLE bronze.crm_prd_info;
CREATE TABLE [bronze].[crm_prd_info](
	[prd_id] [int] NULL,
	[prd_key] [nvarchar](50) NULL,
	[prd_nm] [nvarchar](50) NULL,
	[prd_cost] [decimal](10, 2) NULL,
	[prd_line] [nvarchar](50) NULL,
	[prd_start_dt] [date] NULL,
	[prd_end_dt] [date] NULL
);

-- CREATE CRM sales details table
IF OBJECT_ID ('[bronze].[crm_sales_details]', 'U') IS NOT NULL
DROP TABLE bronze.crm_sales_details;

CREATE TABLE [bronze].[crm_sales_details](
	[sls_ord_num] [nvarchar](50) NULL,
	[sls_prd_key] [nvarchar](50) NULL,
	[sls_cust_id] [int] NULL,
	[sls_order_dt] [nvarchar](50) NULL,
	[sls_ship_dt] [date] NULL,
	[sls_due_dt] [date] NULL,
	[sls_sales] [int] NULL,
	[sls_quantity] [int] NULL,
	[sls_price] [decimal](10, 2) NULL
) ;

-- CREATE ERP Customer details table
IF OBJECT_ID ('[bronze].[erp_cust_az12]', 'U') IS NOT NULL
DROP TABLE bronze.erp_cust_az12;

CREATE TABLE [bronze].[erp_cust_az12](
	[CID] [nvarchar](50) NULL,
	[bdate] [date] NULL,
	[gen] [varchar](10) NULL
);

-- CREATE ERP location details table
IF OBJECT_ID ('[bronze].[erp_loc_A101]', 'U') IS NOT NULL
DROP TABLE bronze.erp_loc_A101;

CREATE TABLE [bronze].[erp_loc_A101](
	[CID] [nvarchar](50) NULL,
	[CNTRY] [nvarchar](50) NULL,
);


-- CREATE ERP categories details table
IF OBJECT_ID ('[bronze].[erp_px_cat_g1v2]', 'U') IS NOT NULL
DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE [bronze].[erp_px_cat_g1v2](
	[ID] [nvarchar](50) NULL,
	[CAT] [nvarchar](50) NULL,
	[SUBCAT] [varchar](50) NULL,
	[MAINTENANCE] [varchar] (50) NULL
);

-- Creating stored procedures for data loading into the tables since it's a recurring activity

CREATE or ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	-- Insert data into the customer info table through bulk insert
	TRUNCATE TABLE bronze.crm_cust_info;

	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\kanan\OneDrive\01_Projects\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);


	-- Insert data into the product info info table through bulk insert
	TRUNCATE TABLE bronze.crm_prd_info;

	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\kanan\OneDrive\01_Projects\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);


	-- Insert data into the sales details table through bulk insert
	TRUNCATE TABLE bronze.crm_sales_details;

	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\kanan\OneDrive\01_Projects\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	-- Insert data into the ERP customer table through bulk insert
	TRUNCATE TABLE bronze.erp_cust_az12;

	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\kanan\OneDrive\01_Projects\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);


	-- Insert data into the ERP location table through bulk insert
	TRUNCATE TABLE bronze.erp_loc_A101;

	BULK INSERT bronze.erp_loc_A101
	FROM 'C:\Users\kanan\OneDrive\01_Projects\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	-- Insert data into the ERP categories table through bulk insert
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;

	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\kanan\OneDrive\01_Projects\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
END