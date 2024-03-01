-- CREATE TABLE registered(
--     -- It needs at least one address, and at most one address per client and town
--     registered_id VARCHAR(30) ,
--     customer_id NUMBER CHECK(customer_id >= 40000) ,
--     reg_username VARCHAR(30) ,
--     reg_password VARCHAR(40) ,
--     reg_date DATE ,
--     reg_name VARCHAR(30) ,
--     reg_surname_1 VARCHAR(30) ,    
--     reg_surname_2 VARCHAR(30),
--     contact_preference VARCHAR(30) DEFAULT 'sms' ,
--     loyalty_discount CHAR(1),
--     CONSTRAINT pk_registered PRIMARY KEY(registered_id),
--     CONSTRAINT fk_registered_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
-- );
-- CREATE SEQUENCE TO GENERATE registered_id automatically
DROP SEQUENCE seq_registered_id;

CREATE SEQUENCE seq_registered_id
START WITH 100000
INCREMENT BY 1
MAXVALUE 999999
NOCYCLE;

DROP TABLE  temp_table_1;

CREATE TABLE  temp_table_1(
    -- It needs at least one address, and at most one address per client and town
    registered_id NUMBER CHECK(registered_id >= 100000),
    customer_id NUMBER CHECK(customer_id >= 40000),
    reg_username VARCHAR(30),
    reg_password VARCHAR(40) ,
    reg_date DATE ,
    reg_name VARCHAR(30) ,
    reg_surname_1 VARCHAR(30) ,    
    reg_surname_2 VARCHAR(30),
    contact_preference VARCHAR(30) DEFAULT 'sms' ,
    loyalty_discount CHAR(1)
);

INSERT INTO  temp_table_1(reg_username)
SELECT DISTINCT
    t.USERNAME
FROM 
    fsdb.trolley t
JOIN 
    customers c ON t.CLIENT_EMAIL = c.customer_email
WHERE 
    c.registered = 'Y' AND t.username IS NOT NULL;

INSERT INTO registered(registered_id, customer_id, reg_username, reg_password, reg_date, reg_name, reg_surname_1, reg_surname_2, contact_preference, loyalty_discount)
SELECT
    seq_registered_id.NEXTVAL,
    t.customer_id,  -- This assumes 'customer_id' is the correct column in 'fsdb.trolley'
    t.username,  -- Replace with the actual username column from 'fsdb.trolley'
    t.password,  -- Replace with the actual password column from 'fsdb.trolley'
    CURRENT_DATE,  -- Assuming you want to use the current date as the registration date
    t.name,  -- Replace with the actual name column from 'fsdb.trolley'
    t.surname_1,  -- Replace with the actual surname_1 column from 'fsdb.trolley'
    t.surname_2,  -- Replace with the actual surname_2 column from 'fsdb.trolley'
    t.contact_pref,  -- Replace with the actual contact preference column from 'fsdb.trolley'
    t.loyalty_disc  -- Replace with the actual loyalty discount column from 'fsdb.trolley'
FROM 
    fsdb.trolley t
JOIN 
    customers c ON t.customer_id = c.customer_id  -- Adjust this condition to match the actual columns
WHERE 
    c.registered = 'Y';



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

-- select distinct text from fsdb.posts;
-- desc fsdb.trolley;
