import { useCallback, useEffect, useMemo, useState } from "preact/hooks";
import { z } from "zod";
import Caption from "../components/caption";
import Radio, { Option } from "../components/radio";
import SectionCollapsible from "../components/section-collapsible";
import SectionStatic from "../components/section-static";
import useSetting from "../hooks/use-setting";
import { Boundaries } from "../hooks/use-value";
import {
  Caret,
  CaretSchema,
  Encoding,
  Operation,
  TypingDirection,
  TypingDirectionSchema,
  TypingMode,
  TypingModeSchema,
  Unit,
  UnitSchema,
} from "../types";
import AppEditors from "./app-editors";
import AppInstructions from "./app-instructions";
import AppSetting from "./app-setting";
import "./app.css";
import { doNothing } from "../utils";
import Calculator from "../components/calculator";

//==============================================================================
// Radio Options
//==============================================================================

const binaryOptions: Option<boolean>[] = [
  { label: "On", value: true },
  { label: "Off", value: false },
] as const;

const caretOptions: Option<Caret>[] = [
  { label: "Bar", value: Caret.Bar },
  { label: "Box", value: Caret.Box },
  { label: "Underline", value: Caret.Underline },
] as const;

const typingDirectionOptions: Option<TypingDirection>[] = [
  { label: "Left", value: TypingDirection.Left },
  { label: "Right", value: TypingDirection.Right },
] as const;

const typingModeOptions: Option<TypingMode>[] = [
  { label: "Insert", value: TypingMode.Insert },
  { label: "Overwrite", value: TypingMode.Overwrite },
] as const;

const unitOptions: Option<Unit>[] = [
  { label: "Byte", value: Unit.Byte },
  { label: "Word", value: Unit.Word },
] as const;

const OperationLabel = {
  [Operation.And]: "&",
  [Operation.Add]: "+",
  [Operation.Or]: "|",
  [Operation.Subtract]: "-",
  [Operation.Xor]: "^",
};

//==============================================================================
// App
//==============================================================================

export function App() {
  //----------------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------------

  const [operand1, setOperand1] = useState(0);
  const [operand2, setOperand2] = useState(0);
  const [operation, setOperation] = useState(Operation.And);

  const result = useMemo(() => {
    switch (operation) {
      case Operation.Add:
        return (operand1 + operand2) % (Boundaries[Encoding.Decimal].max + 1);
      case Operation.And:
        return operand1 & operand2;
      case Operation.Or:
        return operand1 | operand2;
      case Operation.Subtract:
        return operand1 - operand2;
      case Operation.Xor:
        return operand1 ^ operand2;
    }
  }, [operand1, operation, operand2]);

  const clearInteger = useCallback(() => setOperand1(0), []);
  const clearPartial = useCallback(() => setOperand2(0), []);

  const apply = useCallback(
    (nextOperation: Operation) => {
      setOperation(nextOperation);
      setOperand2(operand1);
    },
    [operand1]
  );

  const add = useCallback(() => apply(Operation.Add), [apply]);
  const subtract = useCallback(() => apply(Operation.Subtract), [apply]);
  const and = useCallback(() => apply(Operation.And), [apply]);
  const or = useCallback(() => apply(Operation.Or), [apply]);
  const xor = useCallback(() => apply(Operation.Xor), [apply]);
  const finalize = useCallback(() => setOperand2(result), [result]);

  //----------------------------------------------------------------------------
  // Settings
  //----------------------------------------------------------------------------

  const [caret, setCaret] = useSetting("caret", Caret.Box, CaretSchema.parse);

  const [flipBitEnabled, setFlipBitEnabled] = useSetting(
    "flip-bit-enabled",
    false,
    z.boolean().parse
  );

  const [hotkeysEnabled, setHotkeysEnabled] = useSetting(
    "hotkeys-enabled",
    false,
    z.boolean().parse
  );

  const [instructionsVisible, setInstructionsVisible] = useSetting(
    "instructions-visible",
    false,
    z.boolean().parse
  );

  const [moveAfterTypingEnabled, setMoveAfterTypingEnabled] = useSetting(
    "move-after-typing-enabled",
    true,
    z.boolean().parse
  );

  const [settingsVisible, setSettingsVisible] = useSetting(
    "settings-visible",
    false,
    z.boolean().parse
  );

  const [typingDirection, setTypingDirection] = useSetting(
    "typing-direction",
    TypingDirection.Right,
    TypingDirectionSchema.parse
  );

  const [typingMode, setTypingMode] = useSetting(
    "typing-mode",
    TypingMode.Overwrite,
    TypingModeSchema.parse
  );

  const [unit, setUnit] = useSetting("unit", Unit.Byte, UnitSchema.parse);

  //----------------------------------------------------------------------------
  // Editors
  //----------------------------------------------------------------------------

  const props = {
    caret,
    flipBitEnabled,
    moveAfterTypingEnabled,
    typingDirection,
    typingMode,
    unit,
  };

  //----------------------------------------------------------------------------
  // Keyboard Event Listener
  //----------------------------------------------------------------------------

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === "k") return setHotkeysEnabled((prev) => !prev);
      if (e.key === "+") return add();
      if (e.key === "-") return subtract();
      if (e.key === "&") return and();
      if (e.key === "|") return or();
      if (e.key === "^") return xor();
      if (e.key === "=") return finalize();

      if (!hotkeysEnabled) return;
      if (e.key === "s") return setSettingsVisible((prev) => !prev);
      if (e.key === "h") return setInstructionsVisible((prev) => !prev);
      if (e.key === "t") return setFlipBitEnabled((prev) => !prev);
      if (e.key === "y") return setUnit(Unit.Byte);
      if (e.key === "w") return setUnit(Unit.Word);
      if (e.key === "i") return setTypingMode(TypingMode.Insert);
      if (e.key === "o") return setTypingMode(TypingMode.Overwrite);
      if (e.key === "l") return setTypingDirection(TypingDirection.Left);
      if (e.key === "r") return setTypingDirection(TypingDirection.Right);
      if (e.key === "m") return setMoveAfterTypingEnabled((prev) => !prev);
    },
    [
      add,
      and,
      finalize,
      hotkeysEnabled,
      or,
      setHotkeysEnabled,
      setTypingMode,
      setUnit,
      subtract,
      xor,
    ]
  );

  useEffect(() => {
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

  //----------------------------------------------------------------------------
  // Render
  //----------------------------------------------------------------------------

  return (
    <div class="app">
      <SectionStatic label="Byte Converter">
        <div>
          <div class="app-editors">
            <div />
            <Caption unit={unit} />
            <div />
            <div />

            <AppEditors
              {...props}
              autoFocus
              integer={operand1}
              isVisibleBin
              isVisibleDec
              isVisibleHex
              onChange={setOperand1}
              onClear={clearInteger}
              prefixBin="BIN"
              prefixDec="DEC"
              prefixHex="HEX"
            />

            <div class="divider" />

            <AppEditors
              {...props}
              integer={operand2}
              isVisibleBin
              isVisibleDec
              isVisibleHex
              onChange={setOperand2}
              onClear={clearPartial}
              prefixBin={OperationLabel[operation]}
            />

            <div class="divider" />

            <AppEditors
              {...props}
              integer={result}
              isDisabled
              isVisibleBin
              isVisibleDec
              isVisibleHex
              onChange={doNothing}
              prefixBin="="
            />
          </div>

          <Calculator
            onAdd={add}
            onAnd={and}
            onFinalize={finalize}
            onOr={or}
            onSubtract={subtract}
            onXor={xor}
          />
        </div>
      </SectionStatic>

      <SectionCollapsible
        isVisible={settingsVisible}
        label="Settings"
        onChange={setSettingsVisible}
      >
        <div class="app-settings">
          <AppSetting label="Unit">
            <Radio onChange={setUnit} options={unitOptions} value={unit} />
          </AppSetting>

          <AppSetting label="Typing Mode">
            <Radio
              onChange={setTypingMode}
              options={typingModeOptions}
              value={typingMode}
            />
          </AppSetting>

          <AppSetting label="Typing Direction">
            <Radio
              onChange={setTypingDirection}
              options={typingDirectionOptions}
              value={typingDirection}
            />
          </AppSetting>

          <AppSetting label="Move Cursor">
            <Radio
              onChange={setMoveAfterTypingEnabled}
              options={binaryOptions}
              value={moveAfterTypingEnabled}
            />
          </AppSetting>

          <AppSetting label="Flip Bit">
            <Radio
              onChange={setFlipBitEnabled}
              options={binaryOptions}
              value={flipBitEnabled}
            />
          </AppSetting>

          <AppSetting label="Caret">
            <Radio onChange={setCaret} options={caretOptions} value={caret} />
          </AppSetting>

          <AppSetting label="Hotkeys">
            <Radio
              onChange={setHotkeysEnabled}
              options={binaryOptions}
              value={hotkeysEnabled}
            />
          </AppSetting>
        </div>
      </SectionCollapsible>

      <AppInstructions
        isVisible={instructionsVisible}
        onChangeVisibility={setInstructionsVisible}
      />

      <div class="app-footer">
        v1.1.0 | zuccha |&nbsp;
        <a
          href="https://github.com/zuccha/smw-code/blob/main/tools/byte_converter/CHANGELOG.md"
          target="_blank"
        >
          Changelog
        </a>
        &nbsp;|&nbsp;
        <a
          href="https://github.com/zuccha/smw-code/blob/main/tools/byte_converter"
          target="_blank"
        >
          GitHub
        </a>
      </div>
    </div>
  );
}
