// Usage: deno run ./.utils/md2/md2html.ts --allow-read --allow-write [-v] <type> <name>
//  -v      Verbose
//  <type>  Resource type, one of: "block" | "patch" | "port" | "sprite" | "tool" | "uberasm"
//  <name>  Name of the resource

import { exists } from "https://deno.land/std@0.193.0/fs/mod.ts";
import { join } from "https://deno.land/std@0.193.0/path/mod.ts";
import {
  normalCase,
  upperFirstCase,
} from "https://deno.land/x/case@2.1.1/mod.ts";
import { CSS, render } from "https://deno.land/x/gfm@0.2.5/mod.ts";
import prettier from "npm:prettier";
import "https://esm.sh/prismjs@1.29.0/components/prism-asm6502?no-check";
import parseArgs from "../args.ts";
import validateResource from "../resource.ts";
import "./assets/syntax_asar.js";
import "./assets/syntax_uberasm.js";

const extraCSS =
  "body{margin:0;}main{max-width:800px;margin:0 auto;padding:1em 1em 4em 1em;}" +
  ".navigation{font-size:0.9em}" +
  "img{width:100% !important;max-width:500px !important;}" +
  "table{margin-left:auto !important;margin-right:auto !important;}";

const generateHtml = async (
  body: string,
  css: string,
  navigation?: string
): Promise<string> =>
  await prettier.format(
    `\
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${css}">
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
`,
    { parser: "html" }
  );

const convertFile = async (
  sourceFile: string,
  targetFile: string,
  cssPath: string,
  navigation?: string
): Promise<void> => {
  const markdown = (await Deno.readTextFile(sourceFile))
    .replace(/\.md\)/g, ".html)")
    .replace(/\/markdown\//g, "/html/");
  const body = render(markdown, { disableHtmlSanitization: true });
  const html = await generateHtml(body, cssPath, navigation);
  if (args.isVerbose) console.log(sourceFile, "->", targetFile);
  await Deno.writeTextFile(targetFile, html);
};

type DocFile = {
  htmlName: string;
  readableName: string;
  markdownPath: string;
  htmlPath: string;
};

const args = parseArgs();
const resource = await validateResource("_dist", args.type, args.name);

await convertFile(
  resource.readme.markdown.path,
  resource.readme.html.path,
  resource.docs.assets.css.relative(resource.path)
);

await convertFile(
  resource.changelog.markdown.path,
  resource.changelog.html.path,
  resource.docs.assets.css.relative(resource.path)
);

await Deno.writeTextFile(resource.docs.assets.css.path, `${CSS}${extraCSS}`);

if (await exists(resource.docs.markdown.path)) {
  const files: DocFile[] = [];
  for await (const dirEntry of Deno.readDir(resource.docs.markdown.path)) {
    const markdownPath = join(resource.docs.markdown.path, dirEntry.name);
    const htmlPath = join(
      resource.docs.html.path,
      dirEntry.name.replace(/md$/, "html")
    );
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

  if (await exists(resource.docs.html.path))
    await Deno.remove(resource.docs.html.path, { recursive: true });
  await Deno.mkdir(resource.docs.html.path);

  files.sort((f1, f2) => {
    if (f1.htmlName > f2.htmlName) return 1;
    if (f1.htmlName < f2.htmlName) return -1;
    return 0;
  });

  for (const file of files) {
    const navigation = [
      `<a href="../../${resource.readme.html.name}">Home</a>`,
      ...files.map((f) =>
        f.htmlName === file.htmlName
          ? f.readableName
          : `<a href="./${f.htmlName}.html">${f.readableName}</a>`
      ),
    ].join(" | ");

    await convertFile(
      file.markdownPath,
      file.htmlPath,
      resource.docs.assets.css.relative(resource.docs.path, ".."),
      navigation
    );
  }
}
