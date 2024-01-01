import { Flex } from "@chakra-ui/react";
import Grid from "./components/grid";
import Menu from "./components/menu";
import MenuAbout from "./components/menu-about";
import MenuChangelog from "./components/menu-changelog";
import MenuExport from "./components/menu-export";
import MenuImport from "./components/menu-import";
import MenuNew from "./components/menu-new";
import MenuSettings from "./components/menu-settings";

const menu = [
  {
    title: "Settings",
    content: <MenuSettings />,
  },
  {
    title: "Export",
    content: <MenuExport />,
  },
  {
    title: "Import",
    content: <MenuImport />,
  },
  {
    title: "New",
    content: <MenuNew />,
  },
  {
    title: "About",
    content: <MenuAbout />,
  },
  {
    title: "Changelog",
    content: <MenuChangelog />,
  },
];

export default function App() {
  return (
    <Flex alignItems="flex-start" gap={4} p={4} wrap="wrap">
      <Grid />

      <Flex color="white" flex={1} minW={300}>
        <Menu settings={menu} />
      </Flex>
    </Flex>
  );
}
