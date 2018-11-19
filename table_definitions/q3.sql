-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS p_ratios CASCADE;
DROP VIEW IF EXISTS possible_date_countries CASCADE;
DROP VIEW IF EXISTS invalid_pairs_countries CASCADE;
DROP VIEW IF EXISTS valid_countries CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- Define views for your intermediate steps here.

create view p_ratios as(
	select avg(cast(votes_cast as real) / (cast (electorate as real))) as p_ratio, EXTRACT(YEAR FROM e_date) as yr, country_id
	from election
	group by EXTRACT(YEAR FROM e_date), country_id
);

create view possible_date_countries as(
	select country_id 
	from election
	where extract(year from e_date) >= 2001 and extract(year from e_date) <= 2016
);

create view invalid_pairs_countries as(
	select p1.country_id as country_id
	from p_ratios p1, p_ratios p2
	where p1.yr < p2.yr and p1.country_id = p2.country_id and p1.p_ratio > p2.p_ratio and p1.yr >= 2001 and p2.yr <= 2016
);


create view valid_countries as(
	(select *
		from possible_date_countries)
	except
	(select *
		from invalid_pairs_countries)
);

create view subanswer as(
	select country_id as id, yr as year, p_ratio as participationRatio
	from p_ratios natural join valid_countries
);

create view answer as (
	select name as countryName, year, participationRatio
	from subanswer natural join country
);

-- the answer to the query 
insert into q3(countryName, year, participationRatio)
	select *
	from answer;


