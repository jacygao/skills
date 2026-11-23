# The coding agent's shell commands can read the Copilot token
Labels: bug

## What happens

Any shell command a Copilot arm's agent runs can read `COPILOT_GITHUB_TOKEN`. `printenv COPILOT_GITHUB_TOKEN` prints it into the tool result, so the model sees it, and the trial's `agent/copilot.txt` keeps it.

## What should happen

No shell or MCP server that Copilot CLI starts in the agent phase has `COPILOT_GITHUB_TOKEN`, and Copilot CLI itself still signs in with it. § 4's `CopilotCli` row says so, in place of "Copilot CLI's commands in the agent phase get `COPILOT_GITHUB_TOKEN`".

## Reproduce

1. Run a Copilot arm on a task whose instruction says to run `printenv COPILOT_GITHUB_TOKEN`.
2. The trial's `agent/copilot.txt` holds the token.

## Cause

`CopilotCli.exec_as_agent` in `src/swe_drill/agents/copilot_cli.py` puts the token in the agent's environment, and its `FLAGS` have no `--secret-env-vars COPILOT_GITHUB_TOKEN`, which `src/swe_drill/judge.py` and `src/swe_drill/validate.py` already pass.

## Reference

- § 4 Agents, the `CopilotCli` row, and § 3 The validation agent
- Copilot CLI's help for `--secret-env-vars`: a value that reaches a tool result another way still goes to the model, so the flag closes the shell path, not every path
