# Working in this repository

Sowie: a Chrome extension that explains highlighted text in the reader's own
language, from a dictionary sense.

## Rules

- **Before changing code, read the rules in `.claude/rules/` that apply to your
  task.** Claude Code loads them itself. Other agents list them with
  `grep -H '^description' .claude/rules/*.md`.

## Checks

```bash
npm test && npm run typecheck
```

## Silent failures

- **A proxy that buffers the SSE response looks like it works.** Confirm the
  `card` event reaches the client before the model completes.

## Pitfalls

Look fine locally, break on real sites.

- **Tokens go on `:host`, not `:root`.** A host page defining `--card` would
  leak straight in.
- **Fonts ship as extension resources, never a CDN.** MV3 CSP blocks remote
  fonts on many hosts.

## Running agents here

- **Never merge.** The owner merges.
- **Say what you couldn't verify,** in your report or the pull request.
