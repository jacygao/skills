#!/usr/bin/env bash
# From mono's markdown.test.ts, whose bold and italic cases test the markdown
# library rather than formatMarkdown's own behaviour.
set -euo pipefail
mkdir -p src test
cat > AGENTS.md <<'EOF'
# Working in this repository

The core of a notes app: plain ES modules on Node 24, with one dependency, `tinymark`, vendored in `node_modules`.

## Tests

**Load the `skills:writing-tests` skill before writing or changing any test.**
Every time, without being asked.

Tests use `node:test` and `node:assert/strict`. A module's tests are in
`test/<module>.test.js`. Run them with `node --test`.
EOF
mkdir -p node_modules/tinymark
cat > package.json <<'EOF'
{ "name": "notes-core", "type": "module", "private": true, "scripts": { "test": "node --test" }, "dependencies": { "tinymark": "1.2.0" } }
EOF
cat > node_modules/tinymark/package.json <<'EOF'
{ "name": "tinymark", "version": "1.2.0", "type": "module", "main": "index.js" }
EOF
cat > node_modules/tinymark/index.js <<'EOF'
const escape = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

function inline(s) {
  return escape(s)
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/\*([^*]+)\*/g, '<em>$1</em>')
    .replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, '<a href="$2">$1</a>');
}

export function render(src) {
  return src
    .split(/\n{2,}/)
    .map((block) => {
      const h = block.match(/^(#{1,6})\s+(.*)$/);
      if (h) return `<h${h[1].length}>${inline(h[2])}</h${h[1].length}>`;
      return `<p>${inline(block.replace(/\n/g, ' '))}</p>`;
    })
    .join('\n');
}
EOF
cat > src/markdown.js <<'EOF'
import { render } from 'tinymark';

export function formatMarkdown(text) {
  if (text == null || text === '') return '';
  const linked = text.replace(
    /\[\[([^\]|]+)\|([^\]]+)\]\]/g,
    (_, id, label) => `[${label}](/notes/${encodeURIComponent(id)})`,
  );
  return render(linked).replace(
    /<a href="(https?:[^"]+)">/g,
    '<a href="$1" target="_blank" rel="noopener noreferrer">',
  );
}
EOF
