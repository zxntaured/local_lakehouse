CREATE SCHEMA IF NOT EXISTS iceberg.bronze;

SELECT 'customer' AS table_name, count(*) AS row_count
FROM iceberg.bronze.customer
UNION ALL
SELECT 'orders', count(*)
FROM iceberg.bronze.orders
UNION ALL
SELECT 'lineitem', count(*)
FROM iceberg.bronze.lineitem

SELECT
    'customer' AS table_name,
    count_if(
        custkey IS NULL
        OR custkey <= 0
        OR mktsegment IS NULL
        OR trim(mktsegment) = ''
    ) AS invalid_rows
FROM iceberg.bronze.customer
UNION ALL
SELECT
    'orders',
    count_if(
        orderkey IS NULL
        OR orderkey <= 0
        OR custkey IS NULL
        OR custkey <= 0
        OR orderdate IS NULL
        OR shippriority IS NULL
    )
FROM iceberg.bronze.orders
UNION ALL
SELECT
    'lineitem',
    count_if(
        orderkey IS NULL
        OR orderkey <= 0
        OR linenumber IS NULL
        OR linenumber <= 0
        OR extendedprice IS NULL
        OR extendedprice < 0
        OR discount IS NULL
        OR discount < 0
        OR discount > 1
        OR shipdate IS NULL
    )
FROM iceberg.bronze.lineitem

SELECT count(*) AS duplicated_customer_keys
FROM (
    SELECT custkey
    FROM iceberg.bronze.customer
    GROUP BY custkey
    HAVING count(*) > 1
) AS duplicates

SELECT count(*) AS duplicated_order_keys
FROM (
    SELECT orderkey
    FROM iceberg.bronze.orders
    GROUP BY orderkey
    HAVING count(*) > 1
) AS duplicates

SELECT count(*) AS duplicated_lineitem_keys
FROM (
    SELECT orderkey, linenumber
    FROM iceberg.bronze.lineitem
    GROUP BY orderkey, linenumber
    HAVING count(*) > 1
) AS duplicates

SELECT count(*) AS orders_without_customer
FROM iceberg.bronze.orders AS o
LEFT JOIN iceberg.bronze.customer AS c
    ON o.custkey = c.custkey
WHERE c.custkey IS null

SELECT count(*) AS lineitems_without_order
FROM iceberg.bronze.lineitem AS l
LEFT JOIN iceberg.bronze.orders AS o
    ON l.orderkey = o.orderkey
WHERE o.orderkey IS NULL