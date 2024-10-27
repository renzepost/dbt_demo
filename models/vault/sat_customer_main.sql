{{ config(
    materialized='incremental',
    unique_key=['seq', 'datum_vanaf']) }}

WITH all_data AS (
    SELECT
        hub.seq AS seq,
        CAST('{{ var("run_date") }}' AS DATE) AS datum_vanaf,
        'TPCH' AS record_source,
        md5(ROW(
                src.c_name,
                src.c_address,
                src.c_nationkey,
                src.c_phone,
                src.c_acctbal,
                src.c_mktsegment,
                src.c_comment
                )::TEXT
            ) AS hash_value,
        src.c_name,
        src.c_address,
        src.c_nationkey,
        src.c_phone,
        src.c_acctbal,
        src.c_mktsegment,
        src.c_comment
    FROM {{ source('raw', 'customer') }} src
    INNER JOIN {{ ref('hub_customer') }} hub ON src.c_custkey = hub.businesskey
    {% if is_incremental() %}
    UNION ALL
    SELECT
        seq,
        datum_vanaf,
        record_source,
        hash_value,
        c_name,
        c_address,
        c_nationkey,
        c_phone,
        c_acctbal,
        c_mktsegment,
        c_comment
    FROM {{ this }}
    {% endif %}
)
, compare_hash AS (
    SELECT
        *,
        LAG(hash_value) OVER (PARTITION BY seq ORDER BY datum_vanaf) AS prev_hash_value
    FROM all_data
)

SELECT
    seq,
    datum_vanaf,
    record_source,
    hash_value,
    c_name,
    c_address,
    c_nationkey,
    c_phone,
    c_acctbal,
    c_mktsegment,
    c_comment
FROM compare_hash
WHERE prev_hash_value IS NULL OR hash_value <> prev_hash_value
