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
    request_amount NUMBER CHECK(request_amount > 0) NOT NULL,
    request_date DATE,
    delivery_date DATE,
    rorder_state VARCHAR(15),
    received_date DATE,
    payment VARCHAR(30) NOT NULL
);

INSERT INTO temp_table (replacement_order_id, bar_code, supplier, request_date, payment)
SELECT
    seq_replacement_order_id.NEXTVAL,
    barcode,
    supplier,
    SYSDATE AS request_date,
    PROV_BANKACC
FROM
    (SELECT DISTINCT c.barcode, c.supplier, c.PROV_BANKACC
     FROM fsdb.catalogue c
     JOIN p_reference s ON c.barcode = s.bar_code
     WHERE c.barcode IS NOT NULL 
       AND c.supplier IS NOT NULL 
       AND c.PROV_BANKACC IS NOT NULL
       AND TO_NUMBER(s.current_stock) < TO_NUMBER(s.min_stock)
    );

-- rorder_state
UPDATE temp_table
SET rorder_state = (
    CASE 
        WHEN SYSDATE > delivery_date THEN 'Placed'
        WHEN received_date > SYSDATE THEN 'fulfilled'
        ELSE 'Draft'
    END
);

UPDATE temp_table tt
SET tt.request_amount = (
    SELECT (TO_NUMBER(pr.max_stock) - TO_NUMBER(pr.current_stock))
    FROM p_reference pr
    WHERE pr.bar_code = tt.bar_code 
        AND TO_NUMBER(pr.current_stock) < TO_NUMBER(pr.min_stock)
);

INSERT INTO replacement_order (replacement_order_id, bar_code, supplier, request_amount, request_date, rorder_state, received_date, payment)
SELECT
    replacement_order_id,
    bar_code,
    supplier,
    request_amount,
    request_date,
    rorder_state,
    received_date,
    payment
FROM TEMP_TABLE;

DROP TABLE temp_table;
