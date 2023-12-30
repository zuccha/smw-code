import { Flex, Kbd, Link, Text } from "@chakra-ui/react";

export default function MenuAbout() {
  return (
    <Flex direction="column" gap={2}>
      <Text>
        <i>Byte Table Editor</i> v1.0.0, made by zuccha. You can find the code{" "}
        <Link
          color="blue.200"
          href="https://github.com/zuccha/smw-code/"
          target="_blank"
        >
          on this repo
        </Link>
        .
      </Text>
      <Text fontWeight="bold">Instructions</Text>
      <Text>
        To import a table, paste it in the <i>Import</i> menu. Alternatively,
        you can create a new table from the <i>New</i> menu. You cannot resize
        tables.
      </Text>
      <Text>
        Once you're done modifying the table, copy it to the clipboard from the{" "}
        <i>Export</i> menu. There are a few settings to customize the output.
      </Text>
      <Text>
        Click and drag the mouse to select multiple cells. Hold <Kbd>ctrl</Kbd>/
        <Kbd>cmd</Kbd> to select multiple areas.
      </Text>
      <Text>
        Double click on a cell to select all cells with the same value.
      </Text>
    </Flex>
  );
}
