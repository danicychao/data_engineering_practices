/*
 * Cumulative query for device_activity_datelist table
 *
 * Purpose:
 *   Generate device_activity_datelist table
 *   from events table
 * 
 * Tables:
 *   - device_activity_datelist (target table)
 *   - events table (source table)
 */

INSERT INTO user_devices_cumulated

-- Deduplicate the events table
WITH user_row AS (
    SELECT
        user_id,
        device_id,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, device_id, event_time 
            ORDER BY event_time
        ) as row_num -- for deduplication
    FROM events
    WHERE user_id IS NOT NULL
    AND device_id IS NOT NULL
),

-- Select user's browser type from the devices table
user_device_browser AS (
    SELECT
        u.user_id as user_id,
        d.device_id as device_id,
        d.browser_type as browser_type,
        DATE(u.event_time) as act_date
    FROM user_row u 
    JOIN devices d ON u.device_id = d.device_id
    WHERE u.row_num = 1 -- select only first row to avoid duplication
),

-- Deduplicate user-browser-active date
user_device_browser_dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, device_id, browser_type, act_date 
            ORDER BY act_date
        ) as row_num
    FROM user_device_browser
),

-- Aggregate active dates by browser type
user_id_browser AS (
    SELECT
        user_id,
        browser_type,
        ARRAY_AGG(DISTINCT act_date) dates
    FROM user_device_browser_dedup
    WHERE row_num = 1
    GROUP BY 1, 2
)

-- Aggregate multiple browser-active dates columns 
-- into one JSON column by user id
-- and insert into the user_devices_cumulated table
SELECT
    user_id as user_id,
    JSONB_OBJECT_AGG(browser_type, dates) as device_activity_datelist
FROM user_id_browser
GROUP BY 1