-- Query 1
-- A leading beverage company has announced a billion-dollar fund for removing debris
-- from forests, rivers and mountains in the US. All states are interested.
-- Which 2 states have the least chance to win a share of the fund?
-- Translation: States with less count of fires caused by debris burning have less chance of the fund
-- Cleanup: select state, count of fires from fires join cause where cause description is 'Debris Burning'
-- sorting by count of fires ascending order and limit 2
use Project1;
select f.STATE
from Fires f join Cause c on f.STAT_CAUSE_CODE = c.STAT_CAUSE_CODE
where c.STAT_CAUSE_DESCR in ('Debris Burning')
group by f.STATE
ORDER BY count(f.FOD_ID) ASC
limit 2;

-- Query 2
-- One of the reporting agencies has suggested that children be banned from its forests 
-- unless there is one adult for every 4 children in a group visiting a forest.
-- Name top 5 forests where this would be the least appropriate.
-- Assumption 1: forests with most fires caused by other causes apart from children will be inappropriate places
-- Assumption 2: higher the non-chidren fire count, lesser appropriate they are 
-- Translation: select the forest where the fires are not caused by children and does not require the ban
-- Cleanup: select Forest from Reporting, Fires and Cause where cause description is not children
-- group by forest order by count of fires limit 5
use Project1;
select distinct r.SOURCE_REPORTING_UNIT_NAME as 'Forest'
from Reporting r join Fires f1 on r.FOD_ID = f1.FOD_ID
join Cause c on f1.STAT_CAUSE_CODE = c.STAT_CAUSE_CODE 
where c.STAT_CAUSE_DESCR not like 'Children' 
group by Forest 
order by count(r.fod_id) desc
limit 5;

-- Query 3
-- One advocacy group says human actions and nature are equally to blame for most wildfires.
-- Write a query that can help determine the truth of this statement.
-- Translation: Compare fires caused by lightening and other human reasons
-- Assumption 1: Natural cause is lightening alone
-- Assumption 2: Human cause is everything apart from lightening, misc and undefined
-- Clean up: select 
-- count of fires from fires join causes where cause description is 'Lightning' grouped by cause description
-- displayed as 'Natural cause' and sum of counts as 'Human caused' from
-- count, cause description from fires join cause group by cause description having cause description not in
-- 'Lightning', 'Miscellaneous', 'Missing/Undefined' 
use project1;
select (select count(f.FOD_ID)
from fires f join cause c on f.STAT_CAUSE_CODE = c.STAT_CAUSE_CODE
where c.STAT_CAUSE_DESCR = 'Lightning'
group by f.STAT_CAUSE_CODE
)  as 'Natural Caused', sum(count2) as 'Human Caused'
from (
select count(f.FOD_ID) as 'count2', c.STAT_CAUSE_DESCR
from fires f join cause c on f.STAT_CAUSE_CODE = c.STAT_CAUSE_CODE
group by f.STAT_CAUSE_CODE having c.STAT_CAUSE_DESCR not in ('Lightning','Miscellaneous','Missing/Undefined')
) as counts;

-- Query 4
-- What are the top two unit types that reported wildfires in each state in the US? 

-- Query 5
-- How many wildfires were reported by at least two units/agencies?

-- Query 6
-- What were the forests that had only one fire that lasted more than two days?
-- Translation: select forest from reporting join fires where contained day minus discovered day is greater than 2
-- group by forest having count = 1
-- Clean up: select source reporting unit name from reporting join fires where contained day minus discovered day
-- is greater than 2 group by source reporting unit name having count = 1
use project1;
select r.SOURCE_REPORTING_UNIT_NAME as 'Forest'
from reporting r join fires f on r.fod_id = f.fod_id
where f.CONT_DOY - f.DISCOVERY_DOY > 2
group by r.SOURCE_REPORTING_UNIT_NAME
having count(f.FOD_ID) = 1;

-- Query 7
-- Which state had fires only in the second half of the calendar years?
-- Translation: select states from Fires with discovery date in second half of year only
-- Cleanup: select state from Fires where Discovery Day of Year is between 183 and 366 and state is not in
-- select state from fires where discovery say of the year is between 1 and 183
-- Assumption1: For non leap years the second half of the year is from 183 to 365
use Project1;
select distinct f1.state from fires f1
where f1.DISCOVERY_DOY BETWEEN 183 AND 366
and not exists (
select 1 from fires f2
where f2.DISCOVERY_DOY BETWEEN 1 AND 183
and f1.FIRE_YEAR = f2.FIRE_YEAR);

-- Query 8
-- Which forest had the number of fires equal to the average number of wild fires in the US?
-- Translation: Select forests in source reporting unit name from reporting with sum of fires reported equal to
-- average number of fires in the us
-- Assumption 1: All fires in given table are from US
-- Assumption 2: Since there so many records, we will not exact match for average value
-- Assumption 3: For business, lets find forests with above average count 
-- Clean up: Select source reporting unit name from reporting where sum of fires reported equal to
-- select average of fires from reporting
use project1;
select SOURCE_REPORTING_UNIT_NAME
from reporting
group by SOURCE_REPORTING_UNIT_NAME
having count(*) > (
select avg(count)
from ( select count(*) as count
from reporting
group by SOURCE_REPORTING_UNIT_NAME
) as counts
);