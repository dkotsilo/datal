drop schema if exists sch CASCADE;

CREATE SCHEMA IF NOT exists sch;

-- ************************************** sch.addresses

CREATE TABLE sch.geograpohy
(
 geo_id  serial NOT NULL,
 country     varchar(100) NOT NULL,
 city        varchar(100) NULL,
 "state"       varchar(100) NULL,
 postal_code int NULL,
 region      varchar(100) NULL,
 CONSTRAINT PK_325 PRIMARY KEY ( geo_id )
);

-- ************************************** sch.calendar

CREATE TABLE sch.calendar
(
 order_date date NOT NULL,
 ship_date  date NOT NULL,
 year       int NULL,
 quarter    varchar(10) NULL,
 month      int NULL,
 week       int NULL,
 week_day   int NULL,
 CONSTRAINT PK_356 PRIMARY KEY ( order_date, ship_date )
);

-- ************************************** sch.products

CREATE TABLE sch.products
(
 product_id     serial NOT NULL,
 product_name   varchar(250) NOT NULL,
 category       varchar(250) NULL,
 sub_category   varchar(250) NULL,
 --product_id_ext varchar(25) NULL,
 CONSTRAINT PK_323 PRIMARY KEY ( product_id )
);


-- ************************************** sch.customers

CREATE TABLE sch.customer
(
 customer_id   serial NOT NULL,
 customer_name varchar(200) NOT NULL,
 code          varchar(50) NOT NULL,
 segment       varchar(50) NULL,
 CONSTRAINT PK_324 PRIMARY KEY ( customer_id )
);

-- ************************************** sch.shipments

CREATE TABLE sch.ship
(
 ship_id   serial NOT NULL,
 ship_mode varchar(50) NOT NULL,
 CONSTRAINT PK_65 PRIMARY KEY ( ship_id )
);


-- ************************************** sch.sales

CREATE TABLE sch.sales
(
 "id"          serial NOT NULL,
 reterned    varchar(5) NULL,
 sales       int NOT NULL,
 quantity    int NOT NULL,
 discount    int NULL,
 profit      int NOT NULL,
 order_id    varchar(50) NOT NULL,
 order_date  date NOT NULL,
 ship_date   date NOT NULL,
 customer_id serial NOT NULL,
 ship_id serial NOT NULL,
 geo_id  serial NOT NULL,
 product_id  serial NOT NULL,
 CONSTRAINT PK_385 PRIMARY KEY ( "id", order_date, ship_date, customer_id, ship_id, geo_id, product_id ),
 CONSTRAINT FK_358 FOREIGN KEY ( order_date, ship_date ) REFERENCES sch.calendar ( order_date, ship_date ),
 CONSTRAINT FK_362 FOREIGN KEY ( customer_id ) REFERENCES sch.customer ( customer_id ),
 CONSTRAINT FK_365 FOREIGN KEY ( ship_id ) REFERENCES sch.ship ( ship_id ),
 CONSTRAINT FK_368 FOREIGN KEY ( geo_id ) REFERENCES sch.geograpohy ( geo_id ),
 CONSTRAINT FK_371 FOREIGN KEY ( product_id ) REFERENCES sch.products ( product_id )
);

CREATE INDEX fkIdx_361 ON sch.sales
(
 order_date,
 ship_date
);

CREATE INDEX fkIdx_364 ON sch.sales
(
 customer_id
);

CREATE INDEX fkIdx_367 ON sch.sales
(
 ship_id
);

CREATE INDEX fkIdx_370 ON sch.sales
(
 geo_id
);

CREATE INDEX fkIdx_376 ON sch.sales
(
 product_id
);

