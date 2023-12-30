import { Center, Text } from "@chakra-ui/react";
import { useMemo } from "preact/hooks";
import { Colors } from "../utils/color";
import { ValueEncoding, ValueSize, valueToString } from "../utils/value";

export type CellProps = {
  border: number;
  colorOpacity: number;
  encoding: ValueEncoding;
  isSelected: boolean;
  mask: number;
  onDoubleClick: () => void;
  onMouseDown: () => void;
  onMouseOver: () => void;
  onMouseUp: () => void;
  size: ValueSize;
  decimal: number;
};

export const Border = {
  Top: 8,
  Bottom: 4,
  Left: 2,
  Right: 1,
} as const;

export default function Cell({
  border,
  colorOpacity,
  encoding,
  isSelected,
  mask,
  onDoubleClick,
  onMouseDown,
  onMouseOver,
  onMouseUp,
  size,
  decimal,
}: CellProps) {
  const [value, blocks] = useMemo(() => {
    const value = valueToString(decimal, encoding, size);
    return [
      value,
      [value.slice(0, value.length - mask), value.slice(value.length - mask)],
    ];
  }, [decimal, encoding, mask, size]);

  const color = useMemo(() => {
    const opacity = valueToString(
      Math.floor((colorOpacity * 255) / 100),
      ValueEncoding.Hexadecimal,
      ValueSize.Byte
    );
    return `${Colors[decimal % Colors.length]}${opacity}`;
  }, [colorOpacity, decimal]);

  return (
    <Center
      aspectRatio={1}
      backgroundColor={isSelected ? "whiteAlpha.300" : color}
      borderBottomColor={border & Border.Bottom ? "white" : "gray.500"}
      borderLeftColor={border & Border.Left ? "white" : "gray.500"}
      borderRightColor={border & Border.Right ? "white" : "gray.500"}
      borderTopColor={border & Border.Top ? "white" : "gray.500"}
      borderWidth={1}
      boxSizing="border-box"
      color={"gray.400"}
      cursor="pointer"
      flex={1}
      fontFamily="monospace"
      fontSize="md"
      lineHeight={3}
      onDblClick={onDoubleClick}
      onMouseDown={onMouseDown}
      onMouseOver={onMouseOver}
      onMouseUp={onMouseUp}
      textAlign="center"
      userSelect="none"
      wordBreak="break-all"
      _hover={{ borderColor: "white" }}
    >
      {mask > 0 ? (
        <Text>
          {blocks[0]}
          <Text as="span" color="white">
            {blocks[1]}
          </Text>
        </Text>
      ) : (
        <Text>{value}</Text>
      )}
    </Center>
  );
}
