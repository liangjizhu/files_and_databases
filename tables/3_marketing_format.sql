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
    format_id NUMBER,
    product_name VARCHAR2(50),
    product_id NUMBER,
    product_format VARCHAR(20) NOT NULL,
    packaging VARCHAR(15)
);


INSERT INTO temp_table (format_id, product_name, product_format, packaging)
SELECT
    seq_format_id.NEXTVAL,
    PRODUCT,
    CASE
        WHEN FORMAT = 'capsules' THEN 'in capsules'
        WHEN FORMAT = 'freeze-dried' THEN 'freeze-dried'
        WHEN FORMAT = 'ground' THEN 'ground'
        WHEN FORMAT = 'prepared' THEN 'prepared'
        WHEN FORMAT = 'roasted bean' THEN 'roasted beans'
        WHEN FORMAT = 'raw bean' THEN 'raw grain'
        ELSE FORMAT
    END,
    PACKAGING
FROM (
    SELECT DISTINCT PRODUCT, FORMAT, PACKAGING
    FROM fsdb.catalogue
    -- filtering the formats from fsdb.catalogue.format
    WHERE PRODUCT IS NOT NULL AND FORMAT IN ('raw bean', 'roasted bean', 'freeze-dried', 'capsules', 'prepared', 'ground') AND PACKAGING IS NOT NULL
);


-- Step 2: Populate the product_id column in fsdb.catalogue
UPDATE temp_table
SET product_id = (
    SELECT product_id
    FROM products
    WHERE product_name = temp_table.product_name
);

INSERT INTO marketing_format(format_id, product_id, product_format, packaging)
SELECT
    format_id,
    product_id,
    product_format,
    packaging
FROM temp_table;
-- 

DROP TABLE temp_table;

-- THERE ARE 3240 possibilities of product with different formats and packaging
-- SELECT PRODUCT, FORMAT, coffea, varietal, origin, ROASTING, DECAF, PACKAGING, COUNT(*)
-- FROM fsdb.catalogue
-- GROUP BY PRODUCT, FORMAT, coffea, varietal, origin, ROASTING, DECAF, PACKAGING;

-- select * from marketing_format;
