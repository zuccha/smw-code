import Collapsible from "../components/collapsible";

type AppInstructions = {
  isVisible: boolean;
  onChangeVisibility: (isVisible: boolean) => void;
};

const keybindings = [
  { hotkeys: ["<arrows>"], description: "Move across editors" },
  {
    hotkeys: ["ctrl+C", "cmd+C"],
    description: "Copy the value of the focused editor in the clipboard.",
  },
  {
    hotkeys: ["ctrl+V", "cmd+V"],
    description:
      "Paste a value in the focused editor from the clipboard. It won't do anything if the clipboard doesn't contain a valid value.",
  },
  {
    hotkeys: ["H"],
    description: "Toggle settings visibility.",
  },
];

const settings = [
  {
    rowSpan: 2,
    name: "Unit",
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
    rowSpan: 2,
    name: "Typing Mode",
    value: "Insert",
    description: "Insert the typed digit where the selected digit is.",
    hotkey: "I",
  },
  {
    value: "Overwrite",
    description: "Replace the selected digit with the typed digit.",
    hotkey: "O",
  },
  {
    rowSpan: 2,
    name: "Typing Direction",
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
    name: "Move After Typing",
    description:
      "If enabled, after typing a digit, the cursor will move in the relevant direction, otherwise it will stay where it is. Removing a digit with backspace will always move.",
    hotkey: "M",
  },
  {
    name: "Caret",
    value: "Bar, Box, Underline",
    description: "Caret appearance.",
    hotkey: "<none>",
  },
  {
    name: "Hotkeys",
    description:
      "Whether or not hotkeys are enabled. This hotkey is always enabled.",
    hotkey: "K",
  },
];

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
        <p>
          <b>Settings:</b>
        </p>
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
                  <td
                    colSpan={setting.value ? 1 : 2}
                    rowSpan={setting.rowSpan ?? 1}
                  >
                    {setting.name}
                  </td>
                )}
                {setting.value && <td>{setting.value}</td>}
                <td>{setting.description}</td>
                <td>
                  <code>{setting.hotkey}</code>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        <p>
          <b>Generic Keybindings:</b>
        </p>
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
      </Collapsible>
    </div>
  );
}
