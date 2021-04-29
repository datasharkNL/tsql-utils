# `tsql-utils`

This [dbt](https://github.com/fishtown-analytics/dbt) package contains macros 
that:
- can be (re)used across dbt projects running on Azure databases
- define implementations of [dispatched macros](https://docs.getdbt.com/reference/dbt-jinja-functions/adapter/#dispatch) from other packages that can be used on a database that speaks T-SQL: SQL Server, Azure SQL, Azure Synapse, etc.

## Installation Instructions

To make use of these TSQL adaptations in your dbt project, you must do two things:
1. Install both `dbt-utils` and `tsql-utils` by adding the following to your `packages.yml`
    ```yaml
    packages:
      - package: fishtown-analytics/dbt_utils
        version: 0.6.4.1
      - package: dbt-msft/tsql_utils
        version: 0.6.4.1
    ```
2. Tell `dbt-utils` to also look for the `tsql-utils` macros by adding this section to your `dbt_project.yml`
    ```yaml
    vars:
      dbt_utils_dispatch_list: ['tsql_utils']
    ```
Check [dbt Hub](https://hub.getdbt.com) for the latest installation 
instructions, or [read the docs](https://docs.getdbt.com/docs/package-management) 
for more information on installing packages.

----

## Usage

Wherever a custom tsql macro exists, dbt_utils adapter dispatch will pass to tsq_utils. This means you can just do `{{dbt_utils.hash('mycolumnname')}}` just like your friends with Snowflake. 

## Compatibility

This package provides "shims" for:
- [dbt_utils](https://github.com/fishtown-analytics/dbt-utils) (partial)

## Contributions

### Help out!

There are a number of macros that have yet to be implemented for T-SQL. Check out
- the issues page, or
- [this file](integration_tests/dbt_utils/dbt_project.yml) for an idea of which macros are not currently supported.

### Dev environment set-up

0. clone this repo
1. open terminal in top-level dir of project
2. run the following to install dbt-utils as a submodule
    `git clone --recursive https://github.com/fishtown-analytics/dbt-utils` 
3. open terminal in `integration_tests/dbt_utils`
4. configure your `~/.dbt/profiles.yml` to have an `integration_tests` section with a `sqlserver` target set as the default like `integrations_tests/ci/sample.profiles.yml` does
5. run all the commands listed in the "Run Tests - dbt-utils" step of `.circleci/config.yml` namely:
    ```bash
    dbt deps --target sqlserver
    dbt seed --target sqlserver --full-refresh
    dbt run --target sqlserver --full-refresh
    dbt test --target sqlserver
    ```

### Multi-Adapter Support

t-sql-utils applies for 2 adapters, sqlserver and synapse.

Therefore, for the time being, a macro should be implemented twice, once for the functionality and once as a reference for the second adapter. 

Imagine an adapter plugin, dbt-synapse, that inherits from dbt-sqlserver.
For the time being, we need to explicitly reimplement sqlserver__ macros as synapse__ macros. This looks like: 

```
{% macro synapse__get_tables_by_pattern_sql(field) %}
    {% do return( tsql_utils.sqlserver__get_tables_by_pattern_sql(schema_pattern, table_pattern, exclude='', database=target.database)) %}
{% endmacro %}
```

TODO: We can make a small change to dbt-core (https://github.com/fishtown-analytics/dbt/issues/2923) that will make the inheritance of dispatched macros work just like the inheritance of other adapter objects, and render the following code redundant.
