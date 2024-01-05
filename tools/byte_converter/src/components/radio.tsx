import Button from "./button";
import "./radio.css";

export type Option<T> = { label: string; value: T };

export type RadioProps<T> = {
  onChange: (value: T) => void;
  options: Option<T>[];
  value: T;
};

export default function Radio<T>({ onChange, options, value }: RadioProps<T>) {
  return (
    <div class="radio">
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
