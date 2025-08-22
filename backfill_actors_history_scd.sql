INSERT INTO actors_history_scd
WITH previous AS (
  SELECT
    actor,
    actorid,
    quality_class,
    LAG(quality_class) OVER (PARTITION BY actorid ORDER BY current_year) AS last_year_class,
    is_active,
    LAG(is_active) OVER (PARTITION BY actorid ORDER BY current_year) AS last_year_active,
    current_year
  FROM actors
),
change_indicator AS (
  SELECT
    actor,
    actorid,
    quality_class,
    is_active,
    CASE
      WHEN quality_class <> last_year_class THEN 1
      WHEN is_active <> last_year_active THEN 1
	 ELSE 0
	 END AS change,
    current_year
  FROM previous
),
streak_indicator AS (
  SELECT
    *,
    SUM(change) OVER (PARTITION BY actorid ORDER BY current_year) AS change_streak
  FROM change_indicator
)
SELECT
  MAX(actor),
  actorid,
  MAX(quality_class),
  is_active,
  MIN(current_year) AS start_date,
  MAX(current_year) AS end_date,
  2020 AS current_year
FROM streak_indicator
GROUP BY actorid, change_streak, is_active