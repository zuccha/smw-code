import Collapsible from "../components/collapsible";

type AppInstructions = {
  isVisible: boolean;
  onChangeVisibility: (isVisible: boolean) => void;
};

export default function AppInstructions({
  isVisible,
  onChangeVisibility,
}: AppInstructions) {
  return (
    <div class="app-instructions">
      <Collapsible
        label="Instructions"
        isVisible={isVisible}
        onChange={onChangeVisibility}
      >
        <ul>
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
            <b>Typing Mode:</b> <i>Insert</i> inserts the typed digit where the
            selected digit is; <i>Overwrite</i> replaces the selected digit with
            the typed digit.
          </li>
          <li>
            <b>Typing Direction:</b> <i>Right</i> moves the cursor to the right
            after typing; <i>Left</i> moves the cursors to the left after
            typing. Deletion direction is also inverted.
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
  );
}
