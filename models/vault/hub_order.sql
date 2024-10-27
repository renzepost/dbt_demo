{{ config(
    materialized='incremental',
    pre_hook='{{ create_sequence() }}') }}

{{ hub(get_sequence(), 'o_orderkey', 'TPCH', source("raw", "orders")) }}
