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

--and election_result.votes * 100.0/votes_valid <=5
-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS average, zero, five, ten, twenty, thirty, forty, percentage, answer CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW percentage AS (
SELECT date_part('year', e_date) as year, country.name as country_name, election_result.votes * 100.0/votes_valid as vote_percentage, party.name as party_name
FROM election JOIN country on country_id = country.id JOIN election_result on election.id = election_id join party on party_id = party.id
WHERE e_date >= '1996-01-01' and e_date <= '2016-12-31'
);

-- satisfy important1: If there is more than one election in the same country in the same year, report the average of the percent of valid votes that a party received across those elections. 
--aggregation?
create view average as (
select year, country_name, avg(vote_percentage) as voteRange, party_name 
from percentage
group by year, country_name, party_name
);

create view zero as (
select year, country_name, '(0,5]'::varchar(20), party_name
from average
where voteRange > 0 and voteRange <= 5
);

create view five as (
select year, country_name, '(5,10]'::varchar(20), party_name
from average
where voteRange > 5 and voteRange <= 10
);

create view ten as (
select year, country_name, '(10,20]'::varchar(20), party_name
from average
where voteRange > 10 and voteRange <= 20
);
 
create view twenty as (
select year, country_name, '(20,30]'::varchar(20), party_name
from average
where voteRange > 20 and voteRange <= 30
);

create view thirty as (
select year, country_name, '(30,40]'::varchar(20), party_name
from average
where voteRange > 30 and voteRange <= 40
);
 
create view forty as (
select year, country_name, '(40,100]'::varchar(20), party_name
from average
where voteRange > 40 and voteRange <= 100
);

create view answer as(
select *
from zero
union
select *
from five
union
select *
from ten
union
select *
from twenty
union
select *
from thirty
union
select *
from forty
);

-- the answer to the query 
insert into q1(year, countryName, voteRange, partyName)
select *
from answer
