import { Button, Flex, Text, Textarea } from "@chakra-ui/react";
import { ChangeEvent } from "preact/compat";
import { useCallback, useState } from "preact/hooks";
import { stringToGrid } from "../utils/grid";
import { ValueSize } from "../utils/value";

export type MenuImportProps = {
  onImport: (grid: number[][], valueSize: ValueSize) => void;
};

export default function MenuImport({ onImport }: MenuImportProps) {
  const [maybeGrid, setMaybeGrid] = useState("");
  const [gridOrError, setGridOrError] = useState<
    undefined | [number[][], ValueSize] | string
  >();

  const isValidGrid = gridOrError && typeof gridOrError !== "string";

  const handleChange = useCallback((e: ChangeEvent<HTMLInputElement>) => {
    setMaybeGrid(e.currentTarget.value);
    setGridOrError(
      e.currentTarget.value === ""
        ? undefined
        : stringToGrid(e.currentTarget.value)
    );
  }, []);

  const handleImport = useCallback(() => {
    if (isValidGrid) {
      onImport(gridOrError[0], gridOrError[1]);
      setMaybeGrid("");
      setGridOrError(undefined);
    }
  }, [gridOrError, isValidGrid, onImport]);

  const clear = useCallback(() => {
    setGridOrError(undefined);
    setMaybeGrid("");
  }, []);

  return (
    <Flex direction="column" gap={2}>
      <Textarea
        onChange={handleChange}
        fontFamily="monospace"
        fontSize="md"
        placeholder="Paste your table here"
        value={maybeGrid}
        wrap="off"
      />
      {gridOrError &&
        (typeof gridOrError === "string" ? (
          <Text color="red.400">{gridOrError}</Text>
        ) : (
          <Flex gap={2}>
            <Flex gap={1}>
              <Flex fontWeight="bold">Width:</Flex>{" "}
              {gridOrError[0][0]?.length ?? 0},
            </Flex>
            <Flex gap={1}>
              <Flex fontWeight="bold">Height:</Flex> {gridOrError[0].length},
            </Flex>
            <Flex gap={2}>
              <Flex fontWeight="bold">Size:</Flex>{" "}
              {gridOrError[1] === ValueSize.Byte ? "Byte" : "Word"}
            </Flex>
          </Flex>
        ))}

      <Flex gap={2} justifyContent="flex-end">
        <Button isDisabled={!maybeGrid} onClick={clear}>
          Clear
        </Button>

        <Button isDisabled={!isValidGrid} onClick={handleImport}>
          Import
        </Button>
      </Flex>
    </Flex>
  );
}
