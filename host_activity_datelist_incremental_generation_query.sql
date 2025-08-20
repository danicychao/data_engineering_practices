INSERT INTO hosts_cumulated
WITH yesterday AS (
SELECT *
FROM hosts_cumulated
WHERE cur_date = DATE('2023-01-03')
),

today AS (
SELECT
host,
DATE(event_time) as cur_date
FROM events
WHERE DATE(event_time) = DATE('2023-01-04')
GROUP BY host, cur_date
)

SELECT
COALESCE(y.host, t.host) as host,
CASE WHEN y.host_activity_datelist IS NULL THEN ARRAY[t.cur_date]
     WHEN t.cur_date IS NULL THEN y.host_activity_datelist
     ELSE y.host_activity_datelist || t.cur_date
	 END as host_activity_datelist,
DATE(COALESCE(t.cur_date, y.cur_date + INTERVAL '1 day')) as cur_date
FROM yesterday y FULL OUTER JOIN today t
ON y.host = t.host