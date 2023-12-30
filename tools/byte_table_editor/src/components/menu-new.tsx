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
import { createGrid } from "../utils/grid";
import { ValueSize } from "../utils/value";

export type MenuNewProps = {
  onCreateNew: (grid: number[][], valueSize: ValueSize) => void;
};

export default function MenuNew({ onCreateNew }: MenuNewProps) {
  const [, render] = useState(0);

  const [height, setHeight] = useState("16");
  const [width, setWidth] = useState("16");
  const [size, setSize] = useState(ValueSize.Byte);

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
    (value: string) => setSize(parseInt(value)),
    []
  );

  const handleCreateNew = useCallback(() => {
    const heightDecimal = Number.parseInt(height);
    const widthDecimal = Number.parseInt(width);
    if (heightDecimal > 0 && widthDecimal > 0) {
      onCreateNew(createGrid(widthDecimal, heightDecimal, 0), size);
      setHeight("16");
      setWidth("16");
      setSize(ValueSize.Byte);
    }
  }, [height, size, width]);

  return (
    <Flex direction="column" gap={2}>
      <Grid columnGap={8} rowGap={2} templateColumns="auto 1fr">
        <Flex alignItems="center">Size:</Flex>
        <RadioGroup onChange={handleChangeSize} value={`${size}`}>
          <Stack direction="row">
            <Radio value={`${ValueSize.Byte}`}>Byte</Radio>
            <Radio value={`${ValueSize.Word}`}>Word</Radio>
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
