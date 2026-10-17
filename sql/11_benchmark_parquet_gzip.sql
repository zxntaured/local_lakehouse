EXPLAIN ANALYZE
CREATE TABLE iceberg.sandbox.write_customer
WITH (
    format = 'PARQUET',
    compression_codec = 'GZIP'
)
AS
SELECT custkey, mktsegment
FROM iceberg.bronze.customer

DROP TABLE iceberg.sandbox.write_customer

EXPLAIN ANALYZE
CREATE TABLE iceberg.sandbox.write_orders
WITH (
    format = 'PARQUET',
    compression_codec = 'GZIP'
)
AS
SELECT orderkey, custkey, orderdate, shippriority
FROM iceberg.bronze.orders

DROP TABLE iceberg.sandbox.write_orders

EXPLAIN ANALYZE
CREATE TABLE iceberg.sandbox.write_lineitem
WITH (
    format = 'PARQUET',
    compression_codec = 'GZIP'
)
AS
SELECT orderkey, linenumber, extendedprice, discount, shipdate
FROM iceberg.bronze.lineitem

DROP TABLE iceberg.sandbox.write_lineitem