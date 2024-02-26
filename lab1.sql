DROP TABLE catalogue;
DROP TABLE products;
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
DROP TABLE client_feedback;
DROP TABLE comments;


CREATE TABLE catalogue (
    product VARCHAR(50) NOT NULL,
    CONSTRAINT pk_catalogue PRIMARY KEY(product)
);

CREATE TABLE products(
    -- product_id == name
    product_id VARCHAR(50) NOT NULL,
    coffea VARCHAR(20),
    varietal VARCHAR(30),
    origin VARCHAR(15),
    roast_type VARCHAR(10),
    decaff BOOL,
    -- if NULL -> delete product
    packaging VARCHAR(15),
    p_reference VARCHAR(15),
    CONSTRAINT pk_products PRIMARY KEY(product_id, p_reference),
    CONSTRAINT fk_products_catalogue FOREIGN KEY(product_id) REFERENCES catalogue(product)
);

CREATE TABLE p_reference(
    bar_code VARCHAR(15),
    packaging VARCHAR(15),
    retail_price VARCHAR(14),
    min_stock INT CHECK (min_stock >= 5),
    max_stock INT CHECK (max_stock >= min_stock),
    current_stock INT CHECK (max_stock >= current_stock >= min_stock),
    CONSTRAINT pk_p_reference PRIMARY KEY(bar_code),
    CONSTRAINT fk_p_reference_products FOREIGN KEY(bar_code) REFERENCE products(p_reference)
);

CREATE TABLE replacement_order(
    p_reference VARCHAR(15);
    -- needed??
    replacement_order_id VARCHAR(15);
    supplier VARCHAR(35);
    request_amount VARCHAR(2);
    request_date DATE NOT NULL;
    delivery_date DATE NOT NULL;
    state VARCHAR(15);
    received_date DATE NOT NULL;
    payment VARCHAR(20);
    CONSTRAINT pk_replacement_order PRIMARY KEY(p_reference, replacement_order_id);
    CONSTRAINT fk_replacement_order_p_reference FOREIGN KEY(p_reference) REFERENCES p_reference(bar_code);

);

CREATE TABLE supplier(
    provider_name VARCHAR(50) NOT NULL;
    cif VARCHAR(10) NOT NULL;
    full_name VARCHAR(100) NOT NULL;
    email VARCHAR(100) NOT NULL;
    phone_number INT CHECK(999999999 > phone_number >= 100000000);
    comm_address VARCHAR(100) NOT NULL;
    offer FLOAT CHECK(offer > 0);
    fulfilled_orders INT CHECK(fulfilled_orders >= 0);
    CONSTRAINT pk_supplier PRIMARY KEY(provider_name, cif);

);

CREATE TABLE purchase_order(
    order_id VARCHAR(20);
    product_id VARCHAR(50);
    purchase_date DATE NOT NULL;
    delivery_data VARCHAR(50);    
);
CREATE TABLE billing_data(
    customer_id INT CHECK(customer_id >= 0);
    -- if bill_type == credit card -> credit_card_data
    bill_type VARCHAR(20);
    payment_date DATE NOT NULL;
    
);

CREATE TABLE credit_card_data(
    customer_id INT CHECK(customer_id >= 0);
    cardholder VARCHAR(50);
    finance_company VARCHAR(30);
    card_number INT CHECK(9999999999999999 > credit_card_data >= 1000000000000000)
);

CREATE TABLE delivery(
    customer_id INT CHECK(customer_id >= 0);
    order_date DATE NOT NULL;
    delivery_address VARCHAR(100);
);

CREATE TABLE orders_item(
    order_id VARCHAR(20);
    product_id VARCHAR(50);
    quantity INT CHECK(quantity > 0);
    unit_price FLOAT CHECK(unit_price > 0);
    total_price FLOAT;
    
);

CREATE TABLE customers(
    customer_id INT CHECK(customer_id >= 0);

);



