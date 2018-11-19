-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS party_info CASCADE;

create view party_info as 
	select p.id, c.name, pp.left_right
	from party p join country c on p.country_id = c.id join party_position pp on p.id = pp.party_id;

create view nullvalues as
	select name, count(left_right) as "r0_2", count(left_right) as "r2_4", count(left_right) as "r4_6", count(left_right) as "r6_8", count(left_right) as "r8_10"
	from party_info
	where left_right is null
	group by name;

-- Define views for your intermediate steps here.
create view zeroTwo as
	select name, count(left_right) as "r0_2"
	from party_info
	where left_right >= 0 and left_right < 2
	group by name;

create view twoFour as
	select name, count(left_right) as "r2_4"
	from party_info
	where left_right >= 2 and left_right < 4
	group by name;

create view fourSix as
	select name, count(left_right) as "r4_6"
	from party_info
	where left_right >= 4 and left_right < 6
	group by name;

create view sixEight as
	select name, count(left_right) as "r6_8"
	from party_info
	where left_right >= 6 and left_right < 8
	group by name;

create view eightTen as 
	select name, count(left_right) as "r8_10"
	from party_info
	where left_right >= 8 and left_right < 10
	group by name;

create view intermediate_step as 
	select zt.name, "r0_2", "r2_4", "r4_6", "r6_8", "r8_10"
	from zeroTwo zt join twoFour tf on zt.name = tf.name join fourSix fs on fs.name = zt.name join sixEight se on se.name = zt.name join eightTen et on et.name = zt.name;


create view final as
	select * from intermediate_step union
	select * from nullvalues;

-- the answer to the query 
INSERT INTO q4 

