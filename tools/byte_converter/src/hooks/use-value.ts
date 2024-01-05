import { useCallback, useMemo } from "preact/hooks";

export enum Encoding {
  Binary,
  Decimal,
  Hexadecimal,
}

export enum Unit {
  Byte,
  Word,
}

const Boundaries = {
  [Unit.Byte]: { min: 0, max: 255 },
  [Unit.Word]: { min: 0, max: 65535 },
} as const;

const Chars = {
  [Encoding.Binary]: /^[0-1]$/,
  [Encoding.Decimal]: /^[0-9]$/,
  [Encoding.Hexadecimal]: /^[0-9a-fA-F]$/,
} as const;

const Length = {
  [Unit.Byte]: {
    [Encoding.Binary]: 8,
    [Encoding.Decimal]: 3,
    [Encoding.Hexadecimal]: 2,
  },
  [Unit.Word]: {
    [Encoding.Binary]: 16,
    [Encoding.Decimal]: 5,
    [Encoding.Hexadecimal]: 4,
  },
} as const;

const Radix = {
  [Encoding.Binary]: 2,
  [Encoding.Decimal]: 10,
  [Encoding.Hexadecimal]: 16,
} as const;

export function useValue(
  integer: number,
  encoding: Encoding,
  unit: Unit
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
  const value = useMemo(() => {
    const { min, max } = Boundaries[unit];
    const length = Length[unit][encoding];
    const n = Math.max(Math.min(integer, max), min)
      .toString(Radix[encoding])
      .toUpperCase();
    return `${"0".repeat(length - n.length)}${n}`;
  }, [encoding, integer, unit]);

  const parse = useCallback(
    (
      maybeValue: string,
      bounds?: { min?: number; max?: number }
    ): number | undefined => {
      const i = Number.parseInt(maybeValue, Radix[encoding]);
      const { min, max } = Boundaries[unit];
      bounds = { ...Boundaries[unit], ...bounds };
      if (i < min) return bounds.min;
      if (i > max) return bounds.max;
      return Number.isNaN(i) ? undefined : i;
    },
    [encoding]
  );

  const validChar = useCallback(
    (char: string) => Chars[encoding].test(char),
    [encoding]
  );

  return [value, { parse, validChar }];
}
