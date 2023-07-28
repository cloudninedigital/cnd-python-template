INSERT INTO `timing-analytics.dashboard_ready_table.applications_ga4`
SELECT 
  parse_date('%Y%m%d',event_date) as event_date,
  user_pseudo_id,
  event_name,
  COUNT(*) AS event_count
FROM `timing-analytics.analytics_291842698.*`
WHERE parse_date('%Y%m%d',event_date) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND event_name IN ('purchase','account_registration_success', 'session_start')
AND NOT EXISTS (
  SELECT 1
  FROM `timing-analytics.dashboard_ready_table.applications_ga4`
  WHERE event_date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
)
GROUP BY
  event_date,
  user_pseudo_id,
  event_name
