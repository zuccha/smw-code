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

export function differsFrom0(char: string): boolean {
  return char !== "0";
}
