/* BRT is a public transport for the people of Peshawar, Pakistan. In this Project I created database, which will help BRT managment
to record the data, and in future after analysis BRT can save and earn millions of ruppes(pkr). Further it can provide satisfiction
to it's customer. It can also track the records of it's employee work. */



drop database if exists BRT;  							-- to ignore error
create database BRT;  									-- create database 
use BRT;												-- select brt database


drop table if exists bus_info;							-- to ignore error
create table bus_info									-- this table contain information about BUS
(
	bus_id varchar(16) unique not null,					-- every unique bus has their own route 
    initial_stop varchar(32), 							-- the 1st stop of bus
    final_stop varchar(32),								-- final destination of bus	
    start_time DATE,									-- time when bus started
    reach_time Date, 									-- time at bus reach it's final destination
    route_line int,										-- every bus has it's own route
    route_type varchar(10),								-- there are two type of route main route and feeder route
    primary key (bus_id)								
);


drop table if exists rider_info;
create table rider_info										-- this table contain info about customer
(
	rider_id int unique not null,							-- rider have unique number
    type varchar(8),										-- ride type are either casual or membership
    Gender varchar(8),
    primary key (rider_id)
);


drop table if exists Driver_info;
create table Driver_info									-- this table conatain info about driver 
(
	driver_id int,											-- every driver has it's own unique number
	first_name varchar(16),
	last_name varchar(16),
	age int,
	gender varchar(8),
    contact_numeber int,
    email varchar(32),
    primary key (driver_id)
);


drop table if exists Ride;
create table Ride													-- this table contain how customer use BRT	
(
	bus_id varchar(32) not null,										
    driver_id int,
    rider_id int,
    on_station varchar (32),									-- station at which customer start it's ride
    off_station varchar (32),									-- station at which customer end it's ride
    on_time datetime,											-- when customer enter the station
    off_time datetime,											-- when customer out from the station
    foreign key (bus_id) references bus_info(bus_id),			-- connecting tables ride and bus_info
    foreign key (rider_id) references rider_info(rider_id),		-- connectine tables ride and rider_info
    foreign key (driver_id) references driver_info(driver_id)	-- connecting tables ride and driver_info
);

    

drop table if exists route_info;
create table route_info											-- this table contain which stations names exists on each route.
(
	bus_id varchar(16),											-- this will be repeated many times here.
	station_name varchar(32),									-- stations names
    foreign key (bus_id) references bus_info(bus_id)
);



