-- "CREATE TABLE purchase_order(
--     order_id VARCHAR(20),
--     product_id NUMBER CHECK(product_id >= 1) NOT NULL,
--     customer_id INT CHECK(customer_id >= 0) NOT NULL,
--     purchase_date DATE NOT NULL,
--     -- Charge credit card the same day as the order ("charges to credit cards are always placed on the order’s date")
--      -- If orders from same customer to same address > 1, create delivery
--     delivery_data VARCHAR(50),   
--     CONSTRAINT pk_purchase_order PRIMARY KEY(order_id),
--     CONSTRAINT fk_purchase_order_products FOREIGN KEY(product_id) REFERENCES products(product_id),
--     CONSTRAINT fk_purchase_order_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
-- );"

DROP TABLE temp_table;

DROP SEQUENCE seq_purchase;

CREATE SEQUENCE seq_purchase
START WITH 50000
INCREMENT BY 1
MAXVALUE 60000
NOCYCLE;

CREATE TABLE temp_table(
    order_id VARCHAR(20),
    bar_code VARCHAR(50),
    customer_id INT,
    delivery_data VARCHAR(50)
);

INSERT INTO temp_table(bar_code)
SELECT
    BARCODE
FROM fsdb.trolley
WHERE BARCODE IS NOT NULL;

UPDATE temp_table
SET customer_id = (
    SELECT customer_id
    FROM temp_table2
    WHERE customer_email = 
    SELECT CLIENT_EMAIL 
    FROM fsdb.trolley
);


UPDATE temp_table
SET customer_id = (
    seq_purchase.NEXTVAL
);
