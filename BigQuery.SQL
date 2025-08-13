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
SELECT * 
FROM t
QUALIFY ROW_NUMBER() OVER(PARTITION BY business_key ORDER BY updated_at DESC) = 1
;
----------------------------------------------------------------------------------------------------------------------------------

