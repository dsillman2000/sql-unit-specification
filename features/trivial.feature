Feature: CLI does not fail

    Scenario: sql-unit is executed with no arguments
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  sql-unit is executed with arguments ""
        Then  sql-unit exits with exit code 0
