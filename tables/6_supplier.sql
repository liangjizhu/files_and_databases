-- CREATE SEQUENCE TO GENERATE format_id automatically
DROP SEQUENCE seq_supplier_barcode_id;

CREATE SEQUENCE seq_supplier_barcode_id
START WITH 30000
INCREMENT BY 1
MAXVALUE 40000
NOCYCLE;

INSERT INTO supplier (supplier_barcode_id, bar_code, cif, supplier_name, full_name, supplier_email, supplier_phone_number, comm_address, supplier_country, supplier_bankacc)
SELECT
    seq_supplier_barcode_id.NEXTVAL,
    c.BARCODE,
    c.PROV_TAXID,
    c.SUPPLIER,
    c.PROV_PERSON,
    c.PROV_EMAIL,
    c.PROV_MOBILE,
    c.PROV_ADDRESS,
    c.PROV_COUNTRY,
    c.PROV_BANKACC
FROM fsdb.catalogue c
JOIN p_reference p ON c.BARCODE = p.bar_code
WHERE c.PROV_TAXID IS NOT NULL 
  AND c.BARCODE IS NOT NULL 
  AND c.SUPPLIER IS NOT NULL 
  AND c.PROV_PERSON IS NOT NULL 
  AND c.PROV_EMAIL IS NOT NULL 
  AND c.PROV_MOBILE IS NOT NULL 
  AND c.PROV_ADDRESS IS NOT NULL 
  AND c.PROV_COUNTRY IS NOT NULL 
  AND c.PROV_BANKACC IS NOT NULL;

select bar_code, cif, supplier_name, full_name, supplier_email, supplier_phone_number, comm_address, supplier_country, supplier_bankacc from supplier;
-- select DISTINCT product_id from p_reference;



-- select distinct PROV_TAXID, BARCODE from fsdb.catalogue;
-- desc fsdb.catalogue;
