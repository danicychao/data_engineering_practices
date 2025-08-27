/*
 * Incremental query for host_activity_reduced table
 *
 * Purpose:
 *   Update host_activity_reduced table day by day
 *   by generating and extending array of 
 *   number of hits in metric_array column (hit_array). 
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

-- Extract number of hits on the day
daily_aggregate AS (
    SELECT
        host,
        DATE(event_time) as cur_date,
        COUNT(1) as num_acts
    FROM dedup
    WHERE DATE(event_time) = DATE('2023-01-03')
        AND row_num = 1
        AND host IS NOT NULL
    GROUP BY host, cur_date
),

-- Snapshot of hit_array in the same month
yesterday_array AS (
    SELECT * FROM host_activity_reduced
    WHERE month_start = DATE('2023-01-01')
      AND metric_name = 'hit_array'
)

/*
 * Final SELECT to insert hit_array
 *   - hit_array:
 *       * If no prior records of hit_array,
 *         initialize the array with number of hits on the day, 
 *         filling zero paddling up to the day 
 *       * If no hit on the day, inherit from yesterday's hit_array
 *       * Otherwise, append number of hits on the day to hit_array 
 */
SELECT
    COALESCE(y.host, d.host) as host,
    COALESCE(y.month_start, DATE(DATE_TRUNC('month', d.cur_date))) as month_start,
    'hit_array' as metric_name,
    CASE 
        WHEN y.metric_array IS NULL THEN
            ARRAY_FILL(0, ARRAY[d.cur_date - DATE(DATE_TRUNC('month', d.cur_date))]) || ARRAY[d.num_acts]
        WHEN d.num_acts IS NULL THEN y.metric_array
        ELSE y.metric_array || d.num_acts
    	END AS metric_array
FROM yesterday_array y 
FULL OUTER JOIN daily_aggregate d ON y.host = d.host

ON CONFLICT(host, month_start, metric_name)
DO UPDATE SET metric_array = EXCLUDED.metric_array