/*
 * Incremental query for host_activity_reduced table
 * (unique_visitor)
 *
 * Purpose:
 *   Update host_activity_reduced table day by day
 *   by generating and extending array of 
 *   number of unique visitors in metric_array column (unique_visitor). 
 * 
 * Tables:
 *   - host_activity_reduced (target table)
 *   - events (source table)
 */

INSERT INTO host_activity_reduced

-- Deduplicate the events table
WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY host, url, event_time ORDER BY event_time) as row_num
    FROM events
    WHERE host IS NOT NULL
),

-- Count a host's unique visitors
daily_aggregate AS (
    SELECT
        host,
        DATE(event_time) as cur_date,
        COUNT(DISTINCT user_id) as num_users
    FROM dedup
    WHERE DATE(event_time) = DATE('2023-01-03')
      AND row_num = 1
      AND user_id IS NOT NULL
    GROUP BY host, cur_date
),

-- Snapshot of unique_visitor in the same month
yesterday_array AS (
    SELECT * FROM host_activity_reduced
    WHERE month_start = DATE('2023-01-01')
      AND metric_name = 'unique_visitor'
)

/*
 * Final SELECT to insert unique_visitor
 *   - unique_visitor array:
 *       * If no prior records of unique_visitor,
 *         initialize the array with number of unique visitors on the day, 
 *         filling zero paddling up to the day 
 *       * If no unique visitor on the day, 
 *         inherit from yesterday's unique_visitor
 *       * Otherwise, append number of unique visitors on the day to unique_visitor 
 */
SELECT
    COALESCE(y.host, d.host) as host,
    COALESCE(y.month_start, DATE(DATE_TRUNC('month', d.cur_date))) as month_start,
    'unique_visitor' as metric_name,
    CASE 
        WHEN y.metric_array IS NULL THEN
            -- Fill zero in the previous dates without unique_visitor
            ARRAY_FILL(0, ARRAY[d.cur_date - DATE(DATE_TRUNC('month', d.cur_date))]) || ARRAY[d.num_users]
        WHEN d.num_users IS NULL THEN y.metric_array
        ELSE y.metric_array || d.num_users
    	END AS metric_array
FROM yesterday_array y 
FULL OUTER JOIN daily_aggregate d ON y.host = d.host

-- Update unique_visitor array instead of insert new row
-- when the array already exists
ON CONFLICT(host, month_start, metric_name)
DO UPDATE SET metric_array = EXCLUDED.metric_array
