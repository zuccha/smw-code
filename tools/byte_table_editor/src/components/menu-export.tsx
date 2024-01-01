import {
  Button,
  Checkbox,
  Flex,
  Grid,
  Input,
  Select,
  useToast,
} from "@chakra-ui/react";
import { ChangeEvent } from "preact/compat";
import { useCallback, useState } from "preact/hooks";
import useSetting from "../hooks/useSetting";
import { ColumnComment, RowComment } from "../store/table";
import { useTable } from "../hooks/useStore";

export default function MenuExport() {
  const table = useTable();

  const toast = useToast();
  const [, render] = useState(0);

  const [tableName, setTableName] = useSetting("export-table-name", "");

  const [indentation, setIndentation] = useSetting("export-indentation", "2");

  const [columnComment, setColumnComment] = useSetting(
    "export-column-comment",
    ColumnComment.None
  );

  const [rowComment, setRowComment] = useSetting(
    "export-row-comment",
    RowComment.None
  );

  const [addSpaces, setAddSpaces] = useSetting("export-add-spaces", true);

  const handleChangeTableName = useCallback(
    (e: ChangeEvent<HTMLInputElement>) => {
      setTableName(e.currentTarget.value.replace(/\W/g, ""));
      render((count) => count + 1);
    },
    []
  );

  const handleChangeIndentation = useCallback(
    (e: ChangeEvent<HTMLInputElement>) => {
      setIndentation(e.currentTarget.value.replace(/\D/g, ""));
      render((count) => count + 1);
    },
    []
  );

  const handleChangeColumnComment = useCallback(
    (e: ChangeEvent<HTMLSelectElement>) => {
      setColumnComment(Number.parseInt(e.currentTarget.value));
    },
    []
  );

  const handleChangeRowComment = useCallback(
    (e: ChangeEvent<HTMLSelectElement>) => {
      setRowComment(Number.parseInt(e.currentTarget.value));
    },
    []
  );

  const handleChangeAddSpaces = useCallback(() => {
    setAddSpaces((prevAddSpaces) => !prevAddSpaces);
  }, []);

  const copyToClipboard = useCallback(() => {
    const output = table.serialize(
      rowComment,
      columnComment,
      tableName,
      Number.parseInt(indentation) || 0,
      addSpaces
    );
    navigator.clipboard.writeText(output);
    toast({ title: "Table copied to clipboard" });
  }, [addSpaces, columnComment, indentation, rowComment, table, tableName]);

  return (
    <Flex direction="column" gap={2}>
      <Grid columnGap={8} rowGap={2} templateColumns="auto 1fr">
        <Flex alignItems="center">Table name:</Flex>
        <Input
          onChange={handleChangeTableName}
          placeholder="None"
          value={tableName}
        />

        <Flex alignItems="center">Row indentation:</Flex>
        <Input
          onChange={handleChangeIndentation}
          placeholder="0"
          value={indentation}
        />

        <Flex alignItems="center">Column comment:</Flex>
        <Select onChange={handleChangeColumnComment} value={columnComment}>
          <option value={ColumnComment.None}>None</option>
          <option value={ColumnComment.ColumnNumberDec}>
            Column Number (Dec)
          </option>
          <option value={ColumnComment.ColumnNumberHex}>
            Column Number (Hex)
          </option>
          <option value={ColumnComment.ColumnValueHex}>
            Column Value (Hex)
          </option>
        </Select>

        <Flex alignItems="center">Row comment:</Flex>
        <Select onChange={handleChangeRowComment} value={rowComment}>
          <option value={RowComment.None}>None</option>
          <option value={RowComment.RowNumberDec}>Row Number (Dec)</option>
          <option value={RowComment.RowNumberHex}>Row Number (Hex)</option>
          <option value={RowComment.RowRangeHex}>Row Range (Hex)</option>
        </Select>
      </Grid>

      <Checkbox
        checked={undefined}
        defaultChecked={undefined}
        isChecked={addSpaces}
        onBlur={undefined}
        onChange={handleChangeAddSpaces}
        minH={"40px"}
      >
        Add spaces between values
      </Checkbox>

      <Button onClick={copyToClipboard}>Copy to Clipboard</Button>
    </Flex>
  );
}
