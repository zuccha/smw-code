import { Copy, X } from "lucide-preact";
import { ReactNode } from "preact/compat";
import Button from "../components/button";

type AppEditor = {
  children: ReactNode;
  label: string;
  onClear?: () => void;
  onCopy: () => void;
};

export default function AppEditor({
  children,
  label,
  onClear,
  onCopy,
}: AppEditor) {
  return (
    <>
      <span class="app-editor-label">{label}</span>
      <div class="app-editor-input">{children}</div>
      <div class="app-editor-actions">
        <Button isRound label={<Copy size="1.5em" />} onClick={onCopy} />
        {onClear && (
          <Button isRound label={<X size="1.5em" />} onClick={onClear} />
        )}
      </div>
    </>
  );
}
