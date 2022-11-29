-- download data from ( https://www.kaggle.com/code/vedanthbaliga/bangalore-house-price-prediction )
-- 1st create database and then import th file
-- then import the download file.


create database House_Price;
use House_Price;


-- let's see the table  
select * from bengaluru_house_prices;


-- drop the unnecessary column
alter table bengaluru_house_prices 
drop column availability,
drop column society,
drop column balcony;


-- count the numbers of record.
select count(*) from bengaluru_house_prices;


-- count the number of record which contian null values.
select count(*) from bengaluru_house_prices
where (area_type = ''
or location = ''
or size = ''
or total_sqft = ''
or bath = ''
or price = '');


-- remove records which caontain null values.
delete from bengaluru_house_prices
where (area_type = ''
or location = ''
or size = ''
or total_sqft = ''
or bath = ''
or price = '');



-- remove duplicate records.
create table bengaluru_house_prices_bkp as
select distinct * from bengaluru_house_prices;   
select count(*) from bengaluru_house_prices_bkp;
truncate table bengaluru_house_prices;
insert into bengaluru_house_prices
select * from bengaluru_house_prices_bkp;
drop table bengaluru_house_prices_bkp;


-- check duplicate records. 
select * from bengaluru_house_prices
group by 1,2,3,4,5,6
having count(*) > 1;



-- delete inconsistent values from column total_sqft
delete from bengaluru_house_prices 
where total_sqft like '%-%' or  
total_sqft rlike '[A-Z]';


-- change total_sqft to float datatype then delete ouliners
alter table bengaluru_house_prices 
modify column total_sqft float;
delete from	bengaluru_house_prices
where total_sqft > 10890 or
total_sqft < 816.752;

select * from bengaluru_house_prices ;


show fields from bengaluru_house_prices;


-- change column size to from text to integer.
SET autocommit=0;
LOCK TABLES bengaluru_house_prices WRITE;
alter table bengaluru_house_prices add column new_size int default null;
update bengaluru_house_prices 
set new_size = REGEXP_SUBSTR(size,"[0-9]+") ;
alter table bengaluru_house_prices drop column size ;
COMMIT;
UNLOCK TABLES;

delete from bengaluru_house_prices
where new_size > 20;



select * from bengaluru_house_prices;









-- ABOUT DATASET
-- dataset name: Bangalore House Price
-- uploaded by: VEDANTH BALIGA
-- downloaded from: kaggle