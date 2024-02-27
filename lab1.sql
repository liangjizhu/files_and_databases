DROP TABLE catalogue;
DROP TABLE products;
DROP TABLE marketing_format;
DROP TABLE p_reference;
DROP TABLE replacement_order;
DROP TABLE supplier;
DROP TABLE purchase_order;
DROP TABLE billing_data;
DROP TABLE credit_card_data;
DROP TABLE delivery;
DROP TABLE orders_item;
DROP TABLE customers;
DROP TABLE registered;
DROP TABLE non_registered;
DROP TABLE customer_feedback;
DROP TABLE comments;

-- START "MY SHOP"
CREATE TABLE catalogue (
    product VARCHAR(50) NOT NULL,
    CONSTRAINT pk_catalogue PRIMARY KEY(product)
);

CREATE TABLE products(
    -- product_id == name
    product_id VARCHAR(50) NOT NULL,
    coffea VARCHAR(20) NOT NULL,
    varietal VARCHAR(30) NOT NULL,
    origin VARCHAR(15) NOT NULL,
    roast_type VARCHAR(10) NOT NULL,
    decaff CHAR(1) NOT NULL,
    -- if NULL -> delete product
    p_reference VARCHAR(15) NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY(product_id),
    CONSTRAINT fk_products_catalogue FOREIGN KEY(product_id) REFERENCES catalogue(product)
);

CREATE TABLE marketing_format(
    format_id VARCHAR(50) NOT NULL, 
    product_id VARCHAR(50) NOT NULL,
    product_format VARCHAR(20) NOT NULL,
    packaging VARCHAR(15) NOT NULL,
    CONSTRAINT pk_marketing_format PRIMARY KEY(format_id),
    CONSTRAINT fk_marketing_format_products FOREIGN KEY(product_id) REFERENCES products(product_id)
);

CREATE TABLE p_reference(    
    bar_code VARCHAR(15) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    packaging VARCHAR(15),
    retail_price VARCHAR(14),
    min_stock INT CHECK (min_stock >= 5),
    max_stock INT NOT NULL,
    current_stock INT NOT NULL,
    CONSTRAINT pk_p_reference PRIMARY KEY(bar_code),
    CONSTRAINT fk_p_reference_products FOREIGN KEY(product_id) REFERENCES products(product_id),
    CONSTRAINT check_current_stock CHECK(current_stock >= min_stock),
    CONSTRAINT check_max_stock CHECK(max_stock >= min_stock)
);

CREATE TABLE replacement_order(
    replacement_order_id VARCHAR(15) NOT NULL,
    bar_code VARCHAR(15) NOT NULL,
    supplier VARCHAR(35),
    request_amount VARCHAR(2),
    request_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    state VARCHAR(15),
    received_date DATE NOT NULL,
    payment VARCHAR(20),
    CONSTRAINT pk_replacement_order PRIMARY KEY(replacement_order_id),
    CONSTRAINT fk_replacement_order_p_reference FOREIGN KEY(bar_code) REFERENCES p_reference(bar_code),

);

CREATE TABLE supplier(
    cif VARCHAR(10) NOT NULL,
    bar_code VARCHAR(15) NOT NULL,
    provider_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    supplier_email VARCHAR(100) NOT NULL,
    supplier_phone_number INT CHECK(999999999 > supplier_phone_number >= 100000000),
    comm_address VARCHAR(100) NOT NULL,
    offer FLOAT CHECK(offer > 0),
    fulfilled_orders INT CHECK(fulfilled_orders >= 0),
    CONSTRAINT pk_supplier PRIMARY KEY(cif),
    CONSTRAINT fk_supplier_replacement_order FOREIGN KEY(bar_code) REFERENCES replacement_order(bar_code)
);
-- END "MY SHOP"

-- START "BUYING"
CREATE TABLE purchase_order(
    order_id VARCHAR(20),
    product_id VARCHAR(50),
    purchase_date DATE NOT NULL,
    delivery_data VARCHAR(50),    
);

CREATE TABLE delivery(
    customer_id INT CHECK(customer_id >= 0),
    order_date DATE NOT NULL,
    delivery_address VARCHAR(100),
);

CREATE TABLE orders_item(
    order_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INT CHECK(quantity > 0) NOT NULL,
    unit_price FLOAT CHECK(unit_price > 0) NOT NULL,
    total_price FLOAT NOT NULL,
);



CREATE TABLE customers(
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    delivery_address VARCHAR(100) NOT NULL,
    billing_data VARCHAR(20) NOT NULL,
    registered BOOL DEFAULT FALSE,
    customer_email VARCHAR(100) NOT NULL,
    customer_phone_number INT CHECK(999999999 > supplier_phone_number >= 100000000),
);

CREATE TABLE registered(
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    reg_username VARCHAR(30) NOT NULL,
    reg_password VARCHAR(40) NOT NULL,
    reg_date DATE NOT NULL,
    reg_name VARCHAR(30) NOT NULL,
    reg_surname_1 VARCHAR(30) NOT NULL,    
    reg_surname_2 VARCHAR(30),
    contact_preference VARCHAR(30) NOT NULL,
    loyalty_discount BOOL,
    order_id VARCHAR(20) NOT NULL,
);

CREATE TABLE non_registered(
    order_id VARCHAR(20) NOT NULL,
    non_reg_name VARCHAR(30) NOT NULL,
    non_reg_surname VARCHAR(30) NOT NULL,
);

CREATE TABLE billing_data(
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    -- if bill_type == credit card -> credit_card_data
    bill_type VARCHAR(20),
    payment_date DATE NOT NULL,
    credit_card_data BOOL,
);

CREATE TABLE credit_card_data(
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    cardholder VARCHAR(50) NOT NULL,
    finance_company VARCHAR(30) NOT NULL,
    card_number INT CHECK(9999999999999999 > credit_card_data >= 1000000000000000),
    expiration_date DATE NOT NULL,
);
-- END "BUYING"

-- START "RATING"
CREATE TABLE customer_feedbacks(
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    product_id VARCHAR(50),
    bar_code VARCHAR(15),
    opinion VARCHAR(1000),
    rating INT CHECK(5 >= rating > 0),
    customer_comment VARCHAR(1000),

    
);

CREATE TABLE customer_comments(
    comment_id VARCHAR(255) NOT NULL,
    score INT CHECK(10 >= rating > 0),
    text VARCHAR(1000),
    likes INT CHECK(likes >= 0),
    tag VARCHAR(40),
);
-- END "RATING"
