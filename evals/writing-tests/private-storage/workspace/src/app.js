const DEFAULT_SETTINGS = { theme: 'light', fontSize: 16 };

export function createApp({ storage }) {
  const saved = JSON.parse(storage.getItem('settings') ?? 'null');
  let settings = { ...DEFAULT_SETTINGS, ...saved };
  return {
    settings: () => ({ ...settings }),
    updateSettings(changes) {
      settings = { ...settings, ...changes };
      storage.setItem('settings', JSON.stringify(settings));
    },
  };
}
