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
 	is_active BOOLEAN,
 	current_year INTEGER,
 	PRIMARY KEY (actorid, current_year)
 );
