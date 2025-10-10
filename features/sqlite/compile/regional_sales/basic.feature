Feature: Shall properly compile the "regional_sales" sqlite script variants

    Scenario: "regional_sales" script
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from sales
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 0
        And   sql-unit shall include the text in the output:
            """
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from sales
            group by region
            """

    Scenario: "regional_sales" template with no tests and defaults
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from {{ sales | default("sales") }}
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 0
        And   sql-unit shall include the text in the output:
            """
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from sales
            group by region
            """
