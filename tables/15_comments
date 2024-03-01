CREATE TABLE customer_comments(
    comment_id VARCHAR(255) NOT NULL,
    customer_id INT CHECK(customer_id >= 0) NOT NULL,
    username CHAR(30),
    product CHAR(50),
    barcode CHAR(15),
    post_date CHAR(14),
    post_time CHAR(14),
    title CHAR(50),
    score INT CHECK(score > 0),
    comment_text CHAR(2000),
    likes INT DEFAULT 0 CHECK(likes >= 0),
    tag CHAR(50),
    CONSTRAINT pk_customer_comments PRIMARY KEY(comment_id),
    CONSTRAINT fk_customer_comments_customers FOREIGN KEY(customer_id) REFERENCES customer(customer_id),
    CONSTRAINT check_customer_comments_score CHECK(6 >= score)
);

CREATE TABLE temp_table_comments (
    comment_id VARCHAR(255),
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
SELECT
    USERNAME,
    PRODUCT,
    BARCODE,
    POST_DATE,
    POST_TIME,
    TITLE,
    SCORE,
    LIKES,
    ENDORSED
FROM fsdb.posts;


UPDATE temp_table_comments
SET customer_id = (
    SELECT customer_id
    FROM customer
    WHERE username = temp_table_comments.username
);

DROP SEQUENCE seq_comment_id;
CREATE SEQUENCE seq_comment_id
START WITH 10000
INCREMENT BY 1
MAXVALUE 20000
NOCYCLE;

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