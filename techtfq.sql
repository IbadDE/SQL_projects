SELECT COUNT(*) as Total_Games
FROM athlete_events;


SELECT DISTINCT year as year, season, city
FROM athlete_events;


SELECT games, COUNT(DISTINCT region) number_of_nations
FROM athlete_events ae
JOIN noc_regions ng
ON ae.noc = ng.noc
GROUP BY games
ORDER BY games;


with cnt as 
(	SELECT ae.games, COUNT(DISTINCT nr.region) number_of_nations
	FROM athlete_events ae
 	JOIN noc_regions nr
 	ON ae.noc = nr.noc
	GROUP BY games
	Order BY games)
SELECT CONCAT(FIRST_VALUE(games) OVER(ORDER BY number_of_nations), ' - ',
		FIRST_VALUE(number_of_nations) OVER(ORDER BY number_of_nations)) as min_nations,
		CONCAT(FIRST_VALUE(games) OVER(ORDER BY number_of_nations desc), ' - ',
		FIRST_VALUE(number_of_nations) OVER(ORDER BY number_of_nations desc)) max_nations
FROM cnt
LIMIT 1;





SELECT nr.region, COUNT(DISTINCT ae.games)
FROM athlete_events ae
JOIN noc_regions nr
ON nr.noc = ae.noc
GROUP BY nr.region
HAVING COUNT(DISTINCT ae.games) = (SELECT COUNT(DISTINCT games) as total_games
FROM athlete_events ae);






SELECT sport,COUNT(DISTINCT games)
FROM athlete_events
WHERE season = 'Summer'
GROUP BY sport
HAVING COUNT(DISTINCT games) = (SELECT COUNT(DISTINCT games) as total_games
FROM athlete_events
WHERE season = 'Summer');


with tbl1 as(
SELECT sport, count(distinct games) as cnt
from athlete_events
group by sport),
tbl2 as(
SELECT DISTINCT sport, games
FROM athlete_events)
SELECT t1.sport, t1.cnt, t2.games 
FROM tbl1 t1
JOIN  tbl2 t2
ON t1.sport = t2.sport
WHERE cnt = 1;



SELECT games, COUNT(DISTINCT sport) as number_of_sports
FROM athlete_events
GROUP BY games
ORDER BY number_of_sports DESC;


ALTER TABLE athlete_events
ALTER COLUMN age TYPE int USING CAST(CASE WHEN age = 'NA' then '0' else age end  as int)
WITH tbl1 as(
SELECT RANK() OVER(ORDER BY age DESC) as rnk,*
FROM athlete_events
WHERE medal = 'Gold')
SELECT * FROM tbl1
WHERE rnk = 1


with unique_name as
(SELECT DISTINCT name,sex
FROM athlete_events),
cnt as(
SELECT COUNT(CASE WHEN sex = 'M' THEN 'male' end)::decimal as male_count,
		COUNT(CASE WHEN sex = 'F' THEN 'Female' end)::decimal as female_count
FROM unique_name)
SELECT concat('1', ' : ',round(male_count/female_count,2))
FROM cnt

with tbl1 as
(SELECT name, team,count(*) as cnt
FROM athlete_events
WHERE medal = 'Gold'
GROUP BY name, team),
tbl2 as
(SELECT *, RANK() OVER(ORDER BY cnt DESC) as rnk
FROM tbl1)
SELECT name, team,cnt
FROM tbl2
WHERE rnk <= 5


with tbl1 as
(SELECT name, team,count(*) as cnt
FROM athlete_events
WHERE medal <> 'NA'
GROUP BY name, team),
tbl2 as
(SELECT *, RANK() OVER(ORDER BY cnt DESC) as rnk
FROM tbl1)
SELECT name, team,cnt
FROM tbl2
WHERE rnk <= 5


with tbl1 as
(SELECT team,count(*) as cnt
FROM athlete_events
WHERE medal <> 'NA'
GROUP BY team),
tbl2 as
(SELECT *, RANK() OVER(ORDER BY cnt DESC) as rnk
FROM tbl1)
SELECT team,cnt
FROM tbl2
WHERE rnk <= 5




select * from athlete_events
select * from noc_regions

