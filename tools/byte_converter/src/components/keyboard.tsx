import { ReactNode, useCallback } from "preact/compat";
import { doNothing } from "../utils";
import Button from "./button";
import "./keyboard.css";

export type KeyboardAction =
  | {
      isActive?: boolean;
      colSpan?: number;
      label: ReactNode;
      onClick: () => void;
      size?: "xxs" | "xs" | "s" | "m" | "l";
    }
  | undefined;

type KeyboardProps = {
  actions: KeyboardAction[];
};

export default function Keyboard({ actions }: KeyboardProps) {
  const handleMouseDown = useCallback(
    (e: MouseEvent) => e.preventDefault(),
    []
  );

  return (
    <div class="keyboard" onMouseDown={handleMouseDown}>
      {actions.map((action, i) =>
        action ? (
          <div
            class="keyboard-key"
            style={
              action.colSpan
                ? { gridColumn: `span ${action.colSpan}`, width: "100%" }
                : undefined
            }
          >
            <Button
              isSelected={action.isActive}
              key={i}
              label={<div class={action.size}>{action.label}</div>}
              onClick={action.isActive ? doNothing : action.onClick}
            />
          </div>
        ) : (
          <div key={i} />
        )
      )}
    </div>
  );
}
