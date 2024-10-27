{{ config(
    materialized='incremental',
    unique_key=['seq', 'datum_vanaf']) }}

{{ sat(
    ref('hub_order'),
    source('raw', 'orders'),
    'o_orderkey',
    'TPCH',
    ['o_orderstatus',
     'o_totalprice',
     'o_orderdate',
     'o_orderpriority',
     'o_clerk',
     'o_shippriority',
     'o_comment']
) }}
