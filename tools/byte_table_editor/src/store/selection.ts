import Grid, { Bounds } from "./grid";
import { Callback } from "./signal";

enum State {
  Unselected,
  Selected,
  SelectedRect,
}

type Rect = {
  x1: number;
  x2: number;
  y1: number;
  y2: number;
};

export default class Selection {
  private _grid: Grid<State>;
  private _rect: Rect | undefined;

  constructor(id: string, width: number, height: number) {
    this._grid = new Grid<State>(`${id}-grid`, width, height, State.Unselected);
    this._rect = undefined;
  }

  resize(width: number, height: number) {
    this._grid.resize(width, height, State.Unselected);
    this._rect = undefined;
  }

  subscribe(x: number, y: number, callback: Callback<boolean>): () => void {
    return this._grid.subscribeSafe(x, y, (state) =>
      callback(state === State.Selected || state === State.SelectedRect)
    );
  }

  clear() {
    this._grid.map(() => State.Unselected);
    this._rect = undefined;
  }

  isSelected(x: number, y: number): boolean {
    const cell = this._grid.getSafe(x, y);
    return cell !== undefined ? cell !== State.Unselected : false;
  }

  select(x: number, y: number) {
    this._grid.set(x, y, State.Selected);
  }

  restart(x: number, y: number) {
    this._grid.map(() => State.Unselected);
    this._grid.set(x, y, State.Selected);
    this._rect = { x1: x, x2: x, y1: y, y2: y };
  }

  start(x: number, y: number) {
    this._grid.set(x, y, State.Selected);
    this._rect = { x1: x, x2: x, y1: y, y2: y };
  }

  stop() {
    if (this._rect) {
      this._grid.mapIf(
        () => State.Selected,
        (cell) => cell === State.SelectedRect,
        this._computeRectBounds()
      );

      this._rect = undefined;
    }
  }

  update(x: number, y: number) {
    if (this._rect) {
      this._grid.mapIf(
        () => State.Unselected,
        (cell) => cell === State.SelectedRect,
        this._computeRectBounds()
      );

      this._rect = { ...this._rect, x2: x, y2: y };
      this._grid.mapIf(
        () => State.SelectedRect,
        (cell) => cell === State.Unselected,
        this._computeRectBounds()
      );
    }
  }

  private _computeRectBounds(): Bounds | undefined {
    return this._rect
      ? {
          xStart: Math.min(this._rect.x1, this._rect.x2),
          xEnd: Math.max(this._rect.x1, this._rect.x2) + 1,
          yStart: Math.min(this._rect.y1, this._rect.y2),
          yEnd: Math.max(this._rect.y1, this._rect.y2) + 1,
        }
      : undefined;
  }
}
