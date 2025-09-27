-- Завдання 1.1: Агреговані показники по датах та платформах
SELECT
    ad_date,
    'Google' AS platform,
    AVG(spend) AS avg_spend,
    MAX(spend) AS max_spend,
    MIN(spend) AS min_spend
FROM google_ads_basic_daily
GROUP BY ad_date

UNION ALL

SELECT
    ad_date,
    'Facebook' AS platform,
    AVG(spend) AS avg_spend,
    MAX(spend) AS max_spend,
    MIN(spend) AS min_spend
FROM facebook_ads_basic_daily
GROUP BY ad_date
ORDER BY ad_date, platform;
