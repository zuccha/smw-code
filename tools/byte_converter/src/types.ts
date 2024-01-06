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
// Encoding
//==============================================================================

export enum Encoding {
  Binary,
  Decimal,
  Hexadecimal,
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
