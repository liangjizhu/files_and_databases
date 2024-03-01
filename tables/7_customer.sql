-- CREATE TABLE customer(
--     customer_id INT CHECK(customer_id >= 0) NOT NULL,
--     username CHAR(30),
--     reg_date CHAR(14),
--     reg_time CHAR(14),
--     user_password CHAR(15),
--     customer_name CHAR(35) NOT NULL,
--     customer_surname1 CHAR(30) NOT NULL,
--     customer_surname2 CHAR(30),
--     customer_email VARCHAR(60),
--     customer_phone_number CHAR(9),
--     CONSTRAINT pk_customer PRIMARY KEY(customer_id)
-- );

-- CREATE SEQUENCE TO GENERATE customer_id automatically
DROP SEQUENCE seq_customer_id;

CREATE SEQUENCE seq_customer_id
START WITH 40000
INCREMENT BY 1
MAXVALUE 50000
NOCYCLE;


CREATE TABLE temp_table(
    customer_id NUMBER CHECK(customer_id >= 40000) NOT NULL,
    username CHAR(30),
    reg_date CHAR(14),
    reg_time CHAR(14),
    user_password CHAR(15),
    customer_name CHAR(35),
    customer_surname1 CHAR(30),
    customer_surname2 CHAR(30),
    customer_email VARCHAR(60),
    customer_phone_number CHAR(9)
);

INSERT INTO temp_table(username ,reg_date,
reg_time , user_password, customer_name, customer_surname1,
customer_surname2, customer_email, customer_phone_number)
SELECT
    USERNAME,
    REG_DATE,
    REG_TIME,
    USER_PASSW,
    CLIENT_NAME,
    CLIENT_SURN1,
    CLIENT_SURN2,
    CLIENT_EMAIL,
    CLIENT_MOBILE
FROM fsdb.trolley
GROUP BY USERNAME, REG_DATE, REG_TIME, USER_PASSW, CLIENT_NAME,
CLIENT_SURN1, CLIENT_SURN2, CLIENT_EMAIL, CLIENT_MOBILE;

UPDATE temp_table
SET customer_id = (
    seq_customer_id.NEXTVAL
);

INSERT INTO customer(customer_id, username, reg_date, reg_time,
user_password, customer_name, customer_surname1, customer_surname2,
customer_email, customer_phone_number)
SELECT
customer_id,
username,
reg_date,
reg_time,
user_password,
customer_name,
customer_surname1,
customer_surname2,
customer_email,
customer_phone_number
FROM temp_table;

DROP TABLE temp_table;

SELECT COUNT(DISTINCT CLIENT_NAME) FROM fsdb.trolley;
SELECT COUNT(DISTINCT USERNAME) FROM fsdb.trolley;

select distinct REG_DATE from fsdb.trolley;
select distinct USER_PASSW from fsdb.trolley;
select distinct CLIENT_MOBILE from fsdb.trolley;

-- registered
select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE 
from fsdb.trolley WHERE USERNAME IS NOT NULL;

-- non registered
select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE 
from fsdb.trolley WHERE USERNAME IS NULL;

select distinct USERNAME, CLIENT_EMAIL, CLIENT_MOBILE, REG_DATE
from fsdb.trolley WHERE USERNAME IS NULL;

select distinct USERNAME, CLIENT_EMAIL from fsdb.trolley;
select distinct USERNAME, CLIENT_MOBILE from fsdb.trolley;

SELECT distinct DLIV_DATE,DLIV_TIME,DLIV_WAYTYPE,DLIV_WAYNAME,DLIV_GATE,DLIV_BLOCK, DLIV_STAIRW, DLIV_FLOOR, DLIV_DOOR, DLIV_ZIP, DLIV_TOWN, DLIV_COUNTRY 
from fsdb.trolley
where DLIV_WAYNAME IS NOT NULL AND DLIV_FLOOR IS NOT NULL AND DLIV_DOOR IS NOT NULL AND DLIV_COUNTRY IS NOT NULL AND DLIV_TOWN IS NOT NULL;
 
desc fsdb.trolley;
