{{ config(
    materialized='incremental',
    pre_hook="CREATE SEQUENCE IF NOT EXISTS hub_cust_serial START WITH 1") }}

SELECT
    nextval('hub_cust_serial') AS seq,
    c_custkey AS businesskey,
    CAST('{{ var("run_date") }}' AS DATE) AS load_date,
    'TPCH' AS record_source
FROM {{ source('raw', 'customer') }}
{% if is_incremental() %}
WHERE c_custkey NOT IN (SELECT businesskey FROM {{ this }})
{% endif %}
