/******  Purchase Order Example ********/



Drop table items     cascade constraint;
Drop table customers cascade constraint;
Drop table orders    cascade constraint;
Drop table LINEITEMS cascade constraint;

create table ITEMS
(
 itemno   Number(5)   constraint items_pk  primary key,
 itemname varchar2(25),
 rate     number(8,2) constraint items_rate_chk check( rate >= 0),
 taxrate  number(4,2)
);



insert into items values('1','Samsung Monitor',7000.0,10.5);
insert into items values('2','Logitech Keyboard',1000,10);
insert into items values('3','Segate HDD 20GB',6500,12.5);
insert into items values('4','PIII processor',8000,8);
insert into items values('5','Logitech Mouse',500,5);
insert into items values('6','Creative Speakers',4500,11.5);


create table CUSTOMERS
(
 custno    number(5)    constraint customers_pk  primary key,
 custname  varchar2(20) constraint customers_custname_nn not null,
 Dob       Date,
 streetaddress  varchar2(30),
 city      varchar2(20),
 state     varchar2(20),
 pin       varchar2(10),
 phone     int
);

insert into customers values(101,'Rahul','12-jan-17','Dwarakanagar',  'Hubli','Karnataka','580016','8533436343');
insert into customers values(102,'Pooja','02-feb-17','CBM Compound','Dharwad','Karnataka','580012','7445453456');
insert into customers values(103,'Mandeep','10-feb-17','Shah bazar', 'Hydrabad','Andrapradesh','530016','5674342345');
insert into customers values(104,'Poornima','25-dec-16','Jayanagar','Banagalore','Karnataka','580021','8756552222');
insert into customers values(105,'Ziya','01-jan-17','Curch street','Vasco','Goa','560013','6553334567');

create table ORDERS
(
 ordno     number(5)  constraint orders_pk  primary key,
 orddate   date,
 shipdate  date,
 custno    number(5) constraint orders_custno_pk references customers,
 address   varchar2(50),
 city      varchar2(30),
 state     varchar2(30),
 pin       varchar2(10),
 phone     varchar2(30),
 constraint order_dates_chk  check( orddate <= shipdate)
);


insert into orders values(1001,'08-jan-2017','10-jan-2017',102, 'CBM Compound','Dharwad','karnataka','530012','7445455675');
insert into orders values(1002,'18-jun-2016','20-jun-2016',101, 'Dwarakanagar','Hubli','karnataka','530016','7645334333');
insert into orders values(1003,'10-feb-2017','10-feb-2017',101, 'Dwarakanagar','Hubli','karnataka','530016','453334333');
insert into orders values(1004,'18-May-2016','24-may-2016',103, 'Abid Nagar', 'Hydrabad','andrapradesh','530016',null);
insert into orders values(1005,'20-jun-2016','30-jun-2016',104, 'Muralinagar','Bangalore','karnataka','530021','875876562222');
insert into orders values(1006,'15-jan-2017', null,104, 'MVP Colony','Vasco','goa','530024',null);

create table LINEITEMS
(
 ordno   number(5)   constraint LINEITEMS_ORDNO_FK references ORDERS,
 itemno  number(5)   constraint LINEITEMS_itemno_FK references ITEMS,
 qty     number(3)   constraint LINEITEMS_qty_CHK CHECK( qty >= 1),
 price   number(8,2),
 discountrate number(4,2) default 0 constraint LINEITEMS_DISRATE_CHK CHECK( discountrate >= 0),
 constraint lineitems_pk primary key (ordno,itemno)
);


insert into lineitems values(1001,2,3,1000,10.0);
insert into lineitems values(1001,1,3,7000,15.0);
insert into lineitems values(1001,4,2,8000,10.0);
insert into lineitems values(1001,6,1,4500,10.0);
insert into lineitems values(1002,6,4,4500,20.0);
insert into lineitems values(1002,4,2,8000,15.0);
insert into lineitems values(1002,5,2,600,10.0);
insert into lineitems values(1003,5,10,500,0.0);
insert into lineitems values(1003,6,2,4750,5.0);
insert into lineitems values(1004,1,1,7000,10.0);
insert into lineitems values(1004,3,2,6500,10.0);
insert into lineitems values(1004,4,1,8000,20.0);
insert into lineitems values(1005,6,1,4600,10.0);
insert into lineitems values(1005,2,2,900,10.0);
insert into lineitems values(1006,2,10,950,20.0);
insert into lineitems values(1006,4,5,7800,10.0);
insert into lineitems values(1006,3,5,6600,15.0);

select c.custno,count(*)
from orders o,customers c
where o.custno=c.custno and c.city like '%anag%'
group by c.custname;

select max(count(*))
from orders
group by custno;

select custno
from orders
groub by custno,to_char(orddate,'mmyy')
having count(*)>2;

select state,count(*)
from customers
where custname like '%deep%'
group by state;

select ordno,avg(price)
from orders o,lineitems l
where o.ordno=l.ordno and sysdate-orddate<=15
group by o.ordno;

select ordno,custname,orddate,shipdate-orddate number_of_days
from orders o,customers c
where shipdate is not null and o.custno=c.custno;

select custno,orddate,count(*) number_of_orders
from orders 
group by custno,orddate
order by orddate;

select ordno,orddate,custno,custname
from orders,lineitems,customers
where order.ordno=lineitems.ordno; and where itemno=5; \

select itemno,sum(qty) total_num_of_units,max(price),min(price)
from lineitems
group by itemno;

select ordno,max(price)
from lineitems
group by ordno
having sum(price*qty)>10000;

select ordno,ordate,o.custno,custname
from orders o,customers c
where o.custno=c.custno and ordno in
(select ordno
from lineitems
where itemno=5);

select custno
from orders 
where ordno in
(select ordno 
from lineitems
group by ordno
having sum(qty*price)>30000);

select * 
from customers
where custno in
(select custno
from orders 
where ordno in
(select ordno 
from lineitems
group by ordno
having sum(qty*price)>30000));

select * 
from orders
where ordno in
(select ordno
from lineitems
where price=
(select max(price)
from lineitems
where itemno=3));

select *
from items
where itemno in
(select itemno
from lineitems
where ordno in
(select ordno
from orders
where sysdate-orddate<=7))
or itemno in
(select itemno
from lineitems
group by itemno
having sum(qty)>10);

select avg(price)
from lineitems;


select *
from orders
where ordno in
(select ordno
from lineitems l,items i
where l.itemno=i.itemno
and price>rate);

select *
from customers
where custno in
(select custno
from orders 
group by custno
having count(*)=
(select max(count(*))
from orders
group by custno));

select *
from items
where itemno in
(select itemno
from lineitems
where ordno in
(select ordno
from orders
where custno=102));

update orders
set shipdate=(select max(orddate) from orders)
where ordno=1004;

select *
from items
where rate=
(select max(rate)
from items);

select custno
from orders
group by custno
having count(*)>=2;

select*
from customers
where custno in
(select custno
from orders
group by custno
having count(*)>=2);


select *
from customers
where custno not in
(select custno
from orders);

select *
from customers
where custno not in
(select custno
from orders
where months_between(sysdate,orddate)<=6);

select *
from items
where itemno in
(select itemno
from lineitems
where price>5000
group by itemno
having sum(qty)>5);

select *
from orders
where custno in
(select  custno
from customers
where phone like '567%'
or ordno in
(select ordno 
from lineitems 
group by ordno
having count(*)>=3));

