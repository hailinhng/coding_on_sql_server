--1.Get a list of customers (not in Central) with total sales amount > 350000
SELECT
	fact.customer_id,
	sc.customer_name,
	SUM(fact.sales_amount) as total_sales_amount
FROM
	order_fact as fact
	LEFT JOIN sales_state as ss ON fact.iso_state_code = ss.iso_state_code
	LEFT JOIN sales_customer as sc ON fact.customer_id = sc.customer_id
WHERE
	ss.region != 'Central'
GROUP BY
	fact.customer_id,
	sc.customer_name
HAVING
	SUM(fact.sales_amount) > 350000
ORDER BY
	SUM(fact.sales_amount) DESC 

--2.Get a list of customers whose total sales amount is between 10000 and 20000 in May or June 2020
SELECT
	fact.customer_id,
	sc.customer_name,
	SUM(fact.sales_amount) as total_sales_amount
FROM
	order_fact as fact
	LEFT JOIN sales_customer as sc ON fact.customer_id = sc.customer_id
WHERE
	MONTH(fact.order_date) IN (5, 6)
	AND YEAR(fact.order_date) = 2020
GROUP BY
	fact.customer_id,
	sc.customer_name
HAVING
	SUM(fact.sales_amount) BETWEEN 10000
	AND 20000 
	
--3.Get the number of customers with total sales amount exceeds the target in 2019
SELECT
	COUNT (DISTINCT customer_id)
FROM
	(
		SELECT
			customer_id
		FROM
			order_fact
		WHERE
			YEAR(order_date) = 2019
		GROUP BY
			customer_id,
			YEAR(order_date)
		HAVING
			SUM(sales_amount) > SUM(sales_amount_target)
	) as tabl 
	
--4.Get contract id, customer name, product name, total sales amount, total sales margin of products in technology group and in December 2020
SELECT
	fact.contract_id,
	sc.customer_name,
	sp.product_name,
	sp.product_sub_group,
	SUM(sales_amount) OVER(
		PARTITION BY fact.customer_id,
		YEAR(order_date),
		MONTH(order_date)
	) as total_sales_amount,
	SUM(sales_margin) OVER(
		PARTITION BY fact.customer_id,
		YEAR(order_date),
		MONTH(order_date)
	) as total_sales_margin
FROM
	order_fact fact
	LEFT JOIN sales_customer sc ON fact.customer_id = sc.customer_id
	LEFT JOIN sales_product sp ON fact.product_code = sp.product_code
WHERE
	sp.product_group = 'Technology'
	AND YEAR(order_date) = 2020
	AND MONTH(order_date) = 12 

--5.Get top 5 products have the highest average sales amount on each state
SELECT
	sp.product_name,
	ss.state,
	bb.avg_sales_amount
FROM
	(
		SELECT
			product_code,
			AVG(sales_amount) as avg_sales_amount,
			iso_state_code,
			DENSE_RANK() OVER(
				PARTITION BY iso_state_code
				ORDER BY
					AVG(sales_amount) DESC
			) as dr_avg
		FROM
			order_fact
		GROUP BY
			product_code,
			iso_state_code
	) as bb
	LEFT JOIN sales_product sp ON bb.product_code = sp.product_code
	LEFT JOIN sales_state ss ON bb.iso_state_code = ss.iso_state_code
WHERE
	bb.dr_avg <= 5 

--6.Get contract id, customer name and contract evaluation in the first quarter in 2019. Where: sales_amount >= sales_amount_target: rating 'pass'; the rest: rating 'fail'
SELECT
	contract_id,
	sc.customer_name,
	sales_amount,
	sales_amount_target,
	CASE
		WHEN sales_amount >= sales_amount_target THEN 'pass'
		ELSE 'fail'
	END AS evaluation
FROM
	order_fact fact
	LEFT JOIN sales_customer sc ON fact.customer_id = sc.customer_id
WHERE
	YEAR(order_date) = 2019
	AND MONTH(order_date) IN (1, 2, 3)
