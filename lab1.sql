DROP TABLE catalogue;
DROP TABLE products;
DROP TABLE p_reference;
DROP TABLE replacement_order;
DROP TABLE supplier;
DROP TABLE supply_line;
DROP TABLE purchase_order;
DROP TABLE billing_data;
DROP TABLE credit_card_data;
DROP TABLE delivery;
DROP TABLE delivery_data;
DROP TABLE registered;
DROP TABLE non_registered;
DROP TABLE client_feedback;
DROP TABLE comments;


CREATE TABLE catalogue{
    product VARCHAR(50) NOT NULL,
    CONSTRAINT pk_catalogue PRIMARY KEY(product)
};

CREATE TABLE products{
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
};

CREATE TABLE p_reference{
    bar_code VARCHAR(15),
    packaging VARCHAR(15),
    retail_price VARCHAR(14),
    min_stock INT CHECK (min_stock >= 0),
    max_stock INT CHECK (max_stock >= min_stock),
    current_stock INT CHECK (max_stock >= current_stock >= min_stock),
    CONSTRAINT pk_p_reference PRIMARY KEY(bar_code),
    CONSTRAINT fk_p_reference_products FOREIGN KEY(bar_code) REFERENCE products(p_reference)
};

CREATE TABLE replacement_order{
    p_reference VARCHAR(15);
    supplier VARCHAR(35);
    request_amount VARCHAR(2);
    request_date DATE NOT NULL;
    delivery_date DATE NOT NULL;

}


