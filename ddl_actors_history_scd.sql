/*
 * actors_history_scd Table DDL
 *
 * Purpose:
 *   Create a table, actors_history_scd, 
 *   tracking actors' performance quality, and their active status.
 * 
 * Tables:
 *   - actors_history_scd
 * 
 * Data will be inserted into actors_history_scd table 
 * by backfill_actors_history_scd.sql.
 */

CREATE TABLE actors_history_scd (
	actor TEXT,
	actorid TEXT,
	quality_class quality_class,
	is_active BOOLEAN,
	start_date INTEGER, -- start year of certain state of quality and active status
	end_date INTEGER, -- end year of certain state of quality and active status
	current_year INTEGER,
	PRIMARY KEY (actorid, start_date)
);