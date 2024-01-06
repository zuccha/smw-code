import { Ref, useCallback, useEffect, useRef, useState } from "preact/hooks";
import { z } from "zod";
import Caption from "../components/caption";
import Editor, { EditorRef } from "../components/editor";
import Radio, { Option } from "../components/radio";
import SectionCollapsible from "../components/section-collapsible";
import SectionStatic from "../components/section-static";
import useSetting from "../hooks/use-setting";
import {
  Caret,
  CaretSchema,
  Encoding,
  TypingDirection,
  TypingDirectionSchema,
  TypingMode,
  TypingModeSchema,
  Unit,
  UnitSchema,
} from "../types";
import AppEditor from "./app-editor";
import AppInstructions from "./app-instructions";
import AppSetting from "./app-setting";
import "./app.css";

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

//==============================================================================
// Use Editor
//==============================================================================

const useEditor = (
  ref: Ref<EditorRef>,
  prevRef: Ref<EditorRef> | undefined,
  nextRef: Ref<EditorRef> | undefined
) => {
  const onMoveUp = useCallback(() => prevRef?.current?.focus(), [prevRef]);
  const onMoveDown = useCallback(() => nextRef?.current?.focus(), [nextRef]);
  const copy = useCallback(() => ref.current?.copy(), [ref]);
  return { copy, onMoveDown, onMoveUp, ref };
};

//==============================================================================
// App
//==============================================================================

export function App() {
  //----------------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------------

  const [integer, onChange] = useState(0);

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
    integer,
    moveAfterTypingEnabled,
    onChange,
    typingDirection,
    typingMode,
    unit,
  };

  const editorBinRef = useRef<EditorRef>(null);
  const editorDecRef = useRef<EditorRef>(null);
  const editorHexRef = useRef<EditorRef>(null);

  const editorBin = useEditor(editorBinRef, undefined, editorDecRef);
  const editorDec = useEditor(editorDecRef, editorBinRef, editorHexRef);
  const editorHex = useEditor(editorHexRef, editorDecRef, undefined);

  //----------------------------------------------------------------------------
  // Keyboard Event Listener
  //----------------------------------------------------------------------------

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === "k") return setHotkeysEnabled((prev) => !prev);

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
    [hotkeysEnabled, setHotkeysEnabled, setTypingMode, setUnit]
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
        <div class="app-editors">
          <div />
          <Caption unit={unit} />
          <div />
          <AppEditor label="BIN" onCopy={editorBin.copy}>
            <Editor
              {...props}
              {...editorBin}
              encoding={Encoding.Binary}
              autoFocus
            />
          </AppEditor>
          <AppEditor label="DEC" onCopy={editorDec.copy}>
            <Editor {...props} {...editorDec} encoding={Encoding.Decimal} />
          </AppEditor>
          <AppEditor label="HEX" onCopy={editorHex.copy}>
            <Editor {...props} {...editorHex} encoding={Encoding.Hexadecimal} />
          </AppEditor>
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
