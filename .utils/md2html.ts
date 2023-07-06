import { parse } from "https://deno.land/std@0.193.0/flags/mod.ts";
import { exists } from "https://deno.land/std@0.193.0/fs/mod.ts";
import { join } from "https://deno.land/std@0.193.0/path/mod.ts";
import {
  normalCase,
  upperFirstCase,
} from "https://deno.land/x/case@2.1.1/mod.ts";
import { CSS, render } from "https://deno.land/x/gfm@0.2.5/mod.ts";
import "https://esm.sh/prismjs@1.29.0/components/prism-asm6502?no-check";

// Usage in top directory: deno run --allow-read --allow-write [-v] <type> <name>

const extraCSS =
  "body {margin:0;}main{max-width:800px;margin:0 auto;padding:1em 1em 4em 1em;}.navigation{font-size:0.9em}";

const generateHtml = (
  body: string,
  assetsPath: string,
  navigation?: string
): string => `
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${assetsPath}/markdown.css">
  </head>
  <body>
    <div data-color-mode="light" data-light-theme="light" data-dark-theme="dark" class="markdown-body">
      <main>
        ${navigation ? `<div class="navigation">${navigation}</div>` : ""}
        ${body}
      </main>
    </div>
  </body>
</html>
`;

const convertFile = async (
  sourceFile: string,
  targetFile: string,
  assetsPath: string,
  navigation?: string
): Promise<void> => {
  const markdown = (await Deno.readTextFile(sourceFile))
    .replace(/\.md\)/g, ".html)")
    .replace(/\/markdown\//g, "/html/");
  const body = render(markdown, { disableHtmlSanitization: true });
  const html = generateHtml(body, assetsPath, navigation);
  if (isVerbose) console.log(sourceFile, "->", targetFile);
  await Deno.writeTextFile(targetFile, html);
};

type DocFile = {
  htmlName: string;
  readableName: string;
  markdownPath: string;
  htmlPath: string;
};

type Type = "patch" | "uber-asm";

const typeToString = (type: Type): string => {
  if (type === "patch") return "Patch";
  if (type === "uber-asm") return "UberASM";
  return type;
};

const typeToDir = (type: Type): string => {
  if (type === "patch") return "patches";
  if (type === "uber-asm") return "uber-asm";
  return type;
};

const args = parse(Deno.args, { boolean: ["v"] });
const projectType = `${args._[0]}`;
const projectName = `${args._[1]}`;
const isVerbose = args.v;

if (!projectType) {
  console.error(`\
No project type provided
Project type must be one of: patch, uber-asm`);
  Deno.exit(1);
}

if (!projectName) {
  console.error(`No project name provided`);
  Deno.exit(1);
}

if (projectType !== "patch" && projectType !== "uber-asm") {
  console.error(`\
Invalid type "${projectType}" provided
Project type must be one of: patch, uber-asm`);
  Deno.exit(1);
}

const projectPath = join(typeToDir(projectType), projectName);
const projectDocs = join(projectPath, "docs");
const projectReadmeMarkdown = join(projectPath, "README.md");
const projectReadmeHtml = join(projectPath, "README.html");
const projectHtml = join(projectDocs, "html");
const projectMarkdown = join(projectDocs, "markdown");
const projectCSS = join(projectDocs, "assets", "markdown.css");

const projectLabel = `${typeToString(projectType)} project "${projectName}"`;

if (!(await exists(projectReadmeMarkdown))) {
  console.error(`\
${projectLabel} doesn't have a readme
Path "${projectReadmeMarkdown}" doesn't exist`);
  Deno.exit(1);
}

await convertFile(
  projectReadmeMarkdown,
  projectReadmeHtml,
  join("docs", "assets")
);

await Deno.writeTextFile(projectCSS, `${CSS}${extraCSS}`);

if (await exists(projectMarkdown)) {
  const files: DocFile[] = [];
  for await (const dirEntry of Deno.readDir(projectMarkdown)) {
    const markdownPath = join(projectMarkdown, dirEntry.name);
    const htmlPath = join(projectHtml, dirEntry.name.replace(/md$/, "html"));
    if (!dirEntry.isFile) continue;
    if (!markdownPath.endsWith(".md")) continue;
    files.push({
      htmlName: dirEntry.name.replace(/.md$/, ""),
      readableName: upperFirstCase(
        normalCase(dirEntry.name.replace(/.md$/, ""))
      ),
      markdownPath,
      htmlPath,
    });
  }

  if (files.length === 0) Deno.exit(0);

  if (await exists(projectHtml))
    await Deno.remove(projectHtml, { recursive: true });
  await Deno.mkdir(projectHtml);

  for (const file of files) {
    const navigation = [
      `<a href="../../README.html">Home</a>`,
      ...files
        .sort((f1, f2) => {
          if (f1.htmlName > f2.htmlName) return 1;
          if (f1.htmlName < f2.htmlName) return -1;
          return 0;
        })
        .map((f) =>
          f.htmlName === file.htmlName
            ? f.readableName
            : `<a href="./${f.htmlName}.html">${f.readableName}</a>`
        ),
    ].join(" | ");

    await convertFile(
      file.markdownPath,
      file.htmlPath,
      join("..", "assets"),
      navigation
    );
  }

  //   for await (const dirEntry of Deno.readDir(projectMarkdown)) {
  //     const markdownPath = join(projectMarkdown, dirEntry.name);
  //     const htmlPath = join(projectHtml, dirEntry.name.replace(/md$/, "html"));
  //     if (!dirEntry.isFile) continue;
  //     if (!markdownPath.endsWith(".md")) continue;
  //     await convertFile(markdownPath, htmlPath, join("..", "assets"), true);
  //   }
}
