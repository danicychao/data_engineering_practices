/*
 * hosts_cumulated Table DDL
 *
 * Purpose:
 *   Create a table, hosts_cumulated, 
 *   tracking dates host experiencing any activity
 * 
 * Tables:
 *   - hosts_cumulated
 *
 * Data will be inserted into hosts_cumulated table by 
 * host_activity_datelist_incremental_generation_query.sql.
 */

CREATE TABLE hosts_cumulated (
    host TEXT,
    host_activity_datelist DATE[], -- dates host experiencing activity
    cur_date DATE,
    PRIMARY KEY (host, cur_date)
);