import { parse } from "https://deno.land/std@0.193.0/flags/mod.ts";

type Args = { isVerbose: boolean; name: string; type: string };

export default function parseArgs(): Args {
  const args = parse(Deno.args, { boolean: ["v"] });
  return { isVerbose: args.v, name: `${args._[1]}`, type: `${args._[0]}` };
}
