import {
  Button,
  Flex,
  Grid,
  Input,
  Radio,
  RadioGroup,
  Stack,
} from "@chakra-ui/react";
import { ChangeEvent } from "preact/compat";
import { useCallback, useState } from "preact/hooks";
import { useTable } from "../hooks/useStore";
import { ValueUnit } from "../store/value";

export default function MenuNew() {
  const [, render] = useState(0);

  const table = useTable();

  const [height, setHeight] = useState("16");
  const [width, setWidth] = useState("16");
  const [unit, setUnit] = useState(ValueUnit.Byte);

  const isValidGrid = Number.parseInt(height) > 0 && Number.parseInt(width) > 0;

  const handleChangeHeight = useCallback((e: ChangeEvent<HTMLInputElement>) => {
    setHeight(e.currentTarget.value.replace(/\D/g, ""));
    render((count) => count + 1);
  }, []);

  const handleChangeWidth = useCallback((e: ChangeEvent<HTMLInputElement>) => {
    setWidth(e.currentTarget.value.replace(/\D/g, ""));
    render((count) => count + 1);
  }, []);

  const handleChangeSize = useCallback(
    (value: string) => setUnit(parseInt(value)),
    []
  );

  const handleCreateNew = useCallback(() => {
    const heightDecimal = Number.parseInt(height);
    const widthDecimal = Number.parseInt(width);
    if (heightDecimal > 0 && widthDecimal > 0) {
      table.resize(widthDecimal, heightDecimal);
      table.unit.set = unit;
      setHeight("16");
      setWidth("16");
      setUnit(ValueUnit.Byte);
    }
  }, [height, unit, width]);

  return (
    <Flex direction="column" gap={2}>
      <Grid columnGap={8} rowGap={2} templateColumns="auto 1fr">
        <Flex alignItems="center">Unit:</Flex>
        <RadioGroup onChange={handleChangeSize} value={`${unit}`}>
          <Stack direction="row">
            <Radio value={`${ValueUnit.Byte}`}>Byte</Radio>
            <Radio value={`${ValueUnit.Word}`}>Word</Radio>
          </Stack>
        </RadioGroup>

        <Flex alignItems="center">Width:</Flex>
        <Input onChange={handleChangeWidth} placeholder="0" value={width} />

        <Flex alignItems="center">Height:</Flex>
        <Input onChange={handleChangeHeight} placeholder="0" value={height} />
      </Grid>

      <Flex justifyContent="flex-end">
        <Button isDisable={!isValidGrid} onClick={handleCreateNew}>
          Create
        </Button>
      </Flex>
    </Flex>
  );
}
