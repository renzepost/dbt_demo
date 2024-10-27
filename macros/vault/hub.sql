{% macro hub(src_pk, businesskey, src_source, src_model) %}
SELECT
    {{ src_pk }} AS seq,
    {{ businesskey }} AS businesskey,
    CAST('{{ var("run_date") }}' AS DATE) AS load_date,
    '{{ src_source }}' AS record_source
FROM {{ src_model }}
{% if is_incremental() %}
WHERE {{ businesskey }} NOT IN (SELECT businesskey FROM {{ this }})
{% endif %}
{% endmacro %}
