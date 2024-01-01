import { Center, Text } from "@chakra-ui/react";
import { Ref, useEffect, useMemo, useRef, useState } from "preact/hooks";
import { Colors } from "../store/color";
import { useTableCellIsSelected, useTableCellValue } from "../hooks/useStore";
import Signal from "../store/signal";
import { ValueEncoding, ValueUnit, valueToString } from "../store/value";

export type CellProps = {
  x: number;
  y: number;

  currentValue: Ref<Signal<string>>;

  encoding: ValueEncoding;
  unit: ValueUnit;

  colorOpacity: number;

  onMouseUp: () => void;
  onDoubleClick: () => void;
  onMouseDown: () => void;
  onMouseOver: () => void;
};

const Border = {
  Top: 8,
  Bottom: 4,
  Left: 2,
  Right: 1,
} as const;

export default function Cell({
  x,
  y,
  currentValue,
  encoding,
  unit,
  colorOpacity,
  onDoubleClick,
  onMouseDown,
  onMouseOver,
  onMouseUp,
}: CellProps) {
  const decimal = useTableCellValue(x, y);
  const isSelected = useTableCellIsSelected(x, y);
  const isSelectedB = useTableCellIsSelected(x, y + 1);
  const isSelectedL = useTableCellIsSelected(x - 1, y);
  const isSelectedR = useTableCellIsSelected(x + 1, y);
  const isSelectedT = useTableCellIsSelected(x, y - 1);

  const unsubscribeCurrentValue = useRef<() => void>();
  const [mask, setMask] = useState(
    isSelected ? currentValue.current?.get.length ?? 0 : 0
  );

  useEffect(() => {
    if (isSelected) {
      unsubscribeCurrentValue.current =
        currentValue.current?.subscribe((value) =>
          setMask(value.length ?? 0)
        ) ?? (() => {});
    }
    return () => {
      unsubscribeCurrentValue.current?.();
      unsubscribeCurrentValue.current = undefined;
    };
  }, [isSelected]);

  const border = useMemo(() => {
    let border = 0;
    if (isSelected) {
      if (!isSelectedB) border |= Border.Bottom;
      if (!isSelectedL) border |= Border.Left;
      if (!isSelectedR) border |= Border.Right;
      if (!isSelectedT) border |= Border.Top;
    }
    return border;
  }, [isSelected, isSelectedB, isSelectedL, isSelectedR, isSelectedT]);

  const [value, blocks] = useMemo(() => {
    const value = valueToString(decimal, encoding, unit);
    return [
      value,
      [value.slice(0, value.length - mask), value.slice(value.length - mask)],
    ];
  }, [decimal, encoding, mask, unit]);

  const color = useMemo(() => {
    const opacity = valueToString(
      Math.floor((colorOpacity * 255) / 100),
      ValueEncoding.Hexadecimal,
      ValueUnit.Byte
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
      lineHeight={1}
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
