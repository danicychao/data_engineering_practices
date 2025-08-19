CREATE TYPE actor_scd_type AS (
quality_class quality_class,
is_active BOOLEAN,
start_date INTEGER,
end_date INTEGER
);

WITH last_year_scd AS (

SELECT * FROM actors_history_scd
WHERE current_year = 2020 AND end_date = 2020
),

historical_scd AS (
SELECT
actor,
actorid,
quality_class,
is_active,
start_date,
end_date
FROM actors_history_scd
WHERE end_date < 2020
),

this_year AS (
SELECT * FROM actors
WHERE current_year = 2021
),

unchanged_record AS (
SELECT
ty.actor,
ty.actorid,
ty.quality_class,
ty.is_active,
ly.start_date as start_date,
ty.current_year as end_date
FROM last_year_scd ly JOIN this_year ty ON ly.actorid = ty.actorid
WHERE ty.quality_class = ly.quality_class
AND   ty.is_active = ly.is_active
),

changed_records AS (
SELECT
ty.actor,
ty.actorid,
ARRAY[ROW(ly.quality_class,
		  ly.is_active,
		  ly.start_date,
		  ly.end_date)::actor_scd_type,
	  ROW(ty.quality_class,
	  	  ty.is_active,
		  ty.current_year,
		  ty.current_year)::actor_scd_type] as records
FROM last_year_scd ly JOIN this_year ty ON ly.actorid = ty.actorid
WHERE ty.quality_class <> ly.quality_class
OR   ty.is_active <> ly.is_active
),

unnested_changed_records AS (
SELECT
actor,
actorid,
(UNNEST(records)::actor_scd_type).quality_class,
(UNNEST(records)::actor_scd_type).is_active,
(UNNEST(records)::actor_scd_type).start_date as start_date,
(UNNEST(records)::actor_scd_type).end_date as end_date
FROM changed_records
),

new_record AS (
SELECT
ty.actor,
ty.actorid,
ty.quality_class,
ty.is_active,
ty.current_year as start_date,
ty.current_year as end_date
FROM last_year_scd ly LEFT JOIN this_year ty ON ly.actorid = ty.actorid
WHERE ly.actorid IS NULL
)

SELECT * FROM historical_scd
UNION
SELECT * FROM unchanged_record
UNION
SELECT * FROM unnested_changed_records
UNION
SELECT * FROM new_record
ORDER BY actorid, start_date