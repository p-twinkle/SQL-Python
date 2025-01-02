
-- Find Median of a column
SELECT ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (colname)),4) AS Median
FROM table_name;

-- Assign Row Number
SELECT ROW_NUMBER() OVER (ORDER BY colname) AS ROW_NUM
FROM table_name;

-- SQL(Int)
SELECT c.city_name, prod.product_name
, ROUND(CAST(SUM(line_total_price) AS FLOAT),2)
FROM city c
INNER JOIN customer cust ON c.id = cust.city_id
INNER JOIN invoice inv ON inv.customer_id = cust.id
INNER JOIN invoice_item itm ON inv.id = itm.invoice_id
INNER JOIN product prod ON prod.id = itm.product_id
GROUP BY c.city_name, prod.product_name
ORDER BY SUM(line_total_price) DESC
;
