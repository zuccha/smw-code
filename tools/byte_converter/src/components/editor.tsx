import { forwardRef } from "preact/compat";
import {
  Ref,
  useCallback,
  useImperativeHandle,
  useMemo,
  useRef,
} from "preact/hooks";
import { useValue } from "../hooks/use-value";
import {
  Caret,
  Direction,
  Encoding,
  Focusable,
  Sign,
  SpaceFrequency,
  TypingDirection,
  TypingMode,
  Unit,
  isSign,
} from "../types";
import {
  classNames,
  isPositiveDigit,
  firstIndexOf,
  lastIndexOf,
} from "../utils";
import "./editor.css";

export type EditorProps = {
  autoFocus?: boolean;
  caret: Caret;
  encoding: Encoding;
  integer: number;
  isDisabled?: boolean;
  isSigned?: boolean;
  shouldFlipBitOnClick?: boolean;
  shouldMoveAfterTyping: boolean;
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
  paste: () => void;
};

export default forwardRef<EditorRef, EditorProps>(function Editor(
  {
    autoFocus,
    caret,
    encoding,
    integer,
    isDisabled = false,
    isSigned = false,
    shouldFlipBitOnClick = false,
    shouldMoveAfterTyping,
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

  const [
    digits,
    index,
    sign,
    {
      copy,
      deleteDigit,
      insertDigit,
      isValidDigit,
      jumpTo,
      moveLeft,
      moveRight,
      negate,
      paste,
      removeDigit,
      replaceDigit,
      shiftDigit,
      shiftLeft,
      shiftRight,
    },
  ] = useValue({
    encoding,
    integer,
    isDisabled,
    isReversed: typingDirection === TypingDirection.Left,
    isSigned,
    shouldMoveAfterTyping,
    onChange,
    unit,
  });

  //----------------------------------------------------------------------------
  // Chars Styles
  //----------------------------------------------------------------------------

  const last = useMemo(
    () =>
      typingDirection === TypingDirection.Right
        ? Math.max(lastIndexOf(digits, isPositiveDigit), index - 1)
        : Math.min(firstIndexOf(digits, isPositiveDigit), index),
    [digits, index, typingDirection]
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

  const signClassName = classNames([
    ["editor-char", true],
    ["solid", typingDirection === TypingDirection.Right],
    ["empty", typingDirection === TypingDirection.Left],
  ]);

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

        if (e.shiftKey && e.key === "Backspace") return ok(onChange(0));
        if (e.shiftKey && e.key === "Delete") return ok(onChange(0));

        if (e.key === "ArrowLeft") return ok(moveLeft());
        if (e.key === "ArrowRight") return ok(moveRight());

        if (e.key === ">") return ok(shiftRight());
        if (e.key === "<") return ok(shiftLeft());

        if (e.key === "}") return ok(shiftRight(true));
        if (e.key === "{") return ok(shiftLeft(true));

        if (e.key === " ") return ok(shiftDigit(e.shiftKey ? -1 : 1));

        if (e.key === "!") return ok(negate());

        if (e.key === "Delete") return ok(deleteDigit());
        if (e.key === "Backspace") return ok(removeDigit());

        if (isValidDigit(e.key)) {
          switch (typingMode) {
            case TypingMode.Insert:
              return ok(insertDigit(e.key));
            case TypingMode.Overwrite:
              return ok(replaceDigit(e.key));
          }
        }

        return false;
      };

      if (processKeys()) e.preventDefault();
    },
    [
      copy,
      deleteDigit,
      insertDigit,
      moveLeft,
      moveRight,
      negate,
      onChange,
      refNext,
      refPrev,
      removeDigit,
      replaceDigit,
      shiftLeft,
      shiftRight,
      typingMode,
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

  useImperativeHandle(ref, () => ({ copy, focus, paste }), [
    copy,
    focus,
    paste,
  ]);

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
      {isSign(sign) && (
        <div class={signClassName}>{sign === Sign.Negative ? "-" : "+"}</div>
      )}

      {digits.map((digit, i) => {
        const className = classNames([
          ["editor-char", true],
          ["selected", i === index],
          ["solid", isSolid(i)],
          ["empty", isEmpty(i)],
        ]);

        return (
          <div
            class={className}
            key={i}
            onMouseDown={(e: MouseEvent) => {
              e.preventDefault();
              focus();
              if (isDisabled) return;
              if (shouldFlipBitOnClick && encoding === Encoding.Bin)
                shiftDigit(1, i);
              else jumpTo(i);
            }}
          >
            {digit}
            {!isDisabled && i === index && <div class="editor-caret" />}
          </div>
        );
      })}
    </div>
  );
});
