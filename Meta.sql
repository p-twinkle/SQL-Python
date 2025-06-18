-- SQL concepts for Interview Prep, questions and concepts sourced from Leetcode, Data Lemur & StrataScratch

-------------------------------------------------------------------------------------------------------------------
-- 1. 
    -- Return the total number of posts made on each calendar day of the month, aggregated across all months and years (ignoring user and year).

WITH ALL_DAYS_SERIES AS
(
SELECT GENERATE_SERIES(1,31) ALL_DAYS
)
SELECT all_days, COALESCE(p_count, 0) POST_COUNT
FROM ALL_DAYS_SERIES
LEFT JOIN 
    (
    select EXTRACT(DAY FROM post_date) DAYS,  COUNT(post_id) p_count
    from facebook_posts
    GROUP BY EXTRACT(DAY FROM post_date)
    )
on ALL_DAYS = DAYS

-------------------------------------------------------------------------------------------------------------------
-- 2. 
    -- Provided a table with user id and the dates they visited the platform, 
    -- find the top 3 users with the longest continuous streak of visiting the platform as of August 10, 2022. 
    -- Output the user ID and the length of the streak. In case of a tie, display all users with the top three longest streaks.


WITH 
VISITS AS
(
(SELECT DISTINCT * FROM user_streaks WHERE date_visited <= '2022-08-10')
)

, FLAG AS
(
SELECT 
user_id
, date_visited
, LAG(date_visited, 1) OVER (PARTITION BY user_id ORDER BY date_visited) prev_date
, CASE WHEN date_visited - LAG(date_visited, 1) OVER (
                                PARTITION BY user_id 
                                ORDER BY date_visited) = 1 
        THEN 0 
        ELSE 1 
        END AS is_new_streak
FROM VISITS
)

, STREAK_NEW AS
(
SELECT user_id, date_visited, is_new_streak
, SUM(is_new_streak) OVER (PARTITION BY user_id ORDER BY date_visited) STREAK_ID
FROM FLAG
)

, STREAK_LEN as
(
SELECT user_id, streak_id, COUNT(*) streak_length
FROM STREAK_NEW
GROUP BY user_id, streak_id
)

, MAX_STREAK AS
(
SELECT user_id, MAX(streak_length) max_streak
FROM STREAK_LEN 
GROUP BY user_id
)

, STREAK_RANKED AS
(
SELECT user_id, max_streak,
RANK() OVER(ORDER BY max_streak DESC) streak_rank 
FROM MAX_STREAK
)

SELECT user_id, max_streak
FROM STREAK_RANKED 
WHERE streak_rank <= 3
;

-- Version 2

WITH VISITS AS
(
SELECT DISTINCT * FROM USER_STREAKS WHERE date_visited <= '2022-08-10'
)
, STREAKS AS
(
SELECT user_id
, date_visited
, LAG(date_visited, 1) OVER(
                            PARTITION BY user_id
                            ORDER BY date_visited) PREV_DATE
, CASE WHEN date_visited - LAG(date_visited, 1) OVER(
                            PARTITION BY user_id
                            ORDER BY date_visited) = 1 
        THEN 0 
        ELSE 1 END IS_NEW_STREAK
FROM VISITS
)
, STREAK_IDENTIFIER AS 
(
SELECT 
user_id, date_visited
, SUM(IS_NEW_STREAK) OVER(
                PARTITION BY user_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) STREAK_ID
FROM STREAKS 
)
, STREAK_LENGTH AS
(
SELECT user_id, COUNT(*) STREAK_LEN
FROM STREAK_IDENTIFIER
GROUP BY user_id, streak_id
)
, STREAK_RANKED AS
(
SELECT user_id, STREAK_LEN
,RANK() OVER(ORDER BY STREAK_LEN DESC) STREAK_RANK
FROM STREAK_LENGTH
)
SELECT user_id, STREAK_LEN
FROM STREAK_RANKED
WHERE STREAK_RANK <= 3
;
-------------------------------------------------------------------------------------------------------------------
-- 3.
    -- Which countries have risen in the rankings based on the number of comments between Dec 2019 vs Jan 2020? 
    -- Hint: Avoid gaps between ranks when ranking countries.
-- Concepts used:
    -- MAX() FILTER() in select
    -- JOIN USING
    -- DATE_TRUNC(Precision, Column) -- Precision 'month', 'year', 'date', 'hour', etc

WITH ADS AS
(
SELECT
u.country,
date_trunc('month', created_at) AS month_start,
SUM(c.number_of_comments) AS total_comments
FROM fb_comments_count c
JOIN fb_active_users  u USING (user_id)
WHERE c.created_at between '2019-12-01' AND '2020-01-31'
GROUP BY 1, 2
)
, RANKED AS
(
SELECT 
country, month_start
, DENSE_RANK() OVER(PARTITION BY month_start ORDER BY total_comments DESC) ranks
FROM ADS
)
, PIVOTED AS
(
SELECT 
country
,MAX(ranks) FILTER(WHERE month_start = '2019-12-01') ranks_19
,MAX(ranks) FILTER(WHERE month_start = '2020-01-01') ranks_20
FROM RANKED
GROUP BY 1
)
SELECT country FROM PIVOTED WHERE ranks_20 < ranks_19
;
-------------------------------------------------------------------------------------------------------------------
-- 4.
    -- Find median for a column, given its frequency

WITH EXPLODED AS
(
SELECT num, GENERATE_SERIES(1, frequency)
FROM Numbers
)
SELECT PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY num) AS median
FROM EXPLODED
;
-------------------------------------------------------------------------------------------------------------------
-- 5. Retention Rate
-- You are given a dataset that tracks user activity. 
-- The dataset includes information about the date of user activity, the account_id associated with the activity, 
-- and the user_id of the user performing the activity. Each row in the dataset represents a user’s activity on a specific date 
-- for a particular account_id.
-- Your task is to calculate the monthly retention rate for users for each account_id for December 2020 and January 2021. 
-- The retention rate is defined as the percentage of users active in a given month who have activity in any future month.

-- For instance, a user is considered retained for December 2020 if they have activity in December 2020 and any subsequent month 
-- (e.g., January 2021 or later). Similarly, a user is retained for January 2021 if they have activity in January 2021 and any
-- later month (e.g., February 2021 or later).
-- The final output should include the account_id and the ratio of the retention rate in January 2021 
-- to the retention rate in December 2020 for each account_id. If there are no users retained in December 2020, 
-- the retention rate ratio should be set to 0.

-- Solution:
WITH max_dates AS
    (
    SELECT user_id,
          account_id,
          MAX(record_date) AS max_date
   FROM sf_events
   GROUP BY user_id,
            account_id
    )

, dec_2020 AS
    (
    SELECT DISTINCT account_id,
                   user_id
   FROM sf_events
   WHERE date_trunc('month', record_date) = '2020-12-01'
    )

, jan_2021 AS
    (
    SELECT DISTINCT account_id,
                   user_id
   FROM sf_events
   WHERE date_trunc('month', record_date) = '2021-01-01'
    )
    
, retention_dec AS
    (
    SELECT d.account_id,
          COUNT(DISTINCT CASE
                             WHEN m.max_date > '2020-12-31' THEN d.user_id
                         END) * 1.0 / COUNT(DISTINCT d.user_id) AS retention_dec
   FROM dec_2020 d
   JOIN max_dates m ON d.user_id = m.user_id
   AND d.account_id = m.account_id
   GROUP BY d.account_id
    )

, retention_jan AS
    (
    SELECT j.account_id,
          COUNT(DISTINCT CASE
                             WHEN m.max_date > '2021-01-31' THEN j.user_id
                         END) * 1.0 / COUNT(DISTINCT j.user_id) AS retention_jan
   FROM jan_2021 j
   JOIN max_dates m ON j.user_id = m.user_id
   AND j.account_id = m.account_id
   GROUP BY j.account_id
    )
    
SELECT rd.account_id,
       COALESCE(rj.retention_jan, 0) / rd.retention_dec AS retention
FROM retention_dec rd
LEFT JOIN retention_jan rj ON rd.account_id = rj.account_id
;

-------------------------------------------------------------------------------------------------------------------
-- Median : Retain both rows if count is even
WITH CTE AS
(
    SELECT 
    id, company, salary
    ,ROW_NUMBER() OVER(PARTITION BY company ORDER BY salary) as row_rank
    , COUNT(*) OVER(PARTITION BY company) as count_
    FROM Employee
)
SELECT
id, company, salary 
FROM CTE 
WHERE 
-- Odd
    (count_ % 2 = 1 AND row_rank = (count_+1)/2)
-- Even
OR  (count_ % 2 = 0 AND 
                    (row_rank = count_ / 2 OR row_rank = (count_/2)+1)
    )
;
-------------------------------------------------------------------------------------------------------------------
-- 3-Day Streak using Lead, Lag

WITH CTE AS
(
SELECT id, visit_date
, LAG(people, 2) OVER (ORDER BY visit_date) p2
, LAG(people, 1) OVER (ORDER BY visit_date) p1
, people
, LEAD(people, 1) OVER (ORDER BY visit_date) f1
, LEAD(people, 2) OVER (ORDER BY visit_date) f2
FROM Stadium
)
SELECT id, visit_date, people
FROM CTE
WHERE people >= 100
AND 
    (
        (p2 >= 100) AND (p1 >= 100)
    OR  (p1 >= 100) AND (f1 >= 100)
    OR  (f1 >= 100) AND (f2 >= 100)
    )
ORDER BY 2
;
-------------------------------------------------------------------------------------------------------------------














