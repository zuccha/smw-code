import { parse } from "https://deno.land/std@0.193.0/flags/mod.ts";
import { exists } from "https://deno.land/std@0.193.0/fs/mod.ts";
import { join } from "https://deno.land/std@0.193.0/path/mod.ts";

// Usage in top directory: deno run ./.utils/md2text.ts --allow-read --allow-write [-v] <type> <name>

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
  isChangelog?: boolean
): Promise<void> => {
  const text = (await Deno.readTextFile(sourceFile))
    .replace("\n\n\n", "\n")
    .split("\n")
    .map((line): string => {
      if (line.startsWith("####")) return line.replace(/^####/, "");
      if (line.startsWith("###"))
        return isChangelog
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
  if (isVerbose) console.log(sourceFile, "->", targetFile);
  await Deno.writeTextFile(targetFile, text);
};

type Type = "block" | "patch" | "port" | "sprite" | "tool" | "uberasm";
const types = ["block", "patch", "port", "sprite", "tool", "uberasm"];

const typeToString = (type: Type): string => {
  if (type === "block") return "Block";
  if (type === "patch") return "Patch";
  if (type === "port") return "Port";
  if (type === "sprite") return "Sprite";
  if (type === "tool") return "Tool";
  if (type === "uberasm") return "UberASM";
  return type;
};

const typeToDir = (type: Type): string => {
  if (type === "block") return "Blocks";
  if (type === "patch") return "patches";
  if (type === "port") return "ports";
  if (type === "sprite") return "sprites";
  if (type === "tool") return "tools";
  if (type === "uberasm") return "uberasm";
  return type;
};

const isType = (maybeType: string): maybeType is Type =>
  types.includes(maybeType);

const args = parse(Deno.args, { boolean: ["v"] });
const projectType = `${args._[0]}`;
const projectName = `${args._[1]}`;
const isVerbose = args.v;

if (!projectType) {
  console.error(`\
No project type provided
Project type must be one of: ${types.join(", ")}`);
  Deno.exit(1);
}

if (!isType(projectType)) {
  console.error(`\
Invalid type "${projectType}" provided
Project type must be one of: ${types.join(", ")}`);
  Deno.exit(1);
}

if (!projectName) {
  console.error(`No project name provided`);
  Deno.exit(1);
}

const projectPath = join("_dist", typeToDir(projectType), projectName);
const projectReadmeMarkdown = join(projectPath, "README.md");
const projectReadmeText = join(projectPath, "README.txt");
const projectChangelogMarkdown = join(projectPath, "CHANGELOG.md");
const projectChangelogText = join(projectPath, "CHANGELOG.txt");

if (!(await exists(projectReadmeMarkdown))) {
  const projectLabel = `${typeToString(projectType)} project "${projectName}"`;
  console.error(`\
${projectLabel} doesn't have a readme
Path "${projectReadmeMarkdown}" doesn't exist`);
  Deno.exit(1);
}

if (!(await exists(projectChangelogMarkdown))) {
  const projectLabel = `${typeToString(projectType)} project "${projectName}"`;
  console.error(`\
  ${projectLabel} doesn't have a changelog
  Path "${projectChangelogMarkdown}" doesn't exist`);
  Deno.exit(1);
}

await convertFile(projectReadmeMarkdown, projectReadmeText);
await convertFile(projectChangelogMarkdown, projectChangelogText, true);
