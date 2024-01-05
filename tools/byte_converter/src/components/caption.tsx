import { useMemo } from "preact/hooks";
import { Encoding, Length, Unit } from "../hooks/use-value";
import "./caption.css";

export type CaptionProps = {
  unit: Unit;
};

export default function Caption({ unit }: CaptionProps) {
  const chars = useMemo(() => {
    const length = Length[unit][Encoding.Binary];
    return Array.from(Array(length).keys()).reverse();
  }, [unit]);

  return (
    <div class="caption">
      {chars.map((char) => (
        <div class="caption-char">{<span>{char}</span>}</div>
      ))}
    </div>
  );
}
