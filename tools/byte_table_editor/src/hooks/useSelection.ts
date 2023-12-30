import { useCallback, useEffect, useMemo, useState } from "preact/hooks";
import { alterGrid, createGrid } from "../utils/grid";

type Rect = {
  minX: number;
  maxX: number;
  minY: number;
  maxY: number;
};

type Selection = {
  clear: () => void;
  isSelected: (x: number, y: number) => boolean;
  restart: (x: number, y: number) => void;
  select: (coords: boolean[][]) => void;
  start: (x: number, y: number) => void;
  stop: () => void;
  update: (x: number, y: number) => void;
};

export default function useSelection(width: number, height: number): Selection {
  const grid = useMemo(() => createGrid(width, height, 0), [width, height]);
  const [rect, setRect] = useState<Rect | undefined>(undefined);
  const [, setRenderCount] = useState(0);
  const rerender = useCallback(() => setRenderCount((c) => c + 1), []);

  useEffect(() => setRect(undefined), [grid]);

  const clear = useCallback(() => {
    alterGrid(grid, () => 0);
    setRect(undefined);
    rerender();
  }, [grid, rerender]);

  const restart = useCallback(
    (x: number, y: number) => {
      alterGrid(grid, () => 0);
      grid[y]![x] = 2;
      setRect({ minX: x, maxX: x, minY: y, maxY: y });
      rerender();
    },
    [grid]
  );

  const select = useCallback(
    (coords: boolean[][]) => {
      alterGrid(grid, (cell, x, y) => (coords[y]?.[x] ? 1 : cell));
      setRect(undefined);
      rerender();
    },
    [grid]
  );

  const start = useCallback(
    (x: number, y: number) => {
      grid[y]![x] = 2;
      setRect({ minX: x, maxX: x, minY: y, maxY: y });
    },
    [grid]
  );

  const stop = useCallback(() => {
    setRect((prevRect) => {
      if (prevRect) alterGrid(grid, (cell) => (cell === 0 ? 0 : 1));
      return undefined;
    });
  }, [grid]);

  const update = useCallback(
    (newX: number, newY: number) => {
      setRect((prevRect) => {
        if (!prevRect) return prevRect;

        alterGrid(grid, (cell) => (cell == 1 ? 1 : 0));

        const minX = Math.min(prevRect.minX, newX);
        const maxX = Math.max(prevRect.maxX, newX);
        const minY = Math.min(prevRect.minY, newY);
        const maxY = Math.max(prevRect.maxY, newY);

        for (let y = minY; y <= maxY; ++y)
          for (let x = minX; x <= maxX; ++x) grid[y]![x] = 2;

        return { maxX, maxY, minX, minY };
      });
    },
    [grid]
  );

  const isSelected = useCallback(
    (x: number, y: number): boolean => {
      return grid[y]?.[x]! > 0;
    },
    [grid, rect]
  );

  return { clear, isSelected, restart, select, start, stop, update };
}
