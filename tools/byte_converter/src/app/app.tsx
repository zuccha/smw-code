import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "preact/hooks";
import { z } from "zod";
import Calculator from "../components/calculator";
import Caption from "../components/caption";
import CheckGroup from "../components/check-group";
import RadioGroup, { Option } from "../components/radio-group";
import SectionCollapsible from "../components/section-collapsible";
import SectionStatic from "../components/section-static";
import useMaskedValue from "../hooks/use-masked-value";
import useSetting from "../hooks/use-setting";
import { Boundaries } from "../hooks/use-value";
import {
  Caret,
  CaretSchema,
  Direction,
  Operation,
  SpaceFrequency,
  SpaceFrequencySchema,
  TypingDirection,
  TypingDirectionSchema,
  TypingMode,
  TypingModeSchema,
  Unit,
  UnitSchema,
} from "../types";
import { doNothing, mod, toggle } from "../utils";
import AppEditors, { AppEditorsRef } from "./app-editors";
import AppInstructions from "./app-instructions";
import AppSetting from "./app-setting";
import "./app.css";

//==============================================================================
// Settings Options
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

const spaceFrequencyOptions: Option<SpaceFrequency>[] = [
  { label: "None", value: SpaceFrequency.None },
  { label: "8 Digits", value: SpaceFrequency.Digits8 },
  { label: "4 Digits", value: SpaceFrequency.Digits4 },
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

const groupVisibilityLabels = ["B", "D", "H"];

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
  // Settings
  //----------------------------------------------------------------------------

  const [calculatorEnabled, setCalculatorEnabled] = useSetting(
    "calculator-enabled",
    false,
    z.boolean().parse
  );

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

  const [operand1Visibility, setOperand1Visibility] = useSetting(
    "operand-1-visibility",
    [true, true, true],
    z.array(z.boolean()).length(3).parse
  );

  const [operand2Visibility, setOperand2Visibility] = useSetting(
    "operand-2-visibility",
    [true, true, true],
    z.array(z.boolean()).length(3).parse
  );

  const [resultVisibility, setResultVisibility] = useSetting(
    "result-visibility",
    [true, true, true],
    z.array(z.boolean()).length(3).parse
  );

  const [settingsVisible, setSettingsVisible] = useSetting(
    "settings-visible",
    false,
    z.boolean().parse
  );

  const [signedDecimalEnabled, setSignedDecimalEnabled] = useSetting(
    "signed-decimal",
    false,
    z.boolean().parse
  );

  const [spaceFrequency, setSpaceFrequency] = useSetting(
    "space-frequency",
    SpaceFrequency.Digits8,
    SpaceFrequencySchema.parse
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
  // State
  //----------------------------------------------------------------------------

  const operand1Ref = useRef<AppEditorsRef>(null);
  const operand2Ref = useRef<AppEditorsRef>(null);
  const resultRef = useRef<AppEditorsRef>(null);

  const [operand1, setOperand1] = useMaskedValue(0, unit);
  const [operand2, setOperand2] = useMaskedValue(0, unit);
  const [operation, setOperation] = useState(Operation.Add);

  const result = useMemo(() => {
    switch (operation) {
      case Operation.Add:
        return (operand1 + operand2) % (Boundaries[unit].max + 1);
      case Operation.And:
        return operand1 & operand2;
      case Operation.Or:
        return operand1 | operand2;
      case Operation.Subtract:
        return mod(operand1 - operand2, Boundaries[unit].max + 1);
      case Operation.Xor:
        return operand1 ^ operand2;
    }
  }, [operand1, operation, operand2, unit]);

  const clearOperand1 = useCallback(() => setOperand1(0), []);
  const clearOperand2 = useCallback(() => setOperand2(0), []);

  const apply = useCallback(
    (nextOperation: Operation) => {
      setOperation(nextOperation);
    },
    [operand1]
  );

  const add = useCallback(() => apply(Operation.Add), [apply]);
  const subtract = useCallback(() => apply(Operation.Subtract), [apply]);
  const and = useCallback(() => apply(Operation.And), [apply]);
  const or = useCallback(() => apply(Operation.Or), [apply]);
  const xor = useCallback(() => apply(Operation.Xor), [apply]);
  const finalize = useCallback(() => setOperand2(result), [result]);
  const clear = useCallback(() => {
    setOperand1(0);
    setOperand2(0);
  }, []);
  const swap = useCallback(() => {
    setOperand1(operand2);
    setOperand2(operand1);
  }, [operand1, operand2]);

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
      const t = (_: unknown) => true; // prevent default
      const f = (_: unknown) => false; // don't prevent default

      const processKeys = (): boolean => {
        if (e.key === "Tab")
          return (document.activeElement ?? document.body) === document.body
            ? t(operand1Ref.current?.focus(Direction.Down))
            : false;

        if (e.key === "k") return f(setHotkeysEnabled((prev) => !prev));

        if (calculatorEnabled) {
          if (e.key === "+") return f(add());
          if (e.key === "-") return f(subtract());
          if (e.key === "&") return f(and());
          if (e.key === "|") return f(or());
          if (e.key === "^") return f(xor());
          if (e.key === "=") return f(finalize());
        }

        if (!hotkeysEnabled) return false;
        if (e.key === "q") return f(setCalculatorEnabled(toggle));
        if (e.key === "s") return f(setSettingsVisible(toggle));
        if (e.key === "h") return f(setInstructionsVisible(toggle));
        if (e.key === "t") return f(setFlipBitEnabled(toggle));
        if (e.key === "y") return f(setUnit(Unit.Byte));
        if (e.key === "w") return f(setUnit(Unit.Word));
        if (e.key === "i") return f(setTypingMode(TypingMode.Insert));
        if (e.key === "o") return f(setTypingMode(TypingMode.Overwrite));
        if (e.key === "l") return f(setTypingDirection(TypingDirection.Left));
        if (e.key === "r") return f(setTypingDirection(TypingDirection.Right));
        if (e.key === "m") return f(setMoveAfterTypingEnabled(toggle));
        if (e.key === "n") return f(setSignedDecimalEnabled(toggle));

        return false;
      };

      if (processKeys()) e.preventDefault();
    },
    [
      add,
      and,
      calculatorEnabled,
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
            <div class="app-spacer">&nbsp;&nbsp;&nbsp;</div>
            <Caption spaceFrequency={spaceFrequency} unit={unit} />
            <div class="app-divider-editors-visibility">
              <CheckGroup
                labels={groupVisibilityLabels}
                onChange={setOperand1Visibility}
                values={operand1Visibility}
              />
            </div>

            <AppEditors
              {...props}
              autoFocus
              integer={operand1}
              isSignedDec={signedDecimalEnabled}
              isVisibleBin={operand1Visibility[0]}
              isVisibleDec={operand1Visibility[1]}
              isVisibleHex={operand1Visibility[2]}
              onChange={setOperand1}
              onClear={clearOperand1}
              prefixBin="BIN"
              prefixDec="DEC"
              prefixHex="HEX"
              ref={operand1Ref}
              refNext={operand2Ref}
              spaceFrequency={spaceFrequency}
            />

            {calculatorEnabled ? (
              <>
                <div class="app-divider-line" />
                <div class="app-divider-editors-visibility">
                  <CheckGroup
                    labels={groupVisibilityLabels}
                    onChange={setOperand2Visibility}
                    values={operand2Visibility}
                  />
                </div>

                <AppEditors
                  {...props}
                  integer={operand2}
                  isSignedDec={signedDecimalEnabled}
                  isVisibleBin={operand2Visibility[0]}
                  isVisibleDec={operand2Visibility[1]}
                  isVisibleHex={operand2Visibility[2]}
                  onChange={setOperand2}
                  onClear={clearOperand2}
                  prefixBin={
                    operand2Visibility[0] ? OperationLabel[operation] : ""
                  }
                  prefixDec={
                    !operand2Visibility[0] && operand2Visibility[1]
                      ? OperationLabel[operation]
                      : ""
                  }
                  prefixHex={
                    !operand2Visibility[0] &&
                    !operand2Visibility[1] &&
                    operand2Visibility[2]
                      ? OperationLabel[operation]
                      : ""
                  }
                  ref={operand2Ref}
                  refNext={resultRef}
                  refPrev={operand1Ref}
                  spaceFrequency={spaceFrequency}
                />

                <div class="app-divider-line" />
                <div class="app-divider-editors-visibility">
                  <CheckGroup
                    labels={groupVisibilityLabels}
                    onChange={setResultVisibility}
                    values={resultVisibility}
                  />
                </div>

                <AppEditors
                  {...props}
                  integer={result}
                  isDisabled
                  isSignedDec={signedDecimalEnabled}
                  isVisibleBin={resultVisibility[0]}
                  isVisibleDec={resultVisibility[1]}
                  isVisibleHex={resultVisibility[2]}
                  onChange={doNothing}
                  prefixBin={resultVisibility[0] ? "=" : ""}
                  prefixDec={
                    !resultVisibility[0] && resultVisibility[1] ? "=" : ""
                  }
                  prefixHex={
                    !resultVisibility[0] &&
                    !resultVisibility[1] &&
                    resultVisibility[2]
                      ? "="
                      : ""
                  }
                  ref={resultRef}
                  refPrev={operand2Ref}
                  spaceFrequency={spaceFrequency}
                />
              </>
            ) : (
              <div class="empty" />
            )}
          </div>

          {calculatorEnabled && (
            <div class="app-calculator">
              <Calculator
                operation={operation}
                onAdd={add}
                onAnd={and}
                onClear={clear}
                onFinalize={finalize}
                onOr={or}
                onSubtract={subtract}
                onSwap={swap}
                onXor={xor}
              />
            </div>
          )}
        </div>
      </SectionStatic>

      <SectionCollapsible
        isVisible={settingsVisible}
        label="Settings"
        onChange={setSettingsVisible}
      >
        <div class="app-settings">
          <AppSetting hotkey="Q" label="Calculator">
            <RadioGroup
              onChange={setCalculatorEnabled}
              options={binaryOptions}
              value={calculatorEnabled}
            />
          </AppSetting>

          <AppSetting hotkey="Y/W" label="Unit">
            <RadioGroup onChange={setUnit} options={unitOptions} value={unit} />
          </AppSetting>

          <AppSetting hotkey="I/O" label="Typing Mode">
            <RadioGroup
              onChange={setTypingMode}
              options={typingModeOptions}
              value={typingMode}
            />
          </AppSetting>

          <AppSetting hotkey="L/R" label="Typing Direction">
            <RadioGroup
              onChange={setTypingDirection}
              options={typingDirectionOptions}
              value={typingDirection}
            />
          </AppSetting>

          <AppSetting hotkey="M" label="Move Cursor">
            <RadioGroup
              onChange={setMoveAfterTypingEnabled}
              options={binaryOptions}
              value={moveAfterTypingEnabled}
            />
          </AppSetting>

          <AppSetting hotkey="T" label="Flip Bit">
            <RadioGroup
              onChange={setFlipBitEnabled}
              options={binaryOptions}
              value={flipBitEnabled}
            />
          </AppSetting>

          <AppSetting hotkey="N" label="Signed Decimal">
            <RadioGroup
              onChange={setSignedDecimalEnabled}
              options={binaryOptions}
              value={signedDecimalEnabled}
            />
          </AppSetting>

          <AppSetting hotkey="K" label="Hotkeys">
            <RadioGroup
              onChange={setHotkeysEnabled}
              options={binaryOptions}
              value={hotkeysEnabled}
            />
          </AppSetting>

          <AppSetting label="Caret">
            <RadioGroup
              onChange={setCaret}
              options={caretOptions}
              value={caret}
            />
          </AppSetting>

          <AppSetting label="Space Frequency">
            <RadioGroup
              onChange={setSpaceFrequency}
              options={spaceFrequencyOptions}
              value={spaceFrequency}
            />
          </AppSetting>
        </div>
      </SectionCollapsible>

      <AppInstructions
        isVisible={instructionsVisible}
        onChangeVisibility={setInstructionsVisible}
      />

      <div class="app-footer">
        v1.2.0 | zuccha |&nbsp;
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
