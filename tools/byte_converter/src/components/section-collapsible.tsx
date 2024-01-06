import { ChevronDown, ChevronUp } from "lucide-preact";
import { ReactNode, useCallback } from "preact/compat";
import { classNames } from "../utils";
import Section from "./section";

export type SectionCollapsibleProps = {
  children: ReactNode;
  label: string;
  isVisible: boolean;
  onChange: (isVisible: boolean) => void;
};

export default function SectionCollapsible({
  children,
  label,
  isVisible,
  onChange,
}: SectionCollapsibleProps) {
  const toggle = useCallback(() => onChange(!isVisible), [isVisible]);

  const className = classNames([
    ["section", true],
    ["collapsible", true],
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
    <Section
      className={className}
      header={
        <div
          class="section-header"
          onKeyDown={handleKeyDown}
          onMouseDown={handleMouseDown}
          tabIndex={0}
        >
          <span>{label}</span>
          {isVisible ? (
            <ChevronUp size="1.5em" />
          ) : (
            <ChevronDown size="1.5em" />
          )}
        </div>
      }
    >
      {children}
    </Section>
  );
}
