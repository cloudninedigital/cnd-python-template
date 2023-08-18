SELECT
    event_name,
    event_date,
    COUNT(1) as occurrences,
FROM `$$table$$`
WHERE event_property1 > "$$variable1$$"