CREATE SCHEMA IF NOT EXISTS iceberg.sandbox;

CREATE TABLE IF NOT EXISTS iceberg.sandbox.connection_check
AS
SELECT
    CAST(1 AS BIGINT) AS id,
    'lakehouse-ok' AS message;

SELECT * FROM iceberg.sandbox.connection_check;
