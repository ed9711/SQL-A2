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
create temp vie same_year as
	select r1.country_id, avg(r1.p_ratio), extract(year from r1.e_date)
	from ratio_election r1
	group by r1.country_id, extract(year from r1.e_date);


-- the answer to the query 
insert into q3 

