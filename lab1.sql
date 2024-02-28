DROP TABLE customer_comments;
DROP TABLE customer_feedbacks;
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
    product_id NUMBER CHECK(product_id >= 10000) NOT NULL,
    product_name VARCHAR(50) NOT NULL,
    coffea VARCHAR(20) NOT NULL,
    varietal VARCHAR(30) NOT NULL,
    origin VARCHAR(15) NOT NULL,
    roast_type VARCHAR(10) NOT NULL,
    decaff VARCHAR(12) NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY(product_id),
    CONSTRAINT fk_products_catalogue FOREIGN KEY(product_name) REFERENCES catalogue(product),
    CONSTRAINT check_roast_type CHECK(roast_type IN ('natural', 'high-roast', 'mixture'))
);

CREATE TABLE marketing_format(
    format_id VARCHAR(50) NOT NULL, 
    product_id INT CHECK(product_id >= 10000) NOT NULL,
    product_format VARCHAR(20) NOT NULL,
    packaging VARCHAR(15) NOT NULL,
    CONSTRAINT pk_marketing_format PRIMARY KEY(format_id),
    CONSTRAINT fk_marketing_format_products FOREIGN KEY(product_id) REFERENCES products(product_id),
    CONSTRAINT check_format_id CHECK(format_id IN ('raw grain', 'roasted beans', 'freeze-dried', 'in capsules', 'prepared'))
);

CREATE TABLE p_reference(    
    bar_code VARCHAR(15) NOT NULL,
    product_id INT CHECK(product_id >= 10000) NOT NULL,
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
    replacement_order_id VARCHAR(15) NOT NULL,
    bar_code VARCHAR(15) NOT NULL,
    -- If for some reason there is no supplier for the reference (???),
    -- the order will remain a draft.
    -- If there is more than one supplier, you gotta choose one (CHOOSE LOWEST COST)
    -- (If tie, choose FASTEST PROVIDER)(IF another tie, CHOOSE fewest orders) (ELSE, choose random)
    supplier VARCHAR(35),
    -- The requested units have to be max_stock - current_stock
    request_amount VARCHAR(2),
    -- This has to be updated once the delivery has arrived
    request_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    -- orders whose state == PLACED can NOT be updated (unless to change status or delivery date) or deleted
    rorder_state VARCHAR(15),
    received_date DATE NOT NULL,
    payment VARCHAR(20),
    CONSTRAINT pk_replacement_order PRIMARY KEY(replacement_order_id),
    CONSTRAINT fk_replacement_order_p_reference FOREIGN KEY(bar_code) REFERENCES p_reference(bar_code),
    CONSTRAINT check_rorder_state CHECK(rorder_state IN ('fulfilled', 'draft', 'placed'))
);

CREATE TABLE supplier(
    -- If supplier is deleted, delete all offers that are not fullfiled yet
    -- Set supplier to null in the fullfiled ones
    cif VARCHAR(10) NOT NULL,
    bar_code VARCHAR(15) NOT NULL,
    provider_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    supplier_email VARCHAR(100) NOT NULL,
    supplier_phone_number INT CHECK(supplier_phone_number >= 100000000),
    comm_address VARCHAR(100) NOT NULL,
    offer INT CHECK(offer >= 0) NOT NULL,
    fulfilled_orders VARCHAR(15),
    CONSTRAINT pk_supplier PRIMARY KEY(cif),
    CONSTRAINT fk_supplier_replacement_order FOREIGN KEY(bar_code) REFERENCES p_reference(bar_code),
    CONSTRAINT check_supplier_phone_number CHECK(999999999 > supplier_phone_number),
    -- not the already fulfilled orders to them (which will be kept without a value for provider). 
    CONSTRAINT fk_fulfilled_orders FOREIGN KEY(fulfilled_orders) REFERENCES replacement_order(replacement_order_id) ON DELETE SET NULL
);

-- END "MY SHOP"

-- START "BUYING"
CREATE TABLE customers(
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    delivery_address VARCHAR(100) NOT NULL,
    billing_data VARCHAR(20) NOT NULL,
    registered CHAR(1),
    customer_email VARCHAR(100) NOT NULL,
    customer_phone_number INT CHECK(customer_phone_number >= 100000000),
    CONSTRAINT pk_customers PRIMARY KEY(customer_id),
    CONSTRAINT check_customer_phone_number CHECK(999999999 > customer_phone_number)
);

CREATE TABLE address(
    address_id INT CHECK (address_id >=0) NOT NULL,
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
    CONSTRAINT pk_address PRIMARY KEY address_id,
    CONSTRAINT fk_address_customers FOREIGN KEY (address_id) REFERENCES customers(customer_id),
    CONSTRAINT check_zip_code CHECK (zip_code >= 10000),
    CONSTRAINT check_valid_ints CHECK (gateway_num > 0 AND block_num > 0 AND door_num > 0)
);

CREATE TABLE purchase_order(
    order_id VARCHAR(20) NOT NULL,
    product_id INT CHECK(product_id >= 10000) NOT NULL,
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    purchase_date DATE NOT NULL,
    -- Charge credit card the same day as the order ("charges to credit cards are always placed on the order’s date")
     -- If orders from same customer to same address > 1, create delivery
    delivery_data VARCHAR(50),   
    CONSTRAINT pk_purchase_order PRIMARY KEY(order_id),
    CONSTRAINT fk_purchase_order_products FOREIGN KEY(product_id) REFERENCES products(product_id),
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
    product_id INT CHECK(product_id >= 10000) NOT NULL,
    -- Check that quantity < Stock (if quantity > stock, quantity = max_stock + display message to user)
    quantity INT CHECK(quantity > 0) NOT NULL,
    unit_price FLOAT CHECK(unit_price > 0) NOT NULL,
    total_price FLOAT NOT NULL,
    CONSTRAINT pk_orders_item PRIMARY KEY(order_id),
    CONSTRAINT fk_orders_item_products FOREIGN KEY(product_id) REFERENCES products(product_id)
);

CREATE TABLE registered(
    -- It needs at least one address, and at most one address per client and town
    registered_id VARCHAR(30) NOT NULL,
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    reg_username VARCHAR(30) NOT NULL,
    reg_password VARCHAR(40) NOT NULL,
    reg_date DATE NOT NULL,
    reg_name VARCHAR(30) NOT NULL,
    reg_surname_1 VARCHAR(30) NOT NULL,    
    reg_surname_2 VARCHAR(30),
    contact_preference VARCHAR(30) DEFAULT 'sms' NOT NULL,
    loyalty_discount CHAR(1),
    order_id VARCHAR(20) DEFAULT 'anonymous',
    CONSTRAINT pk_registered PRIMARY KEY(registered_id),
    CONSTRAINT fk_registered_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE non_registered(
    non_registered_id VARCHAR(30) NOT NULL,
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    order_id VARCHAR(20) NOT NULL,
    non_reg_name VARCHAR(30) NOT NULL,
    non_reg_surname VARCHAR(30) NOT NULL,
    CONSTRAINT pk_non_registered PRIMARY KEY(non_registered_id),
    CONSTRAINT fk_non_registered_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE billing_data(
    billing_id VARCHAR(30) NOT NULL,
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
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
CREATE TABLE customer_feedbacks(
    feedback_id VARCHAR(30) NOT NULL,
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    product_id INT CHECK(product_id >= 10000) NOT NULL,
    bar_code VARCHAR(15),
    opinion VARCHAR(1000),
    rating INT CHECK(rating > 0),
    customer_comment VARCHAR(1000),
    CONSTRAINT pk_customer_feedbacks PRIMARY KEY(feedback_id),
    CONSTRAINT fk_customer_feedbacks_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    CONSTRAINT check_customer_feedbacks_rating CHECK(5 >= rating)
);

CREATE TABLE customer_comments(
    comment_id VARCHAR(255) NOT NULL,
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    score INT CHECK(score > 0),
    text VARCHAR(1000),
    likes INT DEFAULT 0 CHECK(likes >= 0),
    tag VARCHAR(40),
    CONSTRAINT pk_customer_comments PRIMARY KEY(comment_id),
    CONSTRAINT fk_customer_comments_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    CONSTRAINT check_customer_comments_score CHECK(5 >= score)
);
-- END "RATING"
