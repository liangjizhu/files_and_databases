DROP TABLE catalogue;
DROP TABLE products;
DROP TABLE marketing_format;
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
    decaff VARCHAR(12),
    -- marketing_format is a code for identifying what packaging a product follows
    marketing_format VARCHAR(2),
    p_reference VARCHAR(15),

    CONSTRAINT pk_catalogue PRIMARY KEY(product)

    
};

