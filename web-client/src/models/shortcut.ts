type ShortcutCallback = () => void;

const bindings = new Map<string, ShortcutCallback[]>();

export function initializeGlobalEventListeners() {
  document.addEventListener("keydown", (event) => {
    const ctrl = event.ctrlKey ? "ctrl+" : "";
    const key = `${ctrl}${event.key.toLowerCase()}`;

    if (bindings.has(key)) {
      event.preventDefault();
    }

    bindings.get(key)?.forEach((callback) => callback());
  });
}

export function registerShortcut(key: string, callback: ShortcutCallback) {
  if (bindings.has(key)) {
    bindings.get(key)?.push(callback);
  } else {
    bindings.set(key, [callback]);
  }

  const unregister = () => {
    bindings.get(key)?.splice(bindings.get(key)?.indexOf(callback) ?? -1, 1);
  };

  return unregister;
}
