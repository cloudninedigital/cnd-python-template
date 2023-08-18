INSERT INTO `dataset2_$$env$$.table1`
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
    WHERE event_property1 > "$$variable1$$"
    and event_property2 = "$$variable2$$"
)
