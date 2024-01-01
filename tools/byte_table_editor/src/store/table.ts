import Grid from "./grid";
import Selection from "./selection";
import Signal, { Callback } from "./signal";
import {
  ValueBytes,
  ValueEncoding,
  ValueLength,
  ValueUnit,
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

const center = (str: string, length: number): string => {
  const prefix = " ".repeat(Math.ceil(Math.max((length - str.length) / 2, 0)));
  const suffix = " ".repeat(Math.floor(Math.max((length - str.length) / 2, 0)));
  return `${prefix}${str}${suffix}`;
};

const pad = (str: string, length: number): string =>
  `${"0".repeat(Math.max(length - str.length, 0))}${str}`;

export default class Table {
  private _grid: Grid<number>;
  readonly encoding: Signal<ValueEncoding>;
  readonly unit: Signal<ValueUnit>;
  readonly size: Signal<{ height: number; width: number }>;
  readonly selection: Selection;

  constructor(id: string, width: number, height: number) {
    this.encoding = new Signal<ValueEncoding>(
      `${id}-encoding`,
      ValueEncoding.Hexadecimal
    );
    this.unit = new Signal<ValueUnit>(`${id}-unit`, ValueUnit.Byte);
    this.size = new Signal(`${id}-size`, { height, width });
    this.selection = new Selection(
      `${id}-selection`,
      this.size.get.width,
      this.size.get.height
    );
    this._grid = new Grid(
      `${id}-grid`,
      this.size.get.width,
      this.size.get.height,
      0
    );
  }

  resize(width: number, height: number) {
    this._grid.resize(width, height, 0);
    this.size.set = { height, width };
    this.selection.resize(width, height);
  }

  populate(items: number[][], unit: ValueUnit) {
    this._grid.populate(items, 0);
    const width = this._grid.width;
    const height = this._grid.height;
    this.size.set = { height, width };
    this.selection.resize(width, height);
    this.unit.set = unit;
  }

  subscribe(x: number, y: number, callback: Callback<number>): () => void {
    return this._grid.subscribe(x, y, callback);
  }

  get(x: number, y: number): number {
    return this._grid.get(x, y);
  }

  set(x: number, y: number, value: number) {
    this._grid.set(x, y, value);
  }

  setSelected(value: number) {
    this._grid.mapIf(
      () => value,
      (_cell, x, y) => this.selection.isSelected(x, y)
    );
  }

  forEach(forEachCell: (cell: number, x: number, y: number) => void) {
    this._grid.forEach(forEachCell);
  }

  parse(maybeGrid: string): string | { items: number[][]; unit: ValueUnit } {
    const rows = maybeGrid
      .split("\n")
      .map((row) => row.split(";")[0]!.trim())
      .filter((row) => row.startsWith("db") || row.startsWith("dw"));

    if (
      !rows.every((row) => row.startsWith("db")) &&
      !rows.every((row) => row.startsWith("dw"))
    )
      return "Values have inconsistent sizes (some are `db`, some are `dw`)";

    const unit = rows[0]?.startsWith("db") ? ValueUnit.Byte : ValueUnit.Word;

    const items = rows.map((row) =>
      row
        .substring(3)
        .replace(/\s+/g, "")
        .split(",")
        .filter((cell) => cell)
        .map((cell) => {
          if (cell.startsWith("$"))
            return Number.parseInt(cell.substring(1), 16);
          if (cell.startsWith("%"))
            return Number.parseInt(cell.substring(1), 2);
          return Number.parseInt(cell);
        })
    );

    if (items.length === 0 || items.every((row) => row.length === 0))
      return "No values provided";

    const nans: string[] = [];
    items.forEach((row, y) =>
      row.forEach((cell, x) => {
        if (Number.isNaN(cell)) nans.push(`(${x}, ${y})`);
      })
    );
    if (nans.length > 0) return `Invalid values: ${nans.join(", ")}`;

    if (items.some((row) => row.length !== items[0]!.length))
      return "Rows have different number of values";

    return { items: items, unit };
  }

  serialize(
    rowComment: RowComment,
    columnComment: ColumnComment,
    tableName: string,
    indentation: number,
    addSpaces: boolean
  ): string {
    const encoding = this.encoding.get;
    const unit = this.unit.get;

    const nameRow = tableName ? `${tableName}:\n` : "";

    const headerRow = this._computeColumnComment(
      columnComment,
      this.size.get.width,
      ValueLength[unit][encoding] +
        (encoding === ValueEncoding.Decimal ? 0 : 1),
      ValueBytes[unit],
      indentation + 2,
      addSpaces ? 2 : 1
    );

    const dataRows: string[] = [];
    const rowPrefix = " ".repeat(indentation) + ValueWrite[unit];
    for (let y = 0; y < this.size.get.height; ++y) {
      const row: string[] = [];
      for (let x = 0; x < this.size.get.width; ++x) {
        row.push(valueToString(this._grid.get(x, y), encoding, unit, true));
      }
      const cells = row.join(addSpaces ? ", " : ",");
      const comment = this._computeRowComment(
        rowComment,
        y,
        this.size.get.height,
        row.length,
        ValueBytes[unit]
      );
      dataRows.push(`${rowPrefix} ${cells} ${comment}`);
    }
    const data = dataRows.join("\n");

    return `${nameRow}${headerRow}${data}`;
  }

  private _computeColumnComment = (
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

  private _computeRowComment = (
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
}
