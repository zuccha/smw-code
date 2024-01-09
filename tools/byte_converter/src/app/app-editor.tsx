import { Copy, ClipboardPaste } from "lucide-preact";
import { ReactNode } from "preact/compat";
import IconButton from "../components/icon-button";

type AppEditor = {
  children: ReactNode;
  label: string;
  onCopy: () => void;
  onPaste: () => void;
};

export default function AppEditor({
  children,
  label,
  onCopy,
  onPaste,
}: AppEditor) {
  return (
    <>
      <span class="app-editor-label">{label}</span>
      <div class="app-editor-input">{children}</div>
      <div class="app-editor-actions">
        <IconButton
          label={<Copy size="1.5em" />}
          onClick={onCopy}
          tooltip="Copy"
        />
        <IconButton
          label={<ClipboardPaste size="1.5em" />}
          onClick={onPaste}
          tooltip="Paste"
        />
      </div>
    </>
  );
}
