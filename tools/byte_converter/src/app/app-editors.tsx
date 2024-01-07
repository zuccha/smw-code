import { Ref, useCallback, useRef } from "preact/hooks";
import Editor, { EditorRef } from "../components/editor";
import { Caret, Encoding, TypingDirection, TypingMode, Unit } from "../types";
import AppEditor from "./app-editor";

type AppEditorsProps = {
  autoFocus?: boolean;
  caret: Caret;
  flipBitEnabled?: boolean;
  integer: number;
  isDisabled?: boolean;
  isVisibleBin?: boolean;
  isVisibleDec?: boolean;
  isVisibleHex?: boolean;
  moveAfterTypingEnabled: boolean;
  onChange: (integer: number) => void;
  onClear?: () => void;
  prefixBin?: string;
  prefixDec?: string;
  prefixHex?: string;
  typingDirection: TypingDirection;
  typingMode: TypingMode;
  unit: Unit;
};

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

export default function AppEditors({
  autoFocus,
  caret,
  flipBitEnabled,
  integer,
  isDisabled = false,
  isVisibleBin = false,
  isVisibleDec = false,
  isVisibleHex = false,
  moveAfterTypingEnabled,
  onChange,
  onClear,
  prefixBin = "",
  prefixDec = "",
  prefixHex = "",
  typingDirection,
  typingMode,
  unit,
}: AppEditorsProps) {
  const props = {
    caret,
    flipBitEnabled,
    integer,
    isDisabled,
    moveAfterTypingEnabled,
    onChange,
    typingDirection,
    typingMode,
    unit,
  };

  const editorBinRef = useRef<EditorRef>(null);
  const editorDecRef = useRef<EditorRef>(null);
  const editorHexRef = useRef<EditorRef>(null);

  const editorBin = useEditor(editorBinRef, undefined, editorDecRef);
  const editorDec = useEditor(editorDecRef, editorBinRef, editorHexRef);
  const editorHex = useEditor(editorHexRef, editorDecRef, undefined);

  return (
    <>
      {isVisibleBin && (
        <AppEditor label={prefixBin} onCopy={editorBin.copy} onClear={onClear}>
          <Editor
            {...props}
            {...editorBin}
            encoding={Encoding.Binary}
            autoFocus={autoFocus}
          />
        </AppEditor>
      )}

      {isVisibleDec && (
        <AppEditor label={prefixDec} onCopy={editorDec.copy} onClear={onClear}>
          <Editor {...props} {...editorDec} encoding={Encoding.Decimal} />
        </AppEditor>
      )}

      {isVisibleHex && (
        <AppEditor label={prefixHex} onCopy={editorHex.copy} onClear={onClear}>
          <Editor {...props} {...editorHex} encoding={Encoding.Hexadecimal} />
        </AppEditor>
      )}
    </>
  );
}
