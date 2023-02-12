
-- To Preview the data
SELECT *
FROM `bigquery-public-data.new_york_citibike.citibike_trips`;


SELECT count(*)
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration is null;

-- There are more than 5.8 Millions empty records.
-- I want to update my data. Since I'm using free version. DML is not allowed. If you are using paid version. You can use below query to update your table.
DELETE FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration is null;


-- There is another way by creating temporary table. To create temp table. click on more (horizentally with run and save). then click on query setting
-- scroll down and tick use session mode and save it.
-- I wont use the temp table, becasue it tell me your quota is over after running some queries due to the big size of the data.
DROP TABLE IF EXISTS cleanbike_trips;
CREATE TEMP table cleanbike_trips as(
  SELECT tripduration,starttime,stoptime,start_station_id,start_station_name,
        end_station_id,end_station_name,bikeid,birth_year,usertype,gender,customer_plan
  FROM `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE tripduration is not null
);


-- let's see the date range of our data.
SELECT min(starttime) as first_ride,
      max(starttime) as last_ride
From `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime is not null;



SELECT COUNT(station_id) as num_of_stations
FROM `bigquery-public-data.new_york_citibike.citibike_stations`;


-- check the last report time of each stations.
SELECT MIN(last_reported) as min_last_reported,
      MAX(last_reported) as max_last_reported
FROM `bigquery-public-data.new_york_citibike.citibike_stations`;


-- lets see what do we have in tear 1970.
SELECT *
FROM `bigquery-public-data.new_york_citibike.citibike_stations`
WHERE EXTRACT(year from last_reported) = 1970;


WITH my_table as 
(SELECT station_id
FROM `bigquery-public-data.new_york_citibike.citibike_stations`
WHERE EXTRACT(year from last_reported) = 1970)
SELECT ct.start_station_id
FROM cleanbike_trips ct
JOIN my_table mt
ON ct.start_station_id = mt.station_id;


-- update table. we don't need that data,
DELETE FROM `bigquery-public-data.new_york_citibike.citibike_stations`
WHERE EXTRACT(year from last_reported) = 1970;


-- This time i will it because this table is very small.
DROP TABLE IF EXISTS cleanbike_stations;
CREATE TEMP table cleanbike_stations as(
  SELECT *
  FROM `bigquery-public-data.new_york_citibike.citibike_stations`
  WHERE EXTRACT(year from last_reported) <> 1970
);    


-- I use station_id instead of station_name. Because station_name take more time in querying and it has big size.
SELECT start_station_id,end_station_id,count(1) number_of_trips
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration is not null
GROUP BY start_station_id,end_station_id
ORDER BY number_of_trips DESC;


-- I want to see top 10 most use and least start station name.
WITH COUNT_TABLE AS
(SELECT start_station_name,count(1) as cnt
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration is not null
GROUP BY start_station_name),
most_used as
(SELECT CONCAT(start_station_name, ' - ',cnt) as most_used_station,
      ROW_NUMBER() OVER(ORDER BY cnt DESC) as row_num
FROM count_table),
least_used as
(SELECT CONCAT(start_station_name,' - ',cnt) as least_used_station,
      ROW_NUMBER() OVER(ORDER BY cnt) as row_num
FROM count_table)
SELECT most_used_station,least_used_station
FROM most_used mu
JOIN least_used lu
ON lu.row_num = mu.row_num
WHERE lu.row_num < 11;


-- I want to see top 10 most use and least end station name.
WITH COUNT_TABLE AS
(SELECT end_station_name,count(1) as cnt
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration is not null
GROUP BY end_station_name),
most_used as
(SELECT CONCAT(end_station_name, '- ',cnt) as most_used_station,
      ROW_NUMBER() OVER(ORDER BY cnt DESC) as row_num
FROM count_table),
least_used as
(SELECT CONCAT(end_station_name,' - ',cnt) as least_used_station,
      ROW_NUMBER() OVER(ORDER BY cnt) as row_num
FROM count_table)
SELECT most_used_station,least_used_station
FROM most_used mu
JOIN least_used lu
ON lu.row_num = mu.row_num
WHERE lu.row_num < 11;


-- let's see what we have in customer plan.
SELECT customer_plan
      , COUNT(customer_plan) as cnt
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
GROUP BY customer_plan;
-- This column is empty. I don't like data modelling in this dataset. For example there was no need for locations name, latitude and longitude.


-- looking at genderwise
with gender_count as
(SELECT gender
      , COUNT(gender) as cnt
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE gender <> ''
GROUP BY gender)
SELECT gender
      , cnt
      , ROUND((cnt/(SELECT count(*) FROM `bigquery-public-data.new_york_citibike.citibike_trips` WHERE gender <> '' )*100),2) as percent_usage
FROM gender_count; 


-- The above query is wriiten in window function form. I just want to polish my window function skill a little bit.
WITH gender_table as
(SELECT gender
      , COUNT(gender) as cnt
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE gender <> ''
GROUP BY gender),
cum_sum_table as
(SELECT *, SUM(cnt) OVER(ORDER BY cnt DESC) as cum_sum
FROM gender_table),
TOTAL_SUM as
(SELECT gender 
      , cnt
      , FIRST_VALUE(cum_sum) OVER (ORDER BY cum_sum DESC) as max_value
FROM cum_sum_table)
SELECT gender 
      , cnt
      , ROUND(((cnt)/(max_value))*100,2) percentage_usage
FROM total_sum;


-- So We saw that gender is more than 1/3. I'm curios is there any station where females has used most. 
WITH gender_count as
(SELECT start_station_id
      , COUNT(CASE WHEN gender = 'male' THEN 1 END ) as  male_riders
      , COUNT(CASE WHEN gender = 'female' THEN 1 END ) as female_riders
      FROM `bigquery-public-data.new_york_citibike.citibike_trips`
GROUP BY start_station_id)
SELECT *
FROM gender_count
WHERE female_riders > male_riders;


-- let's see how many we have different usertype we have.
SELECT usertype
      , count(usertype) as num_of_rides
      , ROUND(AVG(tripduration)/60,2) as duration_time
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE usertype <> ''
GROUP BY 1;
-- seems like subscriber are using it only for work and customer are like for fun.

--Analyzing it on hourly basis.
SELECT EXTRACT(hour from starttime) as hour_
      , COUNT(CASE WHEN usertype = 'Subscriber' THEN 'sub' end) as sub_rides
      , COUNT(CASE WHEN usertype = 'Customer' THEN 'sub' end) as cus_rides
      , ROUND(AVG(CASE WHEN usertype = 'Subscriber' THEN tripduration end)/60,2) as sub_avg
      , ROUND(AVG(CASE WHEN usertype = 'Customer' THEN tripduration end)/60,2) as cus_avg
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime is not null
GROUP BY 1
ORDER BY 1;


-- looking it on different week of the day.
SELECT EXTRACT(DayOfWeek from starttime) as day_
      , COUNT(CASE WHEN usertype = 'Subscriber' THEN 'sub' end) as sub_rides
      , COUNT(CASE WHEN usertype = 'Customer' THEN 'sub' end) as cus_rides
      , COUNT(CASE WHEN usertype = 'Subscriber' THEN 'sub' end)
      - COUNT(CASE WHEN usertype = 'Customer' THEN 'sub' end) as difference
      , ROUND(AVG(CASE WHEN usertype = 'Subscriber' THEN tripduration end)/60,2) as sub_avg
      , ROUND(AVG(CASE WHEN usertype = 'Customer' THEN tripduration end)/60,2) as cus_avg
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime is not null
GROUP BY 1
ORDER BY 1;


-- analyzing it monthly
SELECT EXTRACT(month from starttime) as month_
      , COUNT(CASE WHEN usertype = 'Subscriber' THEN 'sub' end) as sub_rides
      , COUNT(CASE WHEN usertype = 'Customer' THEN 'sub' end) as cus_rides
      , ROUND(AVG(CASE WHEN usertype = 'Subscriber' THEN tripduration end)/60,2) as sub_avg
      , ROUND(AVG(CASE WHEN usertype = 'Customer' THEN tripduration end)/60,2) as cus_avg
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime is not null
GROUP BY 1
ORDER BY 1;

-- is the riders have been increase or decreas overtime
SELECT FORMAT_DATE("%Y", starttime) as Year_
      , COUNT(CASE WHEN usertype = 'Subscriber' THEN 'sub' end) as sub_rides
      , COUNT(CASE WHEN usertype = 'Customer' THEN 'sub' end) as cus_rides
      , ROUND(AVG(CASE WHEN usertype = 'Subscriber' THEN tripduration end)/60,2) as sub_avg
      , ROUND(AVG(CASE WHEN usertype = 'Customer' THEN tripduration end)/60,2) as cus_avg
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime is not null
GROUP BY 1
ORDER BY 1;


--looking at data on montly and yearly level.
SELECT FORMAT_DATETIME("%Y", starttime) as Year_
      ,FORMAT_DATETIME("%m", starttime) as month_
      , COUNT(CASE WHEN usertype = 'Subscriber' THEN 'sub' end) as sub_rides
      , COUNT(CASE WHEN usertype = 'Customer' THEN 'sub' end) as cus_rides
      , ROUND(AVG(CASE WHEN usertype = 'Subscriber' THEN tripduration end)/60,2) as sub_avg
      , ROUND(AVG(CASE WHEN usertype = 'Customer' THEN tripduration end)/60,2) as cus_avg
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime is not null
GROUP BY 1,2
ORDER BY 1,2;


-- it's easy for computer to read the long data easliy. For human eye wide data is easy to read. Let's make the pivot table,
WITH pivot_table as
(SELECT * FROM(
SELECT FORMAT_DATETIME('%Y', starttime) as Year
      , FORMAT_DATETIME('%m', starttime) as month
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration is not null
ORDER BY month)
PIVOT(
      count(*) for Year IN ('2013' as _2013,'2014' as _2014, '2015' as _2015,'2016' as _2016,'2017' as _2017,'2018' as _2018) 
))
SELECT *
FROM pivot_table
ORDER BY month;
-- In this format we can easily see that during this 2013-2018 the operation was stopped for 6 months in 2016 end and in beginning of 2017.



-- I want to see how many bikes has been using all these
WITH year_of_service_table as
(SELECT DISTINCT bikeid as distinct_bikeid
      , count(distinct EXTRACT(year from starttime)) as year_of_service
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE bikeid is not null
GROUP BY 1),
all_bikes as(
      SELECT COUNT(distinct_bikeid) as cnt_all
      FROM year_of_service_table),
rank_table as
(SELECT *
      , RANK() OVER(ORDER BY year_of_service) as rnk
FROM year_of_service_table),
top_table as
(SELECT COUNT(distinct_bikeid) as cnt_top
FROM rank_table
WHERE rnk = 1 )
SELECT (SELECT cnt_all FROM all_bikes) as total_bike
      , (SELECT cnt_top FROM top_table) as five_year_old_bikes
      ,((SELECT  cnt_all FROM all_bikes)
       - (SELECT  cnt_top FROM top_table)) as difference
FROM top_table;


-- I want to see how many bikes has been added each year.
WITH my_table as
(SELECT bikeid
      , MIN(EXTRACT(year from starttime)) as _year
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime is not null
GROUP BY 1)
SELECT _year, count(bikeid)
FROM my_table
GROUP BY 1
ORDER BY 1;



