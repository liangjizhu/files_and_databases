DROP TABLE temp_table;

CREATE TABLE temp_table (
    bar_code VARCHAR(15),
    packaging VARCHAR(15),
    retail_price VARCHAR(14),
    product_id NUMBER,
    product_name VARCHAR(50),
    current_stock VARCHAR(5),
    min_stock VARCHAR(5),
    max_stock VARCHAR(5)
);


INSERT INTO temp_table(bar_code, packaging, retail_price, current_stock, product_name, min_stock, max_stock)
SELECT
    BARCODE,
    PACKAGING,
    RETAIL_PRICE,
    CUR_STOCK,
    PRODUCT,
    MIN_STOCK,
    MAX_STOCK
FROM fsdb.catalogue
GROUP BY BARCODE, PACKAGING, RETAIL_PRICE, CUR_STOCK, PRODUCT, MIN_STOCK, MAX_STOCK;


UPDATE temp_table
SET product_id = (
    SELECT product_id
    FROM products
    WHERE product_name = temp_table.product_name
);

INSERT INTO p_reference(bar_code, product_id, packaging, retail_price, min_stock, max_stock, current_stock)
SELECT
    bar_code,
    product_id,
    packaging,
    retail_price,
    min_stock,
    max_stock,
    current_stock    
FROM temp_table;

DROP TABLE temp_table;

-- select * from p_reference;
-- select min_stock, max_stock, current_stock from p_reference;
