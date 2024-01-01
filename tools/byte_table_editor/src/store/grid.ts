import Signal, { Callback } from "./signal";

export type Bounds = {
  xStart: number;
  xEnd: number;
  yStart: number;
  yEnd: number;
};

export default class Grid<T> {
  private _id: string;
  private _items: Signal<T>[][] = [];
  private _height: number = 0;
  private _width: number = 0;

  constructor(id: string, width: number, height: number, defaultValue: T) {
    this._id = id;
    this.resize(width, height, defaultValue);
  }

  get height(): number {
    return this._height;
  }

  get width(): number {
    return this._width;
  }

  resize(width: number, height: number, defaultValue: T) {
    this._height = height;
    this._width = width;
    for (let y = 0; y < this._height; ++y) {
      if (!this._items[y]) this._items.push([]);
      for (let x = 0; x < this._width; ++x) {
        if (!this._items[y]![x])
          this._items[y]!.push(
            new Signal(`${this._id}-${x}-${y}`, defaultValue)
          );
        else this._items[y]![x]!.set = defaultValue;
      }
    }
  }

  populate(items: T[][], defaultValue: T) {
    this._height = items.length;
    this._width = Math.max(...items.map((row) => row.length));
    for (let y = 0; y < this._height; ++y) {
      if (!this._items[y]) this._items.push([]);
      for (let x = 0; x < this._width; ++x) {
        if (!this._items[y]![x])
          this._items[y]!.push(
            new Signal(`${this._id}-${x}-${y}`, defaultValue)
          );
        else this._items[y]![x]!.set = items[y]?.[x] ?? defaultValue;
      }
    }
  }

  subscribe(x: number, y: number, callback: Callback<T>): () => void {
    return this._items[y]![x]!.subscribe(callback);
  }

  subscribeSafe(x: number, y: number, callback: Callback<T>): () => void {
    return 0 <= x && x < this._width && 0 <= y && y < this._height
      ? this._items[y]![x]!.subscribe(callback)
      : () => {};
  }

  get(x: number, y: number): T {
    return this._items[y]![x]!.get;
  }

  getSafe(x: number, y: number): T | undefined {
    return 0 <= x && x < this._width && 0 <= y && y < this._height
      ? this._items[y]![x]!.get
      : undefined;
  }

  set(x: number, y: number, value: T): void {
    this._items[y]![x]!.set = value;
  }

  map(mapCell: (cell: T, x: number, y: number) => T, bounds?: Bounds) {
    bounds = this._computeBounds(bounds);
    for (let y = bounds.yStart; y < bounds.yEnd; ++y) {
      for (let x = bounds.xStart; x < bounds.xEnd; ++x) {
        this.set(x, y, mapCell(this.get(x, y), x, y));
      }
    }
  }

  mapIf(
    mapCell: (cell: T, x: number, y: number) => T,
    predicate: (cell: T, x: number, y: number) => boolean,
    bounds?: Bounds
  ) {
    bounds = this._computeBounds(bounds);
    for (let y = bounds.yStart; y < bounds.yEnd; ++y) {
      for (let x = bounds.xStart; x < bounds.xEnd; ++x) {
        if (predicate(this.get(x, y), x, y))
          this.set(x, y, mapCell(this.get(x, y), x, y));
      }
    }
  }

  forEach(
    forEachCell: (cell: T, x: number, y: number) => void,
    bounds?: Bounds
  ) {
    bounds = this._computeBounds(bounds);
    for (let y = bounds.yStart; y < bounds.yEnd; ++y) {
      for (let x = bounds.xStart; x < bounds.xEnd; ++x) {
        forEachCell(this.get(x, y), x, y);
      }
    }
  }

  private _computeBounds(bounds?: Bounds): Bounds {
    return bounds
      ? {
          xStart: Math.max(0, bounds.xStart),
          xEnd: Math.min(this._width, bounds.xEnd),
          yStart: Math.max(0, bounds.yStart),
          yEnd: Math.min(this._height, bounds.yEnd),
        }
      : { xStart: 0, xEnd: this._width, yStart: 0, yEnd: this._height };
  }
}
