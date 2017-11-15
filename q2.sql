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
	select party_count.party_id, count(election_id) as wins, county_id
	from winning, party
	where party.id = party_count.party_id
	group by party_count.party_id;

DROP VIEW IF EXISTS avg_win CASCADE;

-- Define views for your intermediate steps here.

create temp view avg_win as 
	select country.id as country_id, avg(wins) as avg_wins
	from country, party_count
	where party_count.country_id = country.id
	group by country.id;

drop view if exists answer cascade;
create temp view answer as
	select party_count.country_id, party_count.party_id, party_count.wins
	from party_count, avg_win
	where party_count.country_id = avg_win.country_id and party_count.win > 3*avg_wins;
	
drop view if exists recentWon cascade;
create temp view recentWon as
	select 
	from party_count, winning


-- the answer to the query 
insert into q2 
	select countryName, partyName, partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear
	from country, party, answer, party_family, election


