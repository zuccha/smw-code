export type Type = "block" | "patch" | "port" | "sprite" | "tool" | "uberasm";
export const types = ["block", "patch", "port", "sprite", "tool", "uberasm"];

export const typeToString = (type: Type): string => {
  if (type === "block") return "Block";
  if (type === "patch") return "Patch";
  if (type === "port") return "Port";
  if (type === "sprite") return "Sprite";
  if (type === "tool") return "Tool";
  if (type === "uberasm") return "UberASM";
  return type;
};

export const typeToStringPlural = (type: Type): string => {
  if (type === "block") return "Blocks";
  if (type === "patch") return "Patches";
  if (type === "port") return "Ports";
  if (type === "sprite") return "Sprites";
  if (type === "tool") return "Tools";
  if (type === "uberasm") return "UberASM";
  return type;
};

export const typeToDir = (type: Type): string => {
  if (type === "block") return "blocks";
  if (type === "patch") return "patches";
  if (type === "port") return "ports";
  if (type === "sprite") return "sprites";
  if (type === "tool") return "tools";
  if (type === "uberasm") return "uberasm";
  return type;
};

export const isType = (maybeType: string): maybeType is Type =>
  types.includes(maybeType);
