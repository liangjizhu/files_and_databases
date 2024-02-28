show wrap;
set linesize 2000;
alter session set nls_language = 'English';
SELECT table_name FROM all_tables WHERE owner = 'FSDB237';

SELECT * from all_tables;

select distinct decaf from fsdb.catalogue;
select distinct product from fsdb.catalogue;

select * from fsdb.trolley;
select * from fsdb.posts;
select * from all_sequences;

-- trying to insert to the "products" table
select PRODUCT, FORMAT, COFFEA, VARIETAL, ORIGIN, ROASTING, DECAF, PACKAGING from fsdb.catalogue;

INSERT INTO catalogue (product)
SELECT DISTINCT
    c.PRODUCT
FROM fsdb.catalogue c
WHERE c.PRODUCT IS NOT NULL;

INSERT INTO products (product_id, product_name, coffea, varietal, origin, roast_type, decaff)
SELECT
    -- product_id
    seq_product_id.NEXTVAL,
    -- product_name
    DISTINCT PRODUCT,
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
FROM fsdb.catalogue
WHERE PRODUCT IS NOT NULL AND DECAF IS NOT NULL AND COFFEA IS NOT NULL
AND VARIETAL IS NOT NULL AND ORIGIN IS NOT NULL AND ROASTING IN ('natural', 'high-roast', 'blend');

-- 
-- 
INSERT INTO products (product_id, product_name, coffea, varietal, origin, roast_type, decaff)
SELECT
    seq_product_id.NEXTVAL,
    sub.PRODUCT,
    sub.COFFEA,
    sub.VARIETAL,
    sub.ORIGIN,
    CASE
        WHEN sub.ROASTING = 'blend' THEN 'mixture'
        WHEN sub.ROASTING = 'natural' THEN 'natural'
        WHEN sub.ROASTING = 'high-roast' THEN 'high-roast'
        ELSE sub.ROASTING
    END,
    CASE
        WHEN sub.DECAF = 'yes' THEN 'Y'
        WHEN sub.DECAF = 'no' THEN 'N'
        ELSE sub.DECAF
    END
FROM (
    SELECT DISTINCT
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
        DECAF
    FROM fsdb.catalogue
    WHERE PRODUCT IS NOT NULL AND DECAF IS NOT NULL AND COFFEA IS NOT NULL
    AND VARIETAL IS NOT NULL AND ORIGIN IS NOT NULL AND ROASTING IN ('natural', 'high-roast', 'blend')
) sub;
-- 
-- 

select distinct product_id, product_name, coffea, varietal, origin, roast_type, decaff from products;

-- WHERE condition; -- Optional condition to filter the data

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

