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

    Scenario: "regional_sales" template with an empty test
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            /* sql-unit

            Feature: Properly aggregates sales table
                Scenario: Sales table is empty
                    Given sales:
                        | region | sale_uid | amount |
                    When  script is run
                    Then result:
                        | region | num_sales | total_sales |

            */
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
            create temporary table feature_cfec__scenario_c9d2__sales (
                region text,
                sale_uid text,
                amount real
            );
            """
        And   sql-unit shall include the text in the output:
            """
            create temporary table feature_cfec__scenario_c9d2__result as
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from temp.feature_cfec__scenario_c9d2__sales
            group by region;
            """

    Scenario: "regional_sales" template with a trivial non-empty test
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            /* sql-unit

            Feature: Properly aggregates sales table
                Scenario: Sales table has trivial entries for "east" and "west" regions
                    Given sales:
                        | region | sale_uid | amount |
                        | east   | sale1    | 10     |
                        | west   | sale2    | 20     |
                    When  script is run
                    Then result:
                        | region | num_sales | total_sales |
                        | east   | 1         | 10          |
                        | west   | 1         | 20          |

            */
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
            create temporary table feature_cfec__scenario_2cf4__sales (
                region text,
                sale_uid text,
                amount real
            );
            """
        And   sql-unit shall include the text in the output:
            """
            insert into temp.feature_cfec__scenario_2cf4__sales (region, sale_uid, amount) values
                ('east', 'sale1', 10),
                ('west', 'sale2', 20);
            """
        And   sql-unit shall include the text in the output:
            """
            create temporary table feature_cfec__scenario_2cf4__result as
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from temp.feature_cfec__scenario_2cf4__sales
            group by region;
            """

    Scenario: "regional_sales" template with both an empty and a non-empty trivial test alongside one another
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            /* sql-unit

            Feature: Properly aggregates sales table

                Scenario: Sales table is empty
                    Given sales:
                        | region | sale_uid | amount |
                    When  script is run
                    Then result:
                        | region | num_sales | total_sales |

                Scenario: Sales table has trivial entries for "east" and "west" regions
                    Given sales:
                        | region | sale_uid | amount |
                        | east   | sale1    | 10     |
                        | west   | sale2    | 20     |
                    When  script is run
                    Then result:
                        | region | num_sales | total_sales |
                        | east   | 1         | 10          |
                        | west   | 1         | 20          |

            */
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
            create temporary table feature_cfec__scenario_c9d2__sales (
                region text,
                sale_uid text,
                amount real
            );
            """
        And   sql-unit shall include the text in the output:
            """
            create temporary table feature_cfec__scenario_c9d2__result as
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from temp.feature_cfec__scenario_c9d2__sales
            group by region;
            """
        And   sql-unit shall include the text in the output:
            """
            create temporary table feature_cfec__scenario_2cf4__sales (
                region text,
                sale_uid text,
                amount real
            );
            """
        And   sql-unit shall include the text in the output:
            """
            insert into temp.feature_cfec__scenario_2cf4__sales (region, sale_uid, amount) values
                ('east', 'sale1', 10),
                ('west', 'sale2', 20);
            """
        And   sql-unit shall include the text in the output:
            """
            create temporary table feature_cfec__scenario_2cf4__result as
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from temp.feature_cfec__scenario_2cf4__sales
            group by region;
            """
