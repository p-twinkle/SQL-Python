-- Deduplicate, keep latest by timestamp

SELECT * EXCEPT(rn)
FROM (
  SELECT t.*, ROW_NUMBER() OVER (
          PARTITION BY business_key ORDER BY updated_at DESC
       ) rn
  FROM t
)
WHERE rn = 1
;

-- BigQuery
/*
This is BigQuery-specific syntax (also in Snowflake) that filters after window functions are computed.
It’s like putting the window function in a WHERE clause, except WHERE can’t directly use window functions.
*/
SELECT * 
FROM t
QUALIFY ROW_NUMBER() OVER(PARTITION BY business_key ORDER BY updated_at DESC) = 1
;

----------------------------------------------------------------------------------------------------------------------------------

