import { useCallback, useMemo } from "preact/hooks";
import { TypingDirection } from "../types";
import { insert, remove, replace } from "../utils";

export default function useChars(
  chars: string[],
  index: number,
  typingDirection: TypingDirection,
  moveAfterTypingEnabled: boolean
): {
  insertChar: (char: string) => [string[], number];
  replaceChar: (char: string) => [string[], number];
  deleteChar: () => [string[], number];
  removeChar: () => [string[], number];
  shiftAndReplaceChar: (char: string, shift: number) => [string[], number];
} {
  const prepare = useCallback(
    (nextChars: string[], nextIndex: number): [string[], number] => {
      return typingDirection === TypingDirection.Right
        ? [nextChars, nextIndex]
        : [nextChars.slice().reverse(), nextChars.length - nextIndex - 1];
    },
    [typingDirection]
  );

  const [_chars, _index] = useMemo(
    () => prepare(chars, index),
    [chars, index, prepare]
  );

  const moveRight = useCallback(
    () => Math.min(_chars.length - 1, _index + 1),
    [_chars.length, _index]
  );

  const insertChar = useCallback(
    (char: string): [string[], number] => {
      if (_index < 0) return prepare(_chars, 0);
      if (_index >= _chars.length) return prepare(_chars, _chars.length - 1);
      const nextChars = insert(_chars, _index, char);
      const nextIndex = moveAfterTypingEnabled ? moveRight() : _index;
      return prepare(nextChars, nextIndex);
    },
    [_chars, _index, moveAfterTypingEnabled, moveRight, prepare]
  );

  const replaceChar = useCallback(
    (char: string): [string[], number] => {
      if (_index < 0) return prepare(_chars, 0);
      if (_index >= _chars.length) return prepare(_chars, _chars.length - 1);
      const nextChars = replace(_chars, _index, char);
      const nextIndex = moveAfterTypingEnabled ? moveRight() : _index;
      return prepare(nextChars, nextIndex);
    },
    [_chars, _index, moveAfterTypingEnabled, moveRight, prepare]
  );

  const shiftAndReplaceChar = useCallback(
    (char: string, shift: number): [string[], number] => {
      const nextIndex = _index + shift;
      if (nextIndex < 0) return prepare(_chars, 0);
      if (nextIndex >= _chars.length) return prepare(_chars, _chars.length - 1);
      const nextChars = replace(_chars, nextIndex, char);
      return prepare(nextChars, nextIndex);
    },
    [_chars, _index, prepare]
  );

  const deleteChar = useCallback((): [string[], number] => {
    if (_index < 0) return prepare(_chars, 0);
    if (_index >= _chars.length) return prepare(_chars, _chars.length - 1);
    const nextChars = remove(_chars, _index, "0");
    const nextIndex = _index;
    return prepare(nextChars, nextIndex);
  }, [_chars, _index, prepare]);

  const removeChar = useCallback((): [string[], number] => {
    if (_index < 0) return prepare(_chars, 0);
    if (_index >= _chars.length) return prepare(_chars, _chars.length - 1);
    if (_index === 0) return deleteChar();
    const nextChars = remove(_chars, _index - 1, "0");
    const nextIndex = _index - 1;
    return prepare(nextChars, nextIndex);
  }, [_chars, _index, deleteChar, prepare]);

  return {
    deleteChar,
    insertChar,
    removeChar,
    replaceChar,
    shiftAndReplaceChar,
  };
}
