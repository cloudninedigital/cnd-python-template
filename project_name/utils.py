from pathlib import Path

DEFAULT_SQL_SCRIPT_LOCATION = Path(__file__).parent / "sql_scripts"


def resolve_sql_script_location(script_name):
    script_path = Path(script_name)

    if not script_path.is_file():
        script_path = DEFAULT_SQL_SCRIPT_LOCATION / script_name

    if not script_path.is_file():
        raise FileNotFoundError(f"Script named {script_name} cannot be found.")

    return script_path
