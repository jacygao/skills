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
