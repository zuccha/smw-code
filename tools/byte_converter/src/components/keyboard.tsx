import { ReactNode } from "preact/compat";
import { doNothing } from "../utils";
import Button from "./button";
import "./keyboard.css";

type KeyboardProps = {
  actions: {
    isActive?: boolean;
    label: ReactNode;
    onClick: () => void;
  }[];
  className?: string;
};

export default function ({ actions, className = "" }: KeyboardProps) {
  return (
    <div class={`keyboard ${className}`}>
      {actions.map((action) => (
        <Button
          isSelected={action.isActive}
          label={action.label}
          onClick={action.isActive ? doNothing : action.onClick}
        />
      ))}
    </div>
  );
}
