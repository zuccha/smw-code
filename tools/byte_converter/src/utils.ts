export function classNames(options: [string, boolean][]): string {
  return options
    .filter((option) => option[1])
    .map((option) => option[0])
    .join(" ");
}

export function lastIndexOf<T>(
  items: T[],
  predicate: (item: T, index: number) => boolean
): number {
  for (let i = items.length - 1; i >= 0; --i)
    if (predicate(items[i]!, i)) return i;
  return -1;
}
