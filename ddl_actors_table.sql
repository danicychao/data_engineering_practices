/*
 * Actors Table DDL
 *
 * Purpose:
 *   Create a table, actors, including actors' names, 
 *   their films and corresponding votes,
 *   their performance quality, and their active status.
 * 
 * Tables:
 *   - actors
 * 
 * Types:
 *   - film_stat: Composite type for film metrics
 *   - quality_class: Enumeration for actor performance quality
 */

CREATE TYPE film_stat AS (
 	film TEXT,
 	votes INTEGER,
 	rating REAL,
 	filmid TEXT
 );

CREATE TYPE quality_class AS
  	ENUM ('star', 'good', 'average', 'bad');

CREATE TABLE actors (
 	actor TEXT,
 	actorid TEXT,
 	films film_stat[],
 	quality_class quality_class,
 	is_active BOOLEAN, -- whether actor is making films that year
 	current_year INTEGER,
 	PRIMARY KEY (actorid, current_year)
 );
