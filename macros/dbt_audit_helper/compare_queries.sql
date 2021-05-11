{% macro sqlserver__compare_queries(a_query, b_query, primary_key=None) %}

with a as (

    {{ a_query }}

),

b as (

    {{ b_query }}

),

a_intersect_b as (

    select * from a
    {{ dbt_utils.intersect() }}
    select * from b

),

a_except_b as (

    select * from a
    {{ dbt_utils.except() }}
    select * from b

),

b_except_a as (

    select * from b
    {{ dbt_utils.except() }}
    select * from a

),

all_records as (

    select
        *,
        1 as in_a,
        1 as in_b
    from a_intersect_b

    union all

    select
        *,
        1 as in_a,
        0 as in_b
    from a_except_b

    union all

    select
        *,
        0 as in_a,
        1 as in_b
    from b_except_a

),

summary_stats as (
    select
        in_a,
        in_b,
        count(*) as count
    from all_records

    group by in_a, in_b
)
-- select * from all_records
-- where not (in_a and in_b)
-- order by {{ primary_key ~ ", " if primary_key is not none }} in_a desc, in_b desc

select
    *,
    round(100.0 * count / sum(count) over (), 2) as percent_of_total

from summary_stats

{% endmacro %}