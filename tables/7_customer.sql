-- CREATE SEQUENCE TO GENERATE customer_id automatically
DROP SEQUENCE seq_customer_id;

CREATE SEQUENCE seq_customer_id
START WITH 40000
INCREMENT BY 1
MAXVALUE 50000
NOCYCLE;

-- we create a temporal table to avoid the restriction of the primary that cannot be NULL 
DROP TABLE temp_table;

CREATE TABLE temp_table2(
    customer_id NUMBER CHECK(customer_id >= 40000),
    delivery_address VARCHAR(200) NOT NULL,
    billing_id NUMBER,
    registered CHAR(1),
    customer_email VARCHAR(100),
    customer_phone_number INT CHECK(customer_phone_number >= 100000000)
);

INSERT INTO temp_table2 (delivery_address, registered, customer_email, customer_phone_number)
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

