show wrap;
set linesize 2000;
alter session set nls_language = 'English';
select * from all_tables;
select * from fsdb.catalogue;
select * from fsdb.trolley;
select * from fsdb.posts;
select * from all_sequences;

-- trying to insert to the "products" table
select PRODUCT, FORMAT, COFFEA, VARIETAL, ORIGIN, ROASTING, DECAF, PACKAGING from fsdb.catalogue;

INSERT INTO products (column1, column2, ...)
SELECT column1, column2, ...
FROM fsdb.catalogue
WHERE condition; -- Optional condition to filter the data

desc catalogue;
desc products;
desc marketing_format;
desc p_reference;
desc replacement_order;
desc supplier;
desc purchase_order;
desc billing_data;
desc credit_card_data;
desc delivery;
desc orders_item;
desc customers;
desc registered;
desc non_registered;
desc customer_feedbacks;
desc customer_comments;

