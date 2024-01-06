import { Ref, useCallback, useEffect, useRef, useState } from "preact/hooks";
import { z } from "zod";
import Caption from "../components/caption";
import Editor, { EditorRef } from "../components/editor";
import Radio, { Option } from "../components/radio";
import useSetting from "../hooks/use-setting";
import {
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

const unitOptions: Option<Unit>[] = [
  { label: "Byte", value: Unit.Byte },
  { label: "Word", value: Unit.Word },
] as const;

const typingDirectionOptions: Option<TypingDirection>[] = [
  { label: "Left", value: TypingDirection.Left },
  { label: "Right", value: TypingDirection.Right },
] as const;

const typingModeOptions: Option<TypingMode>[] = [
  { label: "Insert", value: TypingMode.Insert },
  { label: "Overwrite", value: TypingMode.Overwrite },
] as const;

const binaryOptions: Option<boolean>[] = [
  { label: "On", value: true },
  { label: "Off", value: false },
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

  const [typingMode, setTypingMode] = useSetting(
    "typing-mode",
    TypingMode.Overwrite,
    TypingModeSchema.parse
  );

  const [typingDirection, setTypingDirection] = useSetting(
    "typing-direction",
    TypingDirection.Right,
    TypingDirectionSchema.parse
  );

  const [moveAfterTypingEnabled, setMoveAfterTypingEnabled] = useSetting(
    "move-after-typing-enabled",
    true,
    z.boolean().parse
  );

  const [unit, setUnit] = useSetting("unit", Unit.Byte, UnitSchema.parse);

  const [hotkeysEnabled, setHotkeysEnabled] = useSetting(
    "hotkeys-enabled",
    false,
    z.boolean().parse
  );

  const [instructionsVisible, setInstructionsVisible] = useSetting(
    "instructions-visible",
    true,
    z.boolean().parse
  );

  //----------------------------------------------------------------------------
  // Editors
  //----------------------------------------------------------------------------

  const props = {
    integer,
    unit,
    moveAfterTypingEnabled,
    onChange,
    typingDirection,
    typingMode,
  };

  const editor0Ref = useRef<EditorRef>(null);
  const editor1Ref = useRef<EditorRef>(null);
  const editor2Ref = useRef<EditorRef>(null);

  const editor0 = useEditor(editor0Ref, undefined, editor1Ref);
  const editor1 = useEditor(editor1Ref, editor0Ref, editor2Ref);
  const editor2 = useEditor(editor2Ref, editor1Ref, undefined);

  //----------------------------------------------------------------------------
  // Keyboard Event Listener
  //----------------------------------------------------------------------------

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === "k") return setHotkeysEnabled((prev) => !prev);

      if (!hotkeysEnabled) return;
      if (e.key === "h") return setInstructionsVisible((prev) => !prev);
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
      <div class="app-editors">
        <div />
        <Caption unit={unit} />
        <div />

        <AppEditor label="Binary" onCopy={editor0.copy}>
          <Editor
            {...props}
            {...editor0}
            encoding={Encoding.Binary}
            autoFocus
          />
        </AppEditor>

        <AppEditor label="Decimal" onCopy={editor1.copy}>
          <Editor {...props} {...editor1} encoding={Encoding.Decimal} />
        </AppEditor>

        <AppEditor label="Hexadecimal" onCopy={editor2.copy}>
          <Editor {...props} {...editor2} encoding={Encoding.Hexadecimal} />
        </AppEditor>
      </div>

      <div class="app-divider" />

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

        <AppSetting label="Move After Typing">
          <Radio
            onChange={setMoveAfterTypingEnabled}
            options={binaryOptions}
            value={moveAfterTypingEnabled}
          />
        </AppSetting>

        <AppSetting label="Hotkeys">
          <Radio
            onChange={setHotkeysEnabled}
            options={binaryOptions}
            value={hotkeysEnabled}
          />
        </AppSetting>
      </div>

      <div class="app-divider" />

      <AppInstructions
        isVisible={instructionsVisible}
        onChangeVisibility={setInstructionsVisible}
      />
    </div>
  );
}
