# Rewrite § 1 Purpose from its requirements

## Intent

- Rewrite § 1 Purpose from its two requirements in the list on #908 (`docs/specs/review-harness-requirements.md` on `spec-requirements-list`), one H2 of the spec's rewrite.

## What changed

- The audience clause ("where a person, or an agent trusted to merge, can see how each finding was settled") is gone. It states who reads the record, not what squiz does, and no requirement carries it.
- The local venue's sentence is cut to a citation of § 4. R4.0.1 states it there, and the list marks § 1's copy (old L12–15) for removal.

## Check both ways

List to spec:

| R-id | Sentence in the new § 1 |
|---|---|
| R1.0.1 | "Whenever a coding agent finishes a piece of work, a reviewer agent reviews it. The reviewer can run a different model from the coding agent, and a different harness." |
| R1.0.2 | "The two agents work through the findings over as many rounds as it takes to settle them. Everything they say to each other is kept as review comments on the pull request, or in the worktree under the local venue (§ 4)." |

Spec to list:

| Sentence | R-id |
|---|---|
| "Squiz automates code review between agents." | Heading sentence, summarising R1.0.1 and R1.0.2 |
| "Whenever a coding agent finishes …" | R1.0.1 |
| "The reviewer can run a different model …" | R1.0.1 |
| "The two agents work through the findings …" | R1.0.2 |
| "Everything they say to each other …" | R1.0.2, with the local-venue clause citing R4.0.1 |

Line counts for § 1, heading to the line before § 2: 12 on `main`, 9 on this branch.

## Notes

- Nothing in `main`'s § 1 disagreed with the list, and the list missed no requirement here.
- The spec's version line is unchanged.
