{% macro create_sequence() %}
    {% set stm %}
        CREATE SEQUENCE IF NOT EXISTS '{{ this.name }}_serial' START WITH 1
    {% endset %}

    {% do run_query(stm) %}
{% endmacro %}
