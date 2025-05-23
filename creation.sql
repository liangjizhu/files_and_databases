-- CREATION OF TABLES
-- Basically we create tables with lab1.sql
-- We try to insert the elements in the tables using the commands.sql
-- The sequences we need are in id_generator.sql
DROP TABLE customer_comments;
DROP TABLE non_registered;
DROP TABLE registered;
DROP TABLE orders_item;
DROP TABLE delivery;
DROP TABLE credit_card_data;
DROP TABLE billing_data;
DROP TABLE purchase_order;
DROP TABLE customers;
DROP TABLE supplier;
DROP TABLE replacement_order;
DROP TABLE p_reference;
DROP TABLE marketing_format;
DROP TABLE products;
DROP TABLE catalogue;

-- START "MY SHOP"
CREATE TABLE catalogue (
    product VARCHAR(50) NOT NULL,
    CONSTRAINT pk_catalogue PRIMARY KEY(product)
);

CREATE TABLE products(
    -- product_id == unique ID for each product
    product_id NUMBER CHECK(product_id >= 1) NOT NULL,
    product_name VARCHAR(50) NOT NULL,
    coffea VARCHAR(30) NOT NULL,
    varietal VARCHAR(30) NOT NULL,
    origin VARCHAR(15) NOT NULL,
    roast_type VARCHAR(10) NOT NULL,
    decaff CHAR(1) NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY(product_id),
    CONSTRAINT fk_products_catalogue FOREIGN KEY(product_name) REFERENCES catalogue(product)
    -- CONSTRAINT check_roast_type CHECK(roast_type IN ('natural', 'high-roast', 'blend'))
);

CREATE TABLE marketing_format(
    format_id NUMBER CHECK(format_id >= 10000) NOT NULL, 
    product_id NUMBER CHECK(product_id >= 1) NOT NULL,
    product_format VARCHAR(20) NOT NULL,
    packaging VARCHAR(15) NOT NULL,
    CONSTRAINT pk_marketing_format PRIMARY KEY(format_id),
    CONSTRAINT fk_marketing_format_products FOREIGN KEY(product_id) REFERENCES products(product_id),
    CONSTRAINT check_product_format CHECK(product_format IN ('raw bean', 'roasted bean', 'freeze-dried', 'capsules', 'prepared', 'ground'))
);

CREATE TABLE p_reference(    
    bar_code VARCHAR(15) NOT NULL,
    product_id NUMBER CHECK(product_id >= 1) NOT NULL,
    packaging VARCHAR(15),
    retail_price VARCHAR(14),
    -- By default the min_stock should be 5. How????
    -- When the min_stock is less than 5 it should place a replacement order automatically
    -- The requested units have to be max_stock - current_stock
    min_stock INT DEFAULT 5 CHECK (min_stock >= 5),
    -- Max stock should be by default 10 units higher than min_stock
    max_stock INT NOT NULL,
    current_stock INT DEFAULT 0 NOT NULL,
    CONSTRAINT pk_p_reference PRIMARY KEY(bar_code),
    CONSTRAINT fk_p_reference_products FOREIGN KEY(product_id) REFERENCES products(product_id),
    CONSTRAINT check_current_stock_1 CHECK(current_stock >= min_stock),
    CONSTRAINT check_current_stock_2 CHECK(max_stock >= current_stock),
    CONSTRAINT check_max_stock CHECK(max_stock >= min_stock)
);

CREATE TABLE replacement_order(
    replacement_order_id NUMBER CHECK(replacement_order_id >= 20000) NOT NULL,
    bar_code VARCHAR(15) NOT NULL,
    -- If for some reason there is no supplier for the reference (???),
    -- the order will remain a draft.
    -- If there is more than one supplier, you gotta choose one (CHOOSE LOWEST COST)
    -- (If tie, choose FASTEST PROVIDER)(IF another tie, CHOOSE fewest orders) (ELSE, choose random)
    supplier VARCHAR(35),
    -- The requested units have to be max_stock - current_stock
    request_amount NUMBER CHECK(request_amount > 0),
    -- This has to be updated once the delivery has arrived
    request_date DATE,
    delivery_date DATE,
    -- orders whose state == PLACED can NOT be updated (unless to change status or delivery date) or deleted
    -- CAN BE NULL BECAUSE IN THE DATABASE PROVIDED THERE IS NO RECEIVED ORDER DATE NEITHER STATE
    rorder_state VARCHAR(15) DEFAULT 'draft' NOT NULL,
    received_date DATE,
    -- payments refers to the supplier's bankaccount
    payment VARCHAR(30) NOT NULL,
    CONSTRAINT pk_replacement_order PRIMARY KEY(replacement_order_id),
    CONSTRAINT fk_replacement_order_p_reference FOREIGN KEY(bar_code) REFERENCES p_reference(bar_code),
    CONSTRAINT check_rorder_state CHECK(rorder_state IN ('fulfilled', 'draft', 'placed'))
);

CREATE TABLE supplier(
    -- creating a supplier_barcode_id because there are more suppliers for one product (bar_code)
    supplier_barcode_id NUMBER CHECK(supplier_barcode_id >= 30000),
    -- If supplier is deleted, delete all offers that are not fullfiled yet
    -- Set supplier to null in the fullfiled ones
    cif VARCHAR(10) NOT NULL,
    bar_code VARCHAR(15) NOT NULL,
    supplier_name VARCHAR(90) NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    supplier_email VARCHAR(120) NOT NULL,
    supplier_phone_number INT CHECK(supplier_phone_number >= 100000000),
    comm_address VARCHAR(120) NOT NULL,
    supplier_country CHAR(45) NOT NULL,
    supplier_bankacc CHAR(30) NOT NULL,
    offer FLOAT CHECK(offer > 0),
    fulfilled_orders NUMBER CHECK(fulfilled_orders >= 0),
    CONSTRAINT pk_supplier PRIMARY KEY(supplier_barcode_id),
    CONSTRAINT check_supplier_phone_number CHECK(999999999 > supplier_phone_number),
    CONSTRAINT fk_supplier_replacement_order FOREIGN KEY(bar_code) REFERENCES p_reference(bar_code),
    CONSTRAINT fk_fullfilled_orders FOREIGN KEY(fulfilled_orders) REFERENCES replacement_order(replacement_order_id)
);

-- END "MY SHOP"

-- START "BUYING"
CREATE TABLE customers(
    customer_id NUMBER CHECK(customer_id >= 40000) NOT NULL,
    delivery_address VARCHAR(300) NOT NULL,
    billing_id NUMBER,
    registered CHAR(1),
    customer_email VARCHAR(100),
    customer_phone_number INT CHECK(customer_phone_number >= 100000000),
    customer_username VARCHAR(30),
    CONSTRAINT pk_customers PRIMARY KEY(customer_id),
    CONSTRAINT check_customer_phone_number CHECK(999999999 > customer_phone_number)
);

CREATE TABLE purchase_order(
    order_id VARCHAR(20),
    bar_code VARCHAR(15),
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    purchase_date DATE NOT NULL,
    -- Charge credit card the same day as the order ("charges to credit cards are always placed on the order’s date")
     -- If orders from same customer to same address > 1, create delivery
    delivery_data VARCHAR(50),   
    CONSTRAINT pk_purchase_order PRIMARY KEY(order_id),
    CONSTRAINT fk_purchase_order_products FOREIGN KEY(bar_code) REFERENCES p_reference(bar_code),
    CONSTRAINT fk_purchase_order_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE delivery(
    delivery_id VARCHAR(30) NOT NULL,
    order_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    delivery_address VARCHAR(100),
    CONSTRAINT pk_delivery PRIMARY KEY(delivery_id),
    CONSTRAINT fk_delivery_purchase_order FOREIGN KEY(order_id) REFERENCES purchase_order(order_id)
);

CREATE TABLE orders_item(
    order_id VARCHAR(20) NOT NULL,
    product_id NUMBER CHECK(product_id >= 1) NOT NULL,
    -- Check that quantity < Stock (if quantity > stock, quantity = max_stock + display message to user)
    quantity INT CHECK(quantity > 0) NOT NULL,
    unit_price FLOAT CHECK(unit_price > 0) NOT NULL,
    total_price FLOAT NOT NULL,
    CONSTRAINT pk_orders_item PRIMARY KEY(order_id),
    CONSTRAINT fk_orders_item_products FOREIGN KEY(product_id) REFERENCES products(product_id)
);

CREATE TABLE registered(
    -- It needs at least one address, and at most one address per client and town
    registered_id NUMBER CHECK(registered_id >= 50000) NOT NULL,
    customer_id NUMBER CHECK(customer_id >= 40000) NOT NULL,
    reg_username VARCHAR(30) NOT NULL,
    reg_password VARCHAR(40) NOT NULL,
    reg_date DATE NOT NULL,
    reg_name VARCHAR(35) NOT NULL,
    reg_surname_1 VARCHAR(30) NOT NULL,    
    reg_surname_2 VARCHAR(30),
    contact_preference VARCHAR(30) DEFAULT 'sms' NOT NULL,
    loyalty_discount CHAR(5),
    CONSTRAINT pk_registered PRIMARY KEY(registered_id),
    CONSTRAINT fk_registered_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE non_registered(
    non_registered_id VARCHAR(30) NOT NULL,
    customer_id NUMBER CHECK(customer_id >= 40000) NOT NULL,
    order_id VARCHAR(20) NOT NULL,
    non_reg_name VARCHAR(30) NOT NULL,
    non_reg_surname VARCHAR(30) NOT NULL,
    CONSTRAINT pk_non_registered PRIMARY KEY(non_registered_id),
    CONSTRAINT fk_non_registered_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE billing_data(
    billing_id VARCHAR(30) NOT NULL,
    customer_id NUMBER CHECK(customer_id >= 40000) NOT NULL,
    -- if bill_type == credit card -> credit_card_data
    bill_type VARCHAR(20),
    payment_date DATE NOT NULL,
    credit_card_data CHAR(1),
    CONSTRAINT pk_billing_data PRIMARY KEY(billing_id),
    CONSTRAINT fk_billing_data_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE credit_card_data(
    credit_card_data_id VARCHAR(30) NOT NULL,
    billing_id VARCHAR(30) NOT NULL,
    cardholder VARCHAR(50) NOT NULL,
    finance_company VARCHAR(30) NOT NULL,
    card_number INT CHECK(card_number >= 1000000000000000),
    expiration_date DATE NOT NULL,
    CONSTRAINT pk_credit_card_data PRIMARY KEY(credit_card_data_id),
    CONSTRAINT fk_credit_card_data_billing_data FOREIGN KEY(billing_id) REFERENCES billing_data(billing_id),
    CONSTRAINT check_credit_card_data_card_number CHECK(9999999999999999 > card_number)
);
-- END "BUYING"

-- START "RATING"
CREATE TABLE customer_comments(
    comment_id VARCHAR(255) NOT NULL,
    customer_id NUMBER CHECK(customer_id >= 40000),
    username CHAR(30),
    product CHAR(50),
    barcode CHAR(15),
    post_date CHAR(14),
    post_time CHAR(14),
    title CHAR(50),
    score INT CHECK(score > 0),
    comment_text CHAR(2000),
    likes INT DEFAULT 0 CHECK(likes >= 0),
    tag CHAR(50),
    CONSTRAINT pk_customer_comments PRIMARY KEY(comment_id),
    CONSTRAINT fk_customer_comments_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    CONSTRAINT check_customer_comments_score CHECK(6 >= score)
);
-- END "RATING"

-- clear scr;
