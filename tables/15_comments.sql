DROP SEQUENCE seq_comment_id;

CREATE SEQUENCE seq_comment_id
START WITH 1000000
INCREMENT BY 1
MAXVALUE 9999999
NOCYCLE;

DROP TABLE temp_table_comments;

CREATE TABLE temp_table_comments (
    comment_id NUMBER CHECK(comment_id >= 1000000),
    customer_id INT,
    username CHAR(30),
    product CHAR(50),
    barcode CHAR(15),
    post_date CHAR(14),
    post_time CHAR(14),
    title CHAR(50),
    score INT,
    comment_text CHAR(2000),
    likes INT,
    tag CHAR(50)
);

INSERT INTO temp_table_comments(username,
product, barcode, post_date, post_time,title, score, likes, tag)
SELECT DISTINCT
    USERNAME,
    PRODUCT,
    BARCODE,
    POST_DATE,
    POST_TIME,
    TITLE,
    SCORE,
    LIKES,
    ENDORSED
FROM fsdb.posts
WHERE PRODUCT IS NOT NULL AND BARCODE IS NOT NULL;

UPDATE temp_table_comments tt
SET customer_id = (
    SELECT c.customer_id
    FROM customers c
    WHERE c.customer_username = tt.username
    AND ROWNUM = 1 -- Limits to the first result
)
WHERE EXISTS (
    SELECT 1
    FROM customers c
    WHERE c.customer_username = tt.username AND c.customer_username IS NOT NULL);

UPDATE temp_table_comments
SET comment_id = (
    seq_comment_id.NEXTVAL
);

INSERT INTO customer_comments(comment_id, customer_id,
username, product, barcode, post_date, post_time,title,
score, likes, tag)
SELECT
comment_id,
customer_id,
username,
product,
barcode,
post_date,
post_time,
title,
score,
likes,
tag
FROM temp_table_comments;

DROP TABLE temp_table_comments;