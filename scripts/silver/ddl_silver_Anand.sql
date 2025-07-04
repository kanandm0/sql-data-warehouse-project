CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	TRUNCATE TABLE silver.crm_cust_info;
	INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			cst_gndr,
			cst_create_date)
	--Remove duplicates from the primary key - cst_id
	SELECT 
		cst_id,
		cst_key,
		TRIM (cst_firstname) AS cst_firstname,
		TRIM (cst_lastname) AS cst_lastname,
	--Data normalization to be done for marital status and gndr which is giving a complete description
		CASE TRIM(UPPER(cst_material_status))
			WHEN 'M' THEN 'MARRIED'
			WHEN 'S' THEN 'SINGLE'
		END
		AS marital_status,
		CASE TRIM(UPPER(cst_gndr))
			WHEN 'M' THEN 'MALE'
			WHEN 'F' THEN 'FEMALE'
			ELSE 'N/A'
		END AS
		cst_gndr,
		cst_create_date
	FROM (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_latest
	FROM bronze.crm_cust_info
	) t -- Application of sub query 
	WHERE flag_latest = 1; --(!= 1 gives the list of IDs that contains duplicates)

	--Remove unwanted spaces from the first name and last name using TRIM function

	--Cleaning and loading product info table into Silver layer
	TRUNCATE TABLE silver.crm_prd_info;
	INSERT INTO silver.crm_prd_info (
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
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) AS prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'MOUNTAIN'
			WHEN 'R' THEN 'ROAD'
			WHEN 'S' THEN 'OTHER SALES'
			WHEN 'T' THEN 'TOURING'
			ELSE 'n/a'
		END AS
		prd_line,
		CAST (prd_start_dt AS DATE) AS prd_start_dt,
	CAST (LEAD(CONVERT(DATE,prd_start_dt)) OVER(PARTITION BY prd_key ORDER BY CONVERT(DATE,prd_start_dt)) AS DATE) AS prd_end_dt
	 FROM bronze.crm_prd_info;

	 --Cleaning and loading the sales details table from Bronze to silver
	 TRUNCATE TABLE silver.crm_sales_details;
	 INSERT INTO silver.crm_sales_details (
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
	 SELECT sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN
				sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
				END sls_order_dt,
			CASE WHEN
				sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
				END sls_ship_dt,
			CASE WHEN
				sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
				END sls_due_dt,
			CASE WHEN
				sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity
				THEN (ABS(sls_price)*sls_quantity)
				ELSE sls_sales
			END sls_sales,
			sls_quantity,
			CASE WHEN 
				sls_price IS NULL OR sls_price <= 0 THEN
				sls_sales / NULLIF(sls_quantity,0) 
				ELSE sls_price
			END sls_price
	FROM bronze.crm_sales_details;
	-- To check the data quality, pulled all the data from silver layer
	SELECT * FROM silver.crm_sales_details

	-- Cleaning and loading the customer AZ12 data into the silver layer
	TRUNCATE TABLE silver.erp_cust_az12
	INSERT INTO silver.erp_cust_az12 (
			CID,
			bdate,
			gen
			)
	SELECT 
			CASE WHEN
				CID LIKE 'NAS%' THEN SUBSTRING(CID,4, LEN(CID))
				ELSE CID
			END AS
			CID,
			CASE WHEN 
				bdate > GETDATE() THEN NULL
			ELSE bdate
			END AS
			bdate,
			CASE WHEN
			UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'FEMALE'
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'MALE'
			ELSE 'n/a'
			END AS
			gen
	FROM bronze.erp_cust_az12
	-- To check the data quality in silver layer, pulled in all the data
	SELECT DISTINCT gen FROM silver.erp_cust_az12

	-- Clean, transform and loading the location data from ERP bronze layer to silver layer
	TRUNCATE TABLE silver.erp_loc_A101;
	INSERT INTO silver.erp_loc_A101 (
			CID,
			CNTRY
			)
	SELECT 
			REPLACE(CID, '-', '') as CID,
			CASE 
				WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
				WHEN CNTRY = '' THEN 'n/a'
				WHEN CNTRY = 'NULL' THEN 'n/a'
			ELSE CNTRY
			END CNTRY
	FROM bronze.erp_loc_A101


	-- Clean, transform and loading the product category data from ERP bronze layer to silver layer
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	INSERT INTO silver.erp_px_cat_g1v2 (
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
			)

	SELECT ID,
			CAT,
			SUBCAT,
			MAINTENANCE
	FROM bronze.erp_px_cat_g1v2;
END