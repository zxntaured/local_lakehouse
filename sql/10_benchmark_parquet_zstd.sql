CREATE SCHEMA IF NOT EXISTS iceberg.bench_orc_zstd

EXPLAIN ANALYZE
CREATE TABLE iceberg.bench_orc_zstd.customer
WITH (
    format = 'ORC',
    compression_codec = 'ZSTD'
)
AS
SELECT custkey, mktsegment
FROM iceberg.bronze.customer

EXPLAIN ANALYZE
CREATE TABLE iceberg.bench_orc_zstd.orders
WITH (
    format = 'ORC',
    compression_codec = 'ZSTD'
)
AS
SELECT orderkey, custkey, orderdate, shippriority
FROM iceberg.bronze.orders


EXPLAIN ANALYZE
CREATE TABLE iceberg.bench_orc_zstd.lineitem
WITH (
    format = 'ORC',
    compression_codec = 'ZSTD'
)
AS
SELECT orderkey, linenumber, extendedprice, discount, shipdate
FROM iceberg.bronze.lineitem

SELECT
    sum(record_count) AS total_rows,
    sum(file_size_in_bytes) AS size_bytes,
    round(sum(file_size_in_bytes) / 1000000.0, 3) AS size_mb
FROM (
    SELECT record_count, file_size_in_bytes
    FROM iceberg.bench_orc_zstd."customer$files"
    WHERE content = 0

    UNION ALL

    SELECT record_count, file_size_in_bytes
    FROM iceberg.bench_orc_zstd."orders$files"
    WHERE content = 0

    UNION ALL

    SELECT record_count, file_size_in_bytes
    FROM iceberg.bench_orc_zstd."lineitem$files"
    WHERE content = 0
) AS files

EXPLAIN ANALYZE
SELECT
    l.orderkey,
    sum(l.extendedprice * (1 - l.discount)) AS revenue,
    o.orderdate,
    o.shippriority
FROM iceberg.bench_orc_zstd.customer AS c
JOIN iceberg.bench_orc_zstd.orders AS o
    ON c.custkey = o.custkey
JOIN iceberg.bench_orc_zstd.lineitem AS l
    ON l.orderkey = o.orderkey
WHERE c.mktsegment = 'BUILDING'
  AND o.orderdate < DATE '1995-03-15'
  AND l.shipdate > DATE '1995-03-15'
GROUP BY l.orderkey, o.orderdate, o.shippriority
ORDER BY revenue DESC
LIMIT 10