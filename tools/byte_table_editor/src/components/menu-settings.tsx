import { ViewIcon, ViewOffIcon } from "@chakra-ui/icons";
import {
  Button,
  Flex,
  Grid,
  IconButton,
  Input,
  Radio,
  RadioGroup,
  Slider,
  SliderFilledTrack,
  SliderThumb,
  SliderTrack,
} from "@chakra-ui/react";
import { ChangeEvent } from "preact/compat";
import { useCallback, useRef, useState } from "preact/hooks";
import {
  useColorOpacity,
  useImage,
  useImageIsVisible,
  useTableEncoding,
  useTableUnit,
} from "../hooks/useStore";
import { ValueEncoding, ValueUnit } from "../store/value";

export default function MenuSettings() {
  const [encoding, setEncoding] = useTableEncoding();
  const [unit, setUnit] = useTableUnit();

  const [colorOpacity, setColorOpacity] = useColorOpacity();

  const [_image, setImage] = useImage();
  const [imageIsVisible, setImageIsVisible] = useImageIsVisible();
  const imageInputRef = useRef<HTMLInputElement>(null);
  const [imageFilename, setImageFilename] = useState("");

  const handleChangeColorOpacity = useCallback(
    (value: number) => setColorOpacity(value),
    [setColorOpacity]
  );

  const handleChangeEncoding = useCallback(
    (value: string) => setEncoding(parseInt(value)),
    [setEncoding]
  );

  const handleChangeUnit = useCallback(
    (value: string) => setUnit(parseInt(value)),
    [setUnit]
  );

  const openImageFileBrowser = useCallback(() => {
    imageInputRef.current?.click();
  }, []);

  const handleChangeImage = useCallback(
    (e: ChangeEvent<HTMLInputElement>) => {
      if (e.currentTarget.files && e.currentTarget.files[0]) {
        setImageFilename(e.currentTarget.files[0]?.name ?? "");
        setImage(URL.createObjectURL(e.currentTarget.files[0]));
      }
    },
    [setImage]
  );

  const handleChangeIsImageVisible = useCallback(() => {
    setImageIsVisible(!imageIsVisible);
  }, [imageIsVisible, setImageIsVisible]);

  const handleRemoveImage = useCallback(() => {
    if (imageInputRef.current) imageInputRef.current.value = "";
    setImage("");
    setImageFilename("");
  }, [setImage]);

  return (
    <Flex direction="column" flex={1} gap={2}>
      <Grid columnGap={8} rowGap={2} templateColumns="auto 1fr">
        <Flex alignItems="center">Encoding:</Flex>
        <RadioGroup onChange={handleChangeEncoding} value={`${encoding}`}>
          <Flex gap={4}>
            <Radio value={`${ValueEncoding.Binary}`}>Binary</Radio>
            <Radio value={`${ValueEncoding.Decimal}`}>Decimal</Radio>
            <Radio value={`${ValueEncoding.Hexadecimal}`}>Hexadecimal</Radio>
          </Flex>
        </RadioGroup>

        <Flex alignItems="center">Unit:</Flex>
        <RadioGroup onChange={handleChangeUnit} value={`${unit}`}>
          <Flex gap={4}>
            <Radio value={`${ValueUnit.Byte}`}>Byte</Radio>
            <Radio value={`${ValueUnit.Word}`}>Word</Radio>
          </Flex>
        </RadioGroup>

        <Flex alignItems="center">Color:</Flex>
        <Slider
          max={100}
          min={0}
          onChange={handleChangeColorOpacity}
          step={1}
          value={colorOpacity}
        >
          <SliderTrack>
            <SliderFilledTrack />
          </SliderTrack>
          <SliderThumb />
        </Slider>
      </Grid>

      <Flex flex={1} gap={2}>
        <IconButton
          aria-label="toggle visibility"
          icon={imageIsVisible ? <ViewIcon /> : <ViewOffIcon />}
          onClick={handleChangeIsImageVisible}
        />

        <Flex
          alignItems="center"
          borderRadius={4}
          borderStyle="dashed"
          borderWidth={1}
          cursor="pointer"
          flex={1}
          onClick={openImageFileBrowser}
          px={4}
        >
          {imageFilename || "Choose a background image"}

          <Input
            display="none"
            onChange={handleChangeImage}
            ref={imageInputRef}
            type="file"
          />
        </Flex>

        <Button isDisabled={!imageFilename} onClick={handleRemoveImage}>
          Remove
        </Button>
      </Flex>
    </Flex>
  );
}
