-- Топ-5 днів з найбільшим загальним ROMI (value / spend) по обох платформах
WITH combined AS (
  SELECT ad_date, spend, value FROM google_ads_basic_daily
  UNION ALL
  SELECT ad_date, spend, value FROM facebook_ads_basic_daily
),
daily_totals AS (
  SELECT 
    ad_date::date AS ad_date,
    SUM(COALESCE(spend,0)) AS total_spend,
    SUM(COALESCE(value,0)) AS total_value
  FROM combined
  GROUP BY ad_date
)
SELECT
  ad_date,
  total_spend,
  total_value,
  ROUND(total_value::numeric / NULLIF(total_spend::numeric, 0), 4) AS romi
FROM daily_totals
WHERE total_spend > 0
ORDER BY romi DESC, ad_date
LIMIT 5;

