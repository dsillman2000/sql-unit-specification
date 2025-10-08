# ruff: noqa: F811
from behave import given, when, then
import os
import subprocess
import shlex
from pathlib import Path
import tempfile


@when("a file {string} is present in the project directory with content:")
def step_impl(context, **kw):
    assert hasattr(context, "project_dir"), (
        "Must have project configured before creating file.\n%s" % context.__dict__
    )

    file_path = context.project_dir / kw.get("string").strip('"')
    file_path.parent.mkdir(parents=True, exist_ok=True)
    file_path.touch()
    file_path.write_text(context.text)


@given("sql-unit executable is located at $SQL_UNIT_CLI")
def step_impl(context):
    sql_unit_cli_path = os.environ["SQL_UNIT_CLI"]
    assert os.path.exists(sql_unit_cli_path), (
        "Could not find executable at $SQL_UNIT_CLI = " + sql_unit_cli_path
    )

    context.sql_unit_cli = sql_unit_cli_path


@when("sql-unit is executed with arguments {string}")
def step_impl(context, **kw):
    args = shlex.split(kw.get("string").strip('"'))

    result = subprocess.run([context.sql_unit_cli] + args, capture_output=True, text=True)

    context.sql_unit_result = result


@when("a sql-unit project is configured to point to connection URI {string}")
def step_impl(context, **kw):
    with tempfile.TemporaryDirectory() as tmpdir:
        project_dir = Path(tmpdir)
        connection_uri = kw.get("string").strip('"')

        context.project_dir = project_dir
        config_path = project_dir / ".sql-unit.yaml"
        config_path.write_text('connection:\n  uri: "%s"\n' % connection_uri)
        context.config_path = config_path


@then("sql-unit exits with exit code {int}")
def step_impl(context, **kw):
    assert hasattr(context, "sql_unit_result"), "No SQLUnit execution was performed."
    assert context.sql_unit_result.returncode == int(kw.get("int")), "Return code was %d" % (
        context.sql_unit_result.returncode
    )


@then("sql-unit shall include {string} in the output")
def step_impl(context, **kw):
    assert hasattr(context, "sql_unit_result"), "No SQLUnit execution was performed."
    assert kw.get("string").strip('"') in context.sql_unit_result.stdout, (
        "Output did not contain %s\nOutput:\n%s"
        % (kw.get("string").strip('"'), context.sql_unit_result.stdout)
    )


@then("sql-unit shall include the text in the output:")
def step_impl(context, **kw):
    assert hasattr(context, "sql_unit_result"), "No SQLUnit execution was performed."
    assert context.text in context.sql_unit_result.stdout, (
        "Output did not contain %s\nOutput:\n%s" % (context.text, context.sql_unit_result.stdout)
    )


## Steps specific to `sqlite`


@when("a sqlite database is created or replaced on disk at {string}, running the following script:")
def step_impl(context, **kw):
    assert hasattr(context, "project_dir"), (
        "Must have project configured before creating sqlite db.\n%s" % context.__dict__
    )

    import sqlite3

    db_path = context.project_dir / kw.get("string")
    sql_script = context.text

    db_path.parent.mkdir(parents=True, exist_ok=True)
    if db_path.exists():
        db_path.unlink()

    conn = sqlite3.connect(str(db_path))
    cursor = conn.cursor()
    cursor.executescript(sql_script)
    conn.commit()
    conn.close()
