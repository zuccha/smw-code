import { forwardRef } from "preact/compat";
import {
  useCallback,
  useEffect,
  useImperativeHandle,
  useMemo,
} from "preact/hooks";
import { Encoding, Unit, useValue } from "../hooks/use-value";
import { classNames, lastIndexOf } from "../utils";
import "./editor.css";

export enum InsertMode {
  AddAndShiftRight,
  Replace,
}

export type EditorProps = {
  encoding: Encoding;
  hasFocus: boolean;
  index: number;
  insertMode: InsertMode;
  integer: number;
  onChange: (integer: number) => void;
  onChangeIndex: (index: number) => void;
  onMove: (direction: -1 | 1) => void;
  unit: Unit;
};

export type EditorRef = {
  copy: () => void;
};

export default forwardRef<EditorRef, EditorProps>(function Editor(
  {
    hasFocus,
    index,
    insertMode,
    integer,
    encoding,
    onChange,
    onChangeIndex,
    onMove,
    unit,
  },
  ref
) {
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

  const moveLeft = useCallback(() => {
    if (index - 1 >= 0) onChangeIndex(index - 1);
  }, [index, onChangeIndex]);

  const moveRight = useCallback(() => {
    if (index + 1 < length) onChangeIndex(index + 1);
  }, [index, onChangeIndex]);

  const adjust = useCallback(
    (newLength: number) => {
      if (index >= newLength) onChangeIndex(newLength - 1);
    },
    [index, onChangeIndex]
  );

  const handleKeyDelete = useCallback(() => {
    const newChars = [...chars.slice(0, index), ...chars.slice(index + 1), "0"];
    const maybeValue = charsToString(newChars);
    const newInteger = parse(maybeValue, { max: 0 });
    if (newInteger !== undefined) {
      onChange(newInteger);
      adjust(maybeValue.length);
    }
  }, [adjust, chars, charsToString, index, onChange, parse]);

  const handleKeyBackspace = useCallback(() => {
    if (index === 0) return handleKeyDelete();
    const newChars = [...chars.slice(0, index - 1), ...chars.slice(index), "0"];
    const maybeValue = charsToString(newChars);
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
    [adjust, charsToString, insertChar, moveRight, onChange, parse]
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
      if (e.key === "ArrowDown") return onMove(1);
      if (e.key === "ArrowUp") return onMove(-1);
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
      onMove,
      validChar,
    ]
  );

  useEffect(() => {
    if (hasFocus) {
      window.addEventListener("keydown", handleKeyDown);
      return () => {
        window.removeEventListener("keydown", handleKeyDown);
      };
    }
  }, [handleKeyDown, hasFocus]);

  useImperativeHandle(ref, () => ({ copy }), [copy]);

  return (
    <div class="editor">
      {chars.map((char, i) => {
        const className = classNames([
          ["editor-char", true],
          ["editor-char-focus", hasFocus && i === index],
          ["editor-char-solid", hasFocus && i !== index && i <= last],
          ["editor-char-empty", hasFocus && i !== index && i > last],
        ]);

        return (
          <div class={className} onClick={() => onChangeIndex(i)}>
            {char}
          </div>
        );
      })}
    </div>
  );
});
