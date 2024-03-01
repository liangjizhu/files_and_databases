-- 
-- catalogue
-- 
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
-- 

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
-- 

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
-- 

DROP TABLE temp_table;

CREATE TABLE temp_table (
    bar_code VARCHAR(15),
    packaging VARCHAR(15),
    retail_price VARCHAR(14),
    product_id NUMBER,
    product_name VARCHAR(50),
    current_stock VARCHAR(5),
    min_stock VARCHAR(5),
    max_stock VARCHAR(5)
);


INSERT INTO temp_table(bar_code, packaging, retail_price, current_stock, product_name, min_stock, max_stock)
SELECT
    BARCODE,
    PACKAGING,
    RETAIL_PRICE,
    CUR_STOCK,
    PRODUCT,
    MIN_STOCK,
    MAX_STOCK
FROM fsdb.catalogue
GROUP BY BARCODE, PACKAGING, RETAIL_PRICE, CUR_STOCK, PRODUCT, MIN_STOCK, MAX_STOCK;


UPDATE temp_table
SET product_id = (
    SELECT product_id
    FROM products
    WHERE product_name = temp_table.product_name
);

INSERT INTO p_reference(bar_code, product_id, packaging, retail_price, min_stock, max_stock, current_stock)
SELECT
    bar_code,
    product_id,
    packaging,
    retail_price,
    min_stock,
    max_stock,
    current_stock    
FROM temp_table;

DROP TABLE temp_table;

-- select * from p_reference;
-- select min_stock, max_stock, current_stock from p_reference;

-- 
-- replacement_order
-- 

-- CREATE SEQUENCE TO GENERATE format_id automatically
DROP SEQUENCE seq_replacement_order_id;

CREATE SEQUENCE seq_replacement_order_id
START WITH 20000
INCREMENT BY 1
MAXVALUE 30000
NOCYCLE;

DROP TABLE temp_table;

-- create a temporal table to work with the datas
CREATE TABLE temp_table (
    replacement_order_id NUMBER CHECK(replacement_order_id >= 20000) NOT NULL,
    bar_code VARCHAR(15) NOT NULL,
    supplier VARCHAR(35),
    request_amount NUMBER CHECK(request_amount > 0) NOT NULL,
    request_date DATE,
    delivery_date DATE,
    rorder_state VARCHAR(15),
    received_date DATE,
    payment VARCHAR(30) NOT NULL
);

INSERT INTO temp_table (replacement_order_id, bar_code, supplier, request_date, payment)
SELECT
    seq_replacement_order_id.NEXTVAL,
    barcode,
    supplier,
    SYSDATE AS request_date,
    PROV_BANKACC
FROM
    (SELECT DISTINCT c.barcode, c.supplier, c.PROV_BANKACC
     FROM fsdb.catalogue c
    --  check that bar_code from p_reference table matches with this table
     JOIN p_reference s ON c.barcode = s.bar_code
     WHERE c.barcode IS NOT NULL 
       AND c.supplier IS NOT NULL 
       AND c.PROV_BANKACC IS NOT NULL
       AND TO_NUMBER(s.current_stock) < TO_NUMBER(s.min_stock)
    );

-- rorder_state
UPDATE temp_table
SET rorder_state = (
    CASE 
        WHEN SYSDATE > delivery_date THEN 'Placed'
        WHEN received_date > SYSDATE THEN 'fulfilled'
        ELSE 'Draft'
    END
);

-- request_amount generated automatically??
UPDATE temp_table tt
SET tt.request_amount = (
    SELECT (TO_NUMBER(pr.max_stock) - TO_NUMBER(pr.current_stock))
    FROM p_reference pr
    WHERE pr.bar_code = tt.bar_code 
        AND TO_NUMBER(pr.current_stock) < TO_NUMBER(pr.min_stock)
);

-- upload to main table
INSERT INTO replacement_order (replacement_order_id, bar_code, supplier, request_amount, request_date, rorder_state, received_date, payment)
SELECT
    replacement_order_id,
    bar_code,
    supplier,
    request_amount,
    request_date,
    rorder_state,
    received_date,
    payment
FROM TEMP_TABLE;

DROP TABLE temp_table;


-- 
-- supplier
-- 
-- CREATE SEQUENCE TO GENERATE format_id automatically
DROP SEQUENCE seq_supplier_barcode_id;

CREATE SEQUENCE seq_supplier_barcode_id
START WITH 30000
INCREMENT BY 1
MAXVALUE 40000
NOCYCLE;

INSERT INTO supplier (supplier_barcode_id, bar_code, cif, supplier_name, full_name, supplier_email, supplier_phone_number, comm_address, supplier_country, supplier_bankacc)
SELECT
    seq_supplier_barcode_id.NEXTVAL,
    c.BARCODE,
    c.PROV_TAXID,
    c.SUPPLIER,
    c.PROV_PERSON,
    c.PROV_EMAIL,
    c.PROV_MOBILE,
    c.PROV_ADDRESS,
    c.PROV_COUNTRY,
    c.PROV_BANKACC
FROM fsdb.catalogue c
JOIN p_reference p ON c.BARCODE = p.bar_code
WHERE c.PROV_TAXID IS NOT NULL 
  AND c.BARCODE IS NOT NULL 
  AND c.SUPPLIER IS NOT NULL 
  AND c.PROV_PERSON IS NOT NULL 
  AND c.PROV_EMAIL IS NOT NULL 
  AND c.PROV_MOBILE IS NOT NULL 
  AND c.PROV_ADDRESS IS NOT NULL 
  AND c.PROV_COUNTRY IS NOT NULL 
  AND c.PROV_BANKACC IS NOT NULL;

-- select bar_code, cif, supplier_name, full_name, supplier_email, supplier_phone_number, comm_address, supplier_country, supplier_bankacc from supplier;
-- select DISTINCT product_id from p_reference;



-- select distinct PROV_TAXID, BARCODE from fsdb.catalogue;
-- desc fsdb.catalogue;

-- 
-- customers
-- 

-- CREATE SEQUENCE TO GENERATE customer_id automatically
DROP SEQUENCE seq_customer_id;

CREATE SEQUENCE seq_customer_id
START WITH 40000
INCREMENT BY 1
MAXVALUE 50000
NOCYCLE;

-- we create a temporal table to avoid the restriction of the primary that cannot be NULL 
DROP TABLE temp_table;

CREATE TABLE temp_table(
    customer_id NUMBER CHECK(customer_id >= 40000),
    delivery_address VARCHAR(200) NOT NULL,
    billing_id NUMBER,
    registered CHAR(1),
    customer_email VARCHAR(100),
    customer_phone_number INT CHECK(customer_phone_number >= 100000000)
);

INSERT INTO temp_table (delivery_address, registered, customer_email, customer_phone_number)
SELECT DISTINCT
    -- we concatenate the delivery address of the customer
    COALESCE(DLIV_WAYTYPE, '') || ' ' || COALESCE(DLIV_WAYNAME, '') || ' ' || COALESCE(DLIV_GATE, '') || ' ' ||
    COALESCE(DLIV_BLOCK, '') || ' ' || COALESCE(DLIV_STAIRW, '') || ' ' || COALESCE(DLIV_FLOOR, '') || ' ' ||
    COALESCE(DLIV_DOOR, '') || ' ' || COALESCE(DLIV_ZIP, '') || ' ' || COALESCE(DLIV_TOWN, '') || ' ' ||
    COALESCE(DLIV_COUNTRY, '') AS delivery_address,
    -- we set a value to registered customers if they have a username and the either they have
    -- email or mobile number
    CASE
        WHEN USERNAME IS NOT NULL AND (CLIENT_EMAIL IS NOT NULL OR CLIENT_MOBILE IS NOT NULL) THEN 'Y'
        ELSE 'N'
    END AS registered,
    CLIENT_EMAIL,
    CLIENT_MOBILE
FROM fsdb.trolley
WHERE DLIV_WAYNAME IS NOT NULL AND DLIV_FLOOR IS NOT NULL AND DLIV_DOOR IS NOT NULL AND 
    DLIV_COUNTRY IS NOT NULL AND DLIV_TOWN IS NOT NULL AND (CLIENT_EMAIL IS NOT NULL OR CLIENT_MOBILE IS NOT NULL);

-- we generate the customer id
UPDATE temp_table
SET customer_id = (
    seq_customer_id.NEXTVAL
);

-- we insert info to the main table
INSERT INTO customers (customer_id, delivery_address, registered, customer_email, customer_phone_number)
SELECT
    customer_id, delivery_address, registered, customer_email, customer_phone_number
FROM temp_table;

-- we eliminate the temporal table
DROP TABLE temp_table;

