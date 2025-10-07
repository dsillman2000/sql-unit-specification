install:
	uv sync
	pre-commit install

test-echo:
	SQL_UNIT_CLI="/usr/bin/echo" uv run behave

lint:
	pre-commit run --all-files
