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
