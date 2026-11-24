# Give the site's script and stylesheet a new URL on each deploy

## Intent

After #313 deployed, the user still saw the old layout. Pages serves `app.js` and `styles.css` with `cache-control: max-age=600`, so a browser kept running the previous script for up to ten minutes. Now the deploy adds `?v=<short commit>` to both URLs in `index.html`. A reload always re-checks the page itself, so it picks up the new URLs at once and fetches the new files.

## What changed

- `.github/workflows/pages.yml`: a step before the upload rewrites `index.html` with `sed -E`, then fails the deploy if either URL lacks its `?v=`. The repository's `index.html` is unchanged.

## Verification

- Running the same `sed -E` on `site/index.html` locally, with a sample commit id, gives `styles.css?v=abcdef1` and `app.js?v=abcdef1`.
- After merge: the live `index.html` should reference both files with `?v=` and the merge commit.
