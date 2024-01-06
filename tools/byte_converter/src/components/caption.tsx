import { useMemo } from "preact/hooks";
import { Length } from "../hooks/use-value";
import { Encoding, Unit } from "../types";
import "./caption.css";

export type CaptionProps = {
  unit: Unit;
};

const Chars: Record<number, string> = {
  0: "0",
  1: "1",
  2: "2",
  3: "3",
  4: "4",
  5: "5",
  6: "6",
  7: "7",
  8: "8",
  9: "9",
  10: "A",
  11: "B",
  12: "C",
  13: "D",
  14: "E",
  15: "F",
};

export default function Caption({ unit }: CaptionProps) {
  const digits = useMemo(() => {
    const length = Length[unit][Encoding.Binary];
    return Array.from(Array(length).keys()).reverse();
  }, [unit]);

  return (
    <div class="caption">
      {digits.map((digit) => (
        <div class="caption-char">{<span>{Chars[digit] ?? "0"}</span>}</div>
      ))}
    </div>
  );
}
