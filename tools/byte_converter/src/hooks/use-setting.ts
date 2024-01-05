import { StateUpdater, useEffect, useState } from "preact/hooks";

const Storage = {
  load: <T>(id: string, defaultValue: T): T => {
    try {
      const stringOrNull = localStorage.getItem(id);
      return stringOrNull === null ? defaultValue : JSON.parse(stringOrNull);
    } catch {
      localStorage.removeItem(id);
      return defaultValue;
    }
  },

  save: <T>(id: string, value: T): void => {
    localStorage.setItem(id, JSON.stringify(value));
  },
};

export default function useSetting<T>(
  id: string,
  initialState: T
): [T, StateUpdater<T>] {
  const [setting, setSetting] = useState(() => Storage.load(id, initialState));

  useEffect(() => {
    Storage.save(id, setting);
  }, [setting]);

  return [setting, setSetting];
}
