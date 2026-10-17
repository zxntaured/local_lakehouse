SELECT
    orderkey,
    revenue,
    orderdate,
    shippriority
FROM iceberg.gold.shipping_priority
ORDER BY revenue DESC, orderkey;

SELECT count(*) AS gold_rows
FROM iceberg.gold.shipping_priority;

WITH expected AS (
    SELECT
        l.orderkey,
        sum(l.extendedprice * (1 - l.discount)) AS revenue,
        o.orderdate,
        o.shippriority
    FROM tpch.sf1.customer AS c
    JOIN tpch.sf1.orders AS o
        ON c.custkey = o.custkey
    JOIN tpch.sf1.lineitem AS l
        ON l.orderkey = o.orderkey
    WHERE c.mktsegment = 'BUILDING'
      AND o.orderdate < DATE '1995-03-15'
      AND l.shipdate > DATE '1995-03-15'
    GROUP BY
        l.orderkey,
        o.orderdate,
        o.shippriority
    ORDER BY revenue DESC
    LIMIT 10
)
SELECT
    coalesce(e.orderkey, g.orderkey) AS orderkey,
    e.revenue AS expected_revenue,
    g.revenue AS gold_revenue,
    abs(e.revenue - g.revenue) AS revenue_difference
FROM expected AS e
FULL OUTER JOIN iceberg.gold.shipping_priority AS g
    ON e.orderkey = g.orderkey
WHERE e.orderkey IS NULL
   OR g.orderkey IS NULL
   OR e.orderdate IS DISTINCT FROM g.orderdate
   OR e.shippriority IS DISTINCT FROM g.shippriority
   OR e.revenue IS NULL
   OR g.revenue IS NULL
   OR abs(e.revenue - g.revenue) > 0.000001