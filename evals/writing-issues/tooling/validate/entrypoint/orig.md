# 15 atlas-rf tasks never start on Docker: their image's /bin/bash entrypoint swallows Harbor's start command
Labels: bug

## What happens

15 of atlas-rf's 70 task images set `ENTRYPOINT ["/bin/bash"]`. Harbor's Docker environment starts a prebuilt image with `command: ["sh", "-c", "sleep infinity"]` and keeps the image's entrypoint, so the container runs `/bin/bash sh -c "sleep infinity"` and exits 126 before the agent starts.

Keeping the image's entrypoint is the right behaviour for Harbor, since other datasets' images rely on theirs. The fault is in these 15 images, whose entrypoint does not run the command it is given.

Affected, as each image's config in the registry reads: all 12 C and C++ tasks (MariaDB server, Suricata, netdata) and 3 TypeScript tasks (renovate): `task-69b7c2a04b6f8ff9ed98812c`, `812d`, `812e`, `812f`, `8131`, `8134`, `8137`, `813a`, `813b`, `813d`, and `task-69d196f015a150488265afc0` to `afc4`. The other 55 images set no entrypoint, or one that runs its arguments (`docker-entrypoint.sh`, `/entrypoint.sh`), and are left as they are.

## What should happen

Every atlas-rf task starts. The lane's copy of each of the 15 tasks adds an `environment/docker-compose.yaml`, which Harbor merges over its own compose file, so the container runs Harbor's command alone:

```yaml
services:
  main:
    entrypoint: []
```

No other task's copy changes. The override stays until Scale rebuilds those images without the entrypoint.

On Modal, a task with that file runs under Docker in Docker. Whether these 15 start there is unchecked.

## Reproduce

The ten-task batch under `checks/atlas-rf-batch/copilot-gpt-6.1-sol/` in storage: `task-69b7c2a04b6f8ff9ed98812c`, `…8131` (job `batch-ea`) and `…812f` (job `batch-je`) failed with `container …-main-1 exited (126)`.

## Reference

- The batch's other 7 tasks graded cleanly: 6 resolved, 1 failed its tests, every rubric item judged.
- After the fix: rerun those 3 tasks, then the lane is ready for full runs.
