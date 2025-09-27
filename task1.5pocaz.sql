-- Завдання 1.5: Найдовший безперервний показ adset_name
WITH all_ads AS (
    SELECT ad_date, adset_name FROM google_ads_basic_daily
    UNION ALL
    SELECT ad_date, adset_name FROM facebook_ads_basic_daily f
    JOIN facebook_adset fc ON f.adset_id = fc.adset_id
),
ad_dates AS (
    SELECT adset_name, ad_date,
           ROW_NUMBER() OVER(PARTITION BY adset_name ORDER BY ad_date) -
           ROW_NUMBER() OVER(ORDER BY ad_date) AS grp
    FROM all_ads
),
streaks AS (
    SELECT adset_name, COUNT(*) AS consecutive_days
    FROM ad_dates
    GROUP BY adset_name, grp
)
SELECT adset_name, MAX(consecutive_days) AS longest_streak
FROM streaks
GROUP BY adset_name
ORDER BY longest_streak DESC
LIMIT 1;
