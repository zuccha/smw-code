import { Flex } from "@chakra-ui/react";
import { useCallback } from "preact/hooks";
import Grid from "./components/grid";
import Menu from "./components/menu";
import MenuAbout from "./components/menu-about";
import MenuChangelog from "./components/menu-changelog";
import MenuExport from "./components/menu-export";
import MenuImport from "./components/menu-import";
import MenuNew from "./components/menu-new";
import MenuSettings from "./components/menu-settings";
import useSetting from "./hooks/useSetting";
import { createGrid } from "./utils/grid";
import { ValueEncoding, ValueSize } from "./utils/value";

const EmptyGrid = createGrid(16, 16, 0);

export default function App() {
  const [grid, setGrid] = useSetting("grid", EmptyGrid);

  const [encoding, setEncoding] = useSetting(
    "value-encoding",
    ValueEncoding.Hexadecimal
  );
  const [size, setSize] = useSetting("value-size", ValueSize.Byte);
  const [colorOpacity, setColorOpacity] = useSetting("color-opacity", 0);

  const [image, setImage] = useSetting("image", "");
  const [isImageVisible, setIsImageVisible] = useSetting(
    "is-image-visible",
    true
  );

  const removeImage = useCallback(() => {
    setImage("");
  }, []);

  const importGrid = useCallback((grid: number[][], valueSize: ValueSize) => {
    setGrid(grid);
    setSize(valueSize);
  }, []);

  return (
    <Flex alignItems="flex-start" gap={4} p={4} wrap="wrap">
      <Grid
        colorOpacity={colorOpacity}
        encoding={encoding}
        grid={grid}
        image={isImageVisible ? image : ""}
        onChange={setGrid}
        size={size}
      />

      <Flex color="white" flex={1} minW={300}>
        <Menu
          settings={[
            {
              title: "Settings",
              content: (
                <MenuSettings
                  colorOpacity={colorOpacity}
                  encoding={encoding}
                  isImageVisible={isImageVisible}
                  onChangeColorOpacity={setColorOpacity}
                  onChangeEncoding={setEncoding}
                  onChangeImage={setImage}
                  onChangeIsImageVisible={setIsImageVisible}
                  onChangeSize={setSize}
                  onRemoveImage={removeImage}
                  size={size}
                />
              ),
            },
            {
              title: "Export",
              content: (
                <MenuExport encoding={encoding} grid={grid} size={size} />
              ),
            },
            {
              title: "Import",
              content: <MenuImport onImport={importGrid} />,
            },
            {
              title: "New",
              content: <MenuNew onCreateNew={importGrid} />,
            },
            {
              title: "About",
              content: <MenuAbout />,
            },
            {
              title: "Changelog",
              content: <MenuChangelog />,
            },
          ]}
        />
      </Flex>
    </Flex>
  );
}
