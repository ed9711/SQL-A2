-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS r0_2 CASCADE;

-- Define views for your intermediate steps here.
create temp view r0_2 as
	select country_id, count(left_right) as r0_2
	from party, party_position
	where party.id = party_position.party_id and left_right > 0 and left_right <= 2
	group by country_id;

	
drop view if exists r2_4 cascade;
create temp view r2_4 as
	select country_id, count(left_right) as r2_4
	from party, party_position
	where party.id = party_position.party_id and left_right > 2 and left_right <= 4
	group by country_id;
	
	
drop view if exists r4_6 cascade;
create temp view r4_6 as
	select country_id, count(left_right) as r4_6
	from party, party_position
	where party.id = party_position.party_id and left_right > 4 and left_right <= 6
	group by country_id;
	
	
drop view if exists r6_8 cascade;
create temp view r6_8 as
	select country_id, count(left_right) as r6_8
	from party, party_position
	where party.id = party_position.party_id and left_right > 6 and left_right <= 8
	group by country_id;
	
	
drop view if exists r8_10 cascade;
create temp view r8_10 as
	select country_id, count(left_right) as r8_10
	from party, party_position
	where party.id = party_position.party_id and left_right > 8 and left_right <= 10
	group by country_id;
-- the answer to the query 
INSERT INTO q4 
	select country.name as countryName, r0_2, r2_4, r4_6, r6_8, r8_10
	from country, r0_2, r2_4, r4_6, r6_8, r8_10
	where country.id = r0_2.country_id and country.id = r2_4.country_id and country.id = r4_6.country_id 
		and country.id = r6_8.country_id and country.id = r8_10.country_id;

