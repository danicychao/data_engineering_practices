/*
 * Backfill query for actors_history_scd table
 *
 * Purpose:
 *   Populate the entire actors_history_scd table
 * 
 * Tables:
 *   - actors_history_scd (target table)
 *   - actors (source table)
 */


INSERT INTO actors_history_scd

-- Compare performance quality and active status with previous year
WITH previous AS (
  SELECT
    actor,
    actorid,
    quality_class,
    LAG(quality_class) OVER (PARTITION BY actorid ORDER BY current_year) as last_year_class,
    is_active,
    LAG(is_active) OVER (PARTITION BY actorid ORDER BY current_year) as last_year_active,
    current_year
  FROM actors
),

-- Flag change (1) if performance quality or active status differ from previous year
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

-- Use running sum to track the state of quality and active status
  streak_indicator AS (
  SELECT
    *,
    SUM(change) OVER (PARTITION BY actorid ORDER BY current_year) as change_streak
  FROM change_indicator
)

/*
 * Final SELECT to insert columns:
 *   - Using GROUP BY actorid, change_streak to aggregate records with
 *     same state of quality and active status
 *   - start_date: first year of a state (of quality and active status)
 *   - end_date: last year of a state
 */

SELECT
  MAX(actor),
  actorid,
  MAX(quality_class),
  is_active,
  MIN(current_year) as start_date,
  MAX(current_year) as end_date,
  2020 as current_year
FROM streak_indicator
GROUP BY actorid, change_streak, is_active