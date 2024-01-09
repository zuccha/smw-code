import { Fragment } from "preact";
import SectionCollapsible from "../components/section-collapsible";

type AppInstructions = {
  isVisible: boolean;
  onChangeVisibility: (isVisible: boolean) => void;
};

const actions = [
  {
    name: "Type",
    description:
      "Type a valid digit in the editor. The digit will either be inserted to the right of the cursor, or replace the selected digit depending on which typing mode is selected. Afterwards, the cursor moves to the right.",
    hotkeys: ["<digits>"],
  },
  {
    name: "Delete (DEL)",
    description: "Delete the digit on the right of the cursor.",
    hotkeys: ["DELETE"],
  },
  {
    name: "Backspace (⌫)",
    description:
      "Delete the digit on the left of the cursor, then move the cursor to the left. If the cursors is already all the way to the left, then it will behave like Delete.",
    hotkeys: ["BACKSPACE"],
  },
  {
    name: "Negate (NEG)",
    description:
      "If the selected editor is negative it becomes positive and vice-versa. It works only if it is signed.",
    hotkeys: ["!"],
  },
  {
    name: "Shift Left («)",
    description:
      "Shift the digits of the selected editor to the left. The left-most digit is lost.",
    hotkeys: ["<"],
  },
  {
    name: "Shift Right (»)",
    description:
      "Shift the digits of the selected editor to the right. The right-most digit is lost.",
    hotkeys: [">"],
  },
  {
    name: "Rotate Left (ROL)",
    description:
      "Shift the digits of the selected editor to the left. The left-most digit is carried on the right side.",
    hotkeys: ["{"],
  },
  {
    name: "Rotate Right (ROR)",
    description:
      "Shift the digits of the selected editor to the right. The right-most digit is carried on the left side.",
    hotkeys: ["}"],
  },
  {
    name: "Clear (Cl)",
    description: "Set the value of the selected editor to zero.",
    hotkeys: ["SHIFT+BACKSPACE", "SHIFT+DELETE"],
  },
  {
    name: "Increase (INC)",
    description:
      "Increase the selected digit by one. It wraps around if it exceeds the maximum. In binary, this is the equivalent of a bit flip.",
    hotkeys: ["SPACE"],
  },
  {
    name: "Decrease (DEC)",
    description:
      "Decrease the selected digit by one. It wraps around if it goes below zero. In binary, this is the equivalent of a bit flip.",
    hotkeys: ["SHIFT+SPACE"],
  },
  {
    name: "Movement",
    description: "Move across editors.",
    hotkeys: ["<arrows>"],
  },
  {
    name: "Navigate",
    hotkeys: ["TAB", "SHIFT+TAB"],
    description: "Navigate to the next/previous focusable element.",
  },
  {
    name: "Copy",
    hotkeys: ["CTRL+C", "CMD+C"],
    description:
      "Copy the value of the focused editor in the clipboard. You can also use the button on the right of the editor.",
  },
  {
    name: "Paste",
    hotkeys: ["CTRL+V", "CMD+V"],
    description:
      "Paste a value from the clipboard in the focused editor. You can also use the button on the right of the editor. It won't do anything if the clipboard doesn't contain a valid value.",
  },
];

const operations = [
  {
    name: "Add (+)",
    description: "Add the two operands together.",
    hotkeys: ["+"],
  },
  {
    name: "Subtract (-)",
    description: "Subtract operand 2 from operand 1.",
    hotkeys: ["-"],
  },
  {
    name: "AND",
    description: "Logical AND between the two operands.",
    hotkeys: ["&"],
  },
  {
    name: "OR",
    description: "Logical OR between the two operands.",
    hotkeys: ["|"],
  },
  {
    name: "XOR",
    description: "Logical XOR between the two operands.",
    hotkeys: ["^"],
  },
  {
    name: "Finalize (=)",
    description: "Transfer the result in operand 2.",
    hotkeys: ["="],
  },
  {
    name: "Clear All (CA)",
    description: "Clear all values (set them to 0).",
    hotkeys: ["CTRL+BACKSPACE", "CTRL+DELETE"],
  },
  {
    name: "Swap Operands (↓↑)",
    description: "Swap operand 1 with operand 2.",
    hotkeys: [";"],
  },
];

const settings = [
  // Hotkeys
  {
    name: "Hotkeys",
    nameRowSpan: 2,
    value: "On",
    description: "Settings hotkeys are enabled.",
    hotkey: "K",
    hotkeyRowSpan: 2,
  },
  {
    value: "Off",
    description: "Settings hotkeys are disabled, except for this one.",
  },
  // Functionalities
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
    description:
      "8-bit editing mode. The high byte is preserved and restored once switching back to 16-bit.",
    hotkey: "Y",
  },
  {
    value: "Word",
    description: "16-bit editing mode.",
    hotkey: "W",
  },
  {
    name: "Keyboard",
    value: "None, Compact, Full",
    description:
      "Display a visual keyboard in the widget. Some keys are visible only in calculator mode.",
    hotkey: "",
  },
  // Typing & Cursor
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
  // Signed
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
  // Appearance
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
  {
    name: "Settings",
    value: "-",
    description: "Toggle settings visibility.",
    hotkey: "S",
  },
  {
    name: "Instructions",
    value: "-",
    description: "Toggle instructions visibility.",
    hotkey: "H",
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
            <div>
              Click on a number to edit it. In a group (bin/dec/hex), the
              numbers are connected, editing one will cause the others to
              update. To hide numbers, click on the three toggle buttons on the
              top-right of the group.
            </div>
          </div>

          <div>
            <div class="app-instructions-section-label">Editor Actions:</div>
            <div>
              Actions that can be performed while an editor is selected. Between
              parenthesis, you find the equivalent of the command on the visual
              keyboard.
            </div>
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Description</th>
                  <th>Keybinding</th>
                </tr>
              </thead>
              <tbody>
                {actions.map((action, i) => (
                  <tr key={i}>
                    <td>{action.name}</td>
                    <td>{action.description}</td>
                    <td>
                      {action.hotkeys.map((hotkey, index) => (
                        <Fragment key={index}>
                          <code>{hotkey}</code>
                          {index < action.hotkeys.length - 1 && " "}
                        </Fragment>
                      ))}
                    </td>
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
                  <th>Name</th>
                  <th>Description</th>
                  <th>Keybinding</th>
                </tr>
              </thead>
              <tbody>
                {operations.map((operation, i) => (
                  <tr key={i}>
                    <td>{operation.name}</td>
                    <td>{operation.description}</td>
                    <td>
                      {operation.hotkeys.map((hotkey, index) => (
                        <Fragment key={index}>
                          <code>{hotkey}</code>
                          {index < operation.hotkeys.length - 1 && " "}
                        </Fragment>
                      ))}
                    </td>
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
                {settings.map((setting, i) => (
                  <tr key={i}>
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
        </div>
      </SectionCollapsible>
    </div>
  );
}
