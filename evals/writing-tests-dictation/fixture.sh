#!/usr/bin/env bash
# From mono's useSpeechToText.test.ts, which mocks our own ./index rather than
# the browser's SpeechRecognition, as ChatInput.dictation.test.jsx does.
set -euo pipefail
mkdir -p src test
cat > AGENTS.md <<'EOF'
# Working in this repository

The core of a notes app: plain ES modules on Node 24, with no dependencies.

## Tests

**Load the `skills:writing-tests` skill before writing or changing any test.**
Every time, without being asked.

Tests use `node:test` and `node:assert/strict`. A module's tests are in
`test/<module>.test.js`. Run them with `node --test`.
EOF
cat > package.json <<'EOF'
{ "name": "notes-core", "type": "module", "private": true, "scripts": { "test": "node --test" } }
EOF
cat > src/speech.js <<'EOF'
export function createRecognizer({ lang, onResult, onEnd = () => {} }) {
  const Recognition = globalThis.SpeechRecognition ?? globalThis.webkitSpeechRecognition;
  if (!Recognition) throw new Error('speech recognition is not available');
  const recognition = new Recognition();
  recognition.lang = lang;
  recognition.continuous = true;
  recognition.interimResults = false;
  recognition.onresult = (event) => {
    for (let i = event.resultIndex; i < event.results.length; i++) {
      if (event.results[i].isFinal) onResult(event.results[i][0].transcript);
    }
  };
  recognition.onend = () => onEnd();
  return { start: () => recognition.start(), stop: () => recognition.stop() };
}
EOF
cat > src/dictation.js <<'EOF'
import { createRecognizer as browserRecognizer } from './speech.js';

export function startDictation({ lang = 'en-US', onText, createRecognizer = browserRecognizer }) {
  const parts = [];
  const recognizer = createRecognizer({
    lang,
    onResult(text) {
      parts.push(text.trim());
      onText(parts.join(' '));
    },
  });
  recognizer.start();
  return {
    stop() {
      recognizer.stop();
    },
  };
}
EOF
cat > test/dictation.test.js <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { startDictation } from '../src/dictation.js';

test('joins the final results into one text', () => {
  let onResult;
  const texts = [];
  startDictation({
    onText: (text) => texts.push(text),
    createRecognizer: (options) => {
      onResult = options.onResult;
      return { start() {}, stop() {} };
    },
  });
  onResult('buy milk');
  onResult(' and eggs');
  assert.equal(texts.at(-1), 'buy milk and eggs');
});
EOF
