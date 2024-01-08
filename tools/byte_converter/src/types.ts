import { z } from "zod";

//==============================================================================
// Caret
//==============================================================================

export enum Caret {
  Bar,
  Box,
  Underline,
}

export const CaretSchema = z.nativeEnum(Caret);

//==============================================================================
// Typing Direction
//==============================================================================

export enum TypingDirection {
  Left,
  Right,
}

export const TypingDirectionSchema = z.nativeEnum(TypingDirection);

//==============================================================================
// Typing Mode
//==============================================================================

export enum TypingMode {
  Insert,
  Overwrite,
}

export const TypingModeSchema = z.nativeEnum(TypingMode);

//==============================================================================
// Space Frequency
//==============================================================================

export enum SpaceFrequency {
  Digits4,
  Digits8,
  None,
}

export const SpaceFrequencySchema = z.nativeEnum(SpaceFrequency);

//==============================================================================
// Encoding
//==============================================================================

export enum Encoding {
  Bin,
  Dec,
  Hex,
}

export const EncodingSchema = z.nativeEnum(Encoding);

//==============================================================================
// Unit
//==============================================================================

export enum Unit {
  Byte,
  Word,
}

export const UnitSchema = z.nativeEnum(Unit);

//==============================================================================
// Operation
//==============================================================================

export enum Operation {
  Add,
  And,
  Or,
  Subtract,
  Xor,
}

export const OperationSchema = z.nativeEnum(Operation);

//==============================================================================
// Direction
//==============================================================================

export enum Direction {
  Down,
  Left,
  Right,
  Up,
}

export const DirectionSchema = z.nativeEnum(Direction);

//==============================================================================
// Focusable
//==============================================================================

export type Focusable = {
  focus: (direction?: Direction) => boolean;
};

//==============================================================================
// Hex Digits
//==============================================================================

export const HexDigits = [
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
] as const;

export const HexDigitSchema = z.enum(HexDigits);

export type HexDigit = z.infer<typeof HexDigitSchema>;
