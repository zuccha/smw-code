import { Ref, useCallback, useImperativeHandle, useRef } from "preact/hooks";
import Editor, { EditorRef } from "../components/editor";
import { Caret, Encoding, TypingDirection, TypingMode, Unit } from "../types";
import AppEditor from "./app-editor";
import { forwardRef } from "preact/compat";

export type AppEditorsProps = {
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
  refNext?: Ref<AppEditorsRef>;
  refPrev?: Ref<AppEditorsRef>;
  typingDirection: TypingDirection;
  typingMode: TypingMode;
  unit: Unit;
};

export type AppEditorsRef = {
  focusFirst: () => void;
  focusLast: () => void;
};

const useEditor = (
  ref: Ref<EditorRef>,
  prevs: (Ref<EditorRef> | Ref<AppEditorsRef> | undefined)[],
  nexts: (Ref<EditorRef> | Ref<AppEditorsRef> | undefined)[]
) => {
  const onMoveUp = useCallback(() => {
    const editor = prevs.find((prev) => prev?.current);
    if (!editor) return;
    if ("focus" in editor.current!) editor.current?.focus();
    else editor.current?.focusLast();
  }, prevs);

  const onMoveDown = useCallback(() => {
    const editor = nexts.find((next) => next?.current);
    if (!editor) return;
    if ("focus" in editor.current!) editor.current?.focus();
    else editor.current?.focusFirst();
  }, nexts);

  const copy = useCallback(() => ref.current?.copy(), [ref]);
  return { copy, onMoveDown, onMoveUp, ref };
};

export default forwardRef<AppEditorsRef, AppEditorsProps>(function AppEditors(
  {
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
    refNext,
    refPrev,
    typingDirection,
    typingMode,
    unit,
  },
  ref
) {
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

  const binRef = useRef<EditorRef>(null);
  const decRef = useRef<EditorRef>(null);
  const hexRef = useRef<EditorRef>(null);

  const bin = isVisibleBin ? binRef : undefined;
  const dec = isVisibleDec ? decRef : undefined;
  const hex = isVisibleHex ? hexRef : undefined;

  const binProps = useEditor(binRef, [refPrev], [dec, hex, refNext]);
  const decProps = useEditor(decRef, [bin, refPrev], [hex, refNext]);
  const hexProps = useEditor(hexRef, [dec, bin, refPrev], [refNext]);

  useImperativeHandle(
    ref,
    () => ({
      focusFirst: () =>
        [bin, dec, hex].find((editor) => editor?.current)?.current?.focus(),
      focusLast: () =>
        [hex, dec, bin].find((editor) => editor?.current)?.current?.focus(),
    }),
    [bin, dec, hex]
  );

  return (
    <>
      {isVisibleBin && (
        <AppEditor label={prefixBin} onCopy={binProps.copy} onClear={onClear}>
          <Editor
            {...props}
            {...binProps}
            encoding={Encoding.Binary}
            autoFocus={autoFocus}
          />
        </AppEditor>
      )}

      {isVisibleDec && (
        <AppEditor label={prefixDec} onCopy={decProps.copy} onClear={onClear}>
          <Editor {...props} {...decProps} encoding={Encoding.Decimal} />
        </AppEditor>
      )}

      {isVisibleHex && (
        <AppEditor label={prefixHex} onCopy={hexProps.copy} onClear={onClear}>
          <Editor {...props} {...hexProps} encoding={Encoding.Hexadecimal} />
        </AppEditor>
      )}
    </>
  );
});
