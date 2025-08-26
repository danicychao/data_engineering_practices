 /*
  * user_devices_cumulated Table DDL
  *
  * Purpose:
  *   Create table that tracks user active days by browser_type
  */
 
 CREATE TABLE user_devices_cumulated (
    user_id NUMERIC,
 	device_activity_datelist JSONB, -- {browser type: active dates}
 	PRIMARY KEY (user_id)
 );


