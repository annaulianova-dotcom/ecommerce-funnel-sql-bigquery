WITH cr_events AS (
  SELECT
    TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
    event_name,
    user_pseudo_id,
    -- унікальний ідентифікатор сесії: user + session_id
    CONCAT(
      user_pseudo_id, '-', 
      CAST((SELECT value.int_value
            FROM UNNEST(event_params)
            WHERE key = 'ga_session_id') AS STRING)
    ) AS user_session_id,
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    traffic_source.name AS campaign
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
  WHERE event_name IN ('session_start', 'add_to_cart', 'begin_checkout', 'purchase')
),

events_count AS (
  SELECT
    DATE(event_timestamp) AS event_date,
    source,
    medium,
    campaign,

    COUNT(DISTINCT user_session_id) AS user_sessions_count,

    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_session_id END) AS added_to_cart_count,
    COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_session_id END) AS begin_checkout_count,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_session_id END) AS purchased_count

  FROM cr_events
  GROUP BY 1,2,3,4
)

SELECT
  event_date,
  source, -- джерело відвідування сайту
  medium,
  campaign,
  user_sessions_count,

  SAFE_DIVIDE(added_to_cart_count, user_sessions_count)   AS visit_to_cart,
  SAFE_DIVIDE(begin_checkout_count, user_sessions_count)  AS visit_to_checkout,
  SAFE_DIVIDE(purchased_count, user_sessions_count)       AS visit_to_purchase

FROM events_count
ORDER BY 1 DESC;

