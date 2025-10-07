Feature: Shall properly establish a connection to SQLite as a backend

    Scenario: SQLite in-memory database is a valid backend
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///:memory:"
        And   sql-unit is executed with arguments "debug"
        Then  sql-unit exits with exit code 0
        And   sql-unit shall include "Connection successful" in the output

    Scenario: SQLite disk database is a valid backend
        Given sql-unit executable is located at $SQL_UNIT_CLI
        When  a sql-unit project is configured to point to connection URI "sqlite:///sqlite.db"
        And   a sqlite database is created or replaced on disk at "sqlite.db", running the following script:
            """
            SELECT 1
            """
        And   sql-unit is executed with arguments "debug"
        Then  sql-unit exits with exit code 0
        And   sql-unit shall include "Connection successful" in the output
