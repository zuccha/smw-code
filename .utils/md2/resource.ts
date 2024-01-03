import { exists } from "https://deno.land/std@0.193.0/fs/mod.ts";
import { join } from "https://deno.land/std@0.193.0/path/mod.ts";
import { isType, typeToDir, typeToString, types } from "./type.ts";

type Item = {
  directory: string;
  name: string;
  path: string;
  relative: (root: string, prefix?: string) => string;
};

type Resource = Item & {
  readme: {
    html: Item;
    markdown: Item;
    text: Item;
  };
  changelog: {
    html: Item;
    markdown: Item;
    text: Item;
  };
  docs: Item & {
    assets: Item & { images: Item; css: Item };
    html: Item;
    markdown: Item;
  };
};

const makeItem = (directory: string, name: string): Item => {
  const path = join(directory, name);
  return {
    directory,
    name,
    path,
    relative: (root: string, prefix = ".") =>
      path.replace(new RegExp(`^${root}`), prefix),
  };
};

export default async function validateResource(
  directory: string,
  type: string,
  name: string
): Promise<Resource> {
  if (!type) {
    console.error(`\
        No project type provided
        Project type must be one of: ${types.join(", ")}`);
    Deno.exit(1);
  }

  if (!isType(type)) {
    console.error(`\
        Invalid type "${type}" provided
        Project type must be one of: ${types.join(", ")}`);
    Deno.exit(1);
  }

  if (!name) {
    console.error(`No project name provided`);
    Deno.exit(1);
  }

  const root = makeItem(join(directory, typeToDir(type)), name);
  const docs = makeItem(root.path, "docs");
  const readmeMarkdown = makeItem(root.path, "README.md");
  const readmeHtml = makeItem(root.path, "README.html");
  const readmeText = makeItem(root.path, "README.txt");
  const changelogMarkdown = makeItem(root.path, "CHANGELOG.md");
  const changelogHtml = makeItem(root.path, "CHANGELOG.html");
  const changelogText = makeItem(root.path, "CHANGELOG.txt");
  const docsMarkdown = makeItem(docs.path, "markdown");
  const docsHtml = makeItem(docs.path, "html");
  const docsAssets = makeItem(docs.path, "assets");
  const docsAssetsImages = makeItem(docsAssets.path, "images");
  const docsAssetsCss = makeItem(docsAssets.path, "markdown.css");

  if (!(await exists(readmeMarkdown.path))) {
    const projectLabel = `${typeToString(type)} project "${name}"`;
    console.error(`\
        ${projectLabel} doesn't have a readme
        Path "${readmeMarkdown}" doesn't exist`);
    Deno.exit(1);
  }

  if (!(await exists(changelogMarkdown.path))) {
    const projectLabel = `${typeToString(type)} project "${name}"`;
    console.error(`\
          ${projectLabel} doesn't have a changelog
          Path "${changelogMarkdown}" doesn't exist`);
    Deno.exit(1);
  }

  return {
    ...root,
    readme: { html: readmeHtml, markdown: readmeMarkdown, text: readmeText },
    changelog: {
      html: changelogHtml,
      markdown: changelogMarkdown,
      text: changelogText,
    },
    docs: {
      ...docs,
      assets: {
        ...docsAssets,
        images: docsAssetsImages,
        css: docsAssetsCss,
      },
      html: docsHtml,
      markdown: docsMarkdown,
    },
  };
}
