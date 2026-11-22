# Choose the venue with a `venue` setting in `.squiz.json`
Labels: task, P1, harness

## Purpose

Make the venue a `.squiz.json` setting, so a session started without `SQUIZ_VENUE` still reviews where the repository means it to.

## Context

Every squiz process reads the venue from `SQUIZ_VENUE` today. A session started without it records no base and reviews against GitHub. AGENTS.md says a user's choice is a setting in `.squiz.json`.

## Acceptance criteria

- [ ] `.squiz.json` takes `"venue": "github"` or `"local"`
- [ ] With no `venue` set, the venue is `github`
- [ ] Any other value is rejected with an error naming the setting, the value and what was expected, as § 10 Configuration rejects other settings
- [ ] The hook, the round host, `squiz review`, `threads`, `reply` and `status` read the venue from `.squiz.json`
- [ ] Nothing reads `SQUIZ_VENUE`
- [ ] A session started where `.squiz.json` says `local` writes `.squiz/local/base.json` with nothing set in the environment
- [ ] § 4 Choosing the venue describes the setting
- [ ] § 10 Configuration lists the setting
- [ ] No part of the spec names `SQUIZ_VENUE`
- [ ] `npm run typecheck && npm test` pass

## Reference

- § 4 Choosing the venue, § 10 Configuration
- AGENTS.md, Configuration
