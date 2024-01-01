export enum ValueEncoding {
  Binary,
  Decimal,
  Hexadecimal,
}

export enum ValueUnit {
  Byte,
  Word,
}

export const ValueBoundaries = {
  [ValueUnit.Byte]: { min: 0, max: 255 },
  [ValueUnit.Word]: { min: 0, max: 65535 },
} as const;

export const ValueBytes = {
  [ValueUnit.Byte]: 1,
  [ValueUnit.Word]: 2,
} as const;

export const ValueChars = {
  [ValueEncoding.Binary]: /^[0-1]$/,
  [ValueEncoding.Decimal]: /^[0-9]$/,
  [ValueEncoding.Hexadecimal]: /^[0-9a-fA-F]$/,
} as const;

export const ValueLength = {
  [ValueUnit.Byte]: {
    [ValueEncoding.Binary]: 8,
    [ValueEncoding.Decimal]: 3,
    [ValueEncoding.Hexadecimal]: 2,
  },
  [ValueUnit.Word]: {
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
  [ValueUnit.Byte]: "db",
  [ValueUnit.Word]: "dw",
} as const;

export const valueToString = (
  decimal: number,
  encoding: ValueEncoding,
  unit: ValueUnit,
  addPrefix = false
): string => {
  const { min, max } = ValueBoundaries[unit];
  const length = ValueLength[unit][encoding];
  const prefix = addPrefix ? ValuePrefix[encoding] : "";
  const n = Math.max(Math.min(decimal, max), min)
    .toString(ValueRadix[encoding])
    .toUpperCase();
  return `${prefix}${"0".repeat(length - n.length)}${n}`;
};

export const stringToValue = (
  maybeValue: string,
  encoding: ValueEncoding
): number => {
  return Number.parseInt(maybeValue, ValueRadix[encoding]) || 0;
};
