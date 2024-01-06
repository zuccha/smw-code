import { ReactNode, useCallback } from "preact/compat";
import Button from "./button";
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
    ["collapsed", !isVisible],
  ]);

  return (
    <div class={className}>
      <div class="collapsible-button">
        <Button
          label={isVisible ? `Hide ${label}` : `Show ${label}`}
          onClick={toggle}
        />
      </div>

      <div class="collapsible-children">{children}</div>
    </div>
  );
}
