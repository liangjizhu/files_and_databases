-- CREATE SEQUENCE TO GENERATE registered_id automatically
DROP SEQUENCE seq_registered_id;

CREATE SEQUENCE seq_registered_id
START WITH 50000
INCREMENT BY 1
MAXVALUE 60000
NOCYCLE;

DROP TABLE temp_table;

CREATE TABLE temp_table(
    -- It needs at least one address, and at most one address per client and town
    registered_id NUMBER CHECK(registered_id >= 50000),
    customer_id NUMBER CHECK(customer_id >= 40000),
    reg_username VARCHAR(30),
    reg_password VARCHAR(40) ,
    reg_date DATE,
    reg_name VARCHAR(35),
    reg_surname_1 VARCHAR(30),    
    reg_surname_2 VARCHAR(30),
    reg_email VARCHAR(100),
    reg_phone_number INT,
    contact_preference VARCHAR(30) DEFAULT 'sms',
    loyalty_discount CHAR(5)
);

INSERT INTO temp_table(reg_username, reg_password, reg_date, reg_name, reg_surname_1, reg_surname_2, reg_email, reg_phone_number, contact_preference, loyalty_discount)
SELECT DISTINCT
    t.USERNAME,
    t.USER_PASSW,
    TO_DATE(t.REG_DATE, 'YYYY/MM/DD'),
    t.CLIENT_NAME,
    t.CLIENT_SURN1,
    t.CLIENT_SURN2,
    t.CLIENT_EMAIL,
    t.CLIENT_MOBILE,
    CASE
        WHEN c.customer_phone_number IS NOT NULL THEN 'sms'
        ELSE 'email'
    END AS contact_preference,
    DISCOUNT
FROM
    fsdb.trolley t
JOIN
    customers c ON t.CLIENT_EMAIL = c.customer_email OR t.CLIENT_MOBILE = c.customer_phone_number
WHERE
    c.registered = 'Y' AND t.USERNAME IS NOT NULL AND t.USER_PASSW IS NOT NULL AND t.CLIENT_NAME IS NOT NULL AND t.REG_DATE IS NOT NULL AND t.CLIENT_SURN1 IS NOT NULL;

UPDATE temp_table tt
SET customer_id = (
    SELECT c.customer_id
    FROM customers c
    WHERE c.customer_username = tt.reg_username
    AND ROWNUM = 1 -- Limits to the first result
)
WHERE EXISTS (
    SELECT 1
    FROM customers c
    WHERE c.customer_username = tt.reg_username AND c.customer_username IS NOT NULL);


INSERT INTO registered(registered_id, customer_id, reg_username, reg_password, reg_date, reg_name, reg_surname_1, reg_surname_2, contact_preference, loyalty_discount)
SELECT
    seq_registered_id.NEXTVAL, customer_id, reg_username, reg_password, reg_date, reg_name, reg_surname_1, reg_surname_2, contact_preference, loyalty_discount
FROM TEMP_TABLE;

DROP TABLE TEMP_TABLE;


-- SELECT COUNT(DISTINCT CLIENT_NAME) FROM fsdb.trolley;
-- SELECT COUNT(DISTINCT USERNAME) FROM fsdb.trolley;

-- select distinct REG_DATE from fsdb.trolley;
-- select distinct USER_PASSW from fsdb.trolley;
-- select distinct CLIENT_MOBILE from fsdb.trolley;

-- -- registered inputs
-- select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE 
-- from fsdb.trolley WHERE USERNAME IS ;

-- -- non registered inputs
-- select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE 
-- from fsdb.trolley WHERE USERNAME IS NULL;

-- select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE, REG_DATE
-- from fsdb.trolley WHERE USERNAME IS NULL;

-- select distinct USERNAME, CLIENT_EMAIL from fsdb.trolley
-- WHERE username IS  AND CLIENT_EMAIL IS ;

-- select distinct PAYMENT_TYPE, USERNAME, CLIENT_MOBILE, CLIENT_EMAIL from fsdb.trolley
-- where PAYMENT_TYPE is null and (CLIENT_MOBILE is  or CLIENT_EMAIL is );



-- -- address inputs
-- SELECT distinct PAYMENT_TYPE, DLIV_DATE,DLIV_TIME,DLIV_WAYTYPE,DLIV_WAYNAME,DLIV_GATE,DLIV_BLOCK, DLIV_STAIRW, DLIV_FLOOR, DLIV_DOOR, DLIV_ZIP, DLIV_TOWN, DLIV_COUNTRY 
-- from fsdb.trolley
-- where PAYMENT_TYPE IS  AND DLIV_WAYNAME IS  AND DLIV_FLOOR IS  AND DLIV_DOOR IS  AND DLIV_COUNTRY IS  AND DLIV_TOWN IS ;

-- select  DISCOUNT from fsdb.trolley;
-- desc fsdb.trolley;
