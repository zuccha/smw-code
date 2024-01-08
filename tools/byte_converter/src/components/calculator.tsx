import { ArrowDownUp } from "lucide-preact";
import { Operation } from "../types";
import { doNothing } from "../utils";
import Button from "./button";
import "./calculator.css";

type CalculatorProps = {
  onAdd: () => void;
  onAnd: () => void;
  onClear: () => void;
  onFinalize: () => void;
  onOr: () => void;
  onSubtract: () => void;
  onSwap: () => void;
  onXor: () => void;
  operation: Operation;
};

export default function ({
  onAdd,
  onAnd,
  onClear,
  onFinalize,
  onOr,
  onSubtract,
  onSwap,
  onXor,
  operation,
}: CalculatorProps) {
  return (
    <div class="calculator">
      <Button
        isSelected={operation === Operation.Add}
        label="+"
        onClick={operation === Operation.Add ? doNothing : onAdd}
      />
      <Button
        isSelected={operation === Operation.Subtract}
        label="-"
        onClick={operation === Operation.Subtract ? doNothing : onSubtract}
      />
      <Button
        isSelected={operation === Operation.And}
        label="&"
        onClick={operation === Operation.And ? doNothing : onAnd}
      />
      <Button
        isSelected={operation === Operation.Or}
        label="|"
        onClick={operation === Operation.Or ? doNothing : onOr}
      />
      <Button
        isSelected={operation === Operation.Xor}
        label="^"
        onClick={operation === Operation.Xor ? doNothing : onXor}
      />
      <Button label="=" onClick={onFinalize} />
      <Button label="C" onClick={onClear} />
      <Button label={<ArrowDownUp />} onClick={onSwap} />
    </div>
  );
}
