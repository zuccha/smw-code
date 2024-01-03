Prism.languages.asar = {
  comment: /;.*/,
  directive: {
    pattern: /(?:\.b|\.w|\.l)/,
    alias: "property",
  },
  define: {
    pattern: /!\w+/,
    alias: "number",
  },
  string: /(["'`])(?:\\.|(?!\1)[^\\\r\n])*\1/,
  "op-code": {
    pattern:
      /\b(?:ADC|AND|ASL|BCC|BCS|BEQ|BIT|BMI|BNE|BPL|BRA|BRK|BRL|BVC|BVS|CLC|CLD|CLI|CLV|CMP|COP|CPX|CPY|DEC|DEX|DEY|EOR|INC|INX|INY|JMP|JSL|JSR|JML|LDA|LDX|LDY|LSR|MVN|MVP|NOP|ORA|PEI|PER|PHA|PHB|PHD|PHK|PHP|PHX|PHY|PLA|PLB|PLD|PLP|PLX|PLY|REP|ROL|ROR|RTI|RTL|RTS|SBC|SEC|SED|SEI|SEP|STA|STX|STY|STZ|TAX|TAY|TCD|TCS|TDC|TRB|TSB|TSC|TSX|TXA|TXS|TXY|TYA|TYX|WAI|WDM|XBA|XCE)\b/i,
    alias: "keyword",
  },
  "hex-number": {
    pattern: /#?\$[\da-f]{1,6}\b/i,
    alias: "number",
  },
  "binary-number": {
    pattern: /#?%[01]+\b/,
    alias: "number",
  },
  "decimal-number": {
    pattern: /#?\b\d+\b/,
    alias: "number",
  },
  register: {
    pattern: /\b[xya]\b/i,
    alias: "variable",
  },
  punctuation: /[(),:]/,
  builtin: {
    pattern:
      /\b(?:if|elseif|else|endif|while|macro|endmacro|org|base|skip|bank|namespace|optimize|pushpc|pullpc|pushbase|pullbase|lorom|sa1|function|incsrc|include|includefrom|freecode|freedata|freespace|db|dw|dl|dd|table|data|print)\b/,
    alias: "function",
  },
  "class-name": /%\w+/,
};
