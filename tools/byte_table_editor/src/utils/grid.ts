import {
  ValueBytes,
  ValueEncoding,
  ValueLength,
  ValueSize,
  ValueWrite,
  valueToString,
} from "./value";

export enum ColumnComment {
  None,
  ColumnNumberDec,
  ColumnNumberHex,
  ColumnValueHex,
}

export enum RowComment {
  None,
  RowNumberDec,
  RowNumberHex,
  RowRangeHex,
}

export function createGrid<T>(
  width: number,
  height: number,
  defaultValue: T
): T[][] {
  return Array.from({ length: height }, () =>
    Array.from({ length: width }, () => defaultValue)
  );
}

export function mapGrid<T>(
  grid: T[][],
  map: (cell: T, x: number, y: number) => T
): T[][] {
  return grid.map((row, y) => row.map((cell, x) => map(cell, x, y)));
}

export function alterGrid<T>(
  grid: T[][],
  map: (cell: T, x: number, y: number) => T
): void {
  for (let y = 0; y < grid.length; ++y)
    for (let x = 0; x < grid[y]!.length; ++x)
      grid[y]![x] = map(grid[y]![x]!, x, y);
}

const center = (str: string, length: number): string => {
  const prefix = " ".repeat(Math.ceil(Math.max((length - str.length) / 2, 0)));
  const suffix = " ".repeat(Math.floor(Math.max((length - str.length) / 2, 0)));
  return `${prefix}${str}${suffix}`;
};

const pad = (str: string, length: number): string =>
  `${"0".repeat(Math.max(length - str.length, 0))}${str}`;

const getColumnComment = (
  columnComment: ColumnComment,
  columnCount: number,
  valueLength: number,
  valueBytes: number,
  prefixLength: number,
  valueSpacing: number
): string => {
  const prefix = `;${" ".repeat(prefixLength)}`;
  const separator = `${prefix}${"-".repeat(
    valueLength * columnCount + valueSpacing * (columnCount - 1)
  )}\n`;
  switch (columnComment) {
    case ColumnComment.ColumnNumberDec: {
      const columns = Array.from({ length: columnCount }, (_, columnIndex) =>
        center(columnIndex.toString(), valueLength)
      ).join(" ".repeat(valueSpacing));
      return `${prefix}${columns}\n${separator}`;
    }
    case ColumnComment.ColumnNumberHex: {
      const length = columnCount > 256 ? 4 : 2;
      const columns = Array.from({ length: columnCount }, (_, columnIndex) =>
        center(
          `$${pad(columnIndex.toString(16).toUpperCase(), length)}`,
          valueLength
        )
      ).join(" ".repeat(valueSpacing));
      return `${prefix}${columns}\n${separator}`;
    }
    case ColumnComment.ColumnValueHex: {
      const length = columnCount > 256 ? 4 : 2;
      const columns = Array.from({ length: columnCount }, (_, columnIndex) =>
        center(
          `$${pad(
            (columnIndex * valueBytes).toString(16).toUpperCase(),
            length
          )}`,
          valueLength
        )
      ).join(" ".repeat(valueSpacing));
      return `${prefix}${columns}\n${separator}`;
    }
  }
  return "";
};

const getRowComment = (
  rowComment: RowComment,
  rowIndex: number,
  rowCount: number,
  columnCount: number,
  valueBytes: number
): string => {
  switch (rowComment) {
    case RowComment.RowNumberDec: {
      return `; ${rowIndex.toString(10)}`;
    }
    case RowComment.RowNumberHex: {
      const length = rowCount > 256 ? 4 : 2;
      return `; $${pad(rowIndex.toString(16).toUpperCase(), length)}`;
    }
    case RowComment.RowRangeHex: {
      const first = (rowIndex * columnCount * valueBytes)
        .toString(16)
        .toUpperCase();
      const last = ((rowIndex + 1) * columnCount * valueBytes - 1)
        .toString(16)
        .toUpperCase();
      const gridSize = rowCount * columnCount * valueBytes;
      const length = gridSize > 256 ? 4 : 2;
      return `; $${pad(first, length)}-$${pad(last, length)}`;
    }
  }
  return "";
};

export function gridToString(
  grid: number[][],
  valueEncoding: ValueEncoding,
  valueSize: ValueSize,
  rowComment: RowComment,
  columnComment: ColumnComment,
  tableName: string,
  indentation: number,
  addSpaces: boolean
): string {
  const nameRow = tableName ? `${tableName}:\n` : "";
  const headerRow = getColumnComment(
    columnComment,
    grid[0]?.length ?? 0,
    ValueLength[valueSize][valueEncoding] +
      (valueEncoding === ValueEncoding.Decimal ? 0 : 1),
    ValueBytes[valueSize],
    indentation + 2,
    addSpaces ? 2 : 1
  );
  const dataRows = grid
    .map((row, y) => {
      const prefix = " ".repeat(indentation) + ValueWrite[valueSize];
      const cells = row
        .map((cell) => valueToString(cell, valueEncoding, valueSize, true))
        .join(addSpaces ? ", " : ",");
      const comment = getRowComment(
        rowComment,
        y,
        grid.length,
        row.length,
        ValueBytes[valueSize]
      );
      return `${prefix} ${cells} ${comment}`;
    })
    .join("\n");
  return `${nameRow}${headerRow}${dataRows}`;
}

export function stringToGrid(
  maybeGrid: string
): string | [number[][], ValueSize] {
  const rawRows = maybeGrid
    .split("\n")
    .map((row) => row.split(";")[0]!.trim())
    .filter((row) => row.startsWith("db") || row.startsWith("dw"));

  if (
    !rawRows.every((row) => row.startsWith("db")) &&
    !rawRows.every((row) => row.startsWith("dw"))
  )
    return "Values have inconsistent sizes (some are `db`, some are `dw`)";

  const valueSize = rawRows[0]?.startsWith("db")
    ? ValueSize.Byte
    : ValueSize.Word;

  const dataRows = rawRows.map((row) =>
    row
      .substring(3)
      .replace(/\s+/g, "")
      .split(",")
      .filter((cell) => cell)
      .map((cell) => {
        if (cell.startsWith("$")) return Number.parseInt(cell.substring(1), 16);
        if (cell.startsWith("%")) return Number.parseInt(cell.substring(1), 2);
        return Number.parseInt(cell);
      })
  );

  if (dataRows.length === 0 || dataRows.every((row) => row.length === 0))
    return "No values provided";

  const nans: string[] = [];
  dataRows.forEach((row, y) =>
    row.forEach((cell, x) => {
      if (Number.isNaN(cell)) nans.push(`(${x}, ${y})`);
    })
  );
  if (nans.length > 0) return `Invalid values: ${nans.join(", ")}`;

  if (dataRows.some((row) => row.length !== dataRows[0]!.length))
    return "Rows have different number of values";

  return [dataRows, valueSize];
}
