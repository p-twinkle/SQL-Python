----------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------
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

-- Version 2 : (Mine)

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
----------------------------------------------------------------------------------------------












