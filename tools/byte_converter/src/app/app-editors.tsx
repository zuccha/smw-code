import {
  Ref,
  useCallback,
  useImperativeHandle,
  useMemo,
  useRef,
} from "preact/hooks";
import Editor, { EditorRef } from "../components/editor";
import {
  Caret,
  Direction,
  Encoding,
  Focusable,
  SpaceFrequency,
  TypingDirection,
  TypingMode,
  Unit,
} from "../types";
import AppEditor from "./app-editor";
import { forwardRef } from "preact/compat";

export type AppEditorsProps = {
  autoFocus?: boolean;
  caret: Caret;
  integer: number;
  isDisabled?: boolean;
  isSignedBin?: boolean;
  isSignedDec?: boolean;
  isSignedHex?: boolean;
  isVisibleBin?: boolean;
  isVisibleDec?: boolean;
  isVisibleHex?: boolean;
  onChange: (integer: number) => void;
  prefixBin?: string;
  prefixDec?: string;
  prefixHex?: string;
  refNext?: Ref<AppEditorsRef>;
  refPrev?: Ref<AppEditorsRef>;
  shouldFlipBitOnClick: boolean;
  shouldMoveAfterTyping: boolean;
  spaceFrequency: SpaceFrequency;
  typingDirection: TypingDirection;
  typingMode: TypingMode;
  unit: Unit;
};

export type AppEditorsRef = Focusable;

const useEditor = (
  ref: Ref<EditorRef>,
  prevs: (Ref<Focusable> | undefined)[],
  nexts: (Ref<Focusable> | undefined)[]
) => {
  const refNext = useMemo(() => nexts.find(Boolean), nexts);
  const refPrev = useMemo(() => prevs.find(Boolean), prevs);
  const copy = useCallback(() => ref.current?.copy(), [ref]);
  const paste = useCallback(() => ref.current?.paste(), [ref]);
  return { copy, paste, ref, refNext, refPrev };
};

export default forwardRef<AppEditorsRef, AppEditorsProps>(function AppEditors(
  {
    autoFocus,
    caret,
    integer,
    isDisabled = false,
    isSignedBin = false,
    isSignedDec = false,
    isSignedHex = false,
    isVisibleBin = false,
    isVisibleDec = false,
    isVisibleHex = false,
    onChange,
    prefixBin = "",
    prefixDec = "",
    prefixHex = "",
    refNext,
    refPrev,
    shouldFlipBitOnClick,
    shouldMoveAfterTyping,
    spaceFrequency,
    typingDirection,
    typingMode,
    unit,
  },
  ref
) {
  const props = {
    caret,
    integer,
    isDisabled,
    onChange,
    shouldFlipBitOnClick,
    shouldMoveAfterTyping,
    spaceFrequency,
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
      focus: (direction?: Direction): boolean => {
        switch (direction) {
          case Direction.Down:
            const nexts = [bin, dec, hex, refNext];
            return Boolean(nexts.find(Boolean)?.current?.focus(Direction.Down));
          case Direction.Up:
            const prevs = [hex, dec, bin, refPrev];
            return Boolean(prevs.find(Boolean)?.current?.focus(Direction.Up));
        }
        return false;
      },
    }),
    [bin, dec, hex, refNext, refPrev]
  );

  return (
    <>
      {isVisibleBin && (
        <AppEditor
          label={prefixBin}
          onCopy={binProps.copy}
          onPaste={binProps.paste}
        >
          <Editor
            {...props}
            {...binProps}
            autoFocus={autoFocus}
            encoding={Encoding.Bin}
            isSigned={isSignedBin}
          />
        </AppEditor>
      )}

      {isVisibleDec && (
        <AppEditor
          label={prefixDec}
          onCopy={decProps.copy}
          onPaste={decProps.paste}
        >
          <Editor
            {...props}
            {...decProps}
            encoding={Encoding.Dec}
            isSigned={isSignedDec}
          />
        </AppEditor>
      )}

      {isVisibleHex && (
        <AppEditor
          label={prefixHex}
          onCopy={hexProps.copy}
          onPaste={hexProps.paste}
        >
          <Editor
            {...props}
            {...hexProps}
            encoding={Encoding.Hex}
            isSigned={isSignedHex}
          />
        </AppEditor>
      )}
    </>
  );
});
