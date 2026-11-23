# Review Harness Specification: A Local Review Loop That Lives on the Pull Request

**Version:** 1.31 (draft)

## 4. The venue

**The venue is where a review happens.** Squiz has two:

| Venue | The change | The record | Used for |
|---|---|---|---|
| **GitHub** | A pull request, at its head commit | Review threads and comments on the pull request | Every review, unless `SQUIZ_VENUE` is `local` |
| **Local** | The working tree, against the commit its work started from | Files in `.squiz/local/` in the worktree | A change with no remote and no pull request |

### Choosing the venue

**Every squiz process chooses its venue from `SQUIZ_VENUE`, the same way.**

| `SQUIZ_VENUE` | The venue |
|---|---|
| Unset, the empty string, or `github` | GitHub |
| `local` | Local |
| Anything else | None. Nothing is reviewed. |

The hook, the round host, `squiz review`, `squiz threads`, `squiz reply` and
`squiz status` each read the variable for themselves. A coding agent's hooks and
shell inherit it from the run, and the round host inherits it from the trigger
that started it, so all of them agree.

A value that names no venue reviews nothing. `squiz review` exits 1 and the hook
says why on stderr:

```
squiz: no review ran: SQUIZ_VENUE is "lcoal", and squiz has the venues github and local
```

The local venue's start hook writes `.squiz/local/base.json`, the commit the
work started from, when a session starts.

## 10. Adoption

### Configuration

`.squiz.json`, at the root of the repository's main worktree, is read from there
whichever worktree is under review. Where the main worktree holds no
`.squiz.json`, every setting takes its default.

| Setting | Default | |
|---|---|---|
| `reviewer` | `pi` | The reviewer CLI, `pi` or `copilot` |
| `rounds` | 3 | The round cap, settable 1 to 8 |
| `timeout` | 900 | Seconds one round's reviewer may run, settable 60 to 3,600 |

A setting outside its range, or of a type the table does not give it, is
rejected with an error naming the setting, the value given and what was
expected. A key the table does not name is rejected the same way.

### The setup check

`squiz doctor` prints a line per dependency and setting it checks, saying it is
present or naming what is missing.
