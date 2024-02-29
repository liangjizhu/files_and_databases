-- CREATE SEQUENCE TO GENERATE format_id automatically
DROP SEQUENCE seq_format_id;

CREATE SEQUENCE seq_format_id
START WITH 10000
INCREMENT BY 1
MAXVALUE 20000
NOCYCLE;
-- 

-- Create temporary table where we will store the values for marketing_format

DROP TABLE temp_table;

CREATE TABLE temp_table (
    product_name VARCHAR2(50),
    product_id NUMBER,
    product_format VARCHAR(20),
    packaging VARCHAR(15)
);


INSERT INTO temp_table (product_name, product_format, packaging)
SELECT
    PRODUCT,
    FORMAT,
    PACKAGING
FROM fsdb.catalogue
WHERE PRODUCT IS NOT NULL AND FORMAT IS NOT NULL AND PACKAGING IS NOT NULL
GROUP BY PRODUCT, FORMAT, PACKAGING;


-- Step 2: Populate the product_id column in fsdb.catalogue
UPDATE temp_table
SET product_id = (
    SELECT product_id
    FROM products
    WHERE product_name = temp_table.product_name
);

INSERT INTO marketing_format(format_id, product_id, product_format, packaging)
SELECT
    seq_format_id.NEXTVAL,
    product_id,
    product_format,
    packaging
FROM temp_table;
-- 


-- THERE ARE 3940 possibilities of product with different formats and packaging
-- SELECT PRODUCT, FORMAT, coffea, varietal, origin, ROASTING, DECAF, PACKAGING, COUNT(*)
-- FROM fsdb.catalogue
-- GROUP BY PRODUCT, FORMAT, coffea, varietal, origin, ROASTING, DECAF, PACKAGING;

