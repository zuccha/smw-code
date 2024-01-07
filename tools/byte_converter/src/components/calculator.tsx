import Button from "./button";
import "./calculator.css";

type CalculatorProps = {
  onAdd: () => void;
  onAnd: () => void;
  onFinalize: () => void;
  onOr: () => void;
  onSubtract: () => void;
  onXor: () => void;
};

export default function ({
  onAdd,
  onAnd,
  onFinalize,
  onOr,
  onSubtract,
  onXor,
}: CalculatorProps) {
  return (
    <div class="calculator">
      <Button label="+" onClick={onAdd} />
      <Button label="-" onClick={onSubtract} />
      <Button label="&" onClick={onAnd} />
      <Button label="|" onClick={onOr} />
      <Button label="^" onClick={onXor} />
      <Button label="=" onClick={onFinalize} />
    </div>
  );
}
