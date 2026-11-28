---
description: "Changing the content script or the card it injects into pages."
paths:
  - "apps/extension/src/content/**"
---

# The content script

- **Keep the content script under 100KB gzipped.** It runs on every page the
  user visits. Defer what selection detection does not need.
- **Make no `chrome.*` call from the card.** It must be testable in a plain web
  page.
