Feature: Shall fail to compile sqlite templates that are invalid

    Scenario: "regional_sales" template with no tests and no defaults
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from {{ sales }}
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 1
        And   sql-unit shall include "SQLUnitError: " in the output
        And   sql-unit shall include "sales" in the output

    Scenario: "regional_sales" template with an incomplete test (stops at scenario)
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            /* sql-unit

            Feature: Properly aggregates sales table
                Scenario: Sales table is empty
                    Goodbye.

            */
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from {{ sales }}
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 1
        And   sql-unit shall include "SQLUnitError: " in the output

    Scenario: "regional_sales" template with an incomplete test (stops at given)
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            /* sql-unit

            Feature: Properly aggregates sales table
                Scenario: Sales table is empty
                    Given sales:
                        | region | sale_uid | amount |

            */
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from {{ sales }}
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 1
        And   sql-unit shall include "SQLUnitError: " in the output

    Scenario: "regional_sales" template with an incomplete test (stops at when)
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

            */
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from {{ sales }}
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 1
        And   sql-unit shall include "SQLUnitError: " in the output

    Scenario: "regional_sales" template with an incomplete test (missing when)
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            /* sql-unit

            Feature: Properly aggregates sales table
                Scenario: Sales table is empty
                    Given sales:
                        | region | sale_uid | amount |
                    Then result:
                        | region | num_sales | total_sales |

            */
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from {{ sales }}
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 1
        And   sql-unit shall include "SQLUnitError: " in the output

    Scenario: "regional_sales" template with extra column in given table
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   a file "regional_sales.sql" is present in the project directory with content:
            """
            /* sql-unit

            Feature: Properly aggregates sales table
                Scenario: Sales table is empty
                    Given sales:
                        | region | sale_uid | amount | additional_key |
                    When  script is run
                    Then result:
                        | region | num_sales | total_sales |

            */
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from {{ sales }}
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 1
        And   sql-unit shall include "SQLUnitError: " in the output
        And   sql-unit shall include "additional_key" in the output

    Scenario: "regional_sales" template with extra column in result table
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
                        | region | num_sales | total_sales | additional_key |

            */
            select
                region,
                count(*) as num_sales,
                sum(amount) as total_sales
            from {{ sales }}
            group by region
            """
        And   sql-unit is executed with arguments "compile regional_sales.sql"
        Then  sql-unit exits with exit code 1
        And   sql-unit shall include "SQLUnitError: " in the output
        And   sql-unit shall include "additional_key" in the output
