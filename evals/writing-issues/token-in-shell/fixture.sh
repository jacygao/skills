#!/usr/bin/env bash
# swe-drill's AGENTS.md, cut to what filing an issue needs, and the spec and
# code the issue is about, as they stood when it was filed.
set -euo pipefail
cat > AGENTS.md <<'EOF_FIXTURE'
# Working in this repository

SWE-drill runs coding agents on benchmark tasks through Harbor, grades each
trial, and ranks the arms on a leaderboard.

## Specs

`docs/specs/swe-drill-spec.md` is the specification. This checkout holds only
the sections the current work touches; the omitted sections exist, and
cross-references to them are correct.

## Checks

```bash
uv run pytest
```

## Issues

Each issue carries one label, `bug` or `task`.

**Use the `writing-issues` skill before writing an issue.** Every time,
without being asked.

GitHub is not reachable from this environment, so do not run `gh`. Write the
issue to `issues/new.md` instead: the title on the first line as `# <title>`,
then a line `Labels: <label>, <label>, ...`, a blank line, and the body exactly
as it would be passed to `gh issue create --body`.
EOF_FIXTURE
mkdir -p docs/specs src/swe_drill/agents issues
cat > docs/specs/swe-drill-spec.md <<'EOF_FIXTURE'
# SWE-drill Specification

## 3. Grading

### The senior judge

The judge reads `COPILOT_GITHUB_TOKEN` from the `.env` beside `swe-drill.toml`, and
gives it to each session's command alone. Harbor's environment, `test.sh` and
every argument go without it. Before `test.sh` runs, every file under the
judge's directories in the sandbox that holds the token is deleted, and
`judge.json` has it replaced with `[redacted]`.

### The validation agent

Before `test.sh`, `JudgeVerifier` writes `settings.json`, and a file holding the
token, to `/opt/swe-drill-judge/validation/`, and gives `test.sh` that directory
in `SWE_DRILL_VALIDATION`. The task's own tests run while the file is there. The
validation deletes it as it reads it, before any session, and gives the token
to Copilot CLI's environment alone, with
`--secret-env-vars COPILOT_GITHUB_TOKEN`, so no story script and no command the
agent runs has it. However `test.sh` ends, the directory is removed, and every
file under the judge's directories and `/logs/verifier` that holds the token is
deleted, in the sandbox and in the trial's `verifier/`.

## 4. Agents

An arm names its agent class in `swe-drill.toml` as `module:Class`. A class
names, as class attributes, the hosts its agent phase reaches in
`ALLOWED_HOSTS`; the agent phase's network allows those hosts and no other.

### Agents in this repository

| Agent | Model and kwargs | Hosts | What it does |
|---|---|---|---|
| `swe_drill.agents.copilot_cli:CopilotCli` | a model, required; `version`, required; `reasoning_effort` | `api.github.com`, `api.enterprise.githubcopilot.com` | Harbor's `copilot-cli` agent. Harbor's agent runs `copilot --prompt=<instruction> --yolo --deny-tool web_fetch --deny-tool web_search --model=<model> --effort <reasoning_effort> --output-format=json`. SWE-drill adds `--disable-builtin-mcps`, `--no-auto-update`, `--disable-client-telemetry`, `--no-ask-user` and `--excluded-tools web_fetch web_search`. Copilot CLI's commands in the agent phase get `COPILOT_GITHUB_TOKEN` from `.env` and no other token: never `GH_TOKEN` or `GITHUB_TOKEN`, and none from Harbor's environment. |

Each trial keeps Copilot CLI's output stream in `agent/copilot.txt`, uploaded to
storage with the rest of the trial.
EOF_FIXTURE
cat > src/swe_drill/agents/copilot_cli.py <<'EOF_FIXTURE'
from typing import Any

from swe_drill.agents import Adapter
from swe_drill.copilot import NpmCopilotCli


class CopilotCli(Adapter, NpmCopilotCli):
    """
    Harbor's Copilot CLI agent, with the built-in MCP servers, the web tools,
    auto-update and client telemetry off, and only the arm's own token.

    The token is COPILOT_GITHUB_TOKEN from the .env beside swe-drill.toml, never
    GH_TOKEN or GITHUB_TOKEN, and it reaches only the agent phase's commands.
    """

    ALLOWED_HOSTS = ("api.github.com", "api.enterprise.githubcopilot.com")
    TOKEN = "COPILOT_GITHUB_TOKEN"
    # Every token Copilot CLI or Harbor's agent would take in its place.
    TOKENS = ("COPILOT_GITHUB_TOKEN", "GH_TOKEN", "GITHUB_TOKEN")
    FLAGS = (
        "--disable-builtin-mcps",
        "--no-auto-update",
        "--disable-client-telemetry",
        "--no-ask-user",
        "--excluded-tools",
        "web_fetch",
        "web_search",
    )

    def build_cli_flags(self) -> str:
        return " ".join([super().build_cli_flags(), *self.GLOBAL_FLAGS, *self.FLAGS]).strip()

    async def exec_as_agent(self, environment, command, env=None, cwd=None, timeout_sec=None):
        """Give the command no token but the arm's, and that one only in the agent phase."""
        env = {key: value for key, value in (env or {}).items() if key not in self.TOKENS}
        if self._token is not None:
            env[self.TOKEN] = self._copilot_token
        return await super().exec_as_agent(
            environment, command, env=env or None, cwd=cwd, timeout_sec=timeout_sec
        )
EOF_FIXTURE
cat > src/swe_drill/judge.py <<'EOF_FIXTURE'
# The script each judge session runs in the task's sandbox.
SESSION_SCRIPT = """\
exec "$copilot" "$@" --output-format json --allow-all-tools \\
    --deny-tool shell --deny-tool write \\
    --no-ask-user --no-custom-instructions --no-auto-update \\
    --disable-client-telemetry --disable-builtin-mcps \\
    --secret-env-vars COPILOT_GITHUB_TOKEN \\
    --log-level debug --log-dir "$logs" > "$out"
"""
EOF_FIXTURE
cat > src/swe_drill/validate.py <<'EOF_FIXTURE'
TOKEN_NAME = "COPILOT_GITHUB_TOKEN"

COPILOT_FLAGS = (
    "--no-ask-user", "--no-custom-instructions", "--no-auto-update",
    "--disable-client-telemetry", "--disable-builtin-mcps", "--secret-env-vars", TOKEN_NAME,
)
EOF_FIXTURE
git init -q -b main
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q -m "Initial commit"
