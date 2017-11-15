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

drop view if exists win_count cascade;
create temp view win_count as
	select winning.party_id, count(election_id) as wins, avg(party.country_id) as country_id
	from winning, party
	where party.id = winning.party_id
	group by winning.party_id;

DROP VIEW IF EXISTS avg_win CASCADE;

-- Define views for your intermediate steps here.

create temp view avg_win as 
	select country.id as country_id, sum(wins)/avg(party_count.count) as avg_wins
	from country, win_count, (select country_id, count(id) 
								from party 
								group by country_id) as party_count
	where win_count.country_id = country.id and party_count.country_id = win_count.country_id
	group by country.id;

drop view if exists answer cascade;
create temp view answer as
	select win_count.country_id, win_count.party_id, win_count.wins
	from win_count, avg_win
	where win_count.country_id = avg_win.country_id and win_count.wins > 3*avg_wins;
	
drop view if exists recentWon cascade;
create temp view recentWon as
	select answer.party_id, elec.dates as dates, elec.id as election_id
	from answer, winning, (election join (select answer.party_id, max(e_date) as dates, avg(election.country_id) as c_id
										from answer, winning, election
										where answer.party_id = winning.party_id and winning.election_id = election.id
										group by answer.party_id) as max_date on election.e_date = max_date.dates 
										and c_id = country_id) as elec
	where answer.party_id = winning.party_id and winning.election_id = elec.id;

drop view if exists combine cascade;
create temp view combine as 
	select country_id, answer.party_id as party_id1, wins, dates, election_id
	from answer, recentWon
	where answer.party_id = recentWon.party_id;
	

-- the answer to the query 
insert into q2 
	select distinct country.name as countryName, party.name as partyName, pt.family as partyFamily,
		pt.wins as wonElections, pt.election_id as mostRecentlyWonElectionId, 
		extract(year from pt.date) as mostRecentlyWonElectionYear
	from country, (party_family right join combine on party_family.party_id = combine.party_id1) as pt, party
	where pt.country_id = country.id and party.id = pt.party_id1;


