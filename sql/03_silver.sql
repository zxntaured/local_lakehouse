CREATE SCHEMA IF NOT EXISTS iceberg.silver

CREATE TABLE iceberg.silver.order_lines
WITH (
    format = 'PARQUET'
)
AS
WITH normalized_customer AS (
    SELECT
        custkey,
        upper(trim(mktsegment)) AS mktsegment
    FROM iceberg.bronze.customer
)
SELECT
    o.orderkey,
    l.linenumber,
    c.custkey,
    c.mktsegment,
    o.orderdate,
    o.shippriority,
    l.shipdate,
    l.extendedprice,
    l.discount,
    l.extendedprice * (1 - l.discount) AS line_revenue
FROM normalized_customer AS c
JOIN iceberg.bronze.orders AS o
    ON c.custkey = o.custkey
JOIN iceberg.bronze.lineitem AS l
    ON o.orderkey = l.orderkey
WHERE c.mktsegment = 'BUILDING'
  AND o.orderdate < DATE '1995-03-15'
  AND l.shipdate > DATE '1995-03-15'