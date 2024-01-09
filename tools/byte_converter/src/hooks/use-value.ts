import { useCallback, useMemo, useState } from "preact/hooks";
import { Encoding, Sign, Unit, isSign } from "../types";
import {
  clamp,
  digitToHex,
  hexToDigit,
  insert,
  mod,
  ok,
  padL,
  remove,
  replace,
} from "../utils";

export const Boundaries = {
  [Unit.Byte]: { min: 0, max: 255 },
  [Unit.Word]: { min: 0, max: 65535 },
} as const;

export const SignedBoundaries = {
  [Unit.Byte]: { min: -129, max: 127 },
  [Unit.Word]: { min: -32768, max: 32767 },
} as const;

export const Chars = {
  [Encoding.Bin]: /^[0-1]$/,
  [Encoding.Dec]: /^[0-9]$/,
  [Encoding.Hex]: /^[0-9a-fA-F]$/,
} as const;

export const Length = {
  [Unit.Byte]: {
    [Encoding.Bin]: 8,
    [Encoding.Dec]: 3,
    [Encoding.Hex]: 2,
  },
  [Unit.Word]: {
    [Encoding.Bin]: 16,
    [Encoding.Dec]: 5,
    [Encoding.Hex]: 4,
  },
} as const;

export const Radix = {
  [Encoding.Bin]: 2,
  [Encoding.Dec]: 10,
  [Encoding.Hex]: 16,
} as const;

const invertSign = (sign: Sign | undefined): Sign | undefined => {
  return !isSign(sign)
    ? undefined
    : sign === Sign.Positive
    ? Sign.Negative
    : Sign.Positive;
};

const stripSign = (digits: string[]): [string[], Sign | undefined] => {
  if (!isSign(digits[0])) return [digits, undefined];
  return [digits.slice(1), digits[0]];
};

const applySign = (digits: string[], sign: Sign | undefined): string[] => {
  return sign ? [sign, ...digits] : digits;
};

export function useValue({
  encoding,
  integer,
  isDisabled,
  isReversed,
  isSigned,
  shouldMoveAfterTyping,
  onChange,
  unit,
}: {
  integer: number;
  encoding: Encoding;
  isDisabled: boolean;
  isReversed: boolean;
  isSigned: boolean;
  onChange: (integer: number) => void;
  shouldMoveAfterTyping: boolean;
  unit: Unit;
}): [
  string[],
  number,
  Sign | undefined,
  {
    copy: () => void;
    deleteDigit: () => void;
    insertDigit: (digit: string) => void;
    isValidDigit: (digit: string) => boolean;
    jumpTo: (nextIndex: number) => void;
    moveLeft: () => void;
    moveRight: () => void;
    negate: () => void;
    paste: () => void;
    removeDigit: () => void;
    replaceDigit: (digit: string) => void;
    shiftDigit: (shift: number, nextIndex?: number) => void;
    shiftLeft: (withCarry?: boolean) => void;
    shiftRight: (withCarry?: boolean) => void;
  }
] {
  const toSigned = useCallback(
    (n: number): number => {
      if (!isSigned) return n;
      if (n <= SignedBoundaries[unit].max) return n;
      return -(2 * (SignedBoundaries[unit].max + 1) - n);
    },
    [isSigned, unit]
  );

  const fromSigned = useCallback(
    (n: number): number => {
      if (!isSigned) return n;
      if (n >= 0) return n;
      return 2 * (SignedBoundaries[unit].max + 1) + n;
    },
    [isSigned, unit]
  );

  const value = useMemo(() => {
    const { min, max } = Boundaries[unit];
    const length = Length[unit][encoding];
    const signed = toSigned(clamp(integer, min, max));
    const signedStr = signed.toString(Radix[encoding]).toUpperCase();
    return signed < 0
      ? `${Sign.Negative}${padL(signedStr.substring(1), length, "0")}`
      : isSigned
      ? `${Sign.Positive}${padL(signedStr, length, "0")}`
      : padL(signedStr, length, "0");
  }, [encoding, integer, toSigned, unit]);

  const [digits, sign] = useMemo(() => stripSign(value.split("")), [value]);
  const [index, setIndex] = useState(0);

  const parse = useCallback(
    (
      maybeValue: string,
      bounds?: { min?: number; max?: number }
    ): number | undefined => {
      const signed = Number.parseInt(maybeValue, Radix[encoding]);
      if (Number.isNaN(signed)) return undefined;
      const { min, max } = isSigned ? SignedBoundaries[unit] : Boundaries[unit];
      bounds = { ...Boundaries[unit], ...bounds };
      return fromSigned(clamp(signed, min, max));
    },
    [encoding, fromSigned, isSigned, unit]
  );

  const isValidDigit = useCallback(
    (digit: string) => Chars[encoding].test(digit),
    [encoding]
  );

  const decode = useCallback(
    (nextDigits: string[], nextIndex: number): [string[], number] => {
      return isReversed
        ? [nextDigits.slice().reverse(), nextDigits.length - nextIndex - 1]
        : [nextDigits, nextIndex];
    },
    [isReversed]
  );

  const encode = useCallback(
    (nextDigits: string[], nextIndex: number): [string[], number] => {
      return isReversed
        ? [nextDigits.slice().reverse(), nextDigits.length - nextIndex - 1]
        : [nextDigits, nextIndex];
    },
    [isReversed]
  );

  const update = useCallback(
    (nextDigits: string[], nextIndex: number, negate?: boolean) => {
      if (isDisabled) return;
      const nextSign = negate ? invertSign(sign) : sign;
      const nextInteger = parse(applySign(nextDigits, nextSign).join(""));
      if (nextInteger !== undefined) {
        onChange(nextInteger);
        setIndex(nextIndex);
      }
    },
    [isDisabled, onChange, parse, sign]
  );

  const fitIndex = useCallback(
    (nextIndex: number): boolean => {
      if (nextIndex < 0) return ok(setIndex(0));
      if (nextIndex > digits.length - 1) return ok(setIndex(digits.length - 1));
      return false;
    },
    [digits.length, isSigned]
  );

  const jumpTo = useCallback(
    (nextIndex: number) => {
      if (!fitIndex(nextIndex)) setIndex(nextIndex);
    },
    [digits.length, index]
  );

  const moveLeft = useCallback(() => {
    const nextIndex = index - 1;
    if (fitIndex(nextIndex)) return;
    setIndex(nextIndex);
  }, [digits.length, index]);

  const moveRight = useCallback(() => {
    const nextIndex = index + 1;
    if (fitIndex(nextIndex)) return;
    setIndex(nextIndex);
  }, [digits.length, index]);

  const insertDigit = useCallback(
    (digit: string) => {
      if (fitIndex(index)) return;

      const [decodedDigits, decodedIndex] = decode(digits, index);
      if (!isValidDigit(digit)) return;
      const nextDigits = insert(decodedDigits, decodedIndex, digit);
      const nextIndex = shouldMoveAfterTyping
        ? Math.min(decodedDigits.length - 1, decodedIndex + 1)
        : decodedIndex;
      update(...encode(nextDigits, nextIndex));
    },
    [digits, decode, encode, index, isValidDigit, shouldMoveAfterTyping, update]
  );

  const replaceDigit = useCallback(
    (digit: string) => {
      if (fitIndex(index)) return;

      const [decodedDigits, decodedIndex] = decode(digits, index);
      if (!isValidDigit(digit)) return;
      const nextDigits = replace(decodedDigits, decodedIndex, digit);
      const nextIndex = shouldMoveAfterTyping
        ? Math.min(decodedDigits.length - 1, decodedIndex + 1)
        : decodedIndex;
      update(...encode(nextDigits, nextIndex));
    },
    [digits, decode, encode, index, isValidDigit, shouldMoveAfterTyping, update]
  );

  const deleteDigit = useCallback(() => {
    if (fitIndex(index)) return;

    const [decodedDigits, decodedIndex] = decode(digits, index);
    const nextNextDigits = remove(decodedDigits, decodedIndex, "0");
    const nextIndex = decodedIndex;
    update(...encode(nextNextDigits, nextIndex));
  }, [digits, decode, encode, index, update]);

  const removeDigit = useCallback(() => {
    if (fitIndex(index)) return;

    const [decodedDigits, decodedIndex] = decode(digits, index);
    if (decodedIndex === 0) return deleteDigit();
    const nextChars = remove(decodedDigits, decodedIndex - 1, "0");
    const nextIndex = decodedIndex - 1;
    update(...encode(nextChars, nextIndex));
  }, [digits, decode, deleteDigit, encode, index, update]);

  const negate = useCallback(() => {
    update(digits, index, true);
  }, [digits, index, update]);

  const shiftLeft = useCallback(
    (withCarry = false) => {
      const carry = withCarry ? digits[0]! : "0";
      update([...digits.slice(1), carry], index);
    },
    [digits, index, update]
  );

  const shiftRight = useCallback(
    (withCarry = false) => {
      const carry = withCarry ? digits[digits.length - 1]! : "0";
      const end = digits.length - 1;
      update([carry, ...digits.slice(0, end)], index);
    },
    [digits, index, update]
  );

  const shiftDigit = useCallback(
    (shift: number, nextIndex?: number) => {
      nextIndex = nextIndex ?? index;
      const digit = hexToDigit(digits[nextIndex]!);
      const nextDigit = digitToHex(mod(digit + shift, Radix[encoding]));
      update(replace(digits, nextIndex, nextDigit), nextIndex);
    },
    [digits, encoding, index, update]
  );

  const copy = useCallback(() => {
    navigator.clipboard.writeText(value);
  }, [value]);

  const paste = useCallback(() => {
    navigator.clipboard.readText().then((maybeValue) => {
      if (isDisabled) return;
      const newInteger = parse(maybeValue);
      if (newInteger !== undefined) onChange(newInteger);
    });
  }, [isDisabled, onChange, parse]);

  return [
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
  ];
}
