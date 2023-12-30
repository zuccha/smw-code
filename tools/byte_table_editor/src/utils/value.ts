export enum ValueEncoding {
  Binary,
  Decimal,
  Hexadecimal,
}

export enum ValueSize {
  Byte,
  Word,
}

export const ValueBoundaries = {
  [ValueSize.Byte]: { min: 0, max: 255 },
  [ValueSize.Word]: { min: 0, max: 65535 },
} as const;

export const ValueBytes = {
  [ValueSize.Byte]: 1,
  [ValueSize.Word]: 2,
} as const;

export const ValueChars = {
  [ValueEncoding.Binary]: /^[0-1]$/,
  [ValueEncoding.Decimal]: /^[0-9]$/,
  [ValueEncoding.Hexadecimal]: /^[0-9a-fA-F]$/,
} as const;

export const ValueLength = {
  [ValueSize.Byte]: {
    [ValueEncoding.Binary]: 8,
    [ValueEncoding.Decimal]: 3,
    [ValueEncoding.Hexadecimal]: 2,
  },
  [ValueSize.Word]: {
    [ValueEncoding.Binary]: 16,
    [ValueEncoding.Decimal]: 5,
    [ValueEncoding.Hexadecimal]: 4,
  },
} as const;

export const ValuePrefix = {
  [ValueEncoding.Binary]: "%",
  [ValueEncoding.Decimal]: "",
  [ValueEncoding.Hexadecimal]: "$",
} as const;

export const ValueRadix = {
  [ValueEncoding.Binary]: 2,
  [ValueEncoding.Decimal]: 10,
  [ValueEncoding.Hexadecimal]: 16,
} as const;

export const ValueWrite = {
  [ValueSize.Byte]: "db",
  [ValueSize.Word]: "dw",
} as const;

export const valueToString = (
  decimal: number,
  encoding: ValueEncoding,
  size: ValueSize,
  addPrefix = false
): string => {
  const { min, max } = ValueBoundaries[size];
  const length = ValueLength[size][encoding];
  const prefix = addPrefix ? ValuePrefix[encoding] : "";
  const n = Math.max(Math.min(decimal, max), min)
    .toString(ValueRadix[encoding])
    .toUpperCase();
  return `${prefix}${"0".repeat(length - n.length)}${n}`;
};
