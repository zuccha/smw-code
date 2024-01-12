// Usage: deno run ./gh_get_notes.ts --allow-read <root> <type> <name>
//  -v      Verbose
//  <root>  Root directory
//  <type>  Resource type, one of: "block" | "patch" | "port" | "sprite" | "tool" | "uberasm"
//  <name>  Name of the resource

import parseArgs from "../_shared/args.ts";
import validateResource from "../_shared/resource.ts";

const args = parseArgs();
const resource = await validateResource(args.root, args.type, args.name);

const text = await Deno.readTextFile(resource.changelog.markdown.path);
const rows = text.split("\n");

const notes: string[] = [];
let read = false;

for (const row of rows) {
  if (row.startsWith("## ")) {
    if (read) break;
    read = true;
    continue;
  }

  if (read) notes.push(row);
}

console.log(notes.join("\n").trim());
