INSERT INTO actors
WITH last_year AS (
	SELECT * FROM actors
	WHERE current_year = 2020
),
	this_year AS (
	SELECT
		MAX(actor) as actor,
		actorid,
		ARRAY_AGG(DISTINCT ARRAY[ROW(film, votes, rating, filmid)::film_stat]) as films,
		sum(rating*votes)/sum(votes) as avg_rating,
		MAX(year) as the_year
	FROM actor_films
	WHERE year = 2021
	GROUP BY actorid
	)

SELECT
	COALESCE(ly.actor, ty.actor) as actor,
	COALESCE(ly.actorid, ty.actorid) as actorid,
	COALESCE(ly.films, ARRAY[]::film_stat[]) || COALESCE(ty.films, ARRAY[]::film_stat[])
	 as films,
	CASE WHEN ty.avg_rating IS NOT NULL THEN
		(CASE WHEN ty.avg_rating > 8 THEN 'star'
		      WHEN ty.avg_rating > 7 THEN 'good'
              WHEN ty.avg_rating > 6 THEN 'average'
			  ELSE 'bad' END
		 )::quality_class
		 ELSE ly.quality_class END as quality_class,
	ty.films IS NOT NULL as is_active,
	COALESCE(ty.the_year, ly.current_year+1) as current_year
FROM last_year ly 
FULL OUTER JOIN this_year ty ON ty.actorid = ly.actorid;