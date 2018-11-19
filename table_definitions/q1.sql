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
DROP VIEW IF EXISTS votes_validNull, votes_validNotNullCalculated, votes_validNotNullFromStart, votes_validFinal CASCADE;
DROP VIEW IF EXISTS VoteForParty CASCADE;
DROP VIEW IF EXISTS part1 CASCADE;
DROP VIEW IF EXISTS part2a CASCADE;
DROP VIEW IF EXISTS part2b CASCADE;
DROP VIEW IF EXISTS ranges CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- get the electionId, country_id and the date where votes_valid is not given from election.
create view votes_validNull as
	select id, country_id, e_date
	from election
	where votes_valid is null;

-- Calculate the votes_valid for every election in, 'votes_validNull.'
create view votes_validNotNullCalculated as 
	SELECT vvn.id, vvn.country_id, vvn.e_date, sum(votes) as votes_valid
	FROM election_result, votes_validNull vvn
	WHERE election_result.election_id = vvn.id
	group by vvn.id, vvn.country_id, vvn.e_date;

-- elections that do not have votes_valid as null from the start.
create view votes_validNotNullFromStart as
	select id, country_id, e_date, votes_valid
	from election e
	where votes_valid is not null;

-- combine, 'votes_validNotNullCalculated' and 'votes_validNotNullFromStart' to get all elections with votes_valid as not null.
create view votes_validFinal as
	select * from votes_validNotNullCalculated calculated union select * from votes_validNotNullFromStart fromStart;

-- election_results that account for the # of votes recieved by a party.
create view VoteForParty as
	select election_id, party_id, votes
	from election_result
	where votes is not null;

-- get the vote % of each party from each country for each election from 1996 - 2016.
create view part1 as 
	select e_date, e.country_id, party_id, (VoteForParty.votes * 1.0/votes_valid * 1.0) * 100.0 as vote_percentage 	
	from votes_validFinal e join country on e.country_id = country.id join VoteForParty on e.id = election_id join party on party_id = party.id	
	where extract(year from e.e_date) >= '1996' and extract(year from e.e_date) <= '2016';

-- get the avg vote % of each party from each country for all years.
create view part2a as 
	select extract(year from e_date) as year, country_id, party_id, avg(vote_percentage) as percentage	
	from part1 		
	group by extract(year from e_date), country_id, party_id;

-- convert the percentages into vote ranges.
create view ranges as 
	select p2a.year as year, p2a.country_id, p.name_short as partyName, 
		case 
			when 0 < percentage and percentage <= 5 then '(0-5]' 
			when 5 < percentage and percentage <= 10 then '(5-10]'	 
			when 10 < percentage and percentage <= 20 then '(10-20]' 
			when 20 < percentage and percentage <= 30 then '(20-30]' 
			when 30 < percentage and percentage <= 40 then '(30-40]'
			when 40 < percentage and percentage <= 100 then '(40-100]' 
		end 
		as voteRange	
	from part2a p2a join party p on p2a.party_id = p.id;

create view answer as 
	select r.year, c.name as countryName, voteRange, r.partyName 
	from ranges r join country c on r.country_id = c.id;

insert into q1(select * from answer);
