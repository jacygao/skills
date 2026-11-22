# 15 atlas-rf tasks never start on Docker
Labels: bug

## What happens

15 of the 70 atlas-rf tasks never start on Docker. Their container exits 126 before the agent runs.

## What should happen

All 70 atlas-rf tasks start on Docker. Each of the 15 tasks' copies adds an `environment/docker-compose.yaml` that clears the image's entrypoint, so the container runs Harbor's command alone. No other task's copy changes, and § 5 `atlas-rf` adds the file to the changes a copy makes:

```yaml
services:
  main:
    entrypoint: []
```

## Evidence

In the ten-task batch under `checks/atlas-rf-batch/copilot-gpt-6.1-sol/` in storage, `task-69b7c2a04b6f8ff9ed98812c`, `…8131` (job `batch-ea`) and `…812f` (job `batch-je`) failed with `container …-main-1 exited (126)`.

## Cause

- The 15 images set `ENTRYPOINT ["/bin/bash"]`: all 12 C and C++ tasks and 3 TypeScript ones, `task-69b7c2a04b6f8ff9ed98812c`, `812d`, `812e`, `812f`, `8131`, `8134`, `8137`, `813a`, `813b`, `813d`, and `task-69d196f015a150488265afc0` to `afc4`.
- Harbor's Docker environment starts a prebuilt image with `sh -c "sleep infinity"` and keeps its entrypoint, so the container runs `/bin/bash sh -c "sleep infinity"`. Keeping it is right for Harbor, since other datasets' images rely on theirs.
- Whether the 15 start on Modal with the file, where a task with one runs under Docker in Docker, is not checked.

## Reference

- § 5 Lanes, `atlas-rf`, and § 5 Sandboxes
