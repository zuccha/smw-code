import { ReactNode } from "preact/compat";
import { useCallback, useMemo } from "preact/hooks";
import { classNames } from "../utils";
import "./button.css";

type ButtonProps = {
  isRound?: boolean;
  isSelected?: boolean;
  label: ReactNode;
  onClick: () => void;
};

export default function Button({
  isRound = false,
  isSelected = false,
  label,
  onClick,
}: ButtonProps) {
  const className = useMemo(
    () =>
      classNames([
        ["button", true],
        ["selected", isSelected],
        ["round", isRound],
      ]),
    [isRound, isSelected]
  );

  const handleMouseDown = useCallback(
    (e: MouseEvent) => {
      e.preventDefault();
      onClick();
    },
    [onClick]
  );

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        onClick();
      }
    },
    [onClick]
  );

  return (
    <div
      class={className}
      onMouseDown={handleMouseDown}
      onKeyDown={handleKeyDown}
      tabIndex={0}
    >
      {label}
    </div>
  );
}
