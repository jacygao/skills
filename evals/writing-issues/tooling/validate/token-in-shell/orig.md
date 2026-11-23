# The coding agent's shell commands can read the Copilot token
Labels: bug

## What happens

`CopilotCli` gives Copilot CLI `COPILOT_GITHUB_TOKEN` in its environment, and every shell command the agent runs inherits it: builds, tests and scripts the agent writes. A command such as `env` or `printenv` prints the token into the tool result. That sends it to the model, and saves it in the trial's `copilot.txt` stream and session history. `CopilotCliSquiz` and `CopilotCliHve` inherit the same behaviour.

The agent phase's network is closed to `api.github.com` and Copilot's host, so a command cannot send the token elsewhere. But a printed token is in the logs that are uploaded to storage, and in what the model saw.

## What should happen

The agent's shells never have the token. Copilot CLI's `--secret-env-vars COPILOT_GITHUB_TOKEN` removes the variable from every shell and MCP server Copilot CLI starts, and masks its value in `--output-format json`, while Copilot CLI itself still signs in with it. SWE-drill's senior judge (`judge.py`) and validation agent (`validate.py`) already pass it.

## Reproduce

1. Run any Copilot arm with an instruction that runs `printenv COPILOT_GITHUB_TOKEN`.
2. The trial's `agent/copilot.txt` holds the token.

## Reference

- `src/swe_drill/agents/copilot_cli.py`, `FLAGS`
- Copilot CLI's help for `--secret-env-vars`: "a value that reaches a tool result another way still goes to the model", so this removes the usual path, not every path
- No local trial file of 30,476 scanned on 2026-11-17 contains the current token
