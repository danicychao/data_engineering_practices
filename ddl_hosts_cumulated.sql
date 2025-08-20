 CREATE TABLE hosts_cumulated (
 host TEXT,
 host_activity_datelist DATE[],
 cur_date DATE,
 PRIMARY KEY (host, cur_date)
 )