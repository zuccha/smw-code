import { Ref, useCallback, useEffect, useRef, useState } from "preact/hooks";
import Button from "./components/button";
import Caption from "./components/caption";
import Editor, { EditorRef, TypeMode } from "./components/editor";
import Radio, { Option } from "./components/radio";
import useSetting from "./hooks/use-setting";
import { Encoding, Unit } from "./hooks/use-value";
import { classNames } from "./utils";
import "./app.css";

const unitOptions: Option<Unit>[] = [
  { label: "Byte", value: Unit.Byte },
  { label: "Word", value: Unit.Word },
] as const;

const typeModeOptions: Option<TypeMode>[] = [
  { label: "Insert", value: TypeMode.Insert },
  { label: "Overwrite", value: TypeMode.Overwrite },
] as const;

const binaryOptions: Option<boolean>[] = [
  { label: "On", value: true },
  { label: "Off", value: false },
] as const;

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

export function App() {
  const [integer, setInteger] = useState(0);

  const [typeMode, setInsertMode] = useSetting("type-mode", TypeMode.Overwrite);
  const [unit, setUnit] = useSetting("unit", Unit.Byte);
  const [hotkeysEnabled, setHotkeysEnabled] = useSetting("hotkeys", false);

  const props = { typeMode, integer, unit, onChange: setInteger };

  const editor0Ref = useRef<EditorRef>(null);
  const editor1Ref = useRef<EditorRef>(null);
  const editor2Ref = useRef<EditorRef>(null);

  const editor0 = useEditor(editor0Ref, undefined, editor1Ref);
  const editor1 = useEditor(editor1Ref, editor0Ref, editor2Ref);
  const editor2 = useEditor(editor2Ref, editor1Ref, undefined);

  const [instructionsVisible, setInstructionsVisible] = useSetting(
    "instructions-visible",
    true
  );

  const toggleInstructions = useCallback(() => {
    setInstructionsVisible((prevIntructionsVisible) => !prevIntructionsVisible);
  }, []);

  const instructionsButtonLabel = instructionsVisible
    ? "Hide Instructions"
    : "Show Instructions";

  const instructionsClassName = classNames([["hidden", !instructionsVisible]]);

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === "k") return setHotkeysEnabled((prev) => !prev);

      if (!hotkeysEnabled) return;
      if (e.key === "h") return toggleInstructions();
      if (e.key === "y") return setUnit(Unit.Byte);
      if (e.key === "w") return setUnit(Unit.Word);
      if (e.key === "i") return setInsertMode(TypeMode.Insert);
      if (e.key === "o") return setInsertMode(TypeMode.Overwrite);
    },
    [
      hotkeysEnabled,
      setHotkeysEnabled,
      setInsertMode,
      setUnit,
      toggleInstructions,
    ]
  );

  useEffect(() => {
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

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
        <Button label="Copy" onClick={editor0.copy} />

        <span class="app-editor-label">Decimal</span>
        <div class="app-editor-input">
          <Editor {...props} {...editor1} encoding={Encoding.Decimal} />
        </div>
        <Button label="Copy" onClick={editor1.copy} />

        <span class="app-editor-label">Hexadecimal</span>
        <div class="app-editor-input">
          <Editor {...props} {...editor2} encoding={Encoding.Hexadecimal} />
        </div>
        <Button label="Copy" onClick={editor2.copy} />
      </div>

      <div class="app-divider" />

      <div class="app-settings">
        <span class="app-setting-label">Unit:</span>
        <div class="app-setting-input">
          <Radio onChange={setUnit} options={unitOptions} value={unit} />
        </div>

        <span class="app-setting-label">Type Mode:</span>
        <div class="app-setting-input">
          <Radio
            onChange={setInsertMode}
            options={typeModeOptions}
            value={typeMode}
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
        <div class="app-instructions-button">
          <Button
            label={instructionsButtonLabel}
            onClick={toggleInstructions}
          />
        </div>

        <ul className={instructionsClassName}>
          <li>
            Click on a number to modify it, the others will change accordingly.
          </li>
          <li>Move with arrow keys.</li>
          <li>
            <code>ctrl/cmd+C</code> while selecting a number to copy it to the
            clipboard, <code>ctrl/cmd+V</code> to paste it (paste won't do
            anything if what's stored in the clipboard is not a valid number in
            the selected format).
          </li>
          <li>
            <b>Unit:</b> <i>Byte</i> is 8-bit; <i>Word</i> is 16-bit.
          </li>
          <li>
            <b>Type Mode:</b> <i>Insert</i> inserts the typed digit where the
            selected digit is; <i>Overwrite</i> replaces the selected digit with
            the typed digit.
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
                <code>I</code> - Set type mode to <i>Insert</i>
              </li>
              <li>
                <code>O</code> - Set type mode to <i>Overwrite</i>
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
      </div>
    </div>
  );
}
