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
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS part1 CASCADE;

-- Define views for your intermediate steps here.

-- table containing partyid, votes earned by a party, total votes, countryid and date
create view part1 as 
	select e.e_date, e.country_id, e.votes_valid, er.party_id, er.votes 	
	from election e join election_result er on e.id = er.id 	
	where extract(year from e.e_date) >= 1996 and extract(year from e.e_date) <= 2016;

create view part2a as 
	select extract(year from e_date) as year, country_id, sum(votes_valid) as tvotes	
	from part1 		
	group by extract(year from e_date), country_id;

create view part2b as 
	select extract(year from p1.e_date) as year, p1.country_id, party_id, (cast(votes as decimal(10, 2))/cast(p2a.tvotes as decimal(10, 2)))*100 as percentage 
	from part1 p1 join part2a p2a on extract(year from p1.e_date) = p2a.year and p1.country_id = p2a.country_id;

create view ranges as 
	select p2b.year as year, p2b.country_id, p.name_short as partyName, 
		case 
			when 0 < percentage and percentage <= 5 then '(0-5]' 
			when 5 < percentage and percentage <= 10 then '(5-10]'	 
			when 10 < percentage and percentage <= 20 then '(10-20]' 
			when 20 < percentage and percentage <= 30 then '(20-30]' 
			when 30 < percentage and percentage <= 40 then '(30-40]'
			when 40 < percentage and percentage <= 100 then '(40-100]' 
		end 
		as voteRange	
	from part2b p2b join party p on p2b.party_id = p.id;

create view answer as 
	select r.year, c.name as countryName, voteRange, r.partyName 
	from ranges r join country c on r.country_id = c.id;

-- the answer to the query 
insert into q1(select * from answer);

