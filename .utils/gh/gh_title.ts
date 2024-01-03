import parseArgs from "../args.ts";
import validateResource from "../resource.ts";

const args = parseArgs();
const resource = await validateResource(".", args.type, args.name);

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
