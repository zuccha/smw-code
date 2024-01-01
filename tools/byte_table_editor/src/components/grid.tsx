import { Flex, Image } from "@chakra-ui/react";
import { useCallback, useEffect, useRef } from "preact/hooks";
import Cell from "./cell";
import useClickOutside from "../hooks/useClickOutside";
import {
  useColorOpacity,
  useImage,
  useImageIsVisible,
  useSelection,
  useTable,
  useTableEncoding,
  useTableSize,
  useTableUnit,
} from "../hooks/useStore";
import Signal from "../store/signal";
import { ValueChars, ValueLength, stringToValue } from "../store/value";

const mod = (n: number, m: number): number => {
  return ((n % m) + m) % m;
};

const range = (n: number): number[] => {
  return Array.from(Array(n).keys());
};

export default function Grid() {
  const table = useTable();
  const selection = useSelection();
  const [encoding] = useTableEncoding();
  const [unit] = useTableUnit();
  const [size] = useTableSize();

  const [colorOpacity] = useColorOpacity();

  const [image] = useImage();
  const [imageIsVisible] = useImageIsVisible();

  const multipleSelection = useRef(false);
  const lastSelected = useRef<undefined | { x: number; y: number }>(undefined);

  const currentValue = useRef(new Signal("", ""));

  const ref = useRef<HTMLElement>(null);
  useClickOutside(
    ref,
    useCallback(() => {
      selection.clear();
      lastSelected.current = undefined;
      currentValue.current.set = "";
    }, [selection.clear])
  );

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.metaKey || e.ctrlKey) multipleSelection.current = true;

      if (lastSelected.current) {
        if (e.key === "Enter" || e.key === "Escape") {
          selection.clear();
          lastSelected.current = undefined;
          currentValue.current.set = "";
          return;
        }

        if (e.key === "Escape") {
          selection.clear();
          lastSelected.current = undefined;
          currentValue.current.set = "";
          return;
        }

        if (e.key === "Backspace" || e.key === "Delete") {
          currentValue.current.set = currentValue.current.get.slice(0, -1);
          table.setSelected(stringToValue(currentValue.current.get, encoding));
          return;
        }

        if (
          ValueChars[encoding].test(e.key) &&
          currentValue.current.get.length < ValueLength[unit][encoding]
        ) {
          currentValue.current.set = currentValue.current.get + e.key;
          table.setSelected(stringToValue(currentValue.current.get, encoding));
          return;
        }

        const coords = {
          ArrowDown: {
            x: lastSelected.current.x,
            y: mod(lastSelected.current.y + 1, size.height),
          },
          ArrowLeft: {
            x: mod(lastSelected.current.x - 1, size.width),
            y: lastSelected.current.y,
          },
          ArrowRight: {
            x: mod(lastSelected.current.x + 1, size.width),
            y: lastSelected.current.y,
          },
          ArrowUp: {
            x: lastSelected.current.x,
            y: mod(lastSelected.current.y - 1, size.height),
          },
        }[e.key];

        if (coords) {
          selection.restart(coords.x, coords.y);
          selection.stop();
          lastSelected.current = coords;
          currentValue.current.set = "";
          return;
        }
      }
    },
    [encoding, selection, size, unit]
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
      maxW={size.width * 50}
      position="relative"
      ref={ref}
    >
      {imageIsVisible && image && (
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

      {range(size.height).map((y) => (
        <Flex flex={1}>
          {range(size.width).map((x) => (
            <Cell
              x={x}
              y={y}
              currentValue={currentValue}
              encoding={encoding}
              unit={unit}
              colorOpacity={colorOpacity}
              onDoubleClick={() => {
                if (!multipleSelection.current) selection.clear();
                const cell = table.get(x, y);
                table.forEach((otherCell, otherX, otherY) => {
                  if (otherCell === cell) selection.select(otherX, otherY);
                });
              }}
              onMouseDown={() => {
                if (multipleSelection.current) {
                  selection.start(x, y);
                } else {
                  selection.restart(x, y);
                  lastSelected.current = { x, y };
                  currentValue.current.set = "";
                }
              }}
              onMouseOver={() => selection.update(x, y)}
              onMouseUp={() => {
                selection.stop();
                lastSelected.current = { x, y };
              }}
            />
          ))}
        </Flex>
      ))}
    </Flex>
  );
}
