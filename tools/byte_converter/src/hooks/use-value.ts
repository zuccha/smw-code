import { useCallback, useMemo } from "preact/hooks";
import { Encoding, Unit } from "../types";
import { clamp, padL } from "../utils";

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

export function useValue(
  integer: number,
  encoding: Encoding,
  unit: Unit,
  signedEnabled: boolean
): [
  string,
  {
    parse: (
      maybeValue: string,
      bounds?: { min?: number; max?: number }
    ) => number | undefined;
    validChar: (char: string) => boolean;
  }
] {
  const toSigned = useCallback(
    (n: number): number => {
      if (!signedEnabled) return n;
      if (n <= SignedBoundaries[unit].max) return n;
      return -(2 * (SignedBoundaries[unit].max + 1) - n);
    },
    [signedEnabled, unit]
  );

  const fromSigned = useCallback(
    (n: number): number => {
      if (!signedEnabled) return n;
      if (n >= 0) return n;
      return 2 * (SignedBoundaries[unit].max + 1) + n;
    },
    [signedEnabled, unit]
  );

  const value = useMemo(() => {
    const { min, max } = Boundaries[unit];
    const length = Length[unit][encoding];
    const signed = toSigned(clamp(integer, min, max));
    const signedStr = signed.toString(Radix[encoding]).toUpperCase();
    return signed < 0
      ? `-${padL(signedStr.substring(1), length, "0")}`
      : signedEnabled
      ? ` ${padL(signedStr, length, "0")}`
      : padL(signedStr, length, "0");
  }, [encoding, integer, toSigned, unit]);

  const parse = useCallback(
    (
      maybeValue: string,
      bounds?: { min?: number; max?: number }
    ): number | undefined => {
      const signed = Number.parseInt(maybeValue, Radix[encoding]);
      if (Number.isNaN(signed)) return undefined;
      const { min, max } = signedEnabled
        ? SignedBoundaries[unit]
        : Boundaries[unit];
      bounds = { ...Boundaries[unit], ...bounds };
      return fromSigned(clamp(signed, min, max));
    },
    [encoding, fromSigned, signedEnabled, unit]
  );

  const validChar = useCallback(
    (char: string) => Chars[encoding].test(char),
    [encoding]
  );

  return [value, { parse, validChar }];
}
