-- THE TABLE IS CALLED CUSTOMER WITHOU 'S' AT THE END. IT IS NOT THE SAME TABLE

CREATE TABLE customer(
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    username CHAR(30),
    reg_date CHAR(14),
    reg_time CHAR(14),
    user_password CHAR(15),
    customer_name CHAR(35) NOT NULL,
    customer_surname1 CHAR(30) NOT NULL,
    customer_surname2 CHAR(30),
    customer_email VARCHAR(60),
    customer_phone_number CHAR(9),
    CONSTRAINT pk_customer PRIMARY KEY(customer_id)
);

DROP SEQUENCE seq_customer_id;
CREATE SEQUENCE seq_customer_id
START WITH 10000
INCREMENT BY 1
MAXVALUE 20000
NOCYCLE;


CREATE TABLE temp_table_customer (
    customer_id NUMBER,
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

INSERT INTO temp_table_customer(username ,reg_date,
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

UPDATE temp_table_customer
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
FROM temp_table_customer;

DROP TABLE temp_table_customer;
