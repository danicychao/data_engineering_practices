/*
 * datelist_int generation query
 *
 * Purpose:
 *   Convert active dates in device_activity_datelist column
 *   in device_activity_datelist table into datelist_int column, 
 *   which tracks both active dates and number of active days.
 * 
 * Tables:
 *   - device_activity_datelist (source table)
 */

-- Generate all the dates in the month
WITH series AS (
    SELECT * FROM
        generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 DAY')
        as date_series
),

-- Extract browser type and active date from the JSONB column device_activity_datelist
unnest_browser AS (
    SELECT
        user_id,
        browser_type,
        dates::DATE as act_dates
    FROM
        user_devices_cumulated_test,
        jsonb_each(device_activity_datelist) AS t(browser_type, date_array),
        jsonb_array_elements_text(t.date_array) AS dates
),

-- Convert active dates into a unique bitmask integer (power of 2)
-- based on their days in the month
placeholder AS (
    SELECT
        u.user_id,
        u.browser_type,
        DATE(s.date_series),
        DATE('2023-01-31') - DATE(s.date_series),
        (u.act_dates = DATE(s.date_series)) as active_status,
        CASE 
            WHEN u.act_dates = DATE(s.date_series)
            THEN CAST(POW(2, 30 - (DATE('2023-01-31') - DATE(s.date_series))) AS BIGINT)
            ELSE 0 
        END AS placeholder_int_value
    FROM unnest_browser u 
    CROSS JOIN series s
),

-- Sum up the bitmask integer to encode active dates and number of active days
placeholder_sum AS (
    SELECT
        user_id,
        browser_type,
        SUM(placeholder_int_value) as date_int
    FROM placeholder
    WHERE placeholder_int_value <> 0
    GROUP BY user_id, browser_type
)

/*
 * Final SELECT:
 *   Aggregate multiple browser-encoded bitmask integers 
 *   into one JSON column by user id
 */
SELECT
    user_id,
    JSON_OBJECT_AGG(browser_type, date_int) as datelist_int
FROM placeholder_sum
GROUP BY user_id;