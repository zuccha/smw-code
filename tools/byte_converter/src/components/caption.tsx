import { useMemo } from "preact/hooks";
import { Length } from "../hooks/use-value";
import { Encoding, Unit } from "../types";
import { digitToHex, range } from "../utils";
import "./caption.css";

export type CaptionProps = {
  unit: Unit;
};

export default function Caption({ unit }: CaptionProps) {
  const digits = useMemo(() => {
    const length = Length[unit][Encoding.Bin];
    return range(length).reverse();
  }, [unit]);

  return (
    <div class="caption">
      {digits.map((digit) => (
        <div class="caption-char">{<span>{digitToHex(digit)}</span>}</div>
      ))}
    </div>
  );
}
