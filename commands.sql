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

INSERT INTO products (product_id, product_name, coffea, varietal, origin, roast_type, decaff)
SELECT
    -- product_id
    seq_product_id.NEXTVAL,
    -- product_name
    PRODUCT,
    COFFEA,
    VARIETAL,
    ORIGIN,
    ROASTING,
    -- decaff
    CASE
        WHEN DECAF = 'yes' THEN 'Y'
        WHEN DECAF = 'no' THEN 'N'
        ELSE DECAF
    END
FROM fsdb.catalogue
WHERE PRODUCT IS NOT NULL AND DECAF IS NOT NULL AND COFFEA IS NOT NULL
AND VARIETAL IS NOT NULL AND ORIGIN IS NOT NULL AND ROASTING IN ('natural', 'high-roast', 'mixture');
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

