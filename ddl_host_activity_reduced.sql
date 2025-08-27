/*
 * host_activity_reduced Table DDL
 *
 * Purpose:
 *   Create a reduced fact table, host_activity_reduced, 
 *   including conclusion metrics such as
 *   number of hits and number of unique visitors.
 * 
 * Tables:
 *   - host_activity_reduced
 *
 * Data will be loaded into host_activity_reduced table by 
 * incremental_host_activity_reduced_[METRIC NAME].sql.
 */

CREATE TABLE host_activity_reduced (
    host TEXT,
    month_start DATE,
    metric_name TEXT,
    metric_array INTEGER[],
    PRIMARY KEY (host, month_start, metric_name)
);