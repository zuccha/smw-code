import { Copy } from "lucide-preact";
import { Ref, useCallback, useEffect, useRef, useState } from "preact/hooks";
import { z } from "zod";
import Button from "./components/button";
import Caption from "./components/caption";
import Collapsible from "./components/collapsible";
import Editor, { EditorRef } from "./components/editor";
import Radio, { Option } from "./components/radio";
import useSetting from "./hooks/use-setting";
import {
  Encoding,
  TypingDirection,
  TypingDirectionSchema,
  TypingMode,
  TypingModeSchema,
  Unit,
  UnitSchema,
} from "./types";
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

  const props = { integer, unit, onChange, typingDirection, typingMode };

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
    },
    [hotkeysEnabled, setHotkeysEnabled, setTypingMode, setUnit]
  );

  useEffect(() => {
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

  const copyButtonLabel = <Copy size={20} />;

  //----------------------------------------------------------------------------
  // Render
  //----------------------------------------------------------------------------

  return (
    <div class="app">
      <div class="app-editors">
        <div />
        <Caption unit={unit} />
        <div />

        <span class="app-editor-label">Binary</span>
        <div class="app-editor-input">
          <Editor
            {...props}
            {...editor0}
            encoding={Encoding.Binary}
            autoFocus
          />
        </div>
        <Button isRound label={copyButtonLabel} onClick={editor0.copy} />

        <span class="app-editor-label">Decimal</span>
        <div class="app-editor-input">
          <Editor {...props} {...editor1} encoding={Encoding.Decimal} />
        </div>
        <Button isRound label={copyButtonLabel} onClick={editor1.copy} />

        <span class="app-editor-label">Hexadecimal</span>
        <div class="app-editor-input">
          <Editor {...props} {...editor2} encoding={Encoding.Hexadecimal} />
        </div>
        <Button isRound label={copyButtonLabel} onClick={editor2.copy} />
      </div>

      <div class="app-divider" />

      <div class="app-settings">
        <span class="app-setting-label">Unit:</span>
        <div class="app-setting-input">
          <Radio onChange={setUnit} options={unitOptions} value={unit} />
        </div>

        <span class="app-setting-label">Typing Mode:</span>
        <div class="app-setting-input">
          <Radio
            onChange={setTypingMode}
            options={typingModeOptions}
            value={typingMode}
          />
        </div>

        <span class="app-setting-label">Typing Direction:</span>
        <div class="app-setting-input">
          <Radio
            onChange={setTypingDirection}
            options={typingDirectionOptions}
            value={typingDirection}
          />
        </div>

        <span class="app-setting-label">Hotkeys:</span>
        <div class="app-setting-input">
          <Radio
            onChange={setHotkeysEnabled}
            options={binaryOptions}
            value={hotkeysEnabled}
          />
        </div>
      </div>

      <div class="app-divider" />

      <div class="app-instructions">
        <Collapsible
          label="Instructions"
          isVisible={instructionsVisible}
          onChange={setInstructionsVisible}
        >
          <ul>
            <li>
              Click on a number to modify it, the others will change
              accordingly.
            </li>
            <li>Move with arrow keys.</li>
            <li>
              <code>ctrl/cmd+C</code> while selecting a number to copy it to the
              clipboard, <code>ctrl/cmd+V</code> to paste it (paste won't do
              anything if what's stored in the clipboard is not a valid number
              in the selected format).
            </li>
            <li>
              <b>Unit:</b> <i>Byte</i> is 8-bit; <i>Word</i> is 16-bit.
            </li>
            <li>
              <b>Typing Mode:</b> <i>Insert</i> inserts the typed digit where
              the selected digit is; <i>Overwrite</i> replaces the selected
              digit with the typed digit.
            </li>
            <li>
              <b>Typing Direction:</b> <i>Right</i> moves the cursor to the
              right after typing; <i>Left</i> moves the cursors to the left
              after typing. Deletion direction is also inverted.
            </li>
            <li>
              <b>Hotkeys:</b> When on, it is possible to control settings with
              keys:
              <ul>
                <li>
                  <code>Y</code> - Set unit to <i>Byte</i>
                </li>
                <li>
                  <code>W</code> - Set unit to <i>Word</i>
                </li>
                <li>
                  <code>I</code> - Set typing mode to <i>Insert</i>
                </li>
                <li>
                  <code>O</code> - Set typing mode to <i>Overwrite</i>
                </li>
                <li>
                  <code>L</code> - Set typing direction to <i>Left</i>
                </li>
                <li>
                  <code>R</code> - Set typing direction to <i>Right</i>
                </li>
                <li>
                  <code>H</code> - Toggle instructions visibility
                </li>
                <li>
                  <code>K</code> - Toggle hotkeys (this is always enabled)
                </li>
              </ul>
            </li>
          </ul>
        </Collapsible>
      </div>
    </div>
  );
}
