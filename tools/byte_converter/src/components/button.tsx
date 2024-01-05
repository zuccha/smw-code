import { useCallback, useMemo } from "preact/hooks";
import { classNames } from "../utils";
import "./button.css";

type ButtonProps = {
  isSelected?: boolean;
  label: string;
  onClick: () => void;
};

export default function Button({
  isSelected = false,
  label,
  onClick,
}: ButtonProps) {
  const className = useMemo(
    () =>
      classNames([
        ["button-item", true],
        ["button-item-selected", isSelected],
      ]),
    [isSelected]
  );

  const handleKeyPress = useCallback(
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
      onClick={onClick}
      onKeyPress={handleKeyPress}
      tabIndex={0}
    >
      {label}
    </div>
  );
}
