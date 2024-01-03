import parseArgs from "../args.ts";
import validateResource from "../resource.ts";

const args = parseArgs();
const resource = await validateResource(".", args.type, args.name);

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
