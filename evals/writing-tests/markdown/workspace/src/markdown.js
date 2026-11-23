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
