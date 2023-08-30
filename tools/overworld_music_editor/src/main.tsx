import { ChakraProvider, DarkMode, extendTheme } from "@chakra-ui/react";
import { render } from "preact";
import App from "./app.tsx";

const theme = extendTheme({
  styles: { global: { body: { bg: "#202124" } } },
});

render(
  <ChakraProvider theme={theme}>
    <DarkMode>
      <App />
    </DarkMode>
  </ChakraProvider>,
  document.getElementById("app")!
);
