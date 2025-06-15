/*
ORDER OF EXECUTION
- FROM (including JOIN) 
– WHERE 
– GROUP BY 
– HAVING 
– Window Functions 
– SELECT 
– DISTINCT 
– ORDER BY 
– LIMIT / FETCH / OFFSET
*/
----------------------------------------------------------------------------------------------
-- Median of a column  -- Version 1
SELECT ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (colname)),4) AS Median
FROM table_name
;

/*
1. PERCENTILE_CONT(p): for a fraction p, returns the continuous percentile at that fraction of your data
2. WITHIN GROUP (ORDER BY col_name) FROM TABLE:  
        - tells the engine to first order all the values in 'col_name' from table.
        - then apply the percentile logic to that ordered list
*/
----------------------------------------------------------------------------------------------
-- Median for searches if the table looks the following  -- Version 2
/*
| searches | num_users |
| :------: | :--------: |
|     1    |      2     |
|     2    |      2     |
|     3    |      3     |
|     4    |      1     |
*/
-- First explode each row to get the ordered list and then use PERCENTILE_CONT()
-- Solution:
WITH EXPLODED AS
(
SELECT searches
FROM search_frequency
GROUP BY searches, generate_series(1, num_users)
)
SELECT PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY searches)
FROM EXPLODED
;

/*
Understanding the generate_series() and CTE above:
GENERATE_SERIES(START, STOP, STEP): Works like the range() in python
*/
-- Let's call the below EQ: Explosion Query
SELECT 
  searches,
  num_users,
  generate_series(1, num_users) AS gs
FROM search_frequency;

/*
The query above created a column gs along side the OG table. 
For each row in OG table, generate_series(1, num_users), duplicates the corresponding 'searches' value with a frequency of 'num_users'.
Almost like doing a lateral join. 

This OG table: 
| searches | num_users |
| :------: | :--------: |
|     1    |      2     | -- Let's look at this row alone. In our exploded list, 1 should have the frequency of 2. Hence, gs(1, num_users)
|     2    |      2     |
|     3    |      3     |
|     4    |      1     |

Now looks like:

| searches | num_users |  gs |
| :------: | :--------: | :-: |
|     1    |      2     |  1  | - gs(1, num_users) = [1, 2], appended to first row ...
|     1    |      2     |  2  | - ...twice, making freq(1) in searches 2. 
|     2    |      2     |  1  |
|     2    |      2     |  2  |
|     3    |      3     |  1  |
|     3    |      3     |  2  |
|     3    |      3     |  3  |
|     4    |      1     |  1  |

All we need is to retain this 'searches' column. Either use the EQ mentioned above in a subquery to get what we need, 
OR group by (searches, gs) and SELECT searches. 

Why this works: gs is distinct for each repeating 'search' value
*/

-- optimised EQ
SELECT searches
FROM search_frequency
GROUP BY searches, generate_series(1, num_users)
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
-- Top 3 high salaries per department -- multiple order by
WITH CTE AS
(
SELECT 
  department_name
  ,name
  ,salary
  , DENSE_RANK() 
      OVER (
            PARTITION BY dpt.department_id 
            ORDER BY salary DESC
            ) ranked
FROM employee emp
INNER JOIN department dpt
  ON emp.department_id = dpt.department_id
)
SELECT 
  department_name
  ,name
  ,salary
FROM CTE
WHERE ranked IN (1,2,3)
ORDER BY department_name ASC, salary DESC, name ASC
;
----------------------------------------------------------------------------------------------
-- Aggregate function, Subquery in Having
SELECT customer_id
FROM customer_contracts c
JOIN products p
ON   c.product_id = p.product_id
GROUP BY customer_id
HAVING COUNT(DISTINCT product_category) IN 
          (SELECT COUNT(DISTINCT product_category) 
                FROM products
                )
;
----------------------------------------------------------------------------------------------
-- Add odd rows and even rows for each date; date type cast
WITH CTE AS
(SELECT 
  DATE(measurement_time) as date_
  , measurement_value
  , ROW_NUMBER() OVER (
      PARTITION BY DATE(measurement_time) 
      ORDER BY measurement_time
      )
FROM measurements
)
SELECT 
  date_
  ,SUM(CASE WHEN row_number%2<>0 THEN measurement_value ELSE 0 END) odd_sum
  ,SUM(CASE WHEN row_number%2=0 THEN measurement_value ELSE 0 END) even_sum
FROM CTE
GROUP BY date_
;
----------------------------------------------------------------------------------------------
-- Swap odd rows with even rows except the last row if it is odd
WITH CTE AS
(
SELECT COUNT(DISTINCT order_id) total FROM orders 
)
SELECT 
  CASE  WHEN order_id % 2 <> 0 THEN
          CASE  WHEN order_id = total THEN order_id
                ELSE order_id + 1
                END
        WHEN order_id % 2 = 0 THEN order_id-1
        END AS corrected_order_id
  ,item
FROM orders 
CROSS JOIN CTE
ORDER BY corrected_order_id
;
----------------------------------------------------------------------------------------------
-- COALESCE(column A, column B) = Takes value from the column that is not null
SELECT 
  COALESCE(ad.user_id, dp.user_id) user_id
  , CASE 
    WHEN dp.user_id IS NULL THEN 'CHURN'
    WHEN dp.user_id IS NOT NULL AND ad.status = 'CHURN' THEN 'RESURRECT'
    WHEN dp.user_id IS NOT NULL AND ad.status != 'CHURN' THEN 'EXISTING'
    WHEN ad.user_id IS NULL AND dp.user_id IS NOT NULL THEN 'NEW'
    END new_status
FROM advertiser ad 
FULL JOIN daily_pay dp 
ON ad.user_id = dp.user_id 
ORDER BY COALESCE(ad.user_id, dp.user_id)
;













