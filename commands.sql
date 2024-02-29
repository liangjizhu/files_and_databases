-- USEFUL SETTINGS
show wrap;
set linesize 2000;
alter session set nls_language = 'English';
-- 

SELECT table_name FROM all_tables WHERE owner = 'FSDB237';

SELECT * from all_tables;

select distinct decaf from fsdb.catalogue;
select distinct product from fsdb.catalogue;

select * from fsdb.trolley;
select * from fsdb.posts;
select * from all_sequences;

-- INSERT the different products' name into the catalogue
INSERT INTO catalogue (product)
SELECT DISTINCT
    c.PRODUCT
FROM fsdb.catalogue c
WHERE c.PRODUCT IS NOT NULL;

-- The attributes used in fsdb.catalogue
select PRODUCT, FORMAT, COFFEA, VARIETAL, ORIGIN, ROASTING, DECAF, PACKAGING from fsdb.catalogue;

-- INSERT the attributes that 'products' table has
-- First we create an temporary table to filter the attributes by different names and attributes that can merge together
DROP TABLE temp_table;

CREATE TABLE temp_table (
    product_name VARCHAR2(255),
    coffea VARCHAR2(255),
    varietal VARCHAR2(255),
    origin VARCHAR2(255),
    roast_type VARCHAR2(255),
    decaff VARCHAR2(1)
);
-- 
-- 
INSERT INTO temp_table (product_name, coffea, varietal, origin, roast_type, decaff)
SELECT
    -- product_name
    PRODUCT,
    COFFEA,
    VARIETAL,
    ORIGIN,
    CASE
        WHEN ROASTING = 'blend' THEN 'mixture'
        WHEN ROASTING = 'natural' THEN 'natural'
        WHEN ROASTING = 'high-roast' THEN 'high-roast'
        ELSE ROASTING
    END,
    -- decaff
    CASE
        WHEN DECAF = 'yes' THEN 'Y'
        WHEN DECAF = 'no' THEN 'N'
        ELSE DECAF
    END
FROM
    fsdb.catalogue
WHERE
    PRODUCT IS NOT NULL AND DECAF IS NOT NULL AND COFFEA IS NOT NULL
    AND VARIETAL IS NOT NULL AND ORIGIN IS NOT NULL AND ROASTING IN ('natural', 'high-roast', 'blend')
GROUP BY
    PRODUCT, COFFEA, VARIETAL, ORIGIN, ROASTING, DECAF;
-- 
-- 
INSERT INTO products (product_id, product_name, coffea, varietal, origin, roast_type, decaff)
SELECT
    seq_product_id.NEXTVAL,
    product_name,
    coffea,
    varietal,
    origin,
    roast_type,
    decaff
FROM temp_table;

DROP TABLE temp_table;
-- 

select distinct product_id, product_name, coffea, varietal, origin, roast_type, decaff from products;

-- THERE ARE 3940 possibilities of product with different formats and packaging
SELECT PRODUCT, FORMAT, coffea, varietal, origin, ROASTING, DECAF, PACKAGING, COUNT(*)
FROM fsdb.catalogue
GROUP BY PRODUCT, FORMAT, coffea, varietal, origin, ROASTING, DECAF, PACKAGING;

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

