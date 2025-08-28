# SQL data engineering practices

This repo contains my solutions to the homework in [DataExpert-io's intermediate data engineering bootcamp](https://github.com/DataExpert-io/data-engineer-handbook). 
In this repo, I not only practice data engineering techniques, but also demonstrate my SQL skills, which are beyond `SELECT ... FROM ...`.

(August 28) I am going to include more data engineering practices such as PySpark in the future.

## Notes on SQL manipulation

The SQL scripts here cover common data engineering workflows:

- **DDL**: Data Definition Language. Creating tables or custom types (schemas) that support efficient storage and querying.
- **CTE**: Common Table Expression. Breaking a complex SQL workflow with a temporary named result sets.
- **Cumulative Generation**: aggregate target data and cumulatively update tables.
- **SCD**: Slowly Changing Dimensions (Type 2 in this repo). Presering multiple versions of historical data with start and end dates.
- **Incremental Load**: Efficiently updating tables with only new or changed data, avoiding reprocessing full database.
- **Deduplication**: Using window functions and ranking to deduplicate records.

These essential building blocks are implemented in the clear and reusable scripts that can be easily adapted for different datasets. 

