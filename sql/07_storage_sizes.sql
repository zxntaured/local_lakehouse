WITH files AS (
    SELECT
        'bronze.customer' AS table_name,
        content,
        file_format,
        record_count,
        file_size_in_bytes
    FROM iceberg.bronze."customer$files"

    UNION ALL
    SELECT
        'bronze.orders',
        content, file_format, record_count, file_size_in_bytes
    FROM iceberg.bronze."orders$files"

    UNION ALL
    SELECT
        'bronze.lineitem',
        content, file_format, record_count, file_size_in_bytes
    FROM iceberg.bronze."lineitem$files"

    UNION ALL
    SELECT
        'silver.order_lines',
        content, file_format, record_count, file_size_in_bytes
    FROM iceberg.silver."order_lines$files"

    UNION ALL
    SELECT
        'gold.shipping_priority',
        content, file_format, record_count, file_size_in_bytes
    FROM iceberg.gold."shipping_priority$files"
)
SELECT
    table_name,
    file_format,
    count(*) AS data_files,
    sum(record_count) AS row_count,
    sum(file_size_in_bytes) AS size_bytes,
    round(
        CAST(sum(file_size_in_bytes) AS DOUBLE) / 1000000,
        3
    ) AS size_mb
FROM files
WHERE content = 0
GROUP BY table_name, file_format
ORDER BY table_name