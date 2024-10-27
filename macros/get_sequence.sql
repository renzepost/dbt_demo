{% macro get_sequence() %}
    nextval('{{ this.name }}_serial')
{% endmacro %}
