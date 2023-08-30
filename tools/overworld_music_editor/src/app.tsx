import {
  Accordion,
  AccordionButton,
  AccordionIcon,
  AccordionItem,
  AccordionPanel,
  Button,
  Checkbox,
  Flex,
  Heading,
  Image,
  Input,
  Textarea,
  useToast,
} from "@chakra-ui/react";
import { ChangeEvent } from "preact/compat";
import { useCallback, useEffect, useRef, useState } from "preact/hooks";
import { Grid, Row, gridFromString, gridToString } from "./grid";
import colors from "./colors";

const SIZE = 16;
const INDEXES = Array.from({ length: SIZE }, (_, i) => i);

const id = (x: number, y: number): string => `${x}-${y}`;

export default function App() {
  const toast = useToast();

  const refs = useRef<Record<string, HTMLInputElement>>({});

  const [image, setImage] = useState("");
  const [input, setInput] = useState("");
  const [output, setOutput] = useState("");

  const [showColors, setShowColors] = useState(false);
  const [showOpacity, setShowOpacity] = useState(true);

  const loadImage = useCallback(() => {
    const maybeImage = localStorage.getItem("image");
    if (!maybeImage) return;
    setImage(maybeImage);
  }, []);

  const parseGrid = useCallback(
    (maybeGrid: string): boolean => {
      const gridOrError = gridFromString(maybeGrid);
      if (typeof gridOrError === "string") {
        toast({
          title: "Failed to load grid",
          description: gridOrError,
          status: "error",
          isClosable: true,
        });
        return false;
      }

      for (let x = 0; x < SIZE; ++x) {
        for (let y = 0; y < SIZE; ++y) {
          const ref = refs.current[id(x, y)];
          if (ref) ref.value = gridOrError[y]![x]!;
        }
      }
      return true;
    },
    [toast]
  );

  const serializeGrid = useCallback((): string => {
    const grid: Grid = [];
    for (let y = 0; y < SIZE; ++y) {
      const row: Row = [];
      for (let x = 0; x < SIZE; ++x) {
        const ref = refs.current[id(x, y)];
        row.push(ref?.value ?? "00");
      }
      grid.push(row);
    }
    return gridToString(grid);
  }, []);

  const saveGrid = useCallback(() => {
    const gridString = serializeGrid();
    localStorage.setItem("grid", gridString);
    setOutput(gridString);
  }, [serializeGrid]);

  const resetGrid = useCallback(() => {
    for (let x = 0; x < SIZE; ++x) {
      for (let y = 0; y < SIZE; ++y) {
        const ref = refs.current[id(x, y)];
        if (ref) ref.value = "00";
      }
    }
    saveGrid();
  }, [saveGrid]);

  const loadGrid = useCallback(() => {
    const maybeGridString = localStorage.getItem("grid");
    if (maybeGridString) {
      const parseSucceeded = parseGrid(maybeGridString);
      if (parseSucceeded) setOutput(maybeGridString);
      else resetGrid();
    } else {
      resetGrid();
    }
  }, [parseGrid, resetGrid]);

  const importGrid = useCallback(() => {
    if (input) {
      const parseSucceeded = parseGrid(input);
      if (parseSucceeded) {
        saveGrid();
        setInput("");
      }
    }
  }, [input, parseGrid, saveGrid]);

  const exportGrid = useCallback(() => {
    navigator.clipboard.writeText(serializeGrid());
  }, [serializeGrid]);

  const updateImage = useCallback((e: ChangeEvent<HTMLInputElement>) => {
    if (e.currentTarget.files && e.currentTarget.files[0]) {
      const newImage = URL.createObjectURL(e.currentTarget.files[0]);
      setImage(newImage);
      localStorage.setItem("image", newImage);
    }
  }, []);

  const updateInput = useCallback((e: ChangeEvent<HTMLInputElement>) => {
    setInput(e.currentTarget.value);
  }, []);

  const removeImage = useCallback(() => {
    setImage("");
    localStorage.removeItem("image");
  }, []);

  const updateCell = useCallback(
    (x: number, y: number) => {
      const ref = refs.current[id(x, y)];
      if (!ref) return;

      ref.value = ref.value.replace(/[^0-9a-fA-F]/g, "").toUpperCase();
      if (ref.value.length === 0) ref.value = "00";
      if (ref.value.length === 1) ref.value = `0${ref.value}`;
      saveGrid();
    },
    [saveGrid]
  );

  useEffect(() => {
    loadGrid();
    loadImage();
  }, [loadGrid, loadImage]);
  return (
    <Flex alignItems="flex-start" color="white" flexWrap="wrap" gap={4} p={5}>
      <Flex borderWidth={1} flex={1} minW={500} maxW={800} position="relative">
        {image && (
          <Image
            left={0}
            h="100%"
            opacity={0.2}
            position="absolute"
            src={image}
            top={0}
          />
        )}

        <Flex direction="column" flex={1} zIndex={1}>
          {INDEXES.map((y) => (
            <Flex>
              {INDEXES.map((x) => {
                const ref = (r: HTMLInputElement) =>
                  (refs.current[id(x, y)] = r);
                const value = refs.current[id(x, y)]?.value ?? "00";
                const color = showOpacity
                  ? `${colors[parseInt(value, 16) % 64]}30`
                  : colors[parseInt(value, 16) % 64];
                return (
                  <Flex
                    aspectRatio={1}
                    cursor="pointer"
                    flex={1}
                    fontFamily="monospace"
                    fontSize="md"
                    _hover={{ color: "white" }}
                  >
                    <Input
                      ref={ref}
                      backgroundColor={showColors ? color ?? "" : ""}
                      borderRadius={0}
                      borderWidth={1}
                      color="gray.400"
                      maxLength={2}
                      onBlur={() => updateCell(x, y)}
                      placeholder="00"
                      textAlign="center"
                      variant="unstyled"
                      _focus={{
                        borderColor: "white",
                        color: "white",
                      }}
                    />
                  </Flex>
                );
              })}
            </Flex>
          ))}
        </Flex>
      </Flex>

      <Accordion allowMultiple flex={1} minW={300}>
        <AccordionItem>
          <AccordionButton>
            <Heading flex={1} size="md" textAlign="left">
              Output
            </Heading>
            <AccordionIcon />
          </AccordionButton>

          <AccordionPanel pb={4}>
            <Textarea
              fontFamily="monospace"
              fontSize="md"
              isDisabled
              placeholder="MusicTBL"
              value={output}
              wrap="off"
            />
            <Flex mt={2} justifyContent="flex-end">
              <Button onClick={exportGrid}>Copy</Button>
            </Flex>
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <AccordionButton>
            <Heading flex={1} size="md" textAlign="left">
              Input
            </Heading>
            <AccordionIcon />
          </AccordionButton>

          <AccordionPanel pb={4}>
            <Textarea
              fontFamily="monospace"
              fontSize="md"
              onChange={updateInput}
              placeholder="MusicTBL"
              value={input}
              wrap="off"
            />
            <Flex mt={2} justifyContent="flex-end">
              <Button isDisabled={!input.length} onClick={importGrid}>
                Import
              </Button>
            </Flex>
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <AccordionButton>
            <Heading flex={1} size="md" textAlign="left">
              Image
            </Heading>
            <AccordionIcon />
          </AccordionButton>

          <AccordionPanel pb={4}>
            <Input
              fontFamily="monospace"
              fontSize="md"
              onChange={updateImage}
              type="file"
            />
            <Flex mt={2} justifyContent="flex-end">
              <Button isDisabled={image.length === 0} onClick={removeImage}>
                Remove
              </Button>
            </Flex>
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <AccordionButton>
            <Heading flex={1} size="md" textAlign="left">
              Colors
            </Heading>
            <AccordionIcon />
          </AccordionButton>

          <AccordionPanel pb={4}>
            <Flex direction="column" gap={2}>
              <Checkbox
                checked={showColors}
                defaultChecked={showColors}
                isChecked={showColors}
                onBlur={() => {}}
                onChange={() =>
                  setShowColors((prevShowColors) => !prevShowColors)
                }
              >
                Show colors
              </Checkbox>

              <Checkbox
                checked={showOpacity}
                defaultChecked={showOpacity}
                isChecked={showOpacity}
                onBlur={() => {}}
                onChange={() =>
                  setShowOpacity((prevShowOpacity) => !prevShowOpacity)
                }
              >
                Transparency
              </Checkbox>
            </Flex>
          </AccordionPanel>
        </AccordionItem>
      </Accordion>
    </Flex>
  );
}
