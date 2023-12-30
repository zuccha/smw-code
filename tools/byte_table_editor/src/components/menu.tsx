import {
  Accordion,
  AccordionButton,
  AccordionIcon,
  AccordionItem,
  AccordionPanel,
  Heading,
} from "@chakra-ui/react";
import useSetting from "../hooks/useSetting";
import { useCallback } from "preact/hooks";

export type MenuProps = {
  settings: {
    title: string;
    content: any;
  }[];
};

export default function Menu({ settings }: MenuProps) {
  const [index, setIndex] = useSetting("menu-index", [0, 1]);

  const handleChangeIndex = useCallback(
    (nextIndex: number[]) => {
      setIndex(nextIndex);
    },
    [setIndex]
  );

  return (
    <Accordion
      allowMultiple
      flex={1}
      index={index}
      onChange={handleChangeIndex}
    >
      {settings.map((setting) => (
        <AccordionItem>
          <AccordionButton>
            <Heading flex={1} size="md" textAlign="left">
              {setting.title}
            </Heading>
            <AccordionIcon />
          </AccordionButton>

          <AccordionPanel pb={4}>{setting.content}</AccordionPanel>
        </AccordionItem>
      ))}
    </Accordion>
  );
}
