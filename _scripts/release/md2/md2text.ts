// Usage: deno run ./md2text.ts --allow-read --allow-write [-v] <root> <type> <name>
//  -v      Verbose
//  <root>  Root directory
//  <type>  Resource type, one of: "block" | "patch" | "port" | "sprite" | "tool" | "uberasm"
//  <name>  Name of the resource

import parseArgs from "../_shared/args.ts";
import validateResource from "../_shared/resource.ts";

const SEPARATOR_1 = "=".repeat(80);
const SEPARATOR_2 = "-".repeat(80);
const SEPARATOR_3 = "~".repeat(80);

const center = (line: string): string => {
  const text = line.replace(/^#/, "").trim().substring(0, 80);
  const spaceLeft = " ".repeat(Math.floor((78 - text.length) / 2));
  const spaceRight = " ".repeat(Math.ceil((78 - text.length) / 2));
  return `|${spaceLeft}${text.toUpperCase()}${spaceRight}|`;
};

const convertFile = async (
  sourceFile: string,
  targetFile: string,
  type: "changelog" | "readme"
): Promise<void> => {
  const text = (await Deno.readTextFile(sourceFile))
    .replace("\n\n\n", "\n")
    .split("\n")
    .map((line): string => {
      if (line.startsWith("####")) return line.replace(/^####/, "");
      if (line.startsWith("###"))
        return type === "changelog"
          ? `${line.replace(/^###/, "").trim()}:`
          : `${SEPARATOR_3}\n${line.replace(/^###/, "#")}\n${SEPARATOR_3}`;
      if (line.startsWith("##"))
        return `\n${SEPARATOR_2}\n${line.replace(/^##/, "#")}\n${SEPARATOR_2}`;
      if (line.startsWith("#"))
        return `${SEPARATOR_1}\n${center(line)}\n${SEPARATOR_1}`;
      return line;
    })
    .map((line) => line.replace(/\[(.*?)\]\((.+?)\)/g, "$1 ($2)"))
    .join("\n");
  if (args.isVerbose) console.log(sourceFile, "->", targetFile);
  await Deno.writeTextFile(targetFile, text);
};

const args = parseArgs();
const resource = await validateResource(args.root, args.type, args.name);

await convertFile(
  resource.readme.markdown.path,
  resource.readme.text.path,
  "readme"
);

await convertFile(
  resource.changelog.markdown.path,
  resource.changelog.text.path,
  "changelog"
);
