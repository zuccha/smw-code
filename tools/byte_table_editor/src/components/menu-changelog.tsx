import { Flex, ListItem, Text, UnorderedList } from "@chakra-ui/react";

export default function MenuChangelog() {
  return (
    <Flex direction="column" gap={2}>
      <Text fontWeight="bold">v1.0.0 (2023-12-30)</Text>
      <Text>Added:</Text>
      <UnorderedList>
        <ListItem>Add grid for editing ASM tables.</ListItem>
        <ListItem>
          Allow to create a new table from scratch, by setting width, height,
          and size (byte or word).
        </ListItem>
        <ListItem>Allow to import a table by pasting an existing one.</ListItem>
        <ListItem>
          Allow to export the table by copying it to the clipboard, with
          possibility to customize name, indentation, spaces, and adding labels
          to columns and rows.
        </ListItem>
        <ListItem>
          Allow to switch between binary, decimal, and hexadecimal encodings.
        </ListItem>
        <ListItem>Allow to switch between bytes and words.</ListItem>
        <ListItem>
          Assign background colors to different values and allow to set their
          opacity.
        </ListItem>
        <ListItem>
          Allow to set a background image and to toggle its visibility.
        </ListItem>
        <ListItem>
          Allow to select multiple cells via mouse drag, with multi selection.
        </ListItem>
        <ListItem>
          Allow to select cells with the same value via double click.
        </ListItem>
      </UnorderedList>
    </Flex>
  );
}
