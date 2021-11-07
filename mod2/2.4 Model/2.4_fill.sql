

create schema sch;




-- ************************************** sch.shipping_dim
drop table if exists sch.shipping_dim ;

CREATE TABLE sch.shipping_dim
(
 ship_id   serial NOT NULL,
 ship_mode varchar(50) NOT NULL,
 CONSTRAINT PK_95 PRIMARY KEY ( ship_id )
);






--deleting rows
truncate table sch.shipping_dim;

--generating ship_id and inserting ship_mode from orders
insert into sch.shipping_dim 
select 100+row_number() over(), ship_mode from (select distinct ship_mode from orders ) a;
--checking
select * from sch.shipping_dim s; 






-- ************************************** sch.customer_dim

drop table if exists sch.customer_dim;
CREATE TABLE sch.customer_dim
(
 cust_id       int NOT NULL,
 customer_name varchar(50) NOT NULL,
 customer_id   varchar(200) NOT NULL, 
 CONSTRAINT PK_34 PRIMARY KEY ( cust_id )
);


--deleting rows
truncate table sch.customer_dim;


--inserting
insert into sch.customer_dim 
select 100+row_number() over(), customer_name, customer_id from (select distinct customer_name, customer_id from orders ) a;


--checking
select * from sch.customer_dim cd;  


-- ************************************** sch.geo_dim

drop table if exists sch.geo_dim;

CREATE TABLE sch.geo_dim
(
 geo_id      serial NOT NULL,
 country     varchar(50) NOT NULL,
 city        varchar(50) NULL,
 "state"       varchar(50) NULL,
 region      varchar(50) NULL,
 postal_code varchar(50) NULL,
 CONSTRAINT PK_46 PRIMARY KEY ( geo_id )
);


--deleting rows
truncate table sch.geo_dim;


--generating geo_id and inserting rows from orders
insert into sch.geo_dim 
select 100+row_number() over(), country, city, state, region, postal_code from (select distinct country, city, state, region, postal_code from orders ) a;


-- data quality check
select distinct city, postal_code from orders o
where country is null or city is null or state is null or region is null or postal_code is null;


-- Fill fiealed postal_code in City Burlington 
update sch.geo_dim 
set postal_code = '05401'
where city = 'Burlington' and postal_code is null;


-- Fill fiealed postal_code in City Burlington 
update public.orders
set postal_code = '05401'
where city = 'Burlington' and postal_code is null;



select * from sch.geo_dim gd;  


-- ************************************** sch.product_dim
drop table if exists sch.product_dim;

CREATE TABLE sch.product_dim
(
 prod_id      serial NOT NULL,
 product_id   varchar NOT NULL,
 product_name varchar NOT NULL,
 category     varchar NULL,
 sub_category varchar NULL,
 segment      varchar NOT NULL,
 CONSTRAINT PK_40 PRIMARY KEY ( prod_id )
);



--deleting rows
truncate table sch.product_dim;

--generating prod_id and inserting rows from orders
insert into sch.product_dim 
select 100+row_number() over () as prod_id ,product_id, product_name, category, subcategory, 
segment from (select distinct product_id, product_name, category, subcategory, segment from orders ) a;

--checking
select * from sch.product_dim pd;  

-- ************************************** sch.calendar_dim

drop table if exists sch.calendar_dim;


CREATE TABLE sch.calendar_dim
(
 date_id  serial NOT NULL,
 year     int NOT NULL,
 quater   int NOT NULL,
 month    int NOT NULL,
 week     int NOT NULL,
 "date"     date NOT NULL,
 week_day varchar(50) NOT NULL,
 leap     varchar(50) NOT NULL,
 CONSTRAINT PK_5 PRIMARY KEY ( date_id )
);


--deleting rows
truncate table sch.calendar_dim;



--create data for calendar_dim
--
insert into sch.calendar_dim 
select 
to_char(date,'yyyymmdd')::int as date_id,  
       extract('year' from date)::int as year,
       extract('quarter' from date)::int as quarter,
       extract('month' from date)::int as month,
       extract('week' from date)::int as week,
       date::date,
       to_char(date, 'dy') as week_day,
       extract('day' from
               (date + interval '2 month - 1 day')
              ) = 29
       as leap
  from generate_series(date '2000-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);

-- cheking 
select * from sch.calendar_dim


-- ************************************** sch.return_dim

drop table if exists sch.returns_dim;

CREATE TABLE sch.return_dim
(
 order_id     varchar(50) NOT NULL,
 returned varchar(50) NOT NULL
);

insert into sch.return_dim
select order_id, returned from ( select Order_id, Returned from public."returns" ) a;

--deleting rows
truncate table sch.return_dim;


-- checking table
select * from sch.return_dim;







-- ************************************** sch.sales_fact
drop table if exists sch.sales_fact;


CREATE TABLE sch.sales_fact
(
 sales_id      serial NOT NULL,
 cust_id       int NOT NULL,
 order_date_id int NOT NULL,
 ship_date_id  int NOT NULL,
 prod_id       serial NOT NULL,
 ship_id       serial NOT NULL,
 geo_id        serial NOT NULL,
 order_id      varchar(50) NOT NULL,
 sales         numeric(9,4) NOT NULL,
 profit        numeric(9,4) NOT NULL,
 quantity      INTEGER NOT NULL,
 discount      INTEGER,
 returned      varchar(50) NULL,
-- date_id       serial NOT NULL,

 CONSTRAINT PK_13 PRIMARY KEY ( sales_id));



--deleting rows
truncate table sch.sales_fact;

--- fill sales fact 

insert into sch.sales_fact 
select
	 100+row_number() over() as sales_id
	 ,cd.cust_id
	 ,to_char(order_date,'yyyymmdd')::int as  order_date_id
	 ,to_char(ship_date,'yyyymmdd')::int as  ship_date_id
	 ,p.prod_id
	 ,ship_id
	 ,geo_id
	 ,o.order_id
	 ,sales
	 ,profit
     ,quantity
	 ,discount
	 ,returned 
	 
from public.orders o 
inner join sch.shipping_dim s on o.ship_mode = s.ship_mode
inner join sch.geo_dim g on o.postal_code = g.postal_code and g.country=o.country and g.city = o.city and o.state = g.state --City Burlington doesn't have postal code
inner join sch.product_dim p on o.product_name = p.product_name and o.segment=p.segment and o.subcategory=p.sub_category and o.category=p.category and o.product_id=p.product_id 
inner join sch.customer_dim cd on cd.customer_id=o.customer_id and cd.customer_name=o.customer_name
left join sch.return_dim sr on sr.order_id = o.order_id 



--do you get 9994rows?
select count(*) from sch.sales_fact sf
inner join sch.shipping_dim s on sf.ship_id=s.ship_id
inner join sch.geo_dim g on sf.geo_id=g.geo_id
inner join sch.product_dim p on sf.prod_id=p.prod_id
inner join sch.customer_dim cd on sf.cust_id=cd.cust_id;


-- cheking 
select *
from sch.sales_fact
where returned is null

select * from sch.return_dim;




--- test dime
-----
drop table if exists sch.returns_d;

--deleting rows
truncate table sch.returns_d;


CREATE TABLE sch.returns_d
(
 order_id     varchar(50) NULL,
 returned varchar(50) NULL
);




insert into sch.returns_d as srd
select o.order_id, returned
from public.orders o
left join "returns" r on r.order_id = o.order_id


select returned from (select distinct returned from  sch.returns_d ) a;








