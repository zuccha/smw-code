import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "preact/hooks";
import { isMobile } from "react-device-detect";
import { z } from "zod";
import Caption from "../components/caption";
import CheckGroup from "../components/check-group";
import Keyboard, { KeyboardAction } from "../components/keyboard";
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
  Encoding,
  HexDigits,
  KeyboardMode,
  KeyboardModeSchema,
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

const keyboardModeOptions: Option<KeyboardMode>[] = [
  { label: "None", value: KeyboardMode.None },
  { label: "Compact", value: KeyboardMode.Compact },
  { label: "Full", value: KeyboardMode.Full },
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
  [Operation.And]: "AND",
  [Operation.Add]: "+",
  [Operation.Or]: "OR",
  [Operation.Subtract]: "-",
  [Operation.Xor]: "XOR",
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

  const [keyboardMode, setKeyboardMode] = useSetting(
    "keyboard-mode",
    KeyboardMode.None,
    KeyboardModeSchema.parse
  );

  const [shouldFlipBitOnClick, setShouldFlipBitOnClick] = useSetting(
    "flip-bit-enabled",
    false,
    z.boolean().parse
  );

  const [shouldMoveAfterTyping, setMoveAfterTypingEnabled] = useSetting(
    "move-after-typing-enabled",
    true,
    z.boolean().parse
  );

  const [signedBinEnabled, setSignedBinEnabled] = useSetting(
    "signed-bin",
    false,
    z.boolean().parse
  );

  const [signedDecEnabled, setSignedDecEnabled] = useSetting(
    "signed-dec",
    false,
    z.boolean().parse
  );

  const [signedHexEnabled, setSignedHexEnabled] = useSetting(
    "signed-hex",
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

  const clearOperand1 = useCallback(() => setOperand1(0), [setOperand1]);
  const clearOperand2 = useCallback(() => setOperand2(0), [setOperand2]);

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
    clearOperand1();
    clearOperand2();
  }, [clearOperand1, clearOperand2]);
  const swap = useCallback(() => {
    setOperand1(operand2);
    setOperand2(operand1);
  }, [operand1, operand2, setOperand1, setOperand2]);

  //----------------------------------------------------------------------------
  // Editors
  //----------------------------------------------------------------------------

  const props = {
    caret,
    shouldFlipBitOnClick,
    shouldMoveAfterTyping,
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
          if (e.ctrlKey && e.key === "Backspace") return t(clear());
          if (e.ctrlKey && e.key === "Delete") return t(clear());
          if (e.key === ";") return t(swap());
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
        if (e.key === "t") return f(setShouldFlipBitOnClick(toggle));
        if (e.key === "y") return f(setUnit(Unit.Byte));
        if (e.key === "w") return f(setUnit(Unit.Word));
        if (e.key === "i") return f(setTypingMode(TypingMode.Insert));
        if (e.key === "o") return f(setTypingMode(TypingMode.Overwrite));
        if (e.key === "l") return f(setTypingDirection(TypingDirection.Left));
        if (e.key === "r") return f(setTypingDirection(TypingDirection.Right));
        if (e.key === "m") return f(setMoveAfterTypingEnabled(toggle));
        if (e.key === "n") return f(setSignedDecEnabled(toggle));

        return false;
      };

      if (processKeys()) e.preventDefault();
    },
    [
      add,
      and,
      calculatorEnabled,
      clear,
      finalize,
      hotkeysEnabled,
      or,
      setHotkeysEnabled,
      setTypingMode,
      setUnit,
      subtract,
      swap,
      xor,
    ]
  );

  useEffect(() => {
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

  //----------------------------------------------------------------------------
  // Keyboard
  //----------------------------------------------------------------------------

  const keyboardActions = useMemo(() => {
    const type = (key: string, shiftKey?: boolean) => () => {
      if (document.activeElement)
        document.activeElement.dispatchEvent(
          new KeyboardEvent("keydown", { key, shiftKey })
        );
    };

    if (!isMobile && keyboardMode === KeyboardMode.None) return [];

    const keys: KeyboardAction[] = [];

    if (isMobile || (keyboardMode !== KeyboardMode.None && calculatorEnabled))
      keys.push(
        { label: "+", onClick: add },
        { label: "-", onClick: subtract },
        { label: "AND", onClick: and, size: "xs" },
        { label: "OR", onClick: or, size: "xs" },
        { label: "XOR", onClick: xor, size: "xs" },
        { label: "=", onClick: finalize },
        { label: "SWAP", onClick: swap, size: "xs" },
        { label: "AC", onClick: clear, size: "s" }
      );

    if (isMobile || keyboardMode !== KeyboardMode.None)
      keys.push(
        { label: "NEG", onClick: type("!"), size: "xs" },
        { label: "«", onClick: type("<") },
        { label: "»", onClick: type(">") },
        { label: "ROL", onClick: type("{"), size: "xs" },
        { label: "ROR", onClick: type("}"), size: "xs" },
        { label: "DEL", onClick: type("Delete"), size: "xs" },
        { label: "⌫", onClick: type("Backspace") },
        { label: "Cl", onClick: type("Delete", true), size: "s" }
      );

    if (isMobile || keyboardMode === KeyboardMode.Full)
      keys.push(
        ...HexDigits.map((digit) => ({ label: digit, onClick: type(digit) })),
        { label: "INC", onClick: type(" "), size: "xs" },
        { label: "DEC", onClick: type(" ", true), size: "xs" },
        { label: " ", onClick: type(" "), colSpan: 2 },
        { label: "←", onClick: type("ArrowLeft") },
        { label: "↑", onClick: type("ArrowUp") },
        { label: "↓", onClick: type("ArrowDown") },
        { label: "→", onClick: type("ArrowRight") }
      );

    return keys;
  }, [
    add,
    and,
    calculatorEnabled,
    clear,
    finalize,
    keyboardMode,
    operation,
    or,
    subtract,
    swap,
    xor,
  ]);

  //----------------------------------------------------------------------------
  // Caption
  //----------------------------------------------------------------------------

  const isAnyBinVisible =
    operand1Visibility[0] || operand2Visibility[0] || resultVisibility[0];
  const isAnyDecVisible =
    operand1Visibility[1] || operand2Visibility[1] || resultVisibility[1];
  const isAnyHexVisible =
    operand1Visibility[2] || operand2Visibility[2] || resultVisibility[2];

  const [isCaptionSigned, captionEncoding] = isAnyBinVisible
    ? [signedBinEnabled, Encoding.Bin]
    : isAnyDecVisible
    ? [signedDecEnabled, Encoding.Dec]
    : isAnyHexVisible
    ? [signedHexEnabled, Encoding.Hex]
    : [false, undefined];

  //----------------------------------------------------------------------------
  // Render
  //----------------------------------------------------------------------------

  return (
    <div class="app">
      <SectionStatic label="Byte Converter">
        <div class="app-main">
          <div class="app-editors">
            <div class="app-spacer">&nbsp;&nbsp;&nbsp;</div>
            <Caption
              encoding={captionEncoding}
              isSigned={isCaptionSigned}
              spaceFrequency={spaceFrequency}
              unit={unit}
            />
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
              isSignedBin={signedBinEnabled}
              isSignedDec={signedDecEnabled}
              isSignedHex={signedHexEnabled}
              isVisibleBin={operand1Visibility[0]}
              isVisibleDec={operand1Visibility[1]}
              isVisibleHex={operand1Visibility[2]}
              onChange={setOperand1}
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
                  isSignedBin={signedBinEnabled}
                  isSignedDec={signedDecEnabled}
                  isSignedHex={signedHexEnabled}
                  isVisibleBin={operand2Visibility[0]}
                  isVisibleDec={operand2Visibility[1]}
                  isVisibleHex={operand2Visibility[2]}
                  onChange={setOperand2}
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
                  isSignedBin={signedBinEnabled}
                  isSignedDec={signedDecEnabled}
                  isSignedHex={signedHexEnabled}
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

          {keyboardActions.length > 0 && <Keyboard actions={keyboardActions} />}
        </div>
      </SectionStatic>

      <SectionCollapsible
        isVisible={settingsVisible}
        label="Settings"
        onChange={setSettingsVisible}
      >
        <div class="app-settings">
          <AppSetting hotkey="K" label="Hotkeys">
            <RadioGroup
              onChange={setHotkeysEnabled}
              options={binaryOptions}
              value={hotkeysEnabled}
            />
          </AppSetting>

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

          {!isMobile && (
            <AppSetting label="Keyboard">
              <RadioGroup
                onChange={setKeyboardMode}
                options={keyboardModeOptions}
                value={keyboardMode}
              />
            </AppSetting>
          )}

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
              value={shouldMoveAfterTyping}
            />
          </AppSetting>

          <AppSetting hotkey="T" label="Flip Bit">
            <RadioGroup
              onChange={setShouldFlipBitOnClick}
              options={binaryOptions}
              value={shouldFlipBitOnClick}
            />
          </AppSetting>

          <AppSetting label="Signed Binary">
            <RadioGroup
              onChange={setSignedBinEnabled}
              options={binaryOptions}
              value={signedBinEnabled}
            />
          </AppSetting>

          <AppSetting hotkey="N" label="Signed Decimal">
            <RadioGroup
              onChange={setSignedDecEnabled}
              options={binaryOptions}
              value={signedDecEnabled}
            />
          </AppSetting>

          <AppSetting label="Signed Hexadecimal">
            <RadioGroup
              onChange={setSignedHexEnabled}
              options={binaryOptions}
              value={signedHexEnabled}
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
        v1.4.0 | zuccha |&nbsp;
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
