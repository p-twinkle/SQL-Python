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
-- UNNEST() more like Explode
/*

id   | items
-----+--------------------------------
101  | [ {sku: 'A1'}, {sku: 'B2'} ]
102  | [ {sku: 'C3'} ]
103  | [ {sku: 'D4'}, {sku: 'E5'}, {sku: 'F6'} ]

OP: 
id   | i
-----+-------------
101  | {sku: 'A1'}
101  | {sku: 'B2'}
102  | {sku: 'C3'}
103  | {sku: 'D4'}
103  | {sku: 'E5'}
103  | {sku: 'F6'}

Do i.sku to get 'A1', etc.
*/

SELECT o.id, i.sku
FROM orders o, UNNEST(o.items) AS i
;
----------------------------------------------------------------------------------------------------------------------------------

