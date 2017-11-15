-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS ratio_election CASCADE;

-- Define views for your intermediate steps here.

create temp view ratio_election as 
	select id, country_id, e_date, votes_cast/electorate::float  as p_ratio
	from election
	where electorate is not null and votes_cast is not null;

drop view if exists same_year cascade;
create temp view same_year as
	select r1.country_id, avg(r1.p_ratio) as p_ratio, extract(year from r1.e_date)
	from ratio_election r1
	group by r1.country_id, extract(year from r1.e_date);

drop view if exists 2001to2016 cascade;
create temp view 2001to2016 as
	select country_id, p_ratio, year
	from same_year
	where year <= 2016 and year >= 2001;
	
drop view if exists decreasing cascade;
create temp view decreasing as
	select distinct t1.country_id
	from 2001to2016 t1, 2001to2016 t2
	where t1.country_id = t2.country_id and t1.year < t2.year and t1.p_ratio > t2.p_ratio;

-- the answer to the query 
insert into q3 
	select country.name as countryName, 2001to2016.year as year, 2001to2016.p_ratio as participationRatio
	from 2001to2016, country
	where not exists (select 1 
						from decreasing
						where decreasing.country_id = 2001to2016.country_id)
			and 2001to2016.country_id = country.id;

