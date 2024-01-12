// Usage: deno run ./update_summary.ts --allow-read --allow-write <summary_path> <summary_json>
//  <summary_path>  Path of the summary file to be updated
//  <summary_json>  Path of the JSON file containing the info about the summary

import { exists } from "https://deno.land/std@0.193.0/fs/mod.ts";
import { parse } from "https://deno.land/std@0.193.0/flags/mod.ts";
import { z } from "https://deno.land/x/zod@v3.21.4/mod.ts";
import { Type, typeToDir, typeToStringPlural } from "../_shared/type.ts";

const url = "https://github.com/zuccha/smw-code/releases/download";

const args = parse(Deno.args);
const summaryPath = `${args._[0]}`;
const summaryJsonPath = `${args._[1]}`;

if (!summaryPath) {
  console.error(`No summary file provided`);
  Deno.exit(1);
}

if (!summaryJsonPath) {
  console.error(`No summary JSON file provided`);
  Deno.exit(1);
}

if (!(await exists(summaryPath))) {
  console.error(`Path "${summaryPath}" doesn't exist`);
  Deno.exit(1);
}

if (!(await exists(summaryJsonPath))) {
  console.error(`Path "${summaryJsonPath}" doesn't exist`);
  Deno.exit(1);
}

const ResourceSchema = z.object({
  name: z.string(),
  version: z.string(),
  online: z.string().optional(),
  deprecated: z.string().optional(),
});

type Resource = z.infer<typeof ResourceSchema>;

const SummarySchema = z.object({
  blocks: z.record(z.string(), ResourceSchema).default({}),
  ports: z.record(z.string(), ResourceSchema).default({}),
  sprites: z.record(z.string(), ResourceSchema).default({}),
  tools: z.record(z.string(), ResourceSchema).default({}),
  uberasm: z.record(z.string(), ResourceSchema).default({}),
});

type Summary = z.infer<typeof SummarySchema>;

const pad = (text: string, size: number): string =>
  `${text}${" ".repeat(size - text.length)}`;

const createResource = (
  type: Type,
  id: string,
  resource: Resource
): { name: string; download: string; online: string } => {
  if (resource.deprecated) {
    const name = `~[${resource.name}](./${typeToDir(type)}/${id})~`;
    const download = `Deprecated, use _${resource.deprecated}_`;
    const online = "-";
    return { name, download, online };
  }

  const name = `[${resource.name}](./${typeToDir(type)}/${id})`;
  const tag = `${type}%2F${id}%2F${resource.version}`;
  const zip = `${id}-${resource.version}.zip`;
  const download = `[v${resource.version}](${url}/${tag}/${zip})`;
  const online = resource.online ? `[Online](${resource.online})` : "-";
  return { name, download, online };
};

const createSection = (summary: Summary, type: Type): string => {
  const resources = Object.entries(summary[typeToDir(type) as keyof Summary])
    .map((entry) => ({ key: entry[0], value: entry[1] }))
    .sort((resource1, resource2) => {
      if (resource1.value.name < resource2.value.name) return -1;
      if (resource1.value.name > resource2.value.name) return 1;
      return 0;
    });

  if (resources.length === 0) return "";

  const online = resources.some((resource) => resource.value.online);

  const rows = [
    { name: "Name", download: "Download", online: "Online" },
    ...resources.map((resource) =>
      createResource(type, resource.key, resource.value)
    ),
  ];

  const widths = rows.reduce(
    (prevWidths, row) => ({
      name: Math.max(prevWidths.name, row.name.length),
      download: Math.max(prevWidths.download, row.download.length),
      online: Math.max(prevWidths.online, row.online.length),
    }),
    { name: 0, download: 0, online: 0 }
  );

  rows.splice(1, 0, {
    name: "-".repeat(widths.name),
    download: "-".repeat(widths.download),
    online: "-".repeat(widths.online),
  });

  const table = rows
    .map((row) => ({
      name: pad(row.name, widths.name),
      download: pad(row.download, widths.download),
      online: pad(row.online, widths.online),
    }))
    .map((row) =>
      online
        ? `| ${row.name} | ${row.download} | ${row.online} |`
        : `| ${row.name} | ${row.download} |`
    )
    .join("\n");

  return `\n## ${typeToStringPlural(type)}\n\n${table}`;
};

const summary = SummarySchema.parse(
  JSON.parse(await Deno.readTextFile(summaryJsonPath))
);

const output = `\
# SMW Code

A collection of SMW resources.
${createSection(summary, "block")}
${createSection(summary, "sprite")}
${createSection(summary, "uberasm")}
${createSection(summary, "tool")}
${createSection(summary, "port")}
`;

await Deno.writeTextFile(summaryPath, output);
