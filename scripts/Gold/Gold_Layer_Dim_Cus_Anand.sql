-- If a dimension table doesn't contain a primary key, then you can create one in SQL itself which called as surrogate key
-- Surrogate key - System generated unique identifier that is assigned to each record
-- Windows function ROW NUMBER helps creating a surrogate key
-- Good practice - Gold layer is always a virtual one

CREATE VIEW gold.dim_customers AS
	SELECT 
		ROW_NUMBER () OVER (ORDER BY cst_id) AS customer_key,
		ci.cst_id as customer_id, --For a dimension table, the primary key is important
		ci.cst_key as customer_number,
		ci.cst_firstname as first_name,
		ci.cst_lastname as last_name,
		la.CNTRY as country,
		ci.cst_material_status AS marital_status,
		CASE
			WHEN ci.cst_gndr IS NOT NULL AND ci.cst_gndr != 'N/A' THEN ci.cst_gndr -- CRM is the master table for gender info
			ELSE COALESCE(
						   CASE WHEN ca.gen = 'n/a' THEN 'N/A' ELSE ca.gen END, -- Replaced 'if' with CASE
						   'N/A'
						  )
		END AS gender,
		ca.bdate as birth_date,
		ci.cst_create_date as create_date
	
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.CID
	LEFT JOIN silver.erp_loc_A101 la
	ON ci.cst_key = la.CID

