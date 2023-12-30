import { StateUpdater, useEffect, useState } from "preact/hooks";

export default function useSetting<T>(
  id: string,
  initialState: T
): [T, StateUpdater<T>] {
  const [setting, setSetting] = useState((): T => {
    try {
      const stringOrNull = localStorage.getItem(id);
      return stringOrNull === null ? initialState : JSON.parse(stringOrNull);
    } catch {
      localStorage.removeItem(id);
      return initialState;
    }
  });

  useEffect(() => {
    localStorage.setItem(id, JSON.stringify(setting));
  }, [setting]);

  return [setting, setSetting];
}
