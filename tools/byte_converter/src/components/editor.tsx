import { forwardRef } from "preact/compat";
import {
  useCallback,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from "preact/hooks";
import useChars from "../hooks/use-chars";
import { useValue } from "../hooks/use-value";
import { Caret, Encoding, TypingDirection, TypingMode, Unit } from "../types";
import {
  classNames,
  differsFrom0,
  firstIndexOf,
  lastIndexOf,
  replace,
} from "../utils";
import "./editor.css";

export type EditorProps = {
  autoFocus?: boolean;
  caret: Caret;
  encoding: Encoding;
  flipBitEnabled?: boolean;
  integer: number;
  moveAfterTypingEnabled: boolean;
  onChange: (integer: number) => void;
  onMoveDown: () => void;
  onMoveUp: () => void;
  typingDirection: TypingDirection;
  typingMode: TypingMode;
  unit: Unit;
};

export type EditorRef = {
  blur: () => void;
  copy: () => void;
  focus: () => void;
};

export default forwardRef<EditorRef, EditorProps>(function Editor(
  {
    autoFocus,
    caret,
    encoding,
    flipBitEnabled = false,
    integer,
    moveAfterTypingEnabled,
    onChange,
    onMoveDown,
    onMoveUp,
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

  const caretClassName = {
    [Caret.Bar]: "caret-bar",
    [Caret.Box]: "caret-box",
    [Caret.Underline]: "caret-underline",
  }[caret];

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

  //----------------------------------------------------------------------------
  // Clipboard
  //----------------------------------------------------------------------------

  const copy = useCallback(() => {
    navigator.clipboard.writeText(value);
  }, [value]);

  const paste = useCallback(() => {
    navigator.clipboard.readText().then((maybeValue) => {
      const newInteger = parse(maybeValue);
      if (newInteger !== undefined) onChange(newInteger);
    });
  }, [onChange, parse]);

  //----------------------------------------------------------------------------
  // Keyboard Event Listener
  //----------------------------------------------------------------------------

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "c") return copy();
      if ((e.ctrlKey || e.metaKey) && e.key === "v") return paste();
      if (e.key === "ArrowDown") return onMoveDown();
      if (e.key === "ArrowUp") return onMoveUp();
      if (e.key === "ArrowLeft") return moveLeft();
      if (e.key === "ArrowRight") return moveRight();
      if (e.key === "Backspace") return update(...removeChar());
      if (e.key === "Delete") return update(...deleteChar());

      if (validChar(e.key)) {
        switch (typingMode) {
          case TypingMode.Insert:
            return update(...insertChar(e.key));
          case TypingMode.Overwrite:
            return update(...replaceChar(e.key));
        }
      }
    },
    [
      copy,
      deleteChar,
      insertChar,
      moveLeft,
      moveRight,
      onMoveDown,
      onMoveUp,
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

  const blur = useCallback(() => containerRef.current?.blur(), []);
  const focus = useCallback(() => containerRef.current?.focus(), []);

  useImperativeHandle(ref, () => ({ blur, copy, focus }), [blur, copy, focus]);

  //----------------------------------------------------------------------------
  // Render
  //----------------------------------------------------------------------------

  return (
    <div
      autoFocus={autoFocus}
      class={`editor ${caretClassName}`}
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
              if (flipBitEnabled && encoding === Encoding.Binary)
                update(replace(chars, i, chars[i] === "0" ? "1" : "0"), i);
              else setIndex(i);
            }}
          >
            {char}
          </div>
        );
      })}

      {0 <= index && index < value.length && (
        <div
          class="editor-caret"
          style={{ left: `calc(${index} * var(--caret-width))` }}
        />
      )}
    </div>
  );
});
