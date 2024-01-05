import { forwardRef } from "preact/compat";
import {
  useCallback,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from "preact/hooks";
import { Encoding, Unit, useValue } from "../hooks/use-value";
import { clamp, classNames, lastIndexOf, remove } from "../utils";
import "./editor.css";

export enum InsertMode {
  AddAndShiftRight,
  Replace,
}

export type EditorProps = {
  autoFocus?: boolean;
  encoding: Encoding;
  insertMode: InsertMode;
  integer: number;
  onChange: (integer: number) => void;
  onMoveDown: () => void;
  onMoveUp: () => void;
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
    insertMode,
    integer,
    encoding,
    onChange,
    onMoveDown,
    onMoveUp,
    unit,
  },
  ref
) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [index, setIndex] = useState(0);

  const [value, { parse, validChar }] = useValue(integer, encoding, unit);
  const chars = useMemo(() => value.split(""), [value]);
  const length = value.length;
  const last = useMemo(
    () =>
      Math.max(
        lastIndexOf(chars, (char) => char !== "0"),
        index
      ),
    [chars, index]
  );

  const insertChar = useCallback(
    (char: string) => {
      switch (insertMode) {
        case InsertMode.AddAndShiftRight:
          return [...chars.slice(0, index), char, ...chars.slice(index)];
        case InsertMode.Replace:
          return [...chars.slice(0, index), char, ...chars.slice(index + 1)];
      }
    },
    [chars, index, insertMode]
  );

  const charsToString = useCallback(
    (newChars: string[]): string => newChars.slice(0, length).join(""),
    [length]
  );

  const updateIndex = useCallback(
    (newIndex: number) => setIndex(clamp(newIndex, 0, length - 1)),
    [length]
  );

  const moveLeft = useCallback(
    () => updateIndex(index - 1),
    [index, updateIndex]
  );

  const moveRight = useCallback(
    () => updateIndex(index + 1),
    [index, updateIndex]
  );

  const handleKeyDelete = useCallback(() => {
    const maybeValue = charsToString([...remove(chars, index), "0"]);
    const newInteger = parse(maybeValue, { max: 0 });
    if (newInteger !== undefined) {
      onChange(newInteger);
      updateIndex(index);
    }
  }, [chars, charsToString, index, onChange, parse, updateIndex]);

  const handleKeyBackspace = useCallback(() => {
    if (index === 0) return handleKeyDelete();
    const maybeValue = charsToString([...remove(chars, index - 1), "0"]);
    const newInteger = parse(maybeValue, { max: 0 });
    if (newInteger !== undefined) {
      onChange(newInteger);
      moveLeft();
    }
  }, [chars, charsToString, handleKeyDelete, index, moveLeft, onChange, parse]);

  const handleKeyChar = useCallback(
    (char: string) => {
      const maybeValue = charsToString(insertChar(char));
      const newInteger = parse(maybeValue);
      if (newInteger !== undefined) {
        onChange(newInteger);
        moveRight();
      }
    },
    [charsToString, insertChar, moveRight, onChange, parse]
  );

  const copy = useCallback(() => {
    navigator.clipboard.writeText(value);
  }, [value]);

  const paste = useCallback(() => {
    navigator.clipboard.readText().then((maybeValue) => {
      const newInteger = parse(maybeValue);
      if (newInteger !== undefined) onChange(newInteger);
    });
  }, [onChange, parse]);

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "c") return copy();
      if ((e.ctrlKey || e.metaKey) && e.key === "v") return paste();
      if (e.key === "ArrowDown") return onMoveDown();
      if (e.key === "ArrowUp") return onMoveUp();
      if (e.key === "ArrowLeft") return moveLeft();
      if (e.key === "ArrowRight") return moveRight();
      if (e.key === "Backspace") handleKeyBackspace();
      if (e.key === "Delete") handleKeyDelete();
      if (validChar(e.key)) handleKeyChar(e.key);
    },
    [
      copy,
      handleKeyChar,
      handleKeyDelete,
      handleKeyBackspace,
      moveLeft,
      moveRight,
      onMoveDown,
      onMoveUp,
      validChar,
    ]
  );

  const blur = useCallback(() => containerRef.current?.blur(), []);
  const focus = useCallback(() => containerRef.current?.focus(), []);

  useImperativeHandle(ref, () => ({ blur, copy, focus }), [blur, copy, focus]);

  return (
    <div
      autoFocus={autoFocus}
      class="editor"
      onKeyDown={handleKeyDown}
      ref={containerRef}
      tabIndex={0}
    >
      {chars.map((char, i) => {
        const className = classNames([
          ["editor-char", true],
          ["selected", i === index && i <= last],
          ["solid", i !== index && i <= last],
          ["empty", i !== index && i > last],
        ]);

        const backgroundClassName = classNames([
          ["editor-char-background", true],
          ["selected", i === index],
        ]);

        return (
          <div
            class={className}
            onMouseDown={(e: MouseEvent) => {
              e.preventDefault();
              setIndex(i);
              focus();
            }}
          >
            <div class={backgroundClassName} />
            {char}
          </div>
        );
      })}
    </div>
  );
});
