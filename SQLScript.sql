----------------------------------------------------------------------------------------------
-- Median of a column 
SELECT ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (colname)),4) AS Median
FROM table_name
;
----------------------------------------------------------------------------------------------
-- Assign Row Number 
SELECT ROW_NUMBER() OVER (ORDER BY colname) AS ROW_NUM
FROM table_name
;
----------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------
-- 3-day Rolling average 
SELECT user_id, tweet_date
, ROUND(AVG(tweet_count) OVER (
        PARTITION BY user_id 
        ORDER BY tweet_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) ,2) rolling_avg_3rd
FROM tweets
;
----------------------------------------------------------------------------------------------
-- Top 3 high salaries per department
WITH CTE AS
(
SELECT 
  department_name
  ,name
  ,salary
  , DENSE_RANK() 
      OVER (
            PARTITION BY dpt.department_id 
            ORDER BY salary desc
            ) ranked
FROM employee emp
INNER JOIN department dpt
  on emp.department_id = dpt.department_id
)
SELECT 
  department_name
  ,name
  ,salary
FROM CTE
WHERE ranked in (1,2,3)
order by department_name asc, salary desc, name asc
;
----------------------------------------------------------------------------------------------
