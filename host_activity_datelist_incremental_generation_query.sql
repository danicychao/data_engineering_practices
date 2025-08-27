/*
 * Incremental query for hosts_cumulated table
 *
 * Purpose:
 *   Update hosts_cumulated table by generating 
 *   and extendinghost_activity_datelist column 
 *   day by day in hosts_cumulated table.
 * 
 *   host_activity_datelist column tracks 
 *   dates a host is experiencing any activity.
 * 
 * Tables:
 *   - hosts_cumulated (target table)
 *   - events table (source table)
 */


INSERT INTO hosts_cumulated

-- Snapshot at a day of hosts_cumulated table
WITH yesterday AS (
    SELECT *
    FROM hosts_cumulated
    WHERE cur_date = DATE('2023-01-03')
),

-- Extract host experiencing activity on next day
today AS (
    SELECT
        host,
        DATE(event_time) as cur_date
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-04')
    GROUP BY host, cur_date
)

/*
 * Final SELECT to INSERT INTO hosts_cumulated
 *   - hosts_cumulated:
 *       * Create array with next day if no hosts_cumulated record
 *       * Inherit from hosts_cumulated record if no activity next day
 *       * Append next day if there are both activity and hosts_cumulated record
 */
SELECT
    COALESCE(y.host, t.host) AS host,
    CASE 
        WHEN y.host_activity_datelist IS NULL THEN ARRAY[t.cur_date]
        WHEN t.cur_date IS NULL THEN y.host_activity_datelist
        ELSE y.host_activity_datelist || t.cur_date
        END AS host_activity_datelist,
    DATE(COALESCE(t.cur_date, y.cur_date + INTERVAL '1 day')) as cur_date
FROM yesterday y 
FULL OUTER JOIN today t ON y.host = t.host;