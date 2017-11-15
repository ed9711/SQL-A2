-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS cabinet20 CASCADE;

-- Define views for your intermediate steps here.

create temp view cabinet20 as
	select id, country_id
	from cabinet
	where extract(year from start_date) >= 1997;

	
drop view if exists number_cabinet cascade;
create temp view number_cabinet as
	select party_id, count(cabinet20.id) as num_cabinet
	from cabinet20, cabinet_party
	where cabinet20.id = cabinet_party.cabinet_id
	group by party_id;

drop view if exists answer cascade;
create temp view answer as
	select party.id, party.country_id
	from number_cabinet, cabinet20, party, (select country_id, count(id) as c_count 
						from cabinet20
						group by country_id) as c_count  
	where number_cabinet.num_cabinet = c_count
		and party.id = number_cabinet.party_id 
		and party.country_id = c_count.country_id;

-- the answer to the query 
insert into q5 
	select country.name as countryName, pt1.name as partyName, pt1.family as partyFamily, pt1.state_market as stateMarket
	from country, answer, ((party left join party_family on party.id = party_family.party_id) as pt 
		left join party_position on pt.id = party_position.party_id) as pt1
	where country.id = answer.country_id and pt1.id = answer.id;
