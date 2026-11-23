import { join, relative } from "node:path";

export async function awaitReview(context: ReviewContext, key: string, episode: Episode): Promise<number> {
  for (;;) {
    const state = readState(episode.directory);
    if (closedFor(state, key)) return print(closed(context, state));
    // A host that may not have started is waited on once a live one holds the
    // lock, and reported once its time to take the lock has passed.
    const window = Math.min(startBy.remaining(), until.remaining());
    if (startUnknown !== undefined && hostRunning(episode.directory, stillRunning, window)) {
      startUnknown = undefined;
    }
    if (startUnknown !== undefined && (startBy.passed() || until.passed())) {
      return print({
        outcome: "not run",
        key,
        reason: `whether the round host for ${context.name} started could not be told, and none has taken the review since: ${startUnknown}`,
        problems: [`\`squiz status ${key}\` shows whether one takes it later, and ${relative(episode.worktree, join(episode.directory, "host.log"))} holds what the host wrote`],
      });
    }
    if (until.passed()) return print(stillReviewing(context, state.records ?? []));
    await sleep(Math.max(1, Math.min(pollMs, until.remaining())));
  }
}
