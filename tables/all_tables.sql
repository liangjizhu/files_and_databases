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
-- CREATE SEQUENCE TO GENERATE format_id automatically
DROP SEQUENCE seq_format_id;

CREATE SEQUENCE seq_format_id
START WITH 10000
INCREMENT BY 1
MAXVALUE 20000
NOCYCLE;
-- 

-- Create temporary table where we will store the values for marketing_format

DROP TABLE temp_table;

CREATE TABLE temp_table (
    format_id NUMBER,
    product_name VARCHAR2(50),
    product_id NUMBER,
    product_format VARCHAR(20) NOT NULL,
    packaging VARCHAR(15)
);


INSERT INTO temp_table (format_id, product_name, product_format, packaging)
SELECT
    seq_format_id.NEXTVAL,
    PRODUCT,
    CASE
        WHEN FORMAT = 'capsules' THEN 'in capsules'
        WHEN FORMAT = 'freeze-dried' THEN 'freeze-dried'
        WHEN FORMAT = 'ground' THEN 'ground'
        WHEN FORMAT = 'prepared' THEN 'prepared'
        WHEN FORMAT = 'roasted bean' THEN 'roasted beans'
        WHEN FORMAT = 'raw bean' THEN 'raw grain'
        ELSE FORMAT
    END,
    PACKAGING
FROM (
    SELECT DISTINCT PRODUCT, FORMAT, PACKAGING
    FROM fsdb.catalogue
    -- filtering the formats from fsdb.catalogue.format
    WHERE PRODUCT IS NOT NULL AND FORMAT IN ('raw bean', 'roasted bean', 'freeze-dried', 'capsules', 'prepared', 'ground') AND PACKAGING IS NOT NULL
);


-- Step 2: Populate the product_id column in fsdb.catalogue
UPDATE temp_table
SET product_id = (
    SELECT product_id
    FROM products
    WHERE product_name = temp_table.product_name
);

INSERT INTO marketing_format(format_id, product_id, product_format, packaging)
SELECT
    format_id,
    product_id,
    product_format,
    packaging
FROM temp_table;
-- 

DROP TABLE temp_table;

-- THERE ARE 3240 possibilities of product with different formats and packaging
-- SELECT PRODUCT, FORMAT, coffea, varietal, origin, ROASTING, DECAF, PACKAGING, COUNT(*)
-- FROM fsdb.catalogue
-- GROUP BY PRODUCT, FORMAT, coffea, varietal, origin, ROASTING, DECAF, PACKAGING;

-- select * from marketing_format;

-- 
-- p_reference
