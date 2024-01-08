import SectionCollapsible from "../components/section-collapsible";

type AppInstructions = {
  isVisible: boolean;
  onChangeVisibility: (isVisible: boolean) => void;
};

const keybindings = [
  { hotkeys: ["<arrows>"], description: "Move across editors." },
  {
    hotkeys: ["TAB", "SHIFT+TAB"],
    description:
      "Move to the next/previous focusable element. If nothing is focused, it should focus the binary editor.",
  },
  {
    hotkeys: ["CTRL+C", "CMD+C"],
    description: "Copy the value of the focused editor in the clipboard.",
  },
  {
    hotkeys: ["CTRL+V", "CMD+V"],
    description:
      "Paste a value in the focused editor from the clipboard. It won't do anything if the clipboard doesn't contain a valid value.",
  },
  {
    hotkeys: ["SPACE", "SHIFT+SPACE"],
    description:
      "Increase/decrease the selected digit by one. In binary, this is the equivalent of a bit flip.",
  },
  {
    hotkeys: ["S"],
    description: "Toggle settings visibility.",
  },
  {
    hotkeys: ["H"],
    description: "Toggle instructions visibility.",
  },
];

const settings = [
  {
    name: "Calculator",
    nameRowSpan: 2,
    value: "On",
    description: "Calculator mode.",
    hotkey: "Q",
    hotkeyRowSpan: 2,
  },
  {
    value: "Off",
    description: "Converter-only mode.",
  },
  {
    name: "Unit",
    nameRowSpan: 2,
    value: "Byte",
    description: "8-bit editing mode.",
    hotkey: "Y",
  },
  {
    value: "Word",
    description: "16-bit editing mode.",
    hotkey: "W",
  },
  {
    name: "Typing Mode",
    nameRowSpan: 2,
    value: "Insert",
    description: "Insert the typed digit where the cursor is.",
    hotkey: "I",
  },
  {
    value: "Overwrite",
    description: "Replace the selected digit with the typed digit.",
    hotkey: "O",
  },
  {
    name: "Typing Direction",
    nameRowSpan: 2,
    value: "Left",
    description:
      "Move the cursors to the left after typing. Backspace moves to the right.",
    hotkey: "L",
  },
  {
    value: "Right",
    description:
      "Move the cursors to the right after typing. Backspace moves to the left.",
    hotkey: "R",
  },
  {
    name: "Move Cursor",
    nameRowSpan: 2,
    value: "On",
    description: "Move cursor after typing.",
    hotkey: "M",
    hotkeyRowSpan: 2,
  },
  {
    value: "Off",
    description: "Don't move cursor after typing.",
  },
  {
    name: "Flip Bit",
    nameRowSpan: 2,
    value: "On",
    description: "Flip a bit of the binary editor when clicking on it.",
    hotkey: "T",
    hotkeyRowSpan: 2,
  },
  {
    value: "Off",
    description: "Don't flip any bit when clicking on the editors.",
  },
  {
    name: "Signed Binary",
    nameRowSpan: 2,
    value: "On",
    description: "Binary numbers are signed (they can be negative).",
    hotkey: "",
    hotkeyRowSpan: 2,
  },
  {
    value: "Off",
    description: "Binary numbers are always positive.",
  },
  {
    name: "Signed Decimal",
    nameRowSpan: 2,
    value: "On",
    description: "Decimal numbers are signed (they can be negative).",
    hotkey: "N",
    hotkeyRowSpan: 2,
  },
  {
    value: "Off",
    description: "Decimal numbers are always positive.",
  },
  {
    name: "Signed Hexadecimal",
    nameRowSpan: 2,
    value: "On",
    description: "Hexadecimal numbers are signed (they can be negative).",
    hotkey: "",
    hotkeyRowSpan: 2,
  },
  {
    value: "Off",
    description: "Hexadecimal numbers are always positive.",
  },
  {
    name: "Hotkeys",
    nameRowSpan: 2,
    value: "On",
    description: "Hotkeys are enabled.",
    hotkey: "K",
    hotkeyRowSpan: 2,
  },
  {
    value: "Off",
    description: "Hotkeys are disabled, except for this one.",
  },
  {
    name: "Caret",
    value: "Bar, Box, Underline",
    description: "Caret appearance.",
    hotkey: "",
  },
  {
    name: "Space Frequency",
    value: "None, 8 Digits, 4 Digits",
    description: "Add some space between digits to improve readability.",
    hotkey: "",
  },
];

const operations = [
  {
    name: "+",
    description: "Add the two operands together.",
    hotkey: "+",
  },
  {
    name: "-",
    description: "Subtract operand 2 from operand 1.",
    hotkey: "-",
  },
  {
    name: "&",
    description: "Logical AND between the two operands.",
    hotkey: "&",
  },
  {
    name: "|",
    description: "Logical OR between the two operands.",
    hotkey: "|",
  },
  {
    name: "^",
    description: "Logical XOR between the two operands.",
    hotkey: "^",
  },
  {
    name: "=",
    description: "Transfer the result in operand 2.",
    hotkey: "=",
  },
  {
    name: "C",
    description: "Clear all values (set them to 0).",
    hotkey: "",
  },
  {
    name: "↓↑",
    description: "Swap operand 1 with operand 2.",
    hotkey: "",
  },
];

export default function AppInstructions({
  isVisible,
  onChangeVisibility,
}: AppInstructions) {
  return (
    <div class="app-instructions">
      <SectionCollapsible
        isVisible={isVisible}
        label="Instructions"
        onChange={onChangeVisibility}
      >
        <div class="app-instructions-sections">
          <div>
            <div class="app-instructions-section-label">General:</div>
            <ul>
              <li>
                Click on a number to edit it. In a group (bin/dec/hex), the
                numbers are connected, editing one will cause the others to
                update. To hide numbers, click on the three toggle buttons on
                the top-right of the group.
              </li>
              <li>
                Copy a specific value (in its format) by pressing on the
                "copy-to-clipboard" button. The "X" button sets the value to 0
                for the entire group.
              </li>
              <li>
                When in "Byte" mode, the high byte will be preserved and
                restored when switching back to "Word".
              </li>
              <li>
                When "Negative Decimal" is enabled, it's possible to manually
                change its sign by selecting it and either delete it if it's a
                minus sign, or type "-" to make the number negative.
              </li>
            </ul>
          </div>

          <div>
            <div class="app-instructions-section-label">Keybindings:</div>
            <table>
              <thead>
                <tr>
                  <th>Keybinding</th>
                  <th>Description</th>
                </tr>
              </thead>
              <tbody>
                {keybindings.map((keybinding) => (
                  <tr>
                    <td>
                      {keybinding.hotkeys.map((hotkey, index) => (
                        <>
                          <code>{hotkey}</code>
                          {index < keybinding.hotkeys.length - 1 && " "}
                        </>
                      ))}
                    </td>
                    <td>{keybinding.description}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div>
            <div class="app-instructions-section-label">Settings:</div>
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Value</th>
                  <th>Description</th>
                  <th>Hotkey</th>
                </tr>
              </thead>
              <tbody>
                {settings.map((setting) => (
                  <tr>
                    {setting.name && (
                      <td rowSpan={setting.nameRowSpan}>{setting.name}</td>
                    )}
                    {setting.value && <td>{setting.value}</td>}
                    <td>{setting.description}</td>
                    {setting.hotkey !== undefined && (
                      <td rowSpan={setting.hotkeyRowSpan}>
                        {setting.hotkey ? <code>{setting.hotkey}</code> : "-"}
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div>
            <div class="app-instructions-section-label">Calculator Mode:</div>
            <div>
              Calculator mode allows to perform operations between two values.
              The widget is divided in three groups (separated by lines): the
              first two are the operands, the last one holds the result of the
              operation (it cannot be modified manually).
            </div>
            <table>
              <thead>
                <tr>
                  <th>Operation</th>
                  <th>Description</th>
                  <th>Hotkey</th>
                </tr>
              </thead>
              <tbody>
                {operations.map((operation) => (
                  <tr>
                    <td>{operation.name}</td>
                    <td>{operation.description}</td>
                    <td>
                      {operation.hotkey ? <code>{operation.hotkey}</code> : "-"}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </SectionCollapsible>
    </div>
  );
}
