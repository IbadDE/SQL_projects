WITH san_table as													-- san francisco CTE
(SELECT EXTRACT(year from start_date) as year 			  			 -- extracting year
      , COUNT(duration_sec) as san_rides							-- count total number of rides per year
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`    -- query from san francisco dataset
GROUP BY 1),
york_table as 													
(SELECT EXTRACT(year from starttime) as year								
      ,COUNT(starttime) as newyork_rides
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 		-- using newyork datset
WHERE starttime is not null
GROUP BY 1),
lag_table as(
SELECT ny.year													
      , san_rides
      , newyork_rides
      , LAG(san_rides) OVER(ORDER BY ny.year) as san_previous        -- compare weather it's increased or decreased compare to previous year
      , LAG(newyork_rides) OVER(ORDER BY ny.year) as new_previous
FROM san_table san
JOIN york_table ny 														-- these both dataset have same years, so use it as a join
ON san.year = ny.year
ORDER BY ny.year)
SELECT *
      , COALESCE((san_rides - san_previous)/san_previous,0) as sanfrancisco     -- to compare weather it's increased or decreased compare to previous year in percentage
      , COALESCE((newyork_rides - new_previous)/new_previous,0) as newyork		-- coalesce is set to zero as reference
FROM lag_table;





(SELECT CASE 
        WHEN duration_sec is not null then 'sanfrancisco' END as location   -- to create a dimension for sanfrancison dataset
      , COUNT(duration_sec) as total_rides
      , AVG(duration_sec)/60 as AVG_time        -- convert the second into minutes dividing it by 60
      , COUNT(DISTINCT bike_number) as total_bikes
      , COUNT(DISTINCT end_station_id) as total_stations
      , COUNT( CASE WHEN coalesce(c_subscription_type,subscriber_type) = 'Subscriber' THEN 'sub' END) as Subscriber    -- count number of sub
      , COUNT( CASE WHEN coalesce(c_subscription_type,subscriber_type) = 'Customer' THEN 'sub' END) as Customer
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
GROUP BY 1)
UNION ALL 				-- use to union the dataset. both queries should have same datatyoe and same column name and should be in same order.
(SELECT CASE 
        WHEN tripduration is not null then 'newyork' END as location  -- to create a dimension for sanfrancison dataset
      , COUNT(tripduration) as total_rides
      , AVG(tripduration)/60 as AVG_time
      , COUNT(DISTINCT bikeid) as total_bikes
      , COUNT(DISTINCT end_station_id) as total_stations
      , COUNT( CASE WHEN usertype = 'Subscriber' THEN 'sub' END) as Subscriber
      , COUNT( CASE WHEN usertype = 'Customer' THEN 'sub' END) as Customer
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime is not null
GROUP BY 1);



WITH start_location as
( SELECT DISTINCT(start_station_name) as start_loc  		-- to create table for sanfrnaciso location. There has been many records which doesn't have latitue and longitude
        , AVG(start_station_latitude) as start_lat			-- this is created for modelling
        , AVG(start_station_longitude) as start_lon
  FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
  GROUP BY 1
),
tbl_1 as
(SELECT start_station_name
      , end_station_name
      , COUNT(*) as num_of_rides
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
GROUP BY 1,2),
tbl_2 as
(SELECT tbl_1.*          -- getting the locations for start stations name from creaitng our table
      , sl.start_lat
      , sl.start_lon
FROM tbl_1
JOIN start_location sl
ON sl.start_loc = tbl_1.start_station_name),
final_tbl as
(SELECT CASE WHEN start_station_name is not null THEN 'sanfranciso' END as location    -- getting dimension for filters
       ,  tbl_2.*
       ,  sl.start_lat as end_lat
       ,  sl.start_lon as end_lon
FROM tbl_2
JOIN start_location sl
ON sl.start_loc = tbl_2.end_station_name)
SELECT * 
FROM final_tbl
WHERE start_lat is not null  -- removing records if any location has null value
  or  start_lon is not null
  or  end_lat is not null
  or  end_lon is not null)
 UNION ALL    -- union all columns
(SELECT CASE WHEN start_station_name is not null THEN 'newyork' END as location -- getting dimension for filters
      , start_station_name
      , end_station_name
      , COUNT(*) as num_of_rides
      , AVG(start_station_latitude) as start_lat
      , AVG(start_station_longitude) as start_lon    -- getting one exact location for each station
      , AVG(end_station_latitude) as end_lat
      , AVG(end_station_longitude) as end_lon
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
GROUP BY 1,2,3);
