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
