-- CREATE TABLE customers(
--     customer_id NUMBER CHECK(customer_id >= 40000) NOT NULL,
--     delivery_address VARCHAR(100) NOT NULL,
--     billing_id,
--     registered CHAR(1),
--     customer_email VARCHAR(100) NOT NULL,
--     customer_phone_number INT CHECK(customer_phone_number >= 100000000),
--     CONSTRAINT pk_customers PRIMARY KEY(customer_id),
--     CONSTRAINT check_customer_phone_number CHECK(999999999 > customer_phone_number)
-- );

-- CREATE SEQUENCE TO GENERATE customer_id automatically
DROP SEQUENCE seq_customer_id;

CREATE SEQUENCE seq_customer_id
START WITH 40000
INCREMENT BY 1
MAXVALUE 50000
NOCYCLE;

DROP TABLE temp_table;

CREATE TABLE temp_table(
    customer_id NUMBER CHECK(customer_id >= 40000),
    delivery_address VARCHAR(1000) NOT NULL,
    billing_id NUMBER,
    registered CHAR(1),
    customer_email VARCHAR(100),
    customer_phone_number INT CHECK(customer_phone_number >= 100000000)
);

INSERT INTO temp_table (delivery_address, registered, customer_email, customer_phone_number)
SELECT DISTINCT
    COALESCE(DLIV_WAYTYPE, '') || ' ' || COALESCE(DLIV_WAYNAME, '') || ' ' || COALESCE(DLIV_GATE, '') || ' ' ||
    COALESCE(DLIV_BLOCK, '') || ' ' || COALESCE(DLIV_STAIRW, '') || ' ' || COALESCE(DLIV_FLOOR, '') || ' ' ||
    COALESCE(DLIV_DOOR, '') || ' ' || COALESCE(DLIV_ZIP, '') || ' ' || COALESCE(DLIV_TOWN, '') || ' ' ||
    COALESCE(DLIV_COUNTRY, '') AS delivery_address,
    CASE
        WHEN USERNAME IS NOT NULL AND (CLIENT_EMAIL IS NOT NULL OR CLIENT_MOBILE IS NOT NULL) THEN 'Y'
        ELSE 'N'
    END AS registered,
    CLIENT_EMAIL,
    CLIENT_MOBILE
FROM fsdb.trolley
WHERE PAYMENT_TYPE IS NOT NULL AND DLIV_WAYNAME IS NOT NULL AND DLIV_FLOOR IS NOT NULL AND DLIV_DOOR IS NOT NULL AND 
    DLIV_COUNTRY IS NOT NULL AND DLIV_TOWN IS NOT NULL AND (CLIENT_EMAIL IS NOT NULL OR CLIENT_MOBILE IS NOT NULL);


UPDATE temp_table
SET customer_id = (
    seq_customer_id.NEXTVAL
);

DROP TABLE temp_table;

SELECT COUNT(DISTINCT CLIENT_NAME) FROM fsdb.trolley;
SELECT COUNT(DISTINCT USERNAME) FROM fsdb.trolley;

select distinct REG_DATE from fsdb.trolley;
select distinct USER_PASSW from fsdb.trolley;
select distinct CLIENT_MOBILE from fsdb.trolley;

-- registered inputs
select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE 
from fsdb.trolley WHERE USERNAME IS NOT NULL;

-- non registered inputs
select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE 
from fsdb.trolley WHERE USERNAME IS NULL;

select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE, REG_DATE
from fsdb.trolley WHERE USERNAME IS NULL;

select distinct USERNAME, CLIENT_EMAIL from fsdb.trolley
WHERE username IS NOT NULL AND CLIENT_EMAIL IS NOT NULL;

select distinct USERNAME, CLIENT_MOBILE from fsdb.trolley;



-- address inputs
SELECT distinct PAYMENT_TYPE, DLIV_DATE,DLIV_TIME,DLIV_WAYTYPE,DLIV_WAYNAME,DLIV_GATE,DLIV_BLOCK, DLIV_STAIRW, DLIV_FLOOR, DLIV_DOOR, DLIV_ZIP, DLIV_TOWN, DLIV_COUNTRY 
from fsdb.trolley
where PAYMENT_TYPE IS NOT NULL AND DLIV_WAYNAME IS NOT NULL AND DLIV_FLOOR IS NOT NULL AND DLIV_DOOR IS NOT NULL AND DLIV_COUNTRY IS NOT NULL AND DLIV_TOWN IS NOT NULL;

select distinct text from fsdb.posts;
desc fsdb.trolley;
