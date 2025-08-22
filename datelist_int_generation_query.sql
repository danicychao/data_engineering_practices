WITH series AS (
    SELECT * FROM
        generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 DAY')
        as date_series
),

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

placeholder_sum AS (
    SELECT
        user_id,
        browser_type,
        SUM(placeholder_int_value) as date_int
    FROM placeholder
    WHERE placeholder_int_value <> 0
    GROUP BY user_id, browser_type
)

SELECT
    user_id,
    JSON_OBJECT_AGG(browser_type, date_int) as datelist_int
FROM placeholder_sum
GROUP BY user_id;