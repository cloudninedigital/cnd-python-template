CREATE OR REPLACE TABLE temp.ga4_events
OPTIONS(EXPIRATION_TIMESTAMP=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 3 HOUR)) as (
select event_date, event_name, count(event_timestamp) events  from $$table$$ group by 1,2);

MERGE INTO analytics_test.ga4_daily_aggregation tar
USING temp.ga4_events sou
on tar.event_date = sou.event_date
and tar.event_name = sou.event_name
WHEN MATCHED
THEN UPDATE SET
tar.events = sou.events
WHEN NOT MATCHED
THEN INSERT
(
event_date, event_name, events
)
VALUES (
  event_date, event_name, events
);