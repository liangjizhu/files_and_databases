-- CREATE SEQUENCE TO GENERATE registered_id automatically
DROP SEQUENCE seq_registered_id;

CREATE SEQUENCE seq_registered_id
START WITH 50000
INCREMENT BY 1
MAXVALUE 60000
NOCYCLE;

-- we create a temporal table to filter the restrictions
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
    -- we change the data char to date
    TO_DATE(t.REG_DATE, 'YYYY/MM/DD'),
    t.CLIENT_NAME,
    t.CLIENT_SURN1,
    t.CLIENT_SURN2,
    t.CLIENT_EMAIL,
    t.CLIENT_MOBILE,
    CASE
        -- when there is phone the contact_preference is set to sms else to smail
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

-- we update by setting the first ocurrence of the customer id
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

-- we insert it to the main table
INSERT INTO registered(registered_id, customer_id, reg_username, reg_password, reg_date, reg_name, reg_surname_1, reg_surname_2, contact_preference, loyalty_discount)
SELECT
    seq_registered_id.NEXTVAL, customer_id, reg_username, reg_password, reg_date, reg_name, reg_surname_1, reg_surname_2, contact_preference, loyalty_discount
FROM TEMP_TABLE;

-- we eliminate the unnecesary table
DROP TABLE TEMP_TABLE;
