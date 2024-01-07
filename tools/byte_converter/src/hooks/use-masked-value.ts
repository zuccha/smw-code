import { useCallback, useMemo, useState } from "preact/hooks";
import { Unit } from "../types";

const HighByteMask = 65280; // %1111111100000000
const LowByteMask = 255; // %0000000011111111

export default function useMaskedValue(
  initialValue: number,
  unit: Unit
): [number, (nextValue: number) => void] {
  const [value, setValue] = useState(initialValue);

  const maskedValue = useMemo(() => {
    switch (unit) {
      case Unit.Byte:
        return value & LowByteMask;
      case Unit.Word:
        return value;
    }
  }, [unit, value]);

  const setMaskedValue = useCallback(
    (nextValue: number) => {
      setValue((prevValue) => {
        switch (unit) {
          case Unit.Byte:
            return (prevValue & HighByteMask) | (nextValue & LowByteMask);
          case Unit.Word:
            return nextValue;
        }
      });
    },
    [unit]
  );

  return [maskedValue, setMaskedValue];
}
