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
