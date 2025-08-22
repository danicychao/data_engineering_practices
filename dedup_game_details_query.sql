WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY player_id, team_id, game_id) as row_num
    FROM game_details
)

SELECT * FROM dedup
WHERE row_num = 1