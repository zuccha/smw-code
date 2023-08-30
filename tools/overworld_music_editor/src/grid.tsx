const ROW_REGEX = /^\s*db\s+((?:\$[0-9a-fA-F]{2}\s*,?\s*){16})/;

export type Cell = string;
export type Row = Cell[];
export type Grid = Row[];

export const gridToString = (grid: Cell[][]): string => {
  return grid
    .map((row) => `db ${row.map((cell) => `$${cell}`).join(", ")}`)
    .join("\n");
};

export const gridFromString = (maybeGrid: string): string | Cell[][] => {
  const grid: Cell[][] = [];

  const maybeRows = maybeGrid
    .split("\n")
    .filter((row) => /^\s*db\s*/.test(row));

  for (let i = 0; i < maybeRows.length; ++i) {
    const maybeRow = maybeRows[i]!;
    const match = maybeRow.match(ROW_REGEX);
    if (match === null)
      return `Line ${i} doesn't have the correct number of elements, or one element is wrong`;

    const newRow = match[1]!
      .split(",")
      .map((cell) => cell.trim().slice(1))
      .filter((cell) => /[0-9a-fA-F]{2}/.test(cell));
    if (newRow.length !== 16)
      return `Line ${i} doesn't have the correct number of elements, or one element is wrong`;

    grid.push(newRow);
  }

  if (grid.length !== 16)
    return `There are not enough rows, only ${grid.length} found`;

  return grid;
};
