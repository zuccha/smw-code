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
    description: "Insert the typed digit where the selected digit is.",
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
    name: "Caret",
    value: "Bar, Box, Underline",
    description: "Caret appearance.",
    hotkey: "<none>",
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
                    {setting.hotkey && (
                      <td rowSpan={setting.hotkeyRowSpan}>
                        <code>{setting.hotkey}</code>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div>
            <div class="app-instructions-section-label">
              Generic Keybindings:
            </div>
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
        </div>
      </SectionCollapsible>
    </div>
  );
}
