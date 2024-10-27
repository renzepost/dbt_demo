{% macro sat(hub_model, source_model, businesskey, src_source, attributes) %}
WITH all_data AS (
    SELECT
        hub.seq AS seq,
        CAST('{{ var("run_date") }}' AS DATE) AS datum_vanaf,
        '{{ src_source }}' AS record_source,
        md5(ROW(
            {% for attribute in attributes %}
            src.{{ attribute }}{% if not loop.last %},{% endif %}
            {% endfor %}
        )::TEXT) AS hash_value,
        {% for attribute in attributes %}
        src.{{ attribute }}{% if not loop.last %},{% endif %}
        {% endfor %}
    FROM {{ source_model }} src
    INNER JOIN {{ hub_model }} hub ON src.{{ businesskey }} = hub.businesskey
    {% if is_incremental() %}
    UNION ALL
    SELECT
        seq,
        datum_vanaf,
        record_source,
        hash_value,
        {% for attribute in attributes %}
        {{ attribute }}{% if not loop.last %},{% endif %}
        {% endfor %}
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
    {% for attribute in attributes %}
    {{ attribute }}{% if not loop.last %},{% endif %}
    {% endfor %}
FROM compare_hash
WHERE prev_hash_value IS NULL OR hash_value <> prev_hash_value
{% endmacro %}
