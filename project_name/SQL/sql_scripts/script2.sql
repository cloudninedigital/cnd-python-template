INSERT INTO `dataset1.table1`
(
event_name,
event_date,
occurrences
)
(
    SELECT
        event_name,
        event_date,
        COUNT(1) as occurrences,
    FROM `$$table$$`
    WHERE event_property1 > "$$variable2$$"
)
