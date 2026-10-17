
SELECT
    count(*) AS silver_rows,
    count(DISTINCT orderkey) AS orders_count,
    sum(line_revenue) AS total_revenue
FROM iceberg.silver.order_lines;

SELECT count(*) AS invalid_rows
FROM iceberg.silver.order_lines
WHERE mktsegment IS NULL
   OR mktsegment <> 'BUILDING'
   OR orderdate IS NULL
   OR orderdate >= DATE '1995-03-15'
   OR shipdate IS NULL
   OR shipdate <= DATE '1995-03-15';
   
SELECT *
FROM iceberg.silver.order_lines
ORDER BY orderkey, linenumber
LIMIT 10