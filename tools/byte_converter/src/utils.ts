import { HexDigit, HexDigits } from "./types";

export function doNothing() {}

export function clamp(n: number, min: number, max: number): number {
  return Math.min(Math.max(n, min), max);
}

export function classNames(options: [string, boolean][]): string {
  return options
    .filter((option) => option[1])
    .map((option) => option[0])
    .join(" ");
}

export function firstIndexOf<T>(
  items: T[],
  predicate: (item: T, index: number) => boolean
): number {
  for (let i = 0; i < items.length; ++i) if (predicate(items[i]!, i)) return i;
  return items.length;
}

export function lastIndexOf<T>(
  items: T[],
  predicate: (item: T, index: number) => boolean
): number {
  for (let i = items.length - 1; i >= 0; --i)
    if (predicate(items[i]!, i)) return i;
  return -1;
}

export function insert<T>(items: T[], index: number, item: T): T[] {
  const end = items.length - 1;
  return [...items.slice(0, index), item, ...items.slice(index, end)];
}

export function replace<T>(items: T[], index: number, item: T): T[] {
  return [...items.slice(0, index), item, ...items.slice(index + 1)];
}

export function remove<T>(items: T[], index: number, fill: T): T[] {
  return [...items.slice(0, index), ...items.slice(index + 1), fill];
}

export function isPositiveDigit(char: string): boolean {
  return char !== "0" && char !== " " && char != "-";
}

export function mod(n: number, m: number): number {
  return ((n % m) + m) % m;
}

export function toggle(value: boolean): boolean {
  return !value;
}

export function range(length: number): number[] {
  return Array.from(Array(length).keys());
}

export function digitToHex(digit: number): HexDigit {
  return HexDigits[digit] ?? "0";
}

export function hexToDigit(hex: string): number {
  return Number.parseInt(hex ?? "0", 16) ?? 0;
}

export function padL(text: string, length: number, fill: string): string {
  return `${fill.repeat(length - text.length)}${text}`;
}

export function padR(text: string, length: number, fill: string): string {
  return `${text}${fill.repeat(length - text.length)}`;
}
