-- This code example intends to design and develop a system to monitor deliveries of grocery products to customers. 
-- This system will support a "third party" grocery service. 
-- Customers will place orders with the service. 
-- The service will coordinate with grocery stores to find the products and arrange for a drone to deliver the products to the customer. 
-- On delivery, the store will be paid electronically by the customer.
-- In this example, tables with sample data will be created first.
-- Then there will be stored procedures which allow the system operators to modify the database state in accordance with the main use case (such as taking orders & delivering groceries)
-- There will also be views to provide information to the system operators about the database state from various "points of view" (i.e., system operator roles)

/* Establish code environment */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'drone_dispatch';
drop database if exists drone_dispatch;
create database if not exists drone_dispatch;
use drone_dispatch;

-- -----------------------------------------------
-- table structures
-- -----------------------------------------------

create table users (
uname varchar(40) not null,
first_name varchar(100) not null,
last_name varchar(100) not null,
address varchar(500) not null,
birthdate date default null,
primary key (uname)
) engine = innodb;

create table customers (
uname varchar(40) not null,
rating integer not null,
credit integer not null,
primary key (uname)
) engine = innodb;

create table employees (
uname varchar(40) not null,
taxID varchar(40) not null,
service integer not null,
salary integer not null,
primary key (uname),
unique key (taxID)
) engine = innodb;

create table drone_pilots (
uname varchar(40) not null,
licenseID varchar(40) not null,
experience integer not null,
primary key (uname),
unique key (licenseID)
) engine = innodb;

create table store_workers (
uname varchar(40) not null,
primary key (uname)
) engine = innodb;

create table products (
barcode varchar(40) not null,
pname varchar(100) not null,
weight integer not null,
primary key (barcode)
) engine = innodb;

create table orders (
orderID varchar(40) not null,
sold_on date not null,
purchased_by varchar(40) not null,
carrier_store varchar(40) not null,
carrier_tag integer not null,
primary key (orderID)
) engine = innodb;

create table stores (
storeID varchar(40) not null,
sname varchar(100) not null,
revenue integer not null,
manager varchar(40) not null,
primary key (storeID)
) engine = innodb;

create table drones (
storeID varchar(40) not null,
droneTag integer not null,
capacity integer not null,
remaining_trips integer not null,
pilot varchar(40) not null,
primary key (storeID, droneTag)
) engine = innodb;

create table order_lines (
orderID varchar(40) not null,
barcode varchar(40) not null,
price integer not null,
quantity integer not null,
primary key (orderID, barcode)
) engine = innodb;

create table employed_workers (
storeID varchar(40) not null,
uname varchar(40) not null,
primary key (storeID, uname)
) engine = innodb;

-- -----------------------------------------------
-- referential structures
-- -----------------------------------------------

alter table customers add constraint fk1 foreign key (uname) references users (uname)
	on update cascade on delete cascade;
alter table employees add constraint fk2 foreign key (uname) references users (uname)
	on update cascade on delete cascade;
alter table drone_pilots add constraint fk3 foreign key (uname) references employees (uname)
	on update cascade on delete cascade;
alter table store_workers add constraint fk4 foreign key (uname) references employees (uname)
	on update cascade on delete cascade;
alter table orders add constraint fk8 foreign key (purchased_by) references customers (uname)
	on update cascade on delete cascade;
alter table orders add constraint fk9 foreign key (carrier_store, carrier_tag) references drones (storeID, droneTag)
	on update cascade on delete cascade;
alter table stores add constraint fk11 foreign key (manager) references store_workers (uname)
	on update cascade on delete cascade;
alter table drones add constraint fk5 foreign key (storeID) references stores (storeID)
	on update cascade on delete cascade;
alter table drones add constraint fk10 foreign key (pilot) references drone_pilots (uname)
	on update cascade on delete cascade;
alter table order_lines add constraint fk6 foreign key (orderID) references orders (orderID)
	on update cascade on delete cascade;
alter table order_lines add constraint fk7 foreign key (barcode) references products (barcode)
	on update cascade on delete cascade;
alter table employed_workers add constraint fk12 foreign key (storeID) references stores (storeID)
	on update cascade on delete cascade;
alter table employed_workers add constraint fk13 foreign key (uname) references store_workers (uname)
	on update cascade on delete cascade;

-- -----------------------------------------------
-- table data
-- -----------------------------------------------

insert into users values
('jstone5', 'Jared', 'Stone', '101 Five Finger Way', '1961-01-06'),
('sprince6', 'Sarah', 'Prince', '22 Peachtree Street', '1968-06-15'),
('awilson5', 'Aaron', 'Wilson', '220 Peachtree Street', '1963-11-11'),
('lrodriguez5', 'Lina', 'Rodriguez', '360 Corkscrew Circle', '1975-04-02'),
('tmccall5', 'Trey', 'McCall', '360 Corkscrew Circle', '1973-03-19'),
('eross10', 'Erica', 'Ross', '22 Peachtree Street', '1975-04-02'),
('hstark16', 'Harmon', 'Stark', '53 Tanker Top Lane', '1971-10-27'),
('echarles19', 'Ella', 'Charles', '22 Peachtree Street', '1974-05-06'),
('csoares8', 'Claire', 'Soares', '706 Living Stone Way', '1965-09-03'),
('agarcia7', 'Alejandro', 'Garcia', '710 Living Water Drive', '1966-10-29'),
('bsummers4', 'Brie', 'Summers', '5105 Dragon Star Circle', '1976-02-09'),
('cjordan5', 'Clark', 'Jordan', '77 Infinite Stars Road', '1966-06-05'),
('fprefontaine6', 'Ford', 'Prefontaine', '10 Hitch Hikers Lane', '1961-01-28');

insert into customers values
('jstone5', 4, 40),
('sprince6', 5, 30),
('awilson5', 2, 100),
('lrodriguez5', 4, 60),
('bsummers4', 3, 110),
('cjordan5', 3, 50);

insert into employees values
('awilson5', '111-11-1111', 9, 46000),
('lrodriguez5', '222-22-2222', 20, 58000),
('tmccall5', '333-33-3333', 29, 33000),
('eross10', '444-44-4444', 10, 61000),
('hstark16', '555-55-5555', 20, 59000),
('echarles19', '777-77-7777', 3, 27000),
('csoares8', '888-88-8888', 26, 57000),
('agarcia7', '999-99-9999', 24, 41000),
('bsummers4', '000-00-0000', 17, 35000),
('fprefontaine6', '121-21-2121', 5, 20000);

insert into store_workers values
('eross10'),
('hstark16'),
('echarles19');

insert into stores values
('pub', 'Publix', 200, 'hstark16'),
('krg', 'Kroger', 300, 'echarles19');

insert into employed_workers values
('pub', 'eross10'),
('pub', 'hstark16'),
('krg', 'eross10'),
('krg', 'echarles19');

insert into drone_pilots values
('awilson5', '314159', 41),
('lrodriguez5', '287182', 67),
('tmccall5', '181633', 10),
('agarcia7', '610623', 38),
('bsummers4', '411911', 35),
('fprefontaine6', '657483', 2);

insert into drones values
('pub', 1, 10, 3, 'awilson5'),
('pub', 2, 20, 2, 'lrodriguez5'),
('krg', 1, 15, 4, 'tmccall5'),
('pub', 9, 45, 1, 'fprefontaine6');

insert into products values
('pr_3C6A9R', 'pot roast', 6),
('ss_2D4E6L', 'shrimp salad', 3),
('hs_5E7L23M', 'hoagie sandwich', 3),
('clc_4T9U25X', 'chocolate lava cake', 5),
('ap_9T25E36L', 'antipasto platter', 4);

insert into orders values
('pub_303', '2024-05-23', 'sprince6', 'pub', 1),
('pub_305', '2024-05-22', 'sprince6', 'pub', 2),
('krg_217', '2024-05-23', 'jstone5', 'krg', 1),
('pub_306', '2024-05-22', 'awilson5', 'pub', 2);

insert into order_lines values
('pub_303', 'pr_3C6A9R', 20, 1),
('pub_303', 'ap_9T25E36L', 4, 1),
('pub_305', 'clc_4T9U25X', 3, 2),
('pub_306', 'hs_5E7L23M', 3, 2),
('pub_306', 'ap_9T25E36L', 10, 1),
('krg_217', 'pr_3C6A9R', 15, 2);

-- -----------------------------------------------
-- stored procedures and views
-- -----------------------------------------------

-- add customer
delimiter // 
create procedure add_customer
	(in ip_uname varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500),
    in ip_birthdate date, in ip_rating integer, in ip_credit integer)
sp_main: begin
	if not exists (select uname from users where uname = ip_uname) then
		insert into users values (ip_uname,ip_first_name,ip_last_name,ip_address,ip_birthdate);
        insert into customers values (ip_uname,ip_rating,ip_credit);
    end if;
end //
delimiter ;

-- add drone pilot
delimiter // 
create procedure add_drone_pilot
	(in ip_uname varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500),
    in ip_birthdate date, in ip_taxID varchar(40), in ip_service integer, 
    in ip_salary integer, in ip_licenseID varchar(40),
    in ip_experience integer)
sp_main: begin
    DECLARE existing_count INTEGER;
	SELECT COUNT(*) INTO existing_count
	FROM drone_pilots
	WHERE uname = ip_uname;
	IF existing_count = 0 THEN
		INSERT INTO users VALUES (ip_uname, ip_first_name, ip_last_name, ip_address, ip_birthdate);
        INSERT INTO employees VALUES (ip_uname,ip_taxID,ip_service,ip_salary);
        INSERT INTO drone_pilots VALUES (ip_uname,ip_licenseID,ip_experience);
	ELSE
		SIGNAL SQLSTATE '45000'
        		SET MESSAGE_TEXT = 'Error: Barcode already exists.';
	END IF;
end //
delimiter ;

-- add product
delimiter // 
create procedure add_product
	(in ip_barcode varchar(40), in ip_pname varchar(100),
    in ip_weight integer)
sp_main: begin
    DECLARE existing_count INTEGER;
	SELECT COUNT(*) INTO existing_count
	FROM products
	WHERE barcode = ip_barcode;
	IF existing_count = 0 THEN
		INSERT INTO Products (barcode, pname, weight)
		VALUES (ip_barcode, ip_pname, ip_weight);
	ELSE
		SIGNAL SQLSTATE '45000'
        		SET MESSAGE_TEXT = 'Error: Barcode already exists.';
	END IF;
end //
delimiter ;

-- add drone
delimiter // 
create procedure add_drone
	(in ip_storeID varchar(40), in ip_droneTag integer,
    in ip_capacity integer, in ip_remaining_trips integer,
    in ip_pilot varchar(40))
sp_main: begin
    DECLARE storeExists INT;
    DECLARE droneExists INT;
    DECLARE notPiloting INT;
    SELECT COUNT(*)
    INTO storeExists
    FROM stores
    WHERE storeID = ip_storeID;
    SELECT COUNT(*)
    INTO droneExists
    FROM drones
    WHERE droneTag = ip_droneTag AND storeID = ip_storeID;
	SELECT COUNT(*)
    INTO notPiloting
    FROM drones
    WHERE pilot = ip_pilot;
    IF storeExists > 0 AND droneExists = 0 AND notPiloting = 0 THEN
        INSERT INTO drones VALUES (ip_storeID, ip_droneTag, ip_capacity, ip_remaining_trips, ip_pilot);
    ELSEIF storeExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Store does not exist.';
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Drone tag already exists within the store.';
    END IF;
end //
delimiter ;

-- increase customer credits
delimiter // 
create procedure increase_customer_credits
	(in ip_uname varchar(40), in ip_money integer)
sp_main: begin
    IF ip_money < 0  THEN
        leave sp_main;
    END IF;
    IF exists (select uname from customers where uname = ip_uname) THEN
		UPDATE customers
		SET credit = credit + ip_money
		WHERE uname = ip_uname;
	END IF;
end //
delimiter ;

-- swap drone control
delimiter // 
create procedure swap_drone_control
	(in ip_incoming_pilot varchar(40), in ip_outgoing_pilot varchar(40))
sp_main: begin
    IF exists (select uname from drone_pilots where uname = ip_incoming_pilot) THEN
		IF not exists (select pilot from drones where pilot = ip_incoming_pilot) THEN
			IF exists (select pilot from drones where pilot = ip_outgoing_pilot) THEN
				update drones set pilot = ip_incoming_pilot where pilot = ip_outgoing_pilot;
            END IF;
        END IF;
    END IF;
end //
delimiter ;

-- repair and refuel a drone
delimiter // 
create procedure repair_refuel_drone
	(in ip_drone_store varchar(40), in ip_drone_tag integer,
    in ip_refueled_trips integer)
sp_main: begin
    IF exists (select storeID, droneTag from drones where storeID = ip_drone_store and droneTag = ip_drone_tag) and ip_refueled_trips >= 0 THEN
		UPDATE drones
		SET remaining_trips = remaining_trips + ip_refueled_trips
		WHERE droneTag = ip_drone_tag AND storeID = ip_drone_store;
    END IF;
end //
delimiter ;

-- begin order
delimiter // 
create procedure begin_order
	(in ip_orderID varchar(40), in ip_sold_on date,
    in ip_purchased_by varchar(40), in ip_carrier_store varchar(40),
    in ip_carrier_tag integer, in ip_barcode varchar(40),
    in ip_price integer, in ip_quantity integer)
sp_main: begin
	IF exists (select uname from customers where uname = ip_purchased_by) and
	not exists (select orderID from orders where orderID = ip_orderID) and
    exists (select storeID, droneTag from drones where storeID = ip_carrier_store and droneTag = ip_carrier_tag) and
    exists (select barcode from products where barcode = ip_barcode) then
		IF ip_price >= 0 and ip_quantity >0 then
			IF (select credit from customers where uname = ip_purchased_by) >= (ip_price*ip_quantity) THEN
				IF (select capacity from drones where storeID = ip_carrier_store and droneTag = ip_carrier_tag) >= (select ip_quantity*weight from products where barcode = ip_barcode) THEN
					INSERT INTO orders values(ip_orderID,ip_sold_on,ip_purchased_by,ip_carrier_store,ip_carrier_tag);
                    INSERT INTO order_lines values (ip_orderID,ip_barcode,ip_price,ip_quantity);
                END IF;
            END IF;
        END IF;
    END IF;
end //
delimiter ;

-- add order line
delimiter // 
create procedure add_order_line
	(in ip_orderID varchar(40), in ip_barcode varchar(40),
    in ip_price integer, in ip_quantity integer)
sp_main: begin
	Declare remaining_capacity INT;
    Declare ip_credit INT;
    select capacity-current_weight into remaining_capacity from drones 
		join (select orders.orderID, carrier_store, carrier_tag, sum(quantity*weight) as current_weight from orders 
		join order_lines on orders.orderID = order_lines.orderID
		join products on order_lines.barcode = products.barcode
		group by orderID) as order_details on storeID= carrier_store and droneTag= carrier_tag
		where orderID = ip_orderID;
	select credit into ip_credit from customers where uname = (select purchased_by from orders where orderID = ip_orderID);
	IF exists (select orderID from orders where orderID = ip_orderID) and exists (select barcode from products where barcode = ip_barcode) THEN
		IF not exists (select barcode from order_lines where orderID = ip_orderID and barcode = ip_barcode) then
			IF ip_price >=0 and ip_quantity>0 then
				IF ip_credit >= ((ip_price*ip_quantity)+(select sum(price*quantity) from order_lines group by orderID having orderID = ip_orderID)) THEN
					IF remaining_capacity >= (select weight*ip_quantity from products where barcode = ip_barcode) then
						INSERT INTO order_lines values (ip_orderID,ip_barcode,ip_price,ip_quantity);
					END IF;
                END IF;
            END IF;
        END IF;
    END IF;
end //
delimiter ;

-- deliver order
delimiter // 
create procedure deliver_order
	(in ip_orderID varchar(40))
sp_main: begin
	DECLARE CostOfOrder INT;
    select sum(price*quantity) into CostOfOrder from order_lines join orders on order_lines.orderID = orders.orderID group by order_lines.orderID having order_lines.orderID = ip_orderID;
	IF exists (select orderID from orders where orderID = ip_orderID) then
		IF (select remaining_trips from drones where storeID = (select carrier_store from orders where orderID = ip_orderID) and droneTag = (select carrier_tag from orders where orderID = ip_orderID)) then
			update customers set credit = credit - CostOfOrder where uname = (select purchased_by from orders where orderID = ip_orderID);
            update stores set revenue = revenue + CostOfOrder where storeID = (select carrier_store from orders where orderID = ip_orderID);
            update drones set remaining_trips = remaining_trips - 1 where storeID = (select carrier_store from orders where orderID = ip_orderID) and droneTag = (select carrier_tag from orders where orderID = ip_orderID);
            update drone_pilots set experience = experience + 1 where uname = (select pilot from drones where storeID =(select carrier_store from orders where orderID = ip_orderID) and  droneTag = (select carrier_tag from orders where orderID = ip_orderID));
            IF CostOfOrder > 25 then
				update customers set rating = rating + 1 where uname = (select purchased_by from orders where orderID = ip_orderID);
			END IF;
            delete from orders where orderID = ip_orderID;
            delete from order_lines where orderID = ip_orderID;
        end if;
    end if;

end //
delimiter ;

-- cancel an order
delimiter // 
create procedure cancel_order
	(in ip_orderID varchar(40))
sp_main: begin
    IF exists (select orderID from orders where orderID = ip_orderID) then
		update customers set rating = rating - 1 where uname = (select purchased_by from orders where orderID = ip_orderID);
        delete from orders where orderID = ip_orderID;
		delete from order_lines where orderID = ip_orderID;
    END IF;
end //
delimiter ;

-- display persons distribution across roles
create or replace view role_distribution (category, total) as
(select 'users' as category, count(*) AS total from users)
UNION (select 'customers', count(*) from customers)
UNION (select 'employees', count(*) from employees)
UNION (select 'customer_employer_overlap', count(*) from customers inner join employees on customers.uname = employees.uname)
Union (select 'drone_pilots', count(*) from drone_pilots)
Union (select 'store_workers', count(*) from store_workers)
Union (select 'other_employee_roles', count(*) from employees where (uname not in (select uname from drone_pilots)) and (uname not in (select uname from store_workers)));

-- display customer status and current credit and spending activity
create or replace view customer_credit_check (customer_name, rating, current_credit,
	credit_already_allocated) as
select uname as customer_name, rating, credit, (CASE WHEN (NOT ISNULL(credit_already_allocated)) THEN credit_already_allocated ELSE 0 END) as current_credit from customers 
left join (select purchased_by, sum(price*quantity) as credit_already_allocated from orders join order_lines on orders.orderID = order_lines.orderID group by purchased_by) as credit_already_allocated_view on uname = purchased_by;

-- display drone status and current activity
create or replace view drone_traffic_control (drone_serves_store, drone_tag, pilot,
	total_weight_allowed, current_weight, deliveries_allowed, deliveries_in_progress) as
select storeID as drone_serves_store, droneTag as drone_tag, pilot,
	capacity as total_weight_allowed, (CASE WHEN (NOT ISNULL(sum(weight*quantity))) THEN sum(weight*quantity) ELSE 0 END) as current_weight, remaining_trips as deliveries_allowed, count(distinct(orderID)) as deliveries_in_progress from drones 
left join drone_pilots on drones.pilot = drone_pilots.uname
left join (select orders.orderID, carrier_store, carrier_tag, barcode, price, quantity, weight from orders 
	join (select orderID, order_lines.barcode as barcode, price, quantity, pname, weight from order_lines 
		  join products on order_lines.barcode = products.barcode) as order_product on orders.orderID = order_product.orderID) as order_details on drones.storeID = order_details.carrier_store and drones.droneTag = order_details.carrier_Tag
group by storeID, droneTag;
    
-- display product status and current activity including most popular products
create or replace view most_popular_products (barcode, product_name, weight, lowest_price,
	highest_price, lowest_quantity, highest_quantity, total_quantity) as
select products.barcode, pname as product_name, weight, min(price) as lowest_price, max(price) as highest_price, 
	(CASE WHEN (NOT ISNULL(min(quantity))) THEN min(quantity) ELSE 0 END) as lowest_quantity, 
    (CASE WHEN (NOT ISNULL(max(quantity))) THEN max(quantity) ELSE 0 END) as highest_quantity, 
    (CASE WHEN (NOT ISNULL(sum(quantity))) THEN sum(quantity) ELSE 0 END) as total_quantity
from products left join order_lines on products.barcode = order_lines.barcode
group by barcode;


-- display drone pilot status and current activity including experience
create or replace view drone_pilot_roster (pilot, licenseID, drone_serves_store,
	drone_tag, successful_deliveries, pending_deliveries) as
select uname as pilot, licenseID, storeID as drone_serves_store,
	droneTag as drone_tag, experience as successful_deliveries, count(distinct orderID) as pending_deliveries from drone_pilots 
left join (select pilot, storeID, droneTag,orderID from drones left join orders on drones.storeID = orders.carrier_store and drones.droneTag = orders.carrier_tag) as drones_orders on drone_pilots.uname = drones_orders.pilot
group by uname, storeID, droneTag;

-- display store revenue and activity
create or replace view store_sales_overview (store_id, sname, manager, revenue,
	incoming_revenue, incoming_orders) as
select storeID as store_id, sname, manager, revenue,
	sum(price*quantity) as incoming_revenue, count(distinct orders.orderID) as incoming_orders from orders 
join stores on orders.carrier_store = stores.storeID
join order_lines on orders.orderID = order_lines.orderID
group by carrier_store;

-- display the current orders that are being placed/in progress
create or replace view orders_in_progress (orderID, cost, num_products, payload,
	contents) as
select orders.orderID as orderID, sum(price*quantity) as cost, count(distinct order_lines.barcode) as num_products, sum(weight*quantity) as payload,
	GROUP_CONCAT(pname ORDER BY pname SEPARATOR ',') as contents from order_lines
join orders on orders.orderID = order_lines.orderID
join products on order_lines.barcode = products.barcode
group by orders.orderID;

-- remove customer
delimiter // 
create procedure remove_customer
	(in ip_uname varchar(40))
sp_main: begin
    DECLARE pending_orders INTEGER;
	DECLARE is_employee INTEGER;
	SELECT COUNT(*) INTO is_employee FROM employees WHERE uname = ip_uname;
	IF is_employee = 0  THEN
		SELECT COUNT(*) INTO pending_orders
		FROM orders
		WHERE purchased_by IN (SELECT uname FROM customers WHERE uname = ip_uname);
		IF pending_orders = 0 THEN
			DELETE FROM users
			WHERE uname = ip_uname;
		ELSE
			SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'Error: Customer has pending orders.';
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: User is an employee.';
	END IF;
end //
delimiter ;

-- remove drone pilot
delimiter // 
create procedure remove_drone_pilot
	(in ip_uname varchar(40))
sp_main: begin
	IF not exists (select pilot from drones where pilot = ip_uname) THEN
		DELETE FROM drone_pilots WHERE uname = ip_uname;
        DELETE from employees where uname = ip_uname;
        IF not exists (select uname from customers where uname = ip_uname) THEN
            DELETE from users where uname = ip_uname;
		end if;
	END IF;

end //
delimiter ;

-- remove product
delimiter // 
create procedure remove_product
	(in ip_barcode varchar(40))
sp_main: begin
    if not exists (select barcode from order_lines where barcode = ip_barcode) then
		delete from products where barcode = ip_barcode;
    end if;
end //
delimiter ;

-- remove drone
delimiter // 
create procedure remove_drone
	(in ip_storeID varchar(40), in ip_droneTag integer)
sp_main: begin
    IF (select count(*) from orders where carrier_store = ip_storeID and carrier_tag = ip_droneTag) = 0 THEN
		DELETE from drones where (storeID = ip_storeID) and (droneTag = ip_droneTag);
    END IF;
end //
delimiter ;
