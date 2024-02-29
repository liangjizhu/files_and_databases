-- catalogue
-- The attributes used in fsdb.catalogue
-- select PRODUCT, FORMAT, COFFEA, VARIETAL, ORIGIN, ROASTING, DECAF, PACKAGING from fsdb.catalogue;

-- INSERT the different products' name into 'catalogue'
INSERT INTO catalogue (product)
SELECT DISTINCT
    c.PRODUCT
FROM fsdb.catalogue c
WHERE c.PRODUCT IS NOT NULL;
-- 

-- products
-- CREATE SEQUENCE TO GENERATE product_id automatically
DROP SEQUENCE seq_product_id;

CREATE SEQUENCE seq_product_id
START WITH 1
INCREMENT BY 1
MAXVALUE 10000
NOCYCLE;

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

-- select distinct product_id, product_name, coffea, varietal, origin, roast_type, decaff from products;

-- THERE ARE 750 possibilities of product with different product names NOT TAKING INTO ACCOUNT THE FORMAT AND PACKAGING

-- 

-- marketing_format

