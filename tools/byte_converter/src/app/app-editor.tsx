import { Copy } from "lucide-preact";
import { ReactNode } from "preact/compat";
import Button from "../components/button";

type AppEditor = {
  children: ReactNode;
  label: string;
  onCopy: () => void;
};

export default function AppEditor({ children, label, onCopy }: AppEditor) {
  return (
    <>
      <span class="app-editor-label">{label}</span>
      <div class="app-editor-input">{children}</div>
      <Button isRound label={<Copy size="1.5em" />} onClick={onCopy} />
    </>
  );
}
