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
DROP VIEW IF EXISTS numElectionInACountry, numPartiesInACountry, average CASCADE;

-- Define views for your intermediate steps here.
create view numElectionInACountry as 
	select c.id, count(*) as numelections
	from election e join country c on e.country_id = c.id 
	group by c.id;

create view numPartiesInACountry as 
	select c.id, count(*) as numparties
	from party p join country c on p.country_id = c.id 
	group by c.id;

create view average1 as
	select numParties.id as country_id, (numElections.numelections * 1.0) / 	 (numParties.numparties * 1.0) as average
	from numPartiesInACountry numParties join numElectionInACountry numElections on
	numParties.id = numElections.id;
	

create view threeOrMoreAvgWins as
	select wp.country_id, wp.party_id, count(pm)
	from winnerParties wp
	group by wp.country_id, wp.party_id;
	
-- create view threeOrMore as
--	select a.country_id as country_id, er.party_id as party_id, count(*) as numwins, --		a.average
--	from election e join election_result er on e.id = er.election_id join average a on 		e.country_id = a.country_id
--	group by er.party_id, a.country_id, a.average
--	having count(*) > 3.0 * a.average;

-- the answer to the query 
insert into q2 


