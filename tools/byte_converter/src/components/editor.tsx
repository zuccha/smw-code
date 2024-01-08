import { forwardRef } from "preact/compat";
import {
  Ref,
  useCallback,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from "preact/hooks";
import useChars from "../hooks/use-chars";
import { Radix, useValue } from "../hooks/use-value";
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
import {
  classNames,
  differsFrom0,
  digitToHex,
  firstIndexOf,
  hexToDigit,
  lastIndexOf,
  mod,
  replace,
} from "../utils";
import "./editor.css";

export type EditorProps = {
  autoFocus?: boolean;
  caret: Caret;
  encoding: Encoding;
  flipBitEnabled?: boolean;
  integer: number;
  isDisabled?: boolean;
  moveAfterTypingEnabled: boolean;
  onChange: (integer: number) => void;
  refNext?: Ref<Focusable>;
  refPrev?: Ref<Focusable>;
  spaceFrequency: SpaceFrequency;
  typingDirection: TypingDirection;
  typingMode: TypingMode;
  unit: Unit;
};

export type EditorRef = Focusable & {
  copy: () => void;
};

export default forwardRef<EditorRef, EditorProps>(function Editor(
  {
    autoFocus,
    caret,
    encoding,
    flipBitEnabled = false,
    integer,
    isDisabled = false,
    moveAfterTypingEnabled,
    onChange,
    refNext,
    refPrev,
    spaceFrequency,
    typingDirection,
    typingMode,
    unit,
  },
  ref
) {
  //----------------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------------

  const containerRef = useRef<HTMLDivElement>(null);

  const [index, setIndex] = useState(0);
  const [value, { parse, validChar }] = useValue(integer, encoding, unit);
  const chars = useMemo(() => value.split(""), [value]);

  const { insertChar, replaceChar, deleteChar, removeChar } = useChars(
    chars,
    index,
    typingDirection,
    moveAfterTypingEnabled
  );

  //----------------------------------------------------------------------------
  // Chars Styles
  //----------------------------------------------------------------------------

  const last = useMemo(
    () =>
      typingDirection === TypingDirection.Right
        ? Math.max(lastIndexOf(chars, differsFrom0), index - 1)
        : Math.min(firstIndexOf(chars, differsFrom0), index),
    [chars, index, typingDirection]
  );

  const isSolid = useCallback(
    (i: number) =>
      typingDirection === TypingDirection.Right ? i <= last : i >= last,
    [last, typingDirection]
  );

  const isEmpty = useCallback(
    (i: number) =>
      typingDirection === TypingDirection.Right ? i > last : i < last,
    [last, typingDirection]
  );

  const className = classNames([
    ["editor", true],
    [
      {
        [Caret.Bar]: "caret-bar",
        [Caret.Box]: "caret-box",
        [Caret.Underline]: "caret-underline",
      }[caret],
      true,
    ],
    ["disabled", isDisabled],
    ["space-4", spaceFrequency === SpaceFrequency.Digits4],
    ["space-8", spaceFrequency === SpaceFrequency.Digits8],
  ]);

  //----------------------------------------------------------------------------
  // Chars/Index Utilities
  //----------------------------------------------------------------------------

  const update = useCallback(
    (nextChars: string[], nextIndex: number) => {
      const nextInteger = parse(nextChars.join(""), { max: 0 });
      if (nextInteger !== undefined) {
        onChange(nextInteger);
        setIndex(nextIndex);
      }
    },
    [onChange, parse]
  );

  const moveLeft = useCallback(() => {
    const nextIndex = index - 1;
    if (nextIndex < 0) return setIndex(0);
    if (nextIndex >= value.length) return setIndex(value.length - 1);
    setIndex(nextIndex);
  }, [index, value.length]);

  const moveRight = useCallback(() => {
    const nextIndex = index + 1;
    if (nextIndex < 0) return setIndex(0);
    if (nextIndex >= value.length) return setIndex(value.length - 1);
    setIndex(nextIndex);
  }, [index, value.length]);

  const shiftDigit = useCallback(
    (nextIndex: number, shift: number) => {
      const digit = hexToDigit(chars[nextIndex]!);
      const nextChar = digitToHex(mod(digit + shift, Radix[encoding]));
      update(replace(chars, nextIndex, nextChar), nextIndex);
    },
    [chars, encoding]
  );

  //----------------------------------------------------------------------------
  // Clipboard
  //----------------------------------------------------------------------------

  const copy = useCallback(() => {
    navigator.clipboard.writeText(value);
  }, [value]);

  const paste = useCallback(() => {
    if (isDisabled) return;
    navigator.clipboard.readText().then((maybeValue) => {
      const newInteger = parse(maybeValue);
      if (newInteger !== undefined) onChange(newInteger);
    });
  }, [isDisabled, onChange, parse]);

  //----------------------------------------------------------------------------
  // Keyboard Event Listener
  //----------------------------------------------------------------------------

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      const ok = (_: unknown) => true;

      const processKeys = (): boolean => {
        if ((e.ctrlKey || e.metaKey) && e.key === "c") return ok(copy());
        if ((e.ctrlKey || e.metaKey) && e.key === "v") return ok(paste());

        if (e.ctrlKey || e.metaKey) return false;

        if (e.key === "ArrowDown")
          return Boolean(refNext?.current?.focus(Direction.Down));
        if (e.key === "ArrowUp")
          return Boolean(refPrev?.current?.focus(Direction.Up));

        if (isDisabled) return false;

        if (e.key === " ") return ok(shiftDigit(index, e.shiftKey ? -1 : 1));
        if (e.key === "ArrowLeft") return ok(moveLeft());
        if (e.key === "ArrowRight") return ok(moveRight());
        if (e.key === "Backspace") return ok(update(...removeChar()));
        if (e.key === "Delete") return ok(update(...deleteChar()));

        if (validChar(e.key)) {
          switch (typingMode) {
            case TypingMode.Insert:
              return ok(update(...insertChar(e.key)));
            case TypingMode.Overwrite:
              return ok(update(...replaceChar(e.key)));
          }
        }

        return false;
      };

      if (processKeys()) e.preventDefault();
    },
    [
      copy,
      deleteChar,
      index,
      insertChar,
      isDisabled,
      moveLeft,
      moveRight,
      refNext,
      refPrev,
      removeChar,
      replaceChar,
      typingMode,
      update,
      validChar,
    ]
  );

  //----------------------------------------------------------------------------
  // Ref
  //----------------------------------------------------------------------------

  const focus = useCallback(() => {
    if (!containerRef.current) return false;
    containerRef.current.focus();
    return true;
  }, []);

  useImperativeHandle(ref, () => ({ copy, focus }), [copy, focus]);

  //----------------------------------------------------------------------------
  // Render
  //----------------------------------------------------------------------------

  return (
    <div
      autoFocus={autoFocus}
      class={className}
      onKeyDown={handleKeyDown}
      ref={containerRef}
      tabIndex={0}
    >
      {chars.map((char, i) => {
        const className = classNames([
          ["editor-char", true],
          ["selected", i === index],
          ["solid", isSolid(i)],
          ["empty", isEmpty(i)],
        ]);

        return (
          <div
            class={className}
            onMouseDown={(e: MouseEvent) => {
              e.preventDefault();
              focus();
              if (isDisabled) return;
              if (flipBitEnabled && encoding === Encoding.Bin) shiftDigit(i, 1);
              else setIndex(i);
            }}
          >
            {char}
            {!isDisabled && i === index && <div class="editor-caret" />}
          </div>
        );
      })}
    </div>
  );
});
