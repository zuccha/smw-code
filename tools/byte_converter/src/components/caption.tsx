import { useMemo } from "preact/hooks";
import { Length } from "../hooks/use-value";
import { Encoding, Unit } from "../types";
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
