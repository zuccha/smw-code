import { ChevronDown, ChevronUp } from "lucide-preact";
import { ReactNode, useCallback } from "preact/compat";
import { classNames } from "../utils";
import "./collapsible.css";

export type CollapsibleProps = {
  children: ReactNode;
  label: string;
  isVisible: boolean;
  onChange: (isVisible: boolean) => void;
};

export default function Collapsible({
  children,
  label,
  isVisible,
  onChange,
}: CollapsibleProps) {
  const toggle = useCallback(() => onChange(!isVisible), [isVisible]);

  const className = classNames([
    ["collapsible", true],
    ["card", true],
    ["collapsed", !isVisible],
  ]);

  const handleMouseDown = useCallback(
    (e: MouseEvent) => {
      e.preventDefault();
      toggle();
    },
    [toggle]
  );

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        toggle();
      }
    },
    [toggle]
  );

  return (
    <div class={className}>
      <div
        class="collapsible-header"
        onKeyDown={handleKeyDown}
        onMouseDown={handleMouseDown}
        tabIndex={0}
      >
        <span>{label}</span>
        {isVisible ? <ChevronUp /> : <ChevronDown />}
      </div>

      <div class="collapsible-children">{children}</div>
    </div>
  );
}
