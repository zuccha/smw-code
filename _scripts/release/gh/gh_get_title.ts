// Usage: deno run ./gh_get_title.ts --allow-read <root> <type> <name>
//  -v      Verbose
//  <root>  Root directory
//  <type>  Resource type, one of: "block" | "patch" | "port" | "sprite" | "tool" | "uberasm"
//  <name>  Name of the resource

import parseArgs from "../_shared/args.ts";
import validateResource from "../_shared/resource.ts";

const args = parseArgs();
const resource = await validateResource(args.root, args.type, args.name);

const text = await Deno.readTextFile(resource.readme.markdown.path);
const rows = text.split("\n");

let title = "";

for (const row of rows) {
  if (row.startsWith("# ")) {
    title = row.replace(/^# /, "");
    break;
  }
}

console.log(title);
