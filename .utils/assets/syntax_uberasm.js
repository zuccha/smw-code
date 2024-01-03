Prism.languages.uberasm = {
  comment: /;.*/,
  filename: {
    pattern: /\b\w+\.\w+\b/,
    alias: "keyword",
  },
  "decimal-number": {
    pattern: /#?\b\d+\b/,
    alias: "number",
  },
  //   "op-code": {
  //     pattern:
  //       /\b(?:level|overworld|gamemode|global|statusbar|macrolib|sprite)\b:/i,
  //     alias: "keyword",
  //   },
};
