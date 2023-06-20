SELECT * FROM customer
WHERE email IN ('56bcd4c6e935a4c@cab516b.cd6', '59bd2e7b334b737@fbf4f51.f77')

-- B-дерево
CREATE INDEX customer__email__btree_idx
ON customer (email);

DROP INDEX IF EXISTS customer__email__btree_idx;

----------------------------------------------------

SELECT * FROM customer_visit
WHERE created_at > (timestamp '2023-01-20 20:00:00' - interval '1 month');

-- B-дерево, частичный
CREATE INDEX customer_visit__created_at__btree_idx
ON customer_visit (created_at)
WHERE created_at > (timestamp '2023-01-20 20:00:00' - interval '1 year');

DROP INDEX IF EXISTS customer_visit__created_at__btree_idx;

----------------------------------------------------

SELECT * FROM customer_visit
WHERE 2 < visit_length AND visit_length < 4;

-- B-дерево, частичный
CREATE INDEX customer_visit__visit_length__btree_idx
ON customer_visit (visit_length)
WHERE visit_length < 10;

DROP INDEX IF EXISTS customer_visit__visit_length__btree_idx;

----------------------------------------------------

SELECT first_name, last_name FROM customer
WHERE phone = '+54671829513';

-- ХЕШ
CREATE INDEX customer__phone__hash_idx
ON customer USING hash (phone);

DROP INDEX IF EXISTS customer__phone__hash_idx;

----------------------------------------------------

SELECT * FROM customer_visit
WHERE geo_tag <@ CIRCLE(POINT(52, 52), 10);

-- GIST
CREATE INDEX customer_visit__geo_tag__gist_idx
ON customer_visit USING gist (geo_tag circle_ops);

DROP INDEX IF EXISTS customer_visit__geo_tag__gist_idx;

----------------------------------------------------

SELECT * FROM customer
WHERE created_at BETWEEN '2011-01-01 00:00:00' AND '2011-02-01 00:00:00';

-- BRIN
CREATE INDEX customer__created_at__brin_idx
ON customer USING brin (created_at);

DROP INDEX IF EXISTS customer__created_at__brin_idx;

----------------------------------------------------

SELECT *
FROM customer_visit
WHERE utm_data @@ '$.error == true'

-- GIN для json
CREATE INDEX customer_visit__utm_data__gist_idx
ON customer_visit USING gin (utm_data jsonb_path_ops);

DROP INDEX IF EXISTS customer_visit__utm_data__gist_idx;
