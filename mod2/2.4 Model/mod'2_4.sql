create table shipping_dim
(
ship_id serial not null,
ship_mode varchar(14) not null,
constraint PK_Shipping primary key ( ship_id ) 

);


--clean table
truncate table shipping_dim;


--insert unique values + generate_id
insert into shipping_dim 
select 100+row_number() over (), ship_mode from (select distinct ship_mode from orders) a;


--check data 
select * from shipping_dim;




