--fact table
CREATE TABLE order_fact(
	contract_id varchar(50),
	order_date datetime,
	customer_id varchar(50),
	product_code varchar(50),
	iso_state_code varchar(50),
	sales_amount real,
	sales_amount_target real,
	sales_margin real,
	sales_margin_target real
);

INSERT INTO
	order_fact
SELECT
	contract_id,
	order_date,
	customer_id,
	product_code,
	iso_state_code,
	sales_amount,
	sales_amount_target,
	sales_margin,
	sales_margin_target
FROM
	sales_samp;

--dim customer
CREATE TABLE sales_customer(
	customer_id varchar(50),
	customer_name varchar(50)
);

INSERT INTO
	sales_customer
SELECT
	DISTINCT Customer_ID,
	Customer
FROM
	sales_samp;

--dim product
CREATE TABLE sales_product(
	product_code varchar(50),
	product_name varchar(50),
	product_group varchar(50),
	product_sub_group varchar(50)
);

INSERT INTO
	sales_product
SELECT
	DISTINCT Product_Code,
	Product_Name,
	Product_Group,
	Product_Sub_Group
FROM
	sales_samp;

--dim state
CREATE TABLE sales_state(
	iso_state_code varchar(50),
	state varchar(50),
	region varchar(50)
);

INSERT INTO
	sales_state
SELECT
	DISTINCT ISO_State_Code,
	State,
	Region
FROM
	sales_samp;
