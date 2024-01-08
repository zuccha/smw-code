import { useMemo } from "preact/hooks";
import { Length } from "../hooks/use-value";
import { Encoding, SpaceFrequency, Unit } from "../types";
import { classNames, digitToHex, range } from "../utils";
import "./caption.css";

export type CaptionProps = {
  spaceFrequency: SpaceFrequency;
  unit: Unit;
};

export default function Caption({ spaceFrequency, unit }: CaptionProps) {
  const digits = useMemo(() => {
    const length = Length[unit][Encoding.Bin];
    return range(length).reverse();
  }, [unit]);

  const className = classNames([
    ["caption", true],
    ["space-4", spaceFrequency === SpaceFrequency.Digits4],
    ["space-8", spaceFrequency === SpaceFrequency.Digits8],
  ]);

  return (
    <div class={className}>
      {digits.map((digit) => (
        <div class="caption-char">{<span>{digitToHex(digit)}</span>}</div>
      ))}
    </div>
  );
}
