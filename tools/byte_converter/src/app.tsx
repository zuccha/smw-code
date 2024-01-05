import { useCallback, useRef, useState } from "preact/hooks";
import Button from "./components/button";
import Editor, { EditorRef, InsertMode } from "./components/editor";
import Radio, { Option } from "./components/radio";
import useClickOutside from "./hooks/use-click-outside";
import useSetting from "./hooks/use-setting";
import { Encoding, Unit } from "./hooks/use-value";
import { classNames } from "./utils";
import "./app.css";

const unitOptions: Option<Unit>[] = [
  { label: "Byte", value: Unit.Byte },
  { label: "Word", value: Unit.Word },
] as const;

const insertModeOptions: Option<InsertMode>[] = [
  { label: "Add&Shift", value: InsertMode.AddAndShiftRight },
  { label: "Replace", value: InsertMode.Replace },
] as const;

const useEditor = (
  id: number,
  selection: number,
  setSelection: (selection: number) => void
) => {
  const ref = useRef<EditorRef>(null);
  const [index, setIndex] = useState(0);
  const hasFocus = id === selection;

  const onChangeIndex = useCallback(
    (newIndex: number) => {
      setIndex(newIndex);
      setSelection(id);
    },
    [id, setSelection]
  );

  const onMove = useCallback(
    (direction: -1 | 1) => {
      const newId = id + direction;
      if (0 <= newId && newId < 3) setSelection(newId);
    },
    [id, setSelection]
  );

  const copy = useCallback(() => ref.current?.copy(), []);

  return { copy, hasFocus, index, onChangeIndex, onMove, ref };
};

export function App() {
  const [integer, setInteger] = useState(0);
  const [selection, setSelection] = useState(0);

  const [insertMode, setInsertMode] = useSetting(
    "insertion-mode",
    InsertMode.Replace
  );

  const [unit, setUnit] = useSetting("unit", Unit.Byte);

  const ref = useRef<HTMLDivElement>(null);
  useClickOutside(
    ref,
    useCallback(() => setSelection(-1), [])
  );

  const props = { insertMode, integer, unit, onChange: setInteger };
  const editor0 = useEditor(0, selection, setSelection);
  const editor1 = useEditor(1, selection, setSelection);
  const editor2 = useEditor(2, selection, setSelection);

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

  return (
    <div class="app" ref={ref}>
      <div class="app-editors">
        <span class="app-editor-label">Binary</span>
        <div class="app-editor-input">
          <Editor {...props} {...editor0} encoding={Encoding.Binary} />
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

        <span class="app-setting-label">Insertion:</span>
        <div class="app-setting-input">
          <Radio
            onChange={setInsertMode}
            options={insertModeOptions}
            value={insertMode}
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
            <b>Insertion:</b> <i>Add&Shift</i> inserts the typed digit and
            shifts everything that follows the selected digit to the right;{" "}
            <i>Replace</i> replaces the selected digit.
          </li>
        </ul>
      </div>
    </div>
  );
}
