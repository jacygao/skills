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
