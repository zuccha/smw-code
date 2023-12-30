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
import { ValueEncoding, ValueSize } from "../utils/value";
import { useCallback, useRef, useState } from "preact/hooks";
import { ChangeEvent } from "preact/compat";
import { ViewIcon, ViewOffIcon } from "@chakra-ui/icons";

export type MenuSettingsProps = {
  colorOpacity: number;
  encoding: ValueEncoding;
  isImageVisible: boolean;
  onChangeColorOpacity: (colorOpacity: number) => void;
  onChangeEncoding: (encoding: ValueEncoding) => void;
  onChangeImage: (image: string) => void;
  onChangeIsImageVisible: (isImageVisible: boolean) => void;
  onChangeSize: (encoding: ValueSize) => void;
  onRemoveImage: () => void;
  size: ValueSize;
};

export default function MenuSettings({
  colorOpacity,
  encoding,
  isImageVisible,
  onChangeColorOpacity,
  onChangeEncoding,
  onChangeImage,
  onChangeIsImageVisible,
  onChangeSize,
  onRemoveImage,
  size,
}: MenuSettingsProps) {
  const imageInputRef = useRef<HTMLInputElement>(null);
  const [imageFilename, setImageFilename] = useState("");

  const handleChangeColorOpacity = useCallback(
    (value: number) => onChangeColorOpacity(value),
    [onChangeColorOpacity]
  );

  const handleChangeEncoding = useCallback(
    (value: string) => onChangeEncoding(parseInt(value)),
    [onChangeEncoding]
  );

  const handleChangeSize = useCallback(
    (value: string) => onChangeSize(parseInt(value)),
    [onChangeSize]
  );

  const openImageFileBrowser = useCallback(() => {
    imageInputRef.current?.click();
  }, []);

  const handleChangeImage = useCallback(
    (e: ChangeEvent<HTMLInputElement>) => {
      if (e.currentTarget.files && e.currentTarget.files[0]) {
        setImageFilename(e.currentTarget.files[0]?.name ?? "");
        onChangeImage(URL.createObjectURL(e.currentTarget.files[0]));
      }
    },
    [onChangeImage]
  );

  const handleChangeIsImageVisible = useCallback(() => {
    onChangeIsImageVisible(!isImageVisible);
  }, [isImageVisible, onChangeIsImageVisible]);

  const handleRemoveImage = useCallback(() => {
    if (imageInputRef.current) imageInputRef.current.value = "";
    onRemoveImage();
    setImageFilename("");
  }, [onRemoveImage]);

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

        <Flex alignItems="center">Size:</Flex>
        <RadioGroup onChange={handleChangeSize} value={`${size}`}>
          <Flex gap={4}>
            <Radio value={`${ValueSize.Byte}`}>Byte</Radio>
            <Radio value={`${ValueSize.Word}`}>Word</Radio>
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
          icon={isImageVisible ? <ViewIcon /> : <ViewOffIcon />}
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
