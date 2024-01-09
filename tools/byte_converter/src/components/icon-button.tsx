import { ReactNode } from "preact/compat";
import Button from "./button";
import "./icon-button.css";

type IconButtonProps = {
  isSelected?: boolean;
  label: ReactNode;
  onClick: () => void;
  tooltip: string;
};

export default function IconButton({
  isSelected = false,
  label,
  onClick,
  tooltip,
}: IconButtonProps) {
  return (
    <div class="icon-button" data-tooltip={tooltip}>
      <Button
        isBorderless
        isSelected={isSelected}
        label={label}
        onClick={onClick}
      />
    </div>
  );
}
