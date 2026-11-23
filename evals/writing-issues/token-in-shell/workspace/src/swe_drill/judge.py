# The script each judge session runs in the task's sandbox.
SESSION_SCRIPT = """\
exec "$copilot" "$@" --output-format json --allow-all-tools \\
    --deny-tool shell --deny-tool write \\
    --no-ask-user --no-custom-instructions --no-auto-update \\
    --disable-client-telemetry --disable-builtin-mcps \\
    --secret-env-vars COPILOT_GITHUB_TOKEN \\
    --log-level debug --log-dir "$logs" > "$out"
"""
