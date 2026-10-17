CREATE SCHEMA IF NOT EXISTS iceberg.bench_parquet_gzip

EXPLAIN ANALYZE
CREATE TABLE iceberg.bench_parquet_gzip.customer
WITH (
    format = 'PARQUET',
    compression_codec = 'GZIP'
)
AS
SELECT custkey, mktsegment
FROM iceberg.bronze.customer

EXPLAIN ANALYZE
CREATE TABLE iceberg.bench_parquet_gzip.orders
WITH (
    format = 'PARQUET',
    compression_codec = 'GZIP'
)
AS
SELECT orderkey, custkey, orderdate, shippriority
FROM iceberg.bronze.orders

EXPLAIN ANALYZE
CREATE TABLE iceberg.bench_parquet_gzip.lineitem
WITH (
    format = 'PARQUET',
    compression_codec = 'GZIP'
)
AS
SELECT orderkey, linenumber, extendedprice, discount, shipdate
FROM iceberg.bronze.lineitem

SELECT 'customer' AS table_name, count(*) AS row_count
FROM iceberg.bench_parquet_gzip.customer
UNION ALL
SELECT 'orders', count(*)
FROM iceberg.bench_parquet_gzip.orders
UNION ALL
SELECT 'lineitem', count(*)
FROM iceberg.bench_parquet_gzip.lineitem

SELECT
    sum(file_size_in_bytes) AS size_bytes,
    round(sum(file_size_in_bytes) / 1000000.0, 3) AS size_mb
FROM (
    SELECT file_size_in_bytes
    FROM iceberg.bench_parquet_gzip."customer$files"
    WHERE content = 0

    UNION ALL

    SELECT file_size_in_bytes
    FROM iceberg.bench_parquet_gzip."orders$files"
    WHERE content = 0

    UNION ALL

    SELECT file_size_in_bytes
    FROM iceberg.bench_parquet_gzip."lineitem$files"
    WHERE content = 0
) AS files

EXPLAIN ANALYZE
SELECT
    l.orderkey,
    sum(l.extendedprice * (1 - l.discount)) AS revenue,
    o.orderdate,
    o.shippriority
FROM iceberg.bench_parquet_gzip.customer AS c
JOIN iceberg.bench_parquet_gzip.orders AS o
    ON c.custkey = o.custkey
JOIN iceberg.bench_parquet_gzip.lineitem AS l
    ON l.orderkey = o.orderkey
WHERE c.mktsegment = 'BUILDING'
  AND o.orderdate < DATE '1995-03-15'
  AND l.shipdate > DATE '1995-03-15'
GROUP BY l.orderkey, o.orderdate, o.shippriority
ORDER BY revenue DESC
LIMIT 10