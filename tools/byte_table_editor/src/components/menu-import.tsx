import { Button, Flex, Text, Textarea } from "@chakra-ui/react";
import { ChangeEvent } from "preact/compat";
import { useCallback, useState } from "preact/hooks";
import { useTable } from "../hooks/useStore";
import { ValueUnit } from "../store/value";

export default function MenuImport() {
  const table = useTable();

  const [maybeGrid, setMaybeGrid] = useState("");
  const [errorOrGridData, setErrorOrGridData] = useState<
    undefined | string | { items: number[][]; unit: ValueUnit }
  >(undefined);

  const isValidGrid = errorOrGridData && typeof errorOrGridData !== "string";

  const handleChange = useCallback((e: ChangeEvent<HTMLInputElement>) => {
    setMaybeGrid(e.currentTarget.value);
    setErrorOrGridData(
      e.currentTarget.value === ""
        ? undefined
        : table.parse(e.currentTarget.value)
    );
  }, []);

  const handleImport = useCallback(() => {
    if (isValidGrid) {
      table.populate(errorOrGridData.items, errorOrGridData.unit);
      setErrorOrGridData(undefined);
      setMaybeGrid("");
    }
  }, [errorOrGridData, isValidGrid, table]);

  const clear = useCallback(() => {
    setErrorOrGridData(undefined);
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
      {errorOrGridData &&
        (typeof errorOrGridData === "string" ? (
          <Text color="red.400">{errorOrGridData}</Text>
        ) : (
          <Flex gap={2}>
            <Flex gap={1}>
              <Flex fontWeight="bold">Width:</Flex>{" "}
              {errorOrGridData.items[0]?.length ?? 0},
            </Flex>
            <Flex gap={1}>
              <Flex fontWeight="bold">Height:</Flex>{" "}
              {errorOrGridData.items.length},
            </Flex>
            <Flex gap={2}>
              <Flex fontWeight="bold">Unit:</Flex>{" "}
              {errorOrGridData.unit === ValueUnit.Byte ? "Byte" : "Word"}
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
