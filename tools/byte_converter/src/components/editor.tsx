import { forwardRef } from "preact/compat";
import {
  useCallback,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from "preact/hooks";
import useChars, { TypeDirection } from "../hooks/use-chars";
import { Encoding, Unit, useValue } from "../hooks/use-value";
import { classNames, differsFrom0, firstIndexOf, lastIndexOf } from "../utils";
import "./editor.css";

export { TypeDirection } from "../hooks/use-chars";

export enum TypeMode {
  Insert,
  Overwrite,
}

export type EditorProps = {
  autoFocus?: boolean;
  encoding: Encoding;
  integer: number;
  onChange: (integer: number) => void;
  onMoveDown: () => void;
  onMoveUp: () => void;
  typeDirection: TypeDirection;
  typeMode: TypeMode;
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
    integer,
    encoding,
    onChange,
    onMoveDown,
    onMoveUp,
    typeDirection,
    typeMode,
    unit,
  },
  ref
) {
  const containerRef = useRef<HTMLDivElement>(null);

  const [index, setIndex] = useState(0);
  const [value, { parse, validChar }] = useValue(integer, encoding, unit);
  const chars = useMemo(() => value.split(""), [value]);

  const { insertChar, replaceChar, deleteChar, removeChar } = useChars(
    chars,
    index,
    typeDirection
  );

  const last = useMemo(
    () =>
      typeDirection === TypeDirection.Right
        ? Math.max(lastIndexOf(chars, differsFrom0), index)
        : Math.min(firstIndexOf(chars, differsFrom0), index),
    [chars, index, typeDirection]
  );

  const isSolid = useCallback(
    (i: number) =>
      typeDirection === TypeDirection.Right ? i <= last : i >= last,
    [last, typeDirection]
  );

  const isEmpty = useCallback(
    (i: number) =>
      typeDirection === TypeDirection.Right ? i > last : i < last,
    [last, typeDirection]
  );

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
    if (index > 0) setIndex(index - 1);
  }, [index]);

  const moveRight = useCallback(() => {
    if (index < chars.length - 1) setIndex(index + 1);
  }, [chars.length, index]);

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
      if (e.key === "Backspace") return update(...removeChar());
      if (e.key === "Delete") return update(...deleteChar());

      if (validChar(e.key)) {
        switch (typeMode) {
          case TypeMode.Insert:
            return update(...insertChar(e.key));
          case TypeMode.Overwrite:
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
      typeMode,
      update,
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
          ["selected", i === index],
          ["solid", i !== index && isSolid(i)],
          ["empty", i !== index && isEmpty(i)],
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
