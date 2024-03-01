DROP SEQUENCE seq_address_id;

CREATE SEQUENCE seq_address_id
START WITH 50000
INCREMENT BY 1
MAXVALUE 60000
NOCYCLE;

-- CREATE TABLE address(
--     address_id INT CHECK (address_id >=50000) NOT NULL,
--     add_type VARCHAR(20) NOT NULL,
--     add_name VARCHAR(100) NOT NULL,
--     gateway_num INT,
--     block_num INT,
--     stairs_id CHAR(1),
--     floor_num INT,
--     door_num INT,
--     zip_code INT NOT NULL,
--     town_name VARCHAR(100) NOT NULL,
--     country VARCHAR(100) NOT NULL,
--     CONSTRAINT pk_address PRIMARY KEY (address_id),
--     CONSTRAINT fk_address_customers FOREIGN KEY (address_id) REFERENCES customers(customer_id),
--     CONSTRAINT check_zip_code CHECK (zip_code >= 10000),
--     CONSTRAINT check_valid_ints CHECK (gateway_num > 0 AND block_num > 0 AND door_num > 0)
-- );

DROP TABLE temp_table;

CREATE TABLE temp_table(
    address_id INT CHECK (address_id >=50000) NOT NULL,
    add_type VARCHAR(20) NOT NULL,
    add_name VARCHAR(100) NOT NULL,
    gateway_num INT,
    block_num INT,
    stairs_id CHAR(1),
    floor_num INT,
    door_num INT,
    zip_code INT NOT NULL,
    town_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
);

INSERT INTO customers(customer_id, username, reg_date, reg_time,
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


