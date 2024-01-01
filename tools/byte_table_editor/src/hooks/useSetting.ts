import { StateUpdater, useEffect, useState } from "preact/hooks";
import Storage from "../store/storage";

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
