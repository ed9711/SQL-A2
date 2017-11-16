-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.

CREATE TABLE q6(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP view IF EXISTS ordered CASCADE;

-- Define views for your intermediate steps here.
create temp view ordered as
	select c1.id, c1.country_id, c1.start_date, c2.start_date as end_date 
	from cabinet c1 left join cabinet c2 on c1.id = c2.previous_cabinet_id;
	
drop view if exists withPmParty cascade;
create temp view withPmParty as
	select ordered.id, ordered.country_id, ordered.start_date, ordered.end_date, cabinet_party.party_id as party_id
	from ordered left join cabinet_party on cabinet_party.cabinet_id = ordered.id and cabinet_party.pm = True;



-- the answer to the query 
insert into q6 
	select country.name as countryName, withPmParty.id as cabinetId, withPmParty.start_date as startDate, 
		withPmParty.end_date as endDate, party.name as pmParty
	from withPmParty, country, party
	where withPmParty.country_id = country.id and withPmParty.party_id = party.id;
