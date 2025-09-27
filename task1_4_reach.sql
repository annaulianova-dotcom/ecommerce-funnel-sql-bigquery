-- Завдання 1.4: Найбільший місячний приріст reach
WITH combined AS (
    SELECT ad_date::date AS ad_date,
           url_parameters AS campaign,
           COALESCE(reach,0) AS reach
    FROM google_ads_basic_daily

    UNION ALL

    SELECT ad_date::date AS ad_date,
           url_parameters AS campaign,
           COALESCE(reach,0) AS reach
    FROM facebook_ads_basic_daily
),

monthly_reach AS (
    -- підсумовуємо reach по "кампаніях" за місяць
    SELECT
        campaign,
        DATE_TRUNC('month', ad_date)::date AS month,
        SUM(reach) AS total_reach
    FROM combined
    GROUP BY campaign, month
),

monthly_diff AS (
    -- рахуємо значення попереднього місяця та абсолютну різницю
    SELECT
        campaign,
        month,
        total_reach,
        LAG(total_reach) OVER (PARTITION BY campaign ORDER BY month) AS prev_month_reach,
        total_reach - LAG(total_reach) OVER (PARTITION BY campaign ORDER BY month) AS reach_diff,
        ABS(total_reach - LAG(total_reach) OVER (PARTITION BY campaign ORDER BY month)) AS reach_diff_abs
    FROM monthly_reach
)

SELECT
    campaign,
    month AS current_month,
    prev_month_reach,
    total_reach AS current_month_reach,
    reach_diff AS current_minus_prev,
    reach_diff_abs AS abs_diff
FROM monthly_diff
WHERE prev_month_reach IS NOT NULL
ORDER BY reach_diff_abs DESC
LIMIT 1;

