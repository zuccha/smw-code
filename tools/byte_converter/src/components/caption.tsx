import { useMemo } from "preact/hooks";
import { Length } from "../hooks/use-value";
import { Encoding, SpaceFrequency, Unit } from "../types";
import { classNames, digitToHex, range } from "../utils";
import "./caption.css";

export type CaptionProps = {
  encoding: Encoding | undefined;
  isSigned: boolean;
  spaceFrequency: SpaceFrequency;
  unit: Unit;
};

export default function Caption({
  encoding,
  isSigned,
  spaceFrequency,
  unit,
}: CaptionProps) {
  const digits = useMemo(() => {
    const length = encoding !== undefined ? Length[unit][encoding] : 0;
    return range(length).reverse();
  }, [encoding, unit]);

  const className = classNames([
    ["caption", true],
    ["space-4", spaceFrequency === SpaceFrequency.Digits4],
    ["space-8", spaceFrequency === SpaceFrequency.Digits8],
  ]);

  return (
    <div class={className}>
      {isSigned && (
        <div class="caption-char">
          <span>±</span>
        </div>
      )}
      {digits.map((digit) => (
        <div class="caption-char">{<span>{digitToHex(digit)}</span>}</div>
      ))}
    </div>
  );
}
