-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS elections19962016 CASCADE;

-- Define views for your intermediate steps here.

create TEMP VIEW elections19962016 as 
	select extract(year from e_date) as year, country_id, party_id, votes/votes_valid::float * 100 as votes
	from election, election_result
	where election_result.election_id = election.id and 1996 <= extract(year from e_date) and extract(year from e_date) <= 		2016;	

DROP VIEW IF EXISTS with_names CASCADE;

create TEMP VIEW with_names as 
	select year, name as countryName, votes, name_short as partyName
	from elections19962016, party, country
	where party.id = party_id and country.id = country_id;

DROP table IF EXISTS range CASCADE;

create table range (
lowerb INT,
upperb INT,
bound VARCHAR(10)
);
insert into range values
(0, 5, '(0-5]'),
(5, 10, '(5-10]'),
(10, 20, '(10-20]'),
(20, 30, '(20-30]'),
(30, 40, '(30-40]'),
(40, 100, '(40-]');


	
-- the answer to the query 
insert into q1 select year, countryName, bound as voteRange, partyName
		from with_names, range
		where votes > lowerb and votes <= upperb; 

