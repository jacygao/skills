# Give the site's script and stylesheet a new URL for each commit deployed

## Intent

- After #313 deployed, a reload still showed the old layout. Pages serves `app.js` and `styles.css` with `cache-control: max-age=600`, so a browser keeps the previous ones for up to ten minutes.
- Each commit deployed now gives both a new URL, `?v=<short commit>`. A reload re-checks `index.html` itself, so it picks up the new URLs at once.

## What changed

- `.github/workflows/pages.yml`: a step before the upload adds the `?v=` to both URLs in the deployed `index.html` with `sed -E`, and fails the deploy if either URL lacks it. The committed `site/index.html` is unchanged.

## Verification

- Locally, the same `sed -E` on `site/index.html` with `abcdef1` as the commit gives `styles.css?v=abcdef1` and `app.js?v=abcdef1`.
- The workflow runs only on main. After merge, check that the live `index.html` references both files with `?v=` and the merge commit's short id.
