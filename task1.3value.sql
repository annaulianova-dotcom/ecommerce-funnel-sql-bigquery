-- Завдання 1.3: Кампанія з найвищим тижневим value
WITH weekly_values AS (
    SELECT
        campaign_name,
        DATE_TRUNC('week', ad_date) AS week_start,
        SUM(value) AS total_value
    FROM (
        SELECT campaign_name, ad_date, value FROM google_ads_basic_daily
        UNION ALL
        SELECT fc.campaign_name, f.ad_date, f.value
        FROM facebook_ads_basic_daily f
        JOIN facebook_campaign fc ON f.campaign_id = fc.campaign_id
    ) AS combined
    GROUP BY campaign_name, week_start
)
SELECT campaign_name, week_start, total_value
FROM weekly_values
ORDER BY total_value DESC
LIMIT 1;

