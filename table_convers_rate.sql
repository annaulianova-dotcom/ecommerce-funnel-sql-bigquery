WITH base_events AS (
  SELECT
    TIMESTAMP_MICROS(event_timestamp) AS event_ts,
    event_name,
    user_pseudo_id,
    -- унікальний ідентифікатор сесії
    CONCAT(
      user_pseudo_id, '-', 
      CAST((SELECT value.int_value
            FROM UNNEST(event_params)
            WHERE key = 'ga_session_id') AS STRING)
    ) AS user_session_id,
    -- landing page (беремо з session_start)
    (SELECT value.string_value
     FROM UNNEST(event_params)
     WHERE key = 'page_location') AS page_location
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
    AND event_name IN ('session_start', 'purchase')
),

landing_pages AS (
  -- лишаємо тільки page_path (без домену та параметрів)
  SELECT
    user_pseudo_id,
    user_session_id,
    REGEXP_EXTRACT(page_location, r'https?://[^/]+([^?#]+)') AS page_path
  FROM base_events
  WHERE event_name = 'session_start'
),

purchases AS (
  -- позначаємо сесії, які мали purchase
  SELECT DISTINCT
    user_session_id
  FROM base_events
  WHERE event_name = 'purchase'
),

sessions_with_flags AS (
  SELECT
    lp.page_path,
    lp.user_session_id,
    lp.user_pseudo_id,
    IF(p.user_session_id IS NOT NULL, 1, 0) AS has_purchase
  FROM landing_pages lp
  LEFT JOIN purchases p
    ON lp.user_session_id = p.user_session_id
)

SELECT
  page_path,
  COUNT(DISTINCT user_session_id) AS user_sessions_count,
  COUNTIF(has_purchase = 1)       AS purchased_sessions,
  SAFE_DIVIDE(COUNTIF(has_purchase = 1),
              COUNT(DISTINCT user_session_id)) AS conversion_rate
FROM sessions_with_flags
GROUP BY page_path
ORDER BY conversion_rate DESC;
