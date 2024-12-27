
-- Find Median of a column
SELECT ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (colname)),4) AS Median
FROM table_name;

-- Assign Row Number
SELECT ROW_NUMBER() OVER (ORDER BY colname) AS ROW_NUM
FROM table_name;

