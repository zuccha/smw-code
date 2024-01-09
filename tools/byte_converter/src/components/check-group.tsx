import { replace } from "../utils";
import Button from "./button";
import "./check-group.css";

export type CheckGroupProps = {
  labels: string[];
  onChange: (values: boolean[]) => void;
  values: boolean[];
};

export default function CheckGroup({
  labels,
  onChange,
  values,
}: CheckGroupProps) {
  return (
    <div class="check-group">
      {labels.map((label, i) => {
        const value = values[i];
        if (value === undefined) return null;

        const onClick = () => {
          const nextValues = replace(values, i, !value);
          onChange(nextValues);
        };
        return (
          <Button
            isSelected={value}
            key={label}
            label={label}
            onClick={onClick}
          />
        );
      })}
    </div>
  );
}
