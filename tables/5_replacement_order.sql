-- CREATE SEQUENCE TO GENERATE format_id automatically
DROP SEQUENCE seq_replacement_order_id;

CREATE SEQUENCE seq_replacement_order_id
START WITH 20000
INCREMENT BY 1
MAXVALUE 30000
NOCYCLE;

DESC fsdb.catalogue;
DESC fsdb.trolley;
DESC fsdb.posts;


select * from fsdb.catalogue;

select distinct barcode from fsdb.catalogue;
select distinct supplier from fsdb.catalogue;
select distinct PROV_BANKACC from fsdb.catalogue;
select distinct  PROV_TAXID from fsdb.catalogue;

select DISTINCT ORDERTIME from fsdb.trolley;
