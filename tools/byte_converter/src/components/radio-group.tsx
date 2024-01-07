import Button from "./button";
import "./radio-group.css";

export type Option<T> = { label: string; value: T };

export type RadioGroupProps<T> = {
  onChange: (value: T) => void;
  options: Option<T>[];
  value: T;
};

export default function RadioGroup<T>({
  onChange,
  options,
  value,
}: RadioGroupProps<T>) {
  return (
    <div class="radio-group">
      {options.map((option) => {
        const onClick = () => onChange(option.value);

        return (
          <Button
            isSelected={option.value === value}
            label={option.label}
            onClick={onClick}
          />
        );
      })}
    </div>
  );
}
