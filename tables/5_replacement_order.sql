-- CREATE SEQUENCE TO GENERATE format_id automatically
DROP SEQUENCE seq_replacement_order_id;

CREATE SEQUENCE seq_replacement_order_id
START WITH 20000
INCREMENT BY 1
MAXVALUE 30000
NOCYCLE;

DROP TABLE temp_table;

CREATE TABLE temp_table (
    replacement_order_id NUMBER CHECK(replacement_order_id >= 20000) NOT NULL,
    bar_code VARCHAR(15) NOT NULL,
    supplier VARCHAR(35),
    request_amount NUMBER CHECK(request_amount > 0),
    request_date DATE,
    delivery_date DATE,
    rorder_state VARCHAR(15),
    received_date DATE,
    payment VARCHAR(30) NOT NULL
);

INSERT INTO temp_table (replacement_order_id, bar_code, supplier, payment)
SELECT
    seq_replacement_order_id.NEXTVAL,
    barcode,
    supplier,
    PROV_BANKACC
FROM (
    SELECT DISTINCT barcode, supplier, PROV_BANKACC
    FROM fsdb.catalogue
    -- filtering the formats from fsdb.catalogue.format
    WHERE barcode IS NOT NULL AND supplier IS NOT NULL AND PROV_BANKACC IS NOT NULL
);
SELECT * FROM TEMP_TABLE;
DESC fsdb.catalogue;
DESC fsdb.trolley;
DESC fsdb.posts;


select * from fsdb.catalogue;

select distinct barcode from fsdb.catalogue;
select distinct supplier from fsdb.catalogue;
select distinct PROV_BANKACC from fsdb.catalogue;
select distinct  PROV_TAXID from fsdb.catalogue;

select DISTINCT ORDERTIME from fsdb.trolley;
