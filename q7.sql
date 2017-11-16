-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS allied CASCADE;

-- Define views for your intermediate steps here.
create temp view allied as
	select e1.party_id as ally1, e2.party_id as ally2
	from election_result e1, election_result e2
	where (e1.id = e2.alliance_id and e1.election_id = e2.election_id) 
		or (e1.alliance_id = e2.alliance_id and e1.election_id = e2.election_id and e1.party_id < e2.party_id);
	
	
drop view if exists election_count cascade;
create temp view election_count as
	select country_id, count(id)
	from election
	group by country_id;
	
drop view if exists ally_count cascade;
create temp view ally_count as
	select ally1, ally2, count(*)
	from allied
	group by ally1, ally2;


-- the answer to the query 
insert into q7 
	select party.country_id as countryId, ally1 as alliedPartyId1, ally2 as alliedPartyId2
	from election_count, ally_count, party
	where party.id = ally_count.ally1 and party.country_id = election_count.country_id 
		and ally_count.count >= election_count.count * 0.3;
