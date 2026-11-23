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
