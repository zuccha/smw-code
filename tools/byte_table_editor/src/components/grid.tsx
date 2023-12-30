import { Flex, Image } from "@chakra-ui/react";
import { useCallback, useEffect, useRef } from "preact/hooks";
import useClickOutside from "../hooks/useClickOutside";
import useSelection from "../hooks/useSelection";
import { mapGrid } from "../utils/grid";
import {
  ValueChars,
  ValueEncoding,
  ValueLength,
  ValueRadix,
  ValueSize,
} from "../utils/value";
import Cell, { Border } from "./cell";

export type GridProps = {
  colorOpacity: number;
  encoding: ValueEncoding;
  image: string;
  grid: number[][];
  onChange: (grid: number[][]) => void;
  size: ValueSize;
};

const mod = (n: number, m: number): number => {
  return ((n % m) + m) % m;
};

export default function Grid({
  colorOpacity,
  encoding,
  grid,
  image,
  onChange,
  size,
}: GridProps) {
  const selection = useSelection(grid[0]?.length ?? 0, grid.length);
  const multipleSelection = useRef(false);
  const lastSelected = useRef<undefined | { x: number; y: number }>(undefined);

  const currentValue = useRef("");

  const ref = useRef<HTMLElement>(null);
  useClickOutside(
    ref,
    useCallback(() => {
      selection.clear();
      lastSelected.current = undefined;
      currentValue.current = "";
    }, [selection.clear])
  );

  const updateSelectedCells = useCallback(() => {
    const value =
      Number.parseInt(currentValue.current, ValueRadix[encoding]) || 0;
    onChange(
      mapGrid(grid, (cell, x, y) => (selection.isSelected(x, y) ? value : cell))
    );
  }, [encoding, onChange, selection.isSelected]);

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.metaKey || e.ctrlKey) multipleSelection.current = true;

      if (lastSelected.current) {
        if (e.key === "Enter" || e.key === "Escape") {
          selection.clear();
          lastSelected.current = undefined;
          currentValue.current = "";
          return;
        }

        if (e.key === "Escape") {
          selection.clear();
          lastSelected.current = undefined;
          currentValue.current = "";
          return;
        }

        if (e.key === "Backspace") {
          currentValue.current = currentValue.current.slice(0, -1);
          updateSelectedCells();
          return;
        }

        if (
          ValueChars[encoding].test(e.key) &&
          currentValue.current.length < ValueLength[size][encoding]
        ) {
          currentValue.current += e.key;
          updateSelectedCells();
          return;
        }

        const coords = {
          ArrowDown: {
            x: lastSelected.current.x,
            y: mod(lastSelected.current.y + 1, grid.length),
          },
          ArrowLeft: {
            x: mod(lastSelected.current.x - 1, grid.length),
            y: lastSelected.current.y,
          },
          ArrowRight: {
            x: mod(lastSelected.current.x + 1, grid.length),
            y: lastSelected.current.y,
          },
          ArrowUp: {
            x: lastSelected.current.x,
            y: mod(lastSelected.current.y - 1, grid.length),
          },
        }[e.key];

        if (coords) {
          selection.restart(coords.x, coords.y);
          selection.stop();
          lastSelected.current = coords;
          currentValue.current = "";
          return;
        }
      }
    },
    [encoding, grid, selection.restart, size, updateSelectedCells]
  );

  const handleKeyUp = useCallback((e: KeyboardEvent) => {
    if (!e.metaKey && !e.ctrlKey) multipleSelection.current = false;
  }, []);

  useEffect(() => {
    const clearMultipleSelection = () => (multipleSelection.current = false);

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);
    window.addEventListener("focus", clearMultipleSelection);

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      window.removeEventListener("keyup", handleKeyUp);
      window.removeEventListener("focus", clearMultipleSelection);
    };
  }, [handleKeyDown, handleKeyUp]);

  return (
    <Flex
      borderWidth={1}
      direction="column"
      flex={1}
      minW={500}
      maxW={(grid[0]?.length ?? 0) * 50}
      position="relative"
      ref={ref}
    >
      {image && (
        <Image
          left={0}
          h="100%"
          opacity={0.2}
          position="absolute"
          src={image}
          top={0}
          zIndex={-1}
        />
      )}

      {grid.map((row, y) => (
        <Flex flex={1}>
          {row.map((cell, x) => {
            const isSelected = selection.isSelected(x, y);
            let border = 0;
            if (isSelected) {
              if (!selection.isSelected(x, y - 1)) border |= Border.Top;
              if (!selection.isSelected(x, y + 1)) border |= Border.Bottom;
              if (!selection.isSelected(x - 1, y)) border |= Border.Left;
              if (!selection.isSelected(x + 1, y)) border |= Border.Right;
            }
            return (
              <Cell
                border={border}
                colorOpacity={colorOpacity}
                decimal={cell}
                encoding={encoding}
                isSelected={isSelected}
                mask={isSelected ? currentValue.current.length : 0}
                onDoubleClick={() => {
                  if (!multipleSelection.current) selection.clear();

                  const coords: boolean[][] = [];
                  for (let i = 0; i < grid.length; ++i) {
                    coords.push([]);
                    for (let j = 0; j < grid.length; ++j)
                      coords[i]!.push(grid[i]![j]! === cell);
                  }
                  selection.select(coords);
                }}
                onMouseDown={() => {
                  if (multipleSelection.current) {
                    selection.start(x, y);
                  } else {
                    selection.restart(x, y);
                    lastSelected.current = { x, y };
                    currentValue.current = "";
                  }
                }}
                onMouseOver={() => selection.update(x, y)}
                onMouseUp={() => {
                  selection.stop();
                  lastSelected.current = { x, y };
                }}
                size={size}
              />
            );
          })}
        </Flex>
      ))}
    </Flex>
  );
}
