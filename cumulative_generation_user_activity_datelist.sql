INSERT INTO user_devices_cumulated
WITH user_row AS (
    SELECT
        user_id,
        device_id,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, device_id, event_time 
            ORDER BY event_time
        ) as row_num
    FROM events
    WHERE user_id IS NOT NULL
    AND device_id IS NOT NULL
),

user_device_browser AS (
    SELECT
        u.user_id as user_id,
        d.device_id as device_id,
        d.browser_type as browser_type,
        DATE(u.event_time) as act_date
    FROM user_row u 
    JOIN devices d ON u.device_id = d.device_id
    WHERE u.row_num = 1
),

user_device_browser_dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, device_id, browser_type, act_date 
            ORDER BY act_date
        ) as row_num
    FROM user_device_browser
),

user_id_browser AS (
    SELECT
        user_id,
        browser_type,
        ARRAY_AGG(DISTINCT act_date) dates
    FROM user_device_browser_dedup
    WHERE row_num = 1
    GROUP BY 1, 2
)

SELECT
    user_id as user_id,
    JSONB_OBJECT_AGG(browser_type, dates) as device_activity_datelist
FROM user_id_browser
GROUP BY 1