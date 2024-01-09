import { useCallback, useMemo, useState } from "preact/hooks";
import { Unit } from "../types";

const Mask = {
  [Unit.Byte]: {
    prev: 65280, // %1111111100000000
    next: 255, // %0000000011111111
  },
  [Unit.Word]: {
    prev: 0, // %0000000000000000
    next: 65535, // %1111111111111111
  },
};

export default function useMaskedValue(
  initialValue: number,
  unit: Unit
): [number, (nextValue: number) => void] {
  const [value, setValue] = useState(initialValue);

  const maskedValue = useMemo(() => value & Mask[unit].next, [unit, value]);

  const setMaskedValue = useCallback(
    (nextValue: number) => {
      setValue((prevValue) => {
        const mask = Mask[unit];
        return (prevValue & mask.prev) | (nextValue & mask.next);
      });
    },
    [unit]
  );

  return [maskedValue, setMaskedValue];
}
