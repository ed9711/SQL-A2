-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)

drop view if exists not_winning cascade;
create temp view not_winning as 
	select distinct e1.id, e1.election_id, e1.party_id, e1.alliance_id, e1.seats, e1.votes, e1.description 
	from election_result e1, election_result e2 
	where e1.election_id = e2.election_id and e1.votes < e2.votes;


drop view if exists winning cascade;
create temp view winning as
	select election_result.party_id, election_result.election_id
	from election_result LEFT JOIN not_winning on election_result.id = not_winning.id
	where not_winning.id is null and election_result.votes is not null;

drop view if exists party_count cascade;
create temp view party_count as
	select party_id, count(election_id) as wins
	from winning
	group by party_id;

DROP VIEW IF EXISTS avg_win CASCADE;

-- Define views for your intermediate steps here.

create temp view avg_win as 
	select country.id as country_id, avg(wins)
	from country, party_count, party
	where party.id = party_count.party_id and party.country_id = country.id
	group by country.id;




-- the answer to the query 
insert into q2 


