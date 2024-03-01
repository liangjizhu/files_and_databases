DROP SEQUENCE seq_format_id;

CREATE SEQUENCE seq_format_id
START WITH 10000
INCREMENT BY 1
MAXVALUE 20000
NOCYCLE;

CREATE TABLE customers(
    customer_id INT 
    customer_name CHAR(35),
    customer_surname1 CHAR(35),
    customer_surname2 CHAR(35),
    delivery_address VARCHAR(100) NOT NULL,
    billing_data VARCHAR(20) NOT NULL,
    registered CHAR(1),
    customer_email VARCHAR(100) NOT NULL,
    customer_phone_number INT CHECK(customer_phone_number >= 100000000),
    CONSTRAINT pk_customers PRIMARY KEY(customer_name),
    CONSTRAINT check_customer_phone_number CHECK(999999999 > customer_phone_number)
);

CREATE TABLE registered(
    -- It needs at least one address, and at most one address per client and town,
    reg_id INT
    reg_username VARCHAR(35) NOT NULL,
    reg_password CHAR(15) NOT NULL,
    reg_date CHAR(14) NOT NULL,
    reg_time CHAR(14) NOT NULL,
    reg_name CHAR(35) NOT NULL,
    reg_surname_1 CHAR(35) NOT NULL,    
    reg_surname_2 CHAR(35),
    reg_email CHAR(60),
    reg_mobile CHAR(9),
    contact_preference VARCHAR(30) DEFAULT 'sms' NOT NULL,
    loyalty_discount CHAR(3),
    CONSTRAINT pk_registered PRIMARY KEY(reg_username),
    CONSTRAINT fk_registered_customers FOREIGN KEY(reg_username) REFERENCES customers(customer_id)
);

DROP TABLE temp_table;

CREATE TABLE temp_table(
    reg_id INT
    reg_username CHAR(35)
    reg_password CHAR(15)
    reg_date CHAR(14)
    reg_name CHAR(35)
    reg_surname_1 CHAR(35)
    reg_surname_2 CHAR(35)
    reg_email CHAR(60)
    reg_mobile CHAR(9)
    contact_preference VARCHAR(30)
    loyalty_discount CHAR(3)
)

INSERT INTO temp_table (reg_username, reg_password, reg_date, reg_name, reg_surname_1,
reg_surname_2, reg_email, reg_mobile, contact_preference, loyalty_discount)
SELECT
    USERNAME,
    USER_PASSW,
    REG_DATE,
    REG_TIME,
    CLIENT_NAME,
    CLIENT_SURN1,
    CLIENT_SURN2,
    CLIENT_EMAIL,
    CLIENT_MOBILE,
    CASE
       WHEN USERNAME IS NOT NULL THEN contact_preference = 'sms'
    END,
    DISCOUNT
FROM fsdb.trolley
WHERE USERNAME IS NOT NULL AND USER_PASSW IS NOT NULL
AND REG_DATE IS NOT NULL AND REG_TIME IS NOT NULL AND CLIENT_NAME
IS NOT NULL AND CLIENT_SURN1 IS NOT NULL;


UPDATE temp_table
SET reg_id = (
    SELECT customer_id
    FROM customers
    WHERE customer_name = temp_table.CLIENT_NAME AND customer_surname1 = temp_table.CLIENT_SURN1
    AND customer_surname2 = temp_table.CLIENT_SURN2
);

INSERT INTO registered(reg_username, reg_password, reg_date, reg_name, reg_surname_1,
reg_surname_2, reg_email, reg_mobile, contact_preference, loyalty_discount)
SELECT
reg_username,
reg_password,
reg_date,
reg_name,
reg_surname_1,
reg_surname_2,
reg_email,
reg_mobile,
contact_preference,
loyalty_discount
FROM temp_table;
