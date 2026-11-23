import { deadlineIn } from "../reviewers/deadline.ts";
import { updateState } from "./state-update.ts";

function keepCost(episode: Episode, state: EpisodeState, review: Review, measured: Measured): Step<EpisodeState> {
  if (withSpend(state, review, measured) === null) return { step: state };

  const written = updateState(
    episode,
    (current) => withSpend(current, review, measured) ?? current,
    // Its own wait rather than what the reserve has left. A reserve the stop has
    // nearly spent would leave too little to take the lock.
    { until: deadlineIn(STATE_LOCK_WAIT_MS) },
  );
  if (written.outcome === "failed") {
    return {
      ended: {
        outcome: "failed",
        failure: "harness",
        reason: `nothing the reviewer found was posted: ${written.reason}`,
      },
    };
  }
  return { step: written.state };
}

// Another writer holds the state lock for one read and one write. A wait longer
// than this is a holder that has stopped, and waiting on would spend the posting
// reserve.
const STATE_LOCK_WAIT_MS = 2_000;
